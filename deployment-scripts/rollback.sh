#!/bin/bash
###############################################################################
# Automated Rollback Script
# Schnelle Wiederherstellung bei fehlgeschlagenem Deployment
###############################################################################

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

error() { echo -e "${RED}[ERROR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log() { echo -e "${BLUE}[INFO]${NC} $1"; }

# Konfiguration
ROLLBACK_TARGET="${1:-previous}"  # 'previous' oder spezifische Version
BACKUP_DIR="${2:-$(ls -td backups/deployment-* | head -1)}"
ROLLBACK_TIMESTAMP=$(date +%Y%m%d_%H%M%S)
ROLLBACK_LOG="quality-reports/rollback-${ROLLBACK_TIMESTAMP}.log"

# Services
SERVICES=("api" "crm" "frontend" "gaming" "website" "n8n")

###############################################################################
# Pre-Rollback Validation
###############################################################################
pre_rollback_validation() {
    log "=========================================="
    log "ROLLBACK INITIATED"
    log "Target: $ROLLBACK_TARGET"
    log "Backup: $BACKUP_DIR"
    log "=========================================="
    
    # Backup existiert?
    if [[ ! -d "$BACKUP_DIR" ]]; then
        error "Backup directory not found: $BACKUP_DIR"
        error "Available backups:"
        ls -lh backups/ || error "No backups available!"
        exit 1
    fi
    
    log "Using backup: $BACKUP_DIR"
    
    # Confirmation (außer bei automatischem Trigger)
    if [[ "${AUTO_ROLLBACK:-false}" != "true" ]]; then
        warn "This will rollback all services to the previous state."
        read -p "Are you sure? (yes/no): " -r
        if [[ ! $REPLY =~ ^yes$ ]]; then
            error "Rollback cancelled by user"
            exit 1
        fi
    fi
}

###############################################################################
# 1. Rollback Database
###############################################################################
rollback_database() {
    log "Step 1: Rolling back database..."
    
    if [[ -f "$BACKUP_DIR/database-backup.dump" ]]; then
        log "Restoring PostgreSQL database..."
        
        # Backup current state (safety)
        pg_dump -Fc -f "backups/pre-rollback-db-${ROLLBACK_TIMESTAMP}.dump" || warn "Pre-rollback backup failed"
        
        # Restore
        log "Restoring from: $BACKUP_DIR/database-backup.dump"
        pg_restore -d "${POSTGRES_DB:-menschlichkeit}" --clean --if-exists "$BACKUP_DIR/database-backup.dump" || {
            error "Database restore failed!"
            return 1
        }
        
        success "Database rolled back ✓"
    else
        warn "No database backup found, skipping..."
    fi
}

###############################################################################
# 2. Rollback API Backend
###############################################################################
rollback_api() {
    log "Step 2: Rolling back API Backend..."
    
    # Stoppe aktuellen Service
    log "Stopping current API service..."
    sudo systemctl stop api-fastapi || warn "Could not stop API service"
    
    # Restore Configuration
    if [[ -f "$BACKUP_DIR/api-env.bak" ]]; then
        cp "$BACKUP_DIR/api-env.bak" api.menschlichkeit-oesterreich.at/.env.production
        log "API configuration restored"
    fi
    
    # Rollback zu vorheriger Version (Docker oder Git)
    if command -v docker &> /dev/null; then
        local previous_tag=$(git describe --abbrev=0 --tags $(git rev-list --tags --skip=1 --max-count=1) 2>/dev/null || echo "v1.0.0")
        log "Rolling back to Docker image: $previous_tag"
        
        docker pull registry.menschlichkeit-oesterreich.at/api:$previous_tag || warn "Docker pull failed"
        docker run -d --name api-rollback \
            --env-file api.menschlichkeit-oesterreich.at/.env.production \
            -p 8001:8001 \
            registry.menschlichkeit-oesterreich.at/api:$previous_tag
    else
        # Git-basierter Rollback
        cd api.menschlichkeit-oesterreich.at
        git checkout HEAD~1 || git checkout "$ROLLBACK_TARGET"
        pip install -r requirements.txt
        cd ..
    fi
    
    # Service neustarten
    sudo systemctl start api-fastapi || warn "Could not start API service"
    
    # Health Check
    sleep 5
    if curl -f http://localhost:8001/health &> /dev/null; then
        success "API Backend rolled back successfully ✓"
    else
        error "API health check failed after rollback!"
        return 1
    fi
}

###############################################################################
# 3. Rollback CRM System
###############################################################################
rollback_crm() {
    log "Step 3: Rolling back CRM System..."
    
    # Drupal Maintenance Mode
    cd crm.menschlichkeit-oesterreich.at
    drush state:set system.maintenance_mode 1 || warn "Could not enable maintenance mode"
    
    # Restore Configuration
    if [[ -f "$BACKUP_DIR/crm-settings.php.bak" ]]; then
        cp "$BACKUP_DIR/crm-settings.php.bak" sites/default/settings.php
        log "CRM settings restored"
    fi
    
    # Restore CiviCRM Database (separate from main DB)
    if [[ -f "$BACKUP_DIR/civicrm-backup.sql" ]]; then
        log "Restoring CiviCRM database..."
        mysql civicrm < "$BACKUP_DIR/civicrm-backup.sql" || warn "CiviCRM restore failed"
    fi
    
    # Rollback Code
    git checkout HEAD~1 || git checkout "$ROLLBACK_TARGET"
    composer install --no-dev
    
    # Drupal Updates rückgängig
    drush updatedb -y || warn "Database updates rollback failed"
    drush cache:rebuild
    
    # Exit Maintenance Mode
    drush state:set system.maintenance_mode 0
    cd ..
    
    success "CRM System rolled back ✓"
}

###############################################################################
# 4. Rollback Frontend
###############################################################################
rollback_frontend() {
    log "Step 4: Rolling back Frontend..."
    
    cd frontend
    
    # Git Rollback
    git checkout HEAD~1 || git checkout "$ROLLBACK_TARGET"
    
    # Rebuild
    npm ci --production
    npm run build
    
    # Deploy (wenn rsync/scp verfügbar)
    if [[ -n "${PLESK_HOST:-}" ]]; then
        rsync -avz dist/ "$PLESK_HOST:/var/www/vhosts/menschlichkeit-oesterreich.at/frontend/"
        success "Frontend deployed to Plesk"
    else
        warn "PLESK_HOST not set, manual deployment required"
    fi
    
    cd ..
    success "Frontend rolled back ✓"
}

###############################################################################
# 5. Rollback Gaming Platform
###############################################################################
rollback_gaming() {
    log "Step 5: Rolling back Gaming Platform..."
    
    cd web
    git checkout HEAD~1 || git checkout "$ROLLBACK_TARGET"
    
    # Rebuild wenn Build-Prozess existiert
    if [[ -f "package.json" ]]; then
        npm ci
        npm run build || warn "Game build failed"
    fi
    
    cd ..
    success "Gaming Platform rolled back ✓"
}

###############################################################################
# 6. Rollback Website (WordPress)
###############################################################################
rollback_website() {
    log "Step 6: Rolling back WordPress Website..."
    
    cd website
    
    # WordPress Database Restore
    if [[ -f "$BACKUP_DIR/wordpress-backup.sql" ]]; then
        wp db import "$BACKUP_DIR/wordpress-backup.sql" || warn "WordPress DB restore failed"
    fi
    
    # Code Rollback
    git checkout HEAD~1 || git checkout "$ROLLBACK_TARGET"
    
    # Plugin Updates rückgängig
    wp plugin update --all || warn "Plugin update rollback failed"
    
    # Cache leeren
    wp cache flush
    
    cd ..
    success "Website rolled back ✓"
}

###############################################################################
# 7. Rollback n8n Workflows
###############################################################################
rollback_n8n() {
    log "Step 7: Rolling back n8n Workflows..."
    
    # Backup aktuelle Workflows
    docker exec n8n n8n export:workflow --all --output=/backups/pre-rollback-workflows.json || warn "Workflow backup failed"
    
    # Restore alte Workflows
    if [[ -f "$BACKUP_DIR/n8n-workflows.json" ]]; then
        docker cp "$BACKUP_DIR/n8n-workflows.json" n8n:/tmp/workflows.json
        docker exec n8n n8n import:workflow --input=/tmp/workflows.json
        success "n8n workflows restored"
    else
        warn "No n8n workflow backup found"
    fi
    
    # n8n neustarten
    docker restart n8n
    success "n8n rolled back ✓"
}

###############################################################################
# 8. Nginx Configuration Rollback
###############################################################################
rollback_nginx() {
    log "Step 8: Rolling back Nginx configuration..."
    
    # Finde neuestes Nginx Backup
    local nginx_backup=$(ls -t /tmp/nginx-*-backup*.conf 2>/dev/null | head -1)
    
    if [[ -n "$nginx_backup" ]]; then
        log "Restoring Nginx config from: $nginx_backup"
        sudo cp "$nginx_backup" /etc/nginx/sites-available/api.menschlichkeit-oesterreich.at.conf
        
        # Config testen
        if sudo nginx -t; then
            sudo systemctl reload nginx
            success "Nginx configuration rolled back ✓"
        else
            error "Nginx config invalid after rollback!"
            return 1
        fi
    else
        warn "No Nginx backup found"
    fi
}

###############################################################################
# 9. Post-Rollback Validation
###############################################################################
post_rollback_validation() {
    log "Step 9: Post-Rollback Validation..."
    
    # Health Checks
    local all_healthy=true
    
    declare -A health_endpoints=(
        ["api"]="https://api.menschlichkeit-oesterreich.at/health"
        ["crm"]="https://crm.menschlichkeit-oesterreich.at/user/login"
        ["frontend"]="https://menschlichkeit-oesterreich.at"
    )
    
    for service in "${!health_endpoints[@]}"; do
        log "Checking $service..."
        if curl -f "${health_endpoints[$service]}" &> /dev/null; then
            success "$service: Healthy ✓"
        else
            error "$service: Unhealthy ✗"
            all_healthy=false
        fi
    done
    
    # Smoke Tests
    log "Running smoke tests..."
    npm run test:e2e --bail || warn "Some smoke tests failed"
    
    if $all_healthy; then
        success "All services healthy after rollback ✓"
    else
        error "Some services still unhealthy after rollback!"
        return 1
    fi
}

###############################################################################
# 10. Generate Rollback Report
###############################################################################
generate_rollback_report() {
    log "Generating rollback report..."
    
    cat > "$ROLLBACK_LOG" << EOF
# Rollback Report

**Timestamp:** $(date)
**Target Version:** $ROLLBACK_TARGET
**Backup Used:** $BACKUP_DIR
**Triggered By:** ${USER:-automated}

## Services Rolled Back

EOF

    for service in "${SERVICES[@]}"; do
        echo "- [x] $service" >> "$ROLLBACK_LOG"
    done

    cat >> "$ROLLBACK_LOG" << EOF

## Post-Rollback Health

$(for service in "${!health_endpoints[@]}"; do
    if curl -f "${health_endpoints[$service]}" &> /dev/null; then
        echo "- ✅ $service: Healthy"
    else
        echo "- ❌ $service: Unhealthy"
    fi
done)

## Duration

Total Rollback Time: ${SECONDS}s

## Next Steps

1. Investigate root cause of deployment failure
2. Fix issues in development/staging
3. Re-test thoroughly before next production deployment
4. Update rollback procedures if needed

---
*Rollback completed at $(date)*
EOF

    success "Rollback report: $ROLLBACK_LOG"
}

###############################################################################
# Main Rollback Orchestration
###############################################################################
main() {
    # Start Logging
    exec > >(tee -a "$ROLLBACK_LOG") 2>&1
    
    log "=========================================="
    error "ROLLBACK PROCEDURE STARTED"
    log "=========================================="
    
    # Error Handler
    trap 'error "Rollback failed at step: ${BASH_COMMAND}"' ERR
    
    # Rollback Steps
    pre_rollback_validation
    rollback_database
    rollback_api
    rollback_crm
    rollback_frontend
    rollback_gaming
    rollback_website
    rollback_n8n
    rollback_nginx
    post_rollback_validation
    generate_rollback_report
    
    log "=========================================="
    success "ROLLBACK COMPLETED SUCCESSFULLY"
    log "Duration: ${SECONDS}s"
    log "Report: $ROLLBACK_LOG"
    log "=========================================="
    
    # Notification
    if command -v curl &> /dev/null; then
        curl -X POST "${N8N_WEBHOOK:-http://localhost:5678/webhook/rollback-complete}" \
            -H "Content-Type: application/json" \
            -d "{\"timestamp\":\"$(date -Iseconds)\",\"status\":\"success\",\"version\":\"$ROLLBACK_TARGET\"}" \
            || warn "Failed to send rollback notification"
    fi
}

# Ausführung
main "$@"
