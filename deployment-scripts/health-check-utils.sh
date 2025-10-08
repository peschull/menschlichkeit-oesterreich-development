#!/bin/bash
###############################################################################
# Service Health Check Utilities
# Wiederverwendbare Funktionen für Service-Health-Checks
###############################################################################

set -euo pipefail

# Source config falls vorhanden
if [[ -f "$(dirname "$0")/deployment-config.sh" ]]; then
    source "$(dirname "$0")/deployment-config.sh"
fi

###############################################################################
# HTTP Health Check
###############################################################################
check_http_health() {
    local url="$1"
    local timeout="${2:-5}"
    local expected_status="${3:-200}"
    
    local response
    local http_code
    
    response=$(curl -f -s -m "$timeout" -w "\n%{http_code}" "$url" 2>/dev/null || true)
    http_code=$(echo "$response" | tail -n1)
    
    if [[ "$http_code" == "$expected_status" ]] || [[ "$http_code" == "200" ]] || [[ "$http_code" == "301" ]] || [[ "$http_code" == "302" ]]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Database Health Check
###############################################################################
check_database_health() {
    local db_url="${1:-$DATABASE_URL}"
    
    if [[ -z "$db_url" ]]; then
        echo "ERROR: No database URL provided"
        return 1
    fi
    
    # Verbindungstest
    if psql "$db_url" -c "SELECT 1;" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Docker Container Health Check
###############################################################################
check_docker_health() {
    local container_name="$1"
    
    if ! command -v docker &>/dev/null; then
        echo "ERROR: Docker not installed"
        return 1
    fi
    
    local status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "not_found")
    
    if [[ "$status" == "healthy" ]] || [[ "$status" == "not_found" ]]; then
        # not_found bedeutet Container läuft ohne Health Check
        if docker ps --filter "name=$container_name" --filter "status=running" | grep -q "$container_name"; then
            return 0
        fi
    fi
    
    return 1
}

###############################################################################
# Service Response Time
###############################################################################
measure_response_time() {
    local url="$1"
    local timeout="${2:-5}"
    
    local response_time
    response_time=$(curl -o /dev/null -s -w '%{time_total}' -m "$timeout" "$url" 2>/dev/null || echo "999")
    
    echo "$response_time"
}

###############################################################################
# Port Check
###############################################################################
check_port() {
    local host="${1:-localhost}"
    local port="$2"
    local timeout="${3:-2}"
    
    if timeout "$timeout" bash -c "cat < /dev/null > /dev/tcp/$host/$port" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# API Endpoint Check mit JSON Response
###############################################################################
check_api_endpoint() {
    local url="$1"
    local expected_field="${2:-status}"
    local expected_value="${3:-ok}"
    local timeout="${4:-5}"
    
    local response
    response=$(curl -f -s -m "$timeout" "$url" 2>/dev/null || echo "{}")
    
    local actual_value
    actual_value=$(echo "$response" | jq -r ".$expected_field" 2>/dev/null || echo "")
    
    if [[ "$actual_value" == "$expected_value" ]]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# All Services Health Check
###############################################################################
check_all_services() {
    local environment="${1:-production}"
    local verbose="${2:-false}"
    
    local all_healthy=true
    
    # API Service
    if [[ "$environment" == "production" ]]; then
        if check_http_health "$API_URL/health"; then
            [[ "$verbose" == "true" ]] && echo "✓ API Service: Healthy"
        else
            [[ "$verbose" == "true" ]] && echo "✗ API Service: Unhealthy"
            all_healthy=false
        fi
    fi
    
    # CRM Service
    if [[ "$environment" == "production" ]]; then
        if check_http_health "$CRM_URL"; then
            [[ "$verbose" == "true" ]] && echo "✓ CRM Service: Healthy"
        else
            [[ "$verbose" == "true" ]] && echo "✗ CRM Service: Unhealthy"
            all_healthy=false
        fi
    fi
    
    # Frontend
    if [[ "$environment" == "production" ]]; then
        if check_http_health "$FRONTEND_URL"; then
            [[ "$verbose" == "true" ]] && echo "✓ Frontend: Healthy"
        else
            [[ "$verbose" == "true" ]] && echo "✗ Frontend: Unhealthy"
            all_healthy=false
        fi
    fi
    
    # Database
    if [[ -n "${DATABASE_URL:-}" ]]; then
        if check_database_health; then
            [[ "$verbose" == "true" ]] && echo "✓ Database: Healthy"
        else
            [[ "$verbose" == "true" ]] && echo "✗ Database: Unhealthy"
            all_healthy=false
        fi
    fi
    
    # n8n (falls Docker)
    if docker ps --filter "name=n8n" --filter "status=running" | grep -q n8n; then
        [[ "$verbose" == "true" ]] && echo "✓ n8n: Running"
    fi
    
    if [[ "$all_healthy" == "true" ]]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Wait for Service Ready
###############################################################################
wait_for_service() {
    local url="$1"
    local max_attempts="${2:-30}"
    local wait_seconds="${3:-5}"
    
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if check_http_health "$url"; then
            echo "Service ready after $((attempt * wait_seconds)) seconds"
            return 0
        fi
        
        echo "Waiting for service... (attempt $attempt/$max_attempts)"
        sleep "$wait_seconds"
        ((attempt++))
    done
    
    echo "ERROR: Service not ready after $((max_attempts * wait_seconds)) seconds"
    return 1
}

###############################################################################
# System Resources Check
###############################################################################
check_system_resources() {
    local cpu_usage
    local memory_usage
    local disk_usage
    local warnings=0
    
    # CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    if (( $(echo "$cpu_usage > ${CPU_THRESHOLD:-80}" | bc -l) )); then
        echo "WARNING: High CPU usage: ${cpu_usage}%"
        ((warnings++))
    fi
    
    # Memory
    memory_usage=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
    if (( $(echo "$memory_usage > ${MEMORY_THRESHOLD:-85}" | bc -l) )); then
        echo "WARNING: High memory usage: ${memory_usage}%"
        ((warnings++))
    fi
    
    # Disk
    disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [[ $disk_usage -gt ${DISK_THRESHOLD:-90} ]]; then
        echo "WARNING: High disk usage: ${disk_usage}%"
        ((warnings++))
    fi
    
    if [[ $warnings -eq 0 ]]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Export Functions
###############################################################################
export -f check_http_health
export -f check_database_health
export -f check_docker_health
export -f measure_response_time
export -f check_port
export -f check_api_endpoint
export -f check_all_services
export -f wait_for_service
export -f check_system_resources
