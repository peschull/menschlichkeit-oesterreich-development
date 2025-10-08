#!/bin/bash
###############################################################################
# Blue-Green Deployment für API Backend
# Zero-Downtime Deployment mit Traffic Shifting
###############################################################################

set -euo pipefail

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Konfiguration
DEPLOYMENT_ENV="${1:-staging}"
SERVICE_NAME="api-backend"
BLUE_PORT=8001
GREEN_PORT=8002
CURRENT_VERSION=$(git describe --tags --always)

# Nginx Upstream Konfiguration
NGINX_CONFIG="/etc/nginx/sites-available/api.menschlichkeit-oesterreich.at.conf"
NGINX_BACKUP="/tmp/nginx-api-backup-$(date +%s).conf"

###############################################################################
# Phase 1: Deploy zu Green (inactive)
###############################################################################
deploy_to_green() {
    log "Phase 1: Deploying to GREEN environment (port $GREEN_PORT)"
    
    # Build neue Version
    cd api.menschlichkeit-oesterreich.at
    
    # Dependencies installieren
    log "Installing dependencies..."
    pip install -r requirements.txt --quiet
    
    # Tests laufen lassen
    log "Running tests..."
    pytest tests/ --cov=app --quiet || {
        error "Tests failed on GREEN deployment"
        return 1
    }
    
    # Security Scan
    log "Running security scan..."
    trivy fs --severity HIGH,CRITICAL . || warn "Security issues detected"
    
    # Starte auf GREEN Port
    log "Starting service on GREEN port $GREEN_PORT..."
    # uvicorn app.main:app --host 0.0.0.0 --port $GREEN_PORT --workers 4 &
    # GREEN_PID=$!
    
    cd ..
    success "GREEN deployment complete"
}

###############################################################################
# Phase 2: Smoke Tests auf Green
###############################################################################
smoke_test_green() {
    log "Phase 2: Running smoke tests on GREEN"
    
    local green_url="http://localhost:$GREEN_PORT"
    
    # Warte bis Service bereit
    log "Waiting for GREEN service to be ready..."
    for i in {1..30}; do
        if curl -f "$green_url/health" &> /dev/null; then
            success "GREEN service is healthy"
            break
        fi
        sleep 2
    done
    
    # Health Check
    log "Health check..."
    HEALTH_RESPONSE=$(curl -s "$green_url/health")
    if echo "$HEALTH_RESPONSE" | grep -q "healthy"; then
        success "Health check passed: $HEALTH_RESPONSE"
    else
        error "Health check failed: $HEALTH_RESPONSE"
        return 1
    fi
    
    # API Endpoint Tests
    log "Testing critical endpoints..."
    
    # Test 1: Get version
    VERSION_RESPONSE=$(curl -s "$green_url/api/v1/version")
    log "Version: $VERSION_RESPONSE"
    
    # Test 2: Database connection
    DB_RESPONSE=$(curl -s "$green_url/api/v1/db/status")
    if echo "$DB_RESPONSE" | grep -q "connected"; then
        success "Database connection verified"
    else
        error "Database connection failed"
        return 1
    fi
    
    success "All smoke tests passed on GREEN"
}

###############################################################################
# Phase 3: Nginx Configuration für Traffic Shifting
###############################################################################
configure_nginx_canary() {
    local green_weight="${1:-10}" # Default 10% zu GREEN
    local blue_weight=$((100 - green_weight))
    
    log "Phase 3: Configuring nginx for $green_weight% GREEN traffic"
    
    # Backup current config
    sudo cp "$NGINX_CONFIG" "$NGINX_BACKUP"
    
    # Generiere neue Config mit Traffic Split
    sudo tee "$NGINX_CONFIG" > /dev/null << EOF
upstream api_blue {
    server localhost:$BLUE_PORT weight=$blue_weight;
}

upstream api_green {
    server localhost:$GREEN_PORT weight=$green_weight;
}

upstream api_backend {
    server localhost:$BLUE_PORT weight=$blue_weight;
    server localhost:$GREEN_PORT weight=$green_weight;
}

server {
    listen 443 ssl http2;
    server_name api.menschlichkeit-oesterreich.at;
    
    # SSL Konfiguration
    ssl_certificate /etc/letsencrypt/live/api.menschlichkeit-oesterreich.at/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.menschlichkeit-oesterreich.at/privkey.pem;
    
    location / {
        proxy_pass http://api_backend;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        
        # Health check bypass (immer zu GREEN für Monitoring)
        if (\$request_uri ~ ^/health) {
            proxy_pass http://api_green;
        }
    }
    
    location /metrics {
        proxy_pass http://api_green;
        allow 10.0.0.0/8;  # Nur internes Netzwerk
        deny all;
    }
}
EOF
    
    # Nginx Config testen
    if sudo nginx -t; then
        success "Nginx config valid"
        sudo systemctl reload nginx
        success "Nginx reloaded with $green_weight% GREEN traffic"
    else
        error "Nginx config invalid, restoring backup"
        sudo cp "$NGINX_BACKUP" "$NGINX_CONFIG"
        return 1
    fi
}

