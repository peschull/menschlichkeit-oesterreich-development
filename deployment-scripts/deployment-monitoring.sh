#!/bin/bash
###############################################################################
# Deployment Health Monitoring & Alerting
# Real-time Monitoring während und nach Deployment
###############################################################################

set -euo pipefail

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
alert() { echo -e "${RED}[ALERT]${NC} $1"; }

# Konfiguration
MONITORING_DURATION="${1:-3600}" # Default: 1 Stunde
CHECK_INTERVAL="${2:-30}"        # Default: 30 Sekunden
ALERT_WEBHOOK="${N8N_ALERT_WEBHOOK:-http://localhost:5678/webhook/deployment-alert}"

# Thresholds
ERROR_RATE_THRESHOLD=0.01      # 1% Error Rate
RESPONSE_TIME_THRESHOLD=0.5    # seconds (0.5s = 500ms)
CPU_THRESHOLD=80               # 80% CPU
MEMORY_THRESHOLD=85            # 85% Memory
DISK_THRESHOLD=90              # 90% Disk

# Services zu monitoren
declare -A SERVICES=(
    ["api"]="https://api.menschlichkeit-oesterreich.at/health"
    ["crm"]="https://crm.menschlichkeit-oesterreich.at/user/login"
    ["frontend"]="https://menschlichkeit-oesterreich.at"
)

# Metrics Storage
METRICS_DIR="quality-reports/deployment-metrics"
mkdir -p "$METRICS_DIR"
METRICS_FILE="$METRICS_DIR/monitoring-$(date +%Y%m%d_%H%M%S).ndjson"

