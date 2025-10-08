#!/bin/bash
###############################################################################
# Deployment Configuration
# Zentrale Konfiguration für alle Deployment-Scripts
###############################################################################

# Umgebungen
export STAGING_DOMAIN="staging.menschlichkeit-oesterreich.at"
export PRODUCTION_DOMAIN="menschlichkeit-oesterreich.at"

# Service URLs (Production)
export API_URL="https://api.menschlichkeit-oesterreich.at"
export CRM_URL="https://crm.menschlichkeit-oesterreich.at"
export FRONTEND_URL="https://menschlichkeit-oesterreich.at"
export ADMIN_URL="https://admin.menschlichkeit-oesterreich.at"
export GAMING_URL="https://games.menschlichkeit-oesterreich.at"

# Service URLs (Staging)
export STAGING_API_URL="https://api.staging.menschlichkeit-oesterreich.at"
export STAGING_CRM_URL="https://crm.staging.menschlichkeit-oesterreich.at"
export STAGING_FRONTEND_URL="https://staging.menschlichkeit-oesterreich.at"

# Ports (Local Development)
export API_PORT=8001
export CRM_PORT=8000
export FRONTEND_PORT=3000
export GAMING_PORT=3001
export N8N_PORT=5678

# Blue-Green Deployment
export BLUE_PORT=8001
export GREEN_PORT=8002
export NGINX_CONFIG="/etc/nginx/sites-available/menschlichkeit-oesterreich"

# Database
export DB_BACKUP_DIR="/var/backups/postgresql"
export DB_BACKUP_RETENTION_DAYS=30
export DB_CONNECTION_POOL_SIZE=20

# Monitoring
export MONITORING_INTERVAL=30
export ERROR_RATE_THRESHOLD=0.01
export RESPONSE_TIME_THRESHOLD=0.5
export CPU_THRESHOLD=80
export MEMORY_THRESHOLD=85
export DISK_THRESHOLD=90

# Quality Gates
export MIN_MAINTAINABILITY=85
export MAX_DUPLICATION=2
export MIN_COVERAGE=80
export MIN_LIGHTHOUSE_SCORE=90

# Security
export MAX_CVE_SCORE=7.0
export SECRET_SCAN_ENABLED=true
export TRIVY_SCAN_ENABLED=true

# Deployment
export MAX_DEPLOYMENT_TIME=1800  # 30 Minuten
export SMOKE_TEST_TIMEOUT=300    # 5 Minuten
export ROLLBACK_SLA=300          # 5 Minuten
export CANARY_10_PERCENT_DURATION=900   # 15 Minuten
export CANARY_50_PERCENT_DURATION=600   # 10 Minuten

# Alerting
export N8N_ALERT_WEBHOOK="${N8N_ALERT_WEBHOOK:-http://localhost:5678/webhook/deployment-alert}"
export SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"
export EMAIL_RECIPIENTS="${EMAIL_RECIPIENTS:-devops@menschlichkeit-oesterreich.at}"

# Backup
export BACKUP_RETENTION_HOURS=24
export AUTO_BACKUP_BEFORE_DEPLOY=true

# Plesk (falls verwendet)
export PLESK_HOST="${PLESK_HOST:-menschlichkeit-oesterreich.at}"
export PLESK_API_KEY="${PLESK_API_KEY:-}"
export PLESK_DOMAIN_ID="${PLESK_DOMAIN_ID:-}"

# Git
export REQUIRED_BRANCH_PRODUCTION="main"
export REQUIRED_BRANCH_STAGING="develop"
export ALLOW_FORCE_PUSH=false

# Logging
export LOG_LEVEL="${LOG_LEVEL:-INFO}"
export LOG_DIR="quality-reports/deployment-logs"
mkdir -p "$LOG_DIR"

# Colors für Terminal Output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export BOLD='\033[1m'
export NC='\033[0m' # No Color

# Emoji (falls Terminal unterstützt)
export CHECK="✓"
export CROSS="✗"
export WARN="!"
export ROCKET="🚀"
export GEAR="⚙️"
export CHART="📊"
export SHIELD="🛡️"
export ROLLBACK_EMOJI="🔙"

# Helper Functions
log() { 
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_DIR/deployment-$(date +%Y%m%d).log"
}

success() { 
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    echo "[SUCCESS] $1" >> "$LOG_DIR/deployment-$(date +%Y%m%d).log"
}

warn() { 
    echo -e "${YELLOW}[WARNING]${NC} $1"
    echo "[WARNING] $1" >> "$LOG_DIR/deployment-$(date +%Y%m%d).log"
}

error() { 
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[ERROR] $1" >> "$LOG_DIR/deployment-$(date +%Y%m%d).log"
}

alert() { 
    echo -e "${RED}[ALERT]${NC} $1"
    echo "[ALERT] $1" >> "$LOG_DIR/deployment-$(date +%Y%m%d).log"
}

# Environment Detection
detect_environment() {
    if [[ "${CI:-false}" == "true" ]]; then
        echo "ci"
    elif [[ "$(git branch --show-current)" == "main" ]]; then
        echo "production"
    elif [[ "$(git branch --show-current)" == "develop" ]]; then
        echo "staging"
    else
        echo "development"
    fi
}

export ENVIRONMENT=$(detect_environment)

# Validate Configuration
validate_config() {
    local errors=0
    
    if [[ "$ENVIRONMENT" == "production" ]] && [[ -z "$PLESK_API_KEY" ]]; then
        warn "PLESK_API_KEY not set for production deployment"
        ((errors++))
    fi
    
    if [[ -z "$DATABASE_URL" ]]; then
        warn "DATABASE_URL not set"
        ((errors++))
    fi
    
    if [[ -z "$N8N_ALERT_WEBHOOK" ]] && [[ "$ENVIRONMENT" == "production" ]]; then
        warn "N8N_ALERT_WEBHOOK not set for production"
    fi
    
    if [[ $errors -gt 0 ]]; then
        warn "$errors configuration warnings found"
        return 1
    fi
    
    return 0
}

# Export all functions
export -f log
export -f success
export -f warn
export -f error
export -f alert
export -f detect_environment
export -f validate_config

log "Deployment Configuration loaded for environment: $ENVIRONMENT"
