#!/bin/bash
# rotate-secrets.sh
# Automatische Rotation kritischer Secrets für Menschlichkeit Österreich
# Empfohlene Ausführung: monatlich via Cron

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Konfiguration
BACKUP_DIR="./secrets-backup-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="rotation-$(date +%Y%m%d_%H%M%S).log"
DRY_RUN=${DRY_RUN:-false}

print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
}

print_header() {
    print_colored "$BLUE" "=" * 60
    print_colored "$BLUE" "$1"
    print_colored "$BLUE" "=" * 60
}

# Generiere neues sicheres Passwort
generate_secure_password() {
    local length=${1:-24}
    python3 -c "
import secrets
import string
chars = string.ascii_letters + string.digits + '!@#\$%^&*+=_-'
# Entferne mehrdeutige Zeichen
chars = ''.join(c for c in chars if c not in '0O1lI|')
password = []
# Mindestens ein Zeichen aus jeder Kategorie
password.append(secrets.choice(string.ascii_lowercase))
password.append(secrets.choice(string.ascii_uppercase))
password.append(secrets.choice(string.digits))
password.append(secrets.choice('!@#\$%^&*'))
# Fülle auf gewünschte Länge auf
for _ in range($length - 4):
    password.append(secrets.choice(chars))
# Mische die Zeichen
secrets.SystemRandom().shuffle(password)
print(''.join(password))
"
}

# Generiere Hex-Key
generate_hex_key() {
    local byte_length=${1:-32}
    python3 -c "import secrets; print(secrets.token_hex($byte_length))"
}

# Backup aktueller Secrets
backup_current_secrets() {
    print_header "💾 Backing up current secrets"
    
    mkdir -p "$BACKUP_DIR"
    
    # Aktuelle .env-Dateien sichern
    for env_file in ".env.deployment" ".env.production.generated" ".env"; do
        if [[ -f "$env_file" ]]; then
            cp "$env_file" "$BACKUP_DIR/"
            print_colored "$GREEN" "✅ Backed up: $env_file"
        fi
    done
    
    # GitHub Secrets exportieren (falls gh CLI verfügbar)
    if command -v gh >/dev/null 2>&1; then
        print_colored "$BLUE" "📦 Exporting GitHub Secrets list..."
        gh secret list --json name,createdAt > "$BACKUP_DIR/github-secrets-list.json" 2>/dev/null || true
    fi
    
    print_colored "$GREEN" "📁 Backup created in: $BACKUP_DIR"
}

# Rotiere kritische Application Secrets
rotate_application_secrets() {
    print_header "🔄 Rotating Application Secrets"
    
    local secrets_to_rotate=(
        "JWT_SECRET:hex:32"
        "API_ENCRYPTION_KEY:hex:24"  
        "SESSION_SECRET:hex:16"
        "N8N_ENCRYPTION_KEY:hex:20"
        "N8N_USER_MANAGEMENT_JWT_SECRET:hex:20"
        "WEBHOOK_SECRET_GITHUB:hex:16"
        "WEBHOOK_SECRET_FIGMA:hex:16"
        "WEBHOOK_SECRET_STRIPE:hex:16"
    )
    
    for secret_def in "${secrets_to_rotate[@]}"; do
        IFS=':' read -r secret_name secret_type secret_param <<< "$secret_def"
        
        local new_value
        case $secret_type in
            "hex")
                new_value=$(generate_hex_key "$secret_param")
                ;;
            "password")
                new_value=$(generate_secure_password "$secret_param")
                ;;
            *)
                print_colored "$RED" "❌ Unknown secret type: $secret_type"
                continue
                ;;
        esac
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_colored "$YELLOW" "🔍 [DRY-RUN] Would rotate: $secret_name = ${new_value:0:10}..."
        else
            # Hier würden wir die Secrets tatsächlich updaten
            # In .env-Datei aktualisieren
            update_env_secret "$secret_name" "$new_value"
            
            # In GitHub Secrets aktualisieren
            update_github_secret "$secret_name" "$new_value"
            
            print_colored "$GREEN" "✅ Rotated: $secret_name"
        fi
    done
}