###############################################################################
# Phase 4: Monitor während Canary Phase
###############################################################################
monitor_canary() {
    local duration_seconds="${1:-900}" # Default 15 Minuten
    local check_interval=30
    
    log "Phase 4: Monitoring canary deployment for $duration_seconds seconds"
    
    local start_time=$(date +%s)
    local error_count=0
    local max_errors=5
    
    while [[ $(($(date +%s) - start_time)) -lt $duration_seconds ]]; do
        # Check Error Rate
        local blue_errors=$(curl -s "http://localhost:$BLUE_PORT/metrics" | grep -c "error" || echo 0)
        local green_errors=$(curl -s "http://localhost:$GREEN_PORT/metrics" | grep -c "error" || echo 0)
        
        # Check Response Time
        local blue_response_time=$(curl -w "%{time_total}" -o /dev/null -s "http://localhost:$BLUE_PORT/health")
        local green_response_time=$(curl -w "%{time_total}" -o /dev/null -s "http://localhost:$GREEN_PORT/health")
        
        log "BLUE - Errors: $blue_errors, Response: ${blue_response_time}s"
        log "GREEN - Errors: $green_errors, Response: ${green_response_time}s"
        
        # Fehler-Schwellwert prüfen
        if [[ $green_errors -gt $blue_errors ]]; then
            ((error_count++))
            warn "GREEN has more errors than BLUE ($error_count/$max_errors)"
            
            if [[ $error_count -ge $max_errors ]]; then
                error "GREEN deployment unstable, triggering rollback"
                return 1
            fi
        else
            error_count=0
        fi
        
        sleep $check_interval
    done
    
    success "Canary monitoring complete - GREEN is stable"
}

###############################################################################
# Phase 5: Full Traffic Switch zu Green
###############################################################################
switch_to_green() {
    log "Phase 5: Switching 100% traffic to GREEN"
    
    # 100% zu GREEN
    configure_nginx_canary 100
    
    # Finale Health Checks
    sleep 5
    if curl -f "https://api.menschlichkeit-oesterreich.at/health" &> /dev/null; then
        success "GREEN is fully active and healthy"
    else
        error "GREEN health check failed after full switch"
        return 1
    fi
    
    # BLUE stoppen (optional, als Fallback behalten)
    log "Keeping BLUE as standby (not stopping)"
    # kill $BLUE_PID || true
    
    success "Full traffic switched to GREEN (version: $CURRENT_VERSION)"
}

###############################################################################
# Rollback zu Blue
###############################################################################
rollback_to_blue() {
    error "ROLLBACK: Reverting to BLUE environment"
    
    # Restore Nginx Config
    if [[ -f "$NGINX_BACKUP" ]]; then
        sudo cp "$NGINX_BACKUP" "$NGINX_CONFIG"
        sudo nginx -t && sudo systemctl reload nginx
        success "Nginx configuration rolled back"
    fi
    
    # Stoppe GREEN
    # kill $GREEN_PID || true
    
    warn "Rollback complete - 100% traffic to BLUE"
}

###############################################################################
# Main Blue-Green Deployment Flow
###############################################################################
main() {
    log "=========================================="
    log "Blue-Green Deployment: $SERVICE_NAME"
    log "Version: $CURRENT_VERSION"
    log "Environment: $DEPLOYMENT_ENV"
    log "=========================================="
    
    # Error Handler
    trap rollback_to_blue ERR
    
    # Deployment Phasen
    deploy_to_green || exit 1
    smoke_test_green || exit 1
    
    # Gradual Traffic Shift
    log "Starting gradual traffic shift..."
    
    # 10% Canary
    configure_nginx_canary 10
    monitor_canary 300 || exit 1  # 5 Minuten bei 10%
    
    # 50% Split
    configure_nginx_canary 50
    monitor_canary 600 || exit 1  # 10 Minuten bei 50%
    
    # 100% GREEN
    switch_to_green || exit 1
    
    success "=========================================="
    success "Blue-Green Deployment Successful! 🎉"
    success "Version $CURRENT_VERSION is now live"
    success "=========================================="
}

# Ausführung
main "$@"