###############################################################################
# Health Check Function
###############################################################################
check_service_health() {
    local service_name="$1"
    local service_url="$2"
    
    local start_time=$(date +%s.%N)
    local http_code=$(curl -o /dev/null -s -w "%{http_code}" \
        --connect-timeout 5 --max-time 10 "$service_url" || echo "000")
    local end_time=$(date +%s.%N)
    local response_time
    response_time=$(awk -v start="$start_time" -v end="$end_time" 'BEGIN { printf "%.4f", end - start }')
    
    local normalized_code="0"
    if [[ "$http_code" =~ ^[0-9]+$ ]]; then
        normalized_code=$((10#$http_code))
    fi

    local status="healthy"
    local alert_level="info"
    
    # HTTP Code Validierung
    if (( normalized_code != 200 && normalized_code != 302 )); then
        status="unhealthy"
        alert_level="critical"
        alert "[$service_name] HTTP $http_code - Service unhealthy!"
    fi
    
    # Response Time Check
    if (( $(awk -v resp="$response_time" -v thresh="$RESPONSE_TIME_THRESHOLD" 'BEGIN { if (resp > thresh) print 1; else print 0 }') )); then
        warn "[$service_name] Slow response: ${response_time}s (threshold: ${RESPONSE_TIME_THRESHOLD}s)"
        alert_level="warning"
    fi
    
    # Metrics speichern (NDJSON)
    printf '{"timestamp":"%s","service":"%s","http_code":%s,"response_time":%.4f,"status":"%s","alert_level":"%s"}\n' \
        "$(date -Iseconds)" \
        "$service_name" \
        "$normalized_code" \
        "$response_time" \
        "$status" \
        "$alert_level" >> "$METRICS_FILE"
    
    log "[$service_name] HTTP $http_code | ${response_time}s | $status"
    
    # Alert senden wenn kritisch
    if [[ "$alert_level" == "critical" ]]; then
        send_alert "$service_name" "Service unhealthy - HTTP $http_code" "$alert_level"
    fi
    
    return $([ "$status" == "healthy" ] && echo 0 || echo 1)
}

###############################################################################
# System Resource Monitoring
###############################################################################
check_system_resources() {
    log "Checking system resources..."
    
    # CPU Usage
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "0")
    if (( $(awk -v usage="$cpu_usage" -v thresh="$CPU_THRESHOLD" 'BEGIN { if (usage > thresh) print 1; else print 0 }') )); then
        warn "High CPU usage: ${cpu_usage}%"
        send_alert "System" "High CPU usage: ${cpu_usage}%" "warning"
    fi
    
    # Memory Usage
    local mem_usage=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
    if (( mem_usage > MEMORY_THRESHOLD )); then
        warn "High memory usage: ${mem_usage}%"
        send_alert "System" "High memory usage: ${mem_usage}%" "warning"
    fi
    
    # Disk Usage
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if (( disk_usage > DISK_THRESHOLD )); then
        alert "Critical disk usage: ${disk_usage}%"
        send_alert "System" "Critical disk usage: ${disk_usage}%" "critical"
    fi
    
    log "Resources: CPU=${cpu_usage}% MEM=${mem_usage}% DISK=${disk_usage}%"
}

###############################################################################
# Database Connection Pool Monitoring
###############################################################################
check_database_health() {
    log "Checking database health..."
    
    # PostgreSQL Connection Count
    if command -v psql &> /dev/null; then
        local db_connections=$(psql -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null || echo "0")
        db_connections=$(echo "$db_connections" | tr -d '[:space:]')
        local max_connections=$(psql -t -c "SHOW max_connections;" 2>/dev/null || echo "100")
        max_connections=$(echo "$max_connections" | tr -d '[:space:]')
        
        local connection_ratio
        connection_ratio=$(awk -v used="$db_connections" -v max="$max_connections" 'BEGIN { if (max == 0) { printf "0" } else { printf "%.2f", (used / max) * 100 } }')
        
        log "Database Connections: $db_connections/$max_connections (${connection_ratio}%)"
        
        if (( $(awk -v ratio="$connection_ratio" 'BEGIN { if (ratio > 80) print 1; else print 0 }') )); then
            warn "High database connection usage: ${connection_ratio}%"
            send_alert "Database" "High connection pool usage: ${connection_ratio}%" "warning"
        fi
    else
        warn "psql not available, skipping database checks"
    fi
}

###############################################################################
# Error Rate Calculation
###############################################################################
calculate_error_rate() {
    local service_name="$1"
    
    # Analysiere bisherige Messwerte (NDJSON)
    local totals
    totals=$(awk -v svc="$service_name" '
        $0 ~ "\"service\":\""svc"\"" {
            total++
            if ($0 ~ "\"status\":\"unhealthy\"") {
                errors++
            }
        }
        END {
            printf "%d %d", total+0, errors+0
        }' "$METRICS_FILE")

    local total_requests=0
    local error_requests=0
    if [[ -n "$totals" ]]; then
        read -r total_requests error_requests <<< "$totals"
    fi
    
    if (( total_requests == 0 )); then
        return
    fi

    local error_rate
    error_rate=$(awk -v err="$error_requests" -v total="$total_requests" 'BEGIN { if (total == 0) { printf "0" } else { printf "%.4f", err / total } }')

    local error_rate_percent
    error_rate_percent=$(awk -v rate="$error_rate" 'BEGIN { printf "%.2f", rate * 100 }')

    if (( $(awk -v rate="$error_rate" -v threshold="$ERROR_RATE_THRESHOLD" 'BEGIN { if (rate > threshold) print 1; else print 0 }') )); then
        alert "[$service_name] High error rate: ${error_rate_percent}%"
        send_alert "$service_name" "High error rate: ${error_rate_percent}%" "critical"
    fi

    log "[$service_name] Error Rate: ${error_rate_percent}% ($error_requests/$total_requests)"
}

###############################################################################
# Alert Notification (n8n Webhook)
###############################################################################
send_alert() {
    local service="$1"
    local message="$2"
    local severity="${3:-info}"
    
    local payload=$(cat << EOF
{
  "timestamp": "$(date -Iseconds)",
  "service": "$service",
  "message": "$message",
  "severity": "$severity",
  "environment": "${DEPLOYMENT_ENV:-production}",
  "version": "$(git describe --tags --always 2>/dev/null || echo 'unknown')"
}
EOF
)
    
    # n8n Webhook senden
    if curl -X POST "$ALERT_WEBHOOK" \
        -H "Content-Type: application/json" \
        -d "$payload" \
        --connect-timeout 3 \
        --max-time 5 &> /dev/null; then
        log "Alert sent to n8n: $service - $message"
    else
        warn "Failed to send alert to n8n (webhook may be unavailable)"
    fi
}

###############################################################################
# Lighthouse Performance Check
###############################################################################
check_performance_metrics() {
    log "Running Lighthouse performance check..."
    
    if command -v lighthouse &> /dev/null; then
        local ts
        ts=$(date +%s)
        local lighthouse_output="$METRICS_DIR/lighthouse-${ts}.json"

        lighthouse https://menschlichkeit-oesterreich.at \
            --only-categories=performance,accessibility \
            --output=json \
            --output-path="$lighthouse_output" \
            --chrome-flags="--headless" \
            --quiet || warn "Lighthouse check failed"
        
        # Parse Scores
        if command -v jq &> /dev/null && [[ -f "$lighthouse_output" ]]; then
            local perf_score
            perf_score=$(jq -r '.categories.performance.score * 100' "$lighthouse_output" 2>/dev/null || echo "0")
            if [[ -z "$perf_score" || "$perf_score" == "null" ]]; then
                perf_score="0"
            fi
            log "Lighthouse Performance Score: $perf_score"

            if [[ -n "$perf_score" ]] && (( $(awk -v score="$perf_score" 'BEGIN { if (score < 90) print 1; else print 0 }') )); then
                warn "Performance score below threshold: $perf_score"
            fi
        else
            warn "jq not available or Lighthouse output missing – skipping score evaluation"
        fi
    else
        warn "Lighthouse not installed, skipping performance checks"
    fi
}

###############################################################################
# Real-time Monitoring Loop
###############################################################################
monitoring_loop() {
    local start_time=$(date +%s)
    local iteration=0
    
    log "=========================================="
    log "Starting Deployment Monitoring"
    log "Duration: ${MONITORING_DURATION}s"
    log "Check Interval: ${CHECK_INTERVAL}s"
    log "=========================================="
    
    # Initiales Metrics-Log (NDJSON)
    : > "$METRICS_FILE"
    
    while [[ $(($(date +%s) - start_time)) -lt $MONITORING_DURATION ]]; do
        ((iteration++))
        log "--- Iteration $iteration ---"
        
        # Health Checks für alle Services
        local all_healthy=true
        for service in "${!SERVICES[@]}"; do
            if ! check_service_health "$service" "${SERVICES[$service]}"; then
                all_healthy=false
            fi
        done
        
        # System Resources
        check_system_resources
        
        # Database Health
        check_database_health
        
        # Error Rates
        for service in "${!SERVICES[@]}"; do
            calculate_error_rate "$service"
        done
        
        # Performance Check (alle 10 Minuten)
        if (( iteration % 20 == 0 )); then
            check_performance_metrics
        fi
        
        # Status Summary
        if $all_healthy; then
            success "All services healthy ✓"
        else
            warn "Some services reporting issues ✗"
        fi
        
        sleep "$CHECK_INTERVAL"
    done
    
    log "=========================================="
    success "Monitoring Complete"
    log "Metrics saved to: $METRICS_FILE"
    log "=========================================="
}

###############################################################################
# Generate Monitoring Report
###############################################################################
generate_report() {
    log "Generating monitoring report..."
    
    local report_file="$METRICS_DIR/monitoring-report-$(date +%Y%m%d).md"
    
    cat > "$report_file" << EOF
# Deployment Monitoring Report

**Date:** $(date)
**Duration:** ${MONITORING_DURATION}s
**Environment:** ${DEPLOYMENT_ENV:-production}

## Service Health Summary

EOF
    
    for service in "${!SERVICES[@]}"; do
        local counts
        counts=$(awk -v svc="$service" '
            $0 ~ "\"service\":\""svc"\"" {
                total++
                if ($0 ~ "\"status\":\"healthy\"") {
                    healthy++
                }
            }
            END {
                printf "%d %d", total+0, healthy+0
            }' "$METRICS_FILE")

        local total=0
        local healthy=0
        if [[ -n "$counts" ]]; then
            read -r total healthy <<< "$counts"
        fi

        local uptime_line="N/A (no samples)"
        if [[ "$total" -gt 0 ]]; then
            local uptime_percent
            uptime_percent=$(awk -v h="$healthy" -v t="$total" 'BEGIN { if (t == 0) { printf "0.00" } else { printf "%.2f", (h / t) * 100 } }')
            uptime_line="${uptime_percent}%"
        fi

        echo "### $service" >> "$report_file"
        echo "- **Uptime:** ${uptime_line}" >> "$report_file"
        echo "- **Total Checks:** $total" >> "$report_file"
        echo "- **Healthy:** $healthy" >> "$report_file"
        echo "" >> "$report_file"
    done
    
    local critical_alerts
    critical_alerts=$(awk '$0 ~ "\"alert_level\":\"critical\"" {count++} END {print count+0}' "$METRICS_FILE")
    local warning_alerts
    warning_alerts=$(awk '$0 ~ "\"alert_level\":\"warning\"" {count++} END {print count+0}' "$METRICS_FILE")

    cat >> "$report_file" << EOF

## Alerts Generated

${critical_alerts} Critical Alerts
${warning_alerts} Warning Alerts

## Recommendations

- Monitor services with uptime < 99%
- Investigate any critical alerts
- Review resource usage trends

---
*Generated by deployment-monitoring.sh*
EOF
    
    success "Report generated: $report_file"
}

###############################################################################
# Main Execution
###############################################################################
main() {
    monitoring_loop
    generate_report
    
    # Final Alert: Monitoring Complete
    send_alert "Monitoring" "Deployment monitoring completed successfully" "info"
}

# Ausführung
main "$@"