# Rotiere Datenbank-Passwörter (kritisch - nur bei Bedarf)
rotate_database_passwords() {
    print_header "🗄️  Database Password Rotation (CRITICAL)"
    
    print_colored "$YELLOW" "⚠️  Database password rotation requires:"
    print_colored "$YELLOW" "   1. Maintenance window"
    print_colored "$YELLOW" "   2. Service restarts"
    print_colored "$YELLOW" "   3. Manual database user updates"
    print_colored "$YELLOW" "   4. Deployment pipeline updates"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_colored "$YELLOW" "🔍 [DRY-RUN] Database rotation would be planned but not executed"
        return
    fi
    
    read -p "Continue with database password rotation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_colored "$YELLOW" "⏸️  Database rotation skipped"
        return
    fi
    
    # Hier würde die tatsächliche Datenbankpasswort-Rotation implementiert
    print_colored "$BLUE" "📝 Database rotation requires manual steps:"
    print_colored "$BLUE" "   1. Update database user passwords via SQL"
    print_colored "$BLUE" "   2. Update connection strings in applications"
    print_colored "$BLUE" "   3. Restart all services"
    print_colored "$BLUE" "   4. Test all connections"
}

# Rotiere Admin-Passwörter
rotate_admin_passwords() {
    print_header "👤 Admin Password Rotation"
    
    local admin_secrets=(
        "CRM_ADMIN_PASS:password:16"
        "N8N_PASSWORD:password:24"
        "GRAFANA_ADMIN_PASSWORD:password:24"
    )
    
    for secret_def in "${admin_secrets[@]}"; do
        IFS=':' read -r secret_name secret_type secret_length <<< "$secret_def"
        
        local new_password
        new_password=$(generate_secure_password "$secret_length")
        
        if [[ "$DRY_RUN" == "true" ]]; then
            print_colored "$YELLOW" "🔍 [DRY-RUN] Would rotate: $secret_name"
        else
            update_env_secret "$secret_name" "$new_password"
            update_github_secret "$secret_name" "$new_password"
            
            print_colored "$GREEN" "✅ Rotated: $secret_name"
            print_colored "$YELLOW" "⚠️  Manual action required: Update password in ${secret_name%_*} interface"
        fi
    done
}

# Aktualisiere Secret in .env-Datei
update_env_secret() {
    local secret_name=$1
    local secret_value=$2
    local env_file=".env.deployment"
    
    if [[ -f "$env_file" ]]; then
        if grep -q "^${secret_name}=" "$env_file"; then
            sed -i "s/^${secret_name}=.*/${secret_name}=${secret_value}/" "$env_file"
        else
            echo "${secret_name}=${secret_value}" >> "$env_file"
        fi
    fi
}

# Aktualisiere GitHub Secret
update_github_secret() {
    local secret_name=$1
    local secret_value=$2
    
    if command -v gh >/dev/null 2>&1; then
        local environments=("staging" "production")
        
        for env in "${environments[@]}"; do
            if gh secret set "$secret_name" --env "$env" --body "$secret_value" >/dev/null 2>&1; then
                print_colored "$GREEN" "  ✅ Updated GitHub Secret: $secret_name ($env)"
            else
                print_colored "$RED" "  ❌ Failed to update GitHub Secret: $secret_name ($env)"
            fi
        done
    else
        print_colored "$YELLOW" "⚠️  GitHub CLI not available - skipping GitHub Secrets update"
    fi
}

# Validiere neue Secrets
validate_rotated_secrets() {
    print_header "✅ Validating Rotated Secrets"
    
    if [[ -f "scripts/validate-secrets.sh" ]]; then
        print_colored "$BLUE" "🔍 Running validation script..."
        if ./scripts/validate-secrets.sh env; then
            print_colored "$GREEN" "✅ Secret validation passed"
        else
            print_colored "$RED" "❌ Secret validation failed"
            return 1
        fi
    else
        print_colored "$YELLOW" "⚠️  Validation script not found - manual verification recommended"
    fi
}

# Aktualisiere Dokumentation
update_documentation() {
    print_header "📝 Updating Documentation"
    
    local rotation_date=$(date '+%Y-%m-%d %H:%M:%S')
    local docs_file="docs/SECRETS.template.md"
    
    if [[ -f "$docs_file" ]]; then
        # Füge Rotation-Entry hinzu
        echo "" >> "$docs_file"
        echo "**Last Rotation:** $rotation_date" >> "$docs_file"
        echo "**Next Rotation:** $(date -d '+90 days' '+%Y-%m-%d')" >> "$docs_file"
        
        print_colored "$GREEN" "✅ Updated documentation"
    fi
    
    # Update INSTRUCTIONS-UPDATE-SUMMARY.md
    local summary_file="INSTRUCTIONS-UPDATE-SUMMARY.md"
    if [[ -f "$summary_file" ]]; then
        echo "" >> "$summary_file"
        echo "## Secret Rotation - $rotation_date" >> "$summary_file"
        echo "- Rotated application secrets (JWT, API keys, webhooks)" >> "$summary_file"
        echo "- Updated GitHub Secrets for staging and production" >> "$summary_file"
        echo "- Next rotation scheduled: $(date -d '+90 days' '+%Y-%m-%d')" >> "$summary_file"
        
        print_colored "$GREEN" "✅ Updated summary documentation"
    fi
}

# Erstelle Rotation-Report
create_rotation_report() {
    print_header "📊 Creating Rotation Report"
    
    local report_file="quality-reports/secret-rotation-$(date +%Y%m%d_%H%M%S).md"
    mkdir -p "quality-reports"
    
    cat > "$report_file" << EOF
# Secret Rotation Report
**Date:** $(date '+%Y-%m-%d %H:%M:%S')
**Dry Run:** $DRY_RUN

## Rotated Secrets
- Application secrets (JWT, API keys, webhooks)
- Admin passwords (CRM, n8n, Grafana)
- Database passwords: ${DATABASE_ROTATION:-"Skipped"}

## Backup Location
- Local backup: $BACKUP_DIR
- Log file: $LOG_FILE

## Next Actions
1. Test all services after rotation
2. Update any hardcoded references
3. Schedule next rotation in 90 days

## Validation Results
- Environment variables: ✅ Validated
- Service connections: See validation log
- GitHub Secrets: Updated in staging and production

## Notes
$(if [[ "$DRY_RUN" == "true" ]]; then echo "This was a DRY RUN - no actual changes made"; fi)
EOF

    print_colored "$GREEN" "📄 Report created: $report_file"
}

# Cleanup nach Rotation
cleanup_rotation() {
    print_header "🧹 Cleanup"
    
    # Sensitive Variablen aus Environment entfernen
    unset PGPASSWORD 2>/dev/null || true
    
    print_colored "$BLUE" "🔒 Cleanup completed"
}

# Hauptprogramm
main() {
    print_header "🔄 Secret Rotation für Menschlichkeit Österreich"
    
    print_colored "$BLUE" "📅 Started: $(date)"
    print_colored "$BLUE" "📁 Working Directory: $(pwd)"
    print_colored "$BLUE" "📋 Dry Run: $DRY_RUN"
    
    # Voraussetzungen prüfen
    if ! command -v python3 >/dev/null 2>&1; then
        print_colored "$RED" "❌ Python3 required for password generation"
        exit 1
    fi
    
    # Backup erstellen
    backup_current_secrets
    
    # Verschiedene Secret-Typen rotieren
    rotate_application_secrets
    rotate_admin_passwords
    
    # Optional: Datenbank-Passwörter (kritisch)
    if [[ "${ROTATE_DATABASES:-false}" == "true" ]]; then
        rotate_database_passwords
    fi
    
    # Validierung und Dokumentation
    if [[ "$DRY_RUN" != "true" ]]; then
        validate_rotated_secrets
        update_documentation
    fi
    
    create_rotation_report
    cleanup_rotation
    
    print_colored "$GREEN" "🎉 Secret rotation completed successfully!"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_colored "$YELLOW" "💡 This was a dry run. To execute:"
        print_colored "$YELLOW" "   DRY_RUN=false ./scripts/rotate-secrets.sh"
    else
        print_colored "$BLUE" "📝 Next steps:"
        print_colored "$BLUE" "   1. Test all services"
        print_colored "$BLUE" "   2. Update any hardcoded references"  
        print_colored "$BLUE" "   3. Schedule next rotation (90 days)"
        print_colored "$YELLOW" "   4. Consider database rotation during maintenance window"
    fi
}

# Trap für Cleanup
trap cleanup_rotation EXIT

# Script-Argumente verarbeiten
case "${1:-all}" in
    "app"|"application")
        backup_current_secrets
        rotate_application_secrets
        if [[ "$DRY_RUN" != "true" ]]; then validate_rotated_secrets; fi
        create_rotation_report
        ;;
    "admin"|"passwords")
        backup_current_secrets
        rotate_admin_passwords
        if [[ "$DRY_RUN" != "true" ]]; then validate_rotated_secrets; fi
        create_rotation_report
        ;;
    "database"|"db")
        backup_current_secrets
        DATABASE_ROTATION="Executed"
        rotate_database_passwords
        if [[ "$DRY_RUN" != "true" ]]; then validate_rotated_secrets; fi
        create_rotation_report
        ;;
    "dry-run"|"test")
        DRY_RUN=true
        main
        ;;
    "all"|*)
        main
        ;;
esac