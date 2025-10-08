#!/bin/bash
###############################################################################
# Environment Setup für Deployment
# Interaktive Konfiguration aller Deployment-relevanten Variablen
###############################################################################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

ENV_FILE=".env.deployment"
ENV_EXAMPLE=".env.deployment.example"

clear
echo -e "${BLUE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           🔧 DEPLOYMENT ENVIRONMENT SETUP                    ║"
echo "║           Menschlichkeit Österreich Platform                ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}\n"

###############################################################################
# Helper Functions
###############################################################################
prompt() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="${3:-}"
    local is_secret="${4:-false}"
    
    if [[ "$is_secret" == "true" ]]; then
        echo -en "${CYAN}$prompt_text${NC}"
        [[ -n "$default_value" ]] && echo -en " ${YELLOW}[hidden]${NC}"
        echo -n ": "
        read -s value
        echo ""
    else
        echo -en "${CYAN}$prompt_text${NC}"
        [[ -n "$default_value" ]] && echo -en " ${YELLOW}[default: $default_value]${NC}"
        echo -n ": "
        read value
    fi
    
    value="${value:-$default_value}"
    
    if [[ -n "$value" ]]; then
        echo "$var_name=\"$value\"" >> "$ENV_FILE"
    fi
}

validate_url() {
    local url="$1"
    if [[ "$url" =~ ^https?:// ]]; then
        return 0
    else
        return 1
    fi
}

###############################################################################
# Main Setup
###############################################################################

# Backup existing file
if [[ -f "$ENV_FILE" ]]; then
    echo -e "${YELLOW}Existing $ENV_FILE found. Creating backup...${NC}"
    cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${GREEN}Backup created.${NC}\n"
fi

# Create new env file
echo "# Deployment Environment Configuration" > "$ENV_FILE"
echo "# Generated on $(date)" >> "$ENV_FILE"
echo "" >> "$ENV_FILE"

echo -e "${BOLD}=== Production URLs ===${NC}\n"

prompt "API_URL" "API URL" "https://api.menschlichkeit-oesterreich.at"
prompt "CRM_URL" "CRM URL" "https://crm.menschlichkeit-oesterreich.at"
prompt "FRONTEND_URL" "Frontend URL" "https://menschlichkeit-oesterreich.at"
prompt "ADMIN_URL" "Admin URL" "https://admin.menschlichkeit-oesterreich.at"

echo "" >> "$ENV_FILE"
echo "# Staging URLs" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Staging URLs ===${NC}\n"

prompt "STAGING_API_URL" "Staging API URL" "https://api.staging.menschlichkeit-oesterreich.at"
prompt "STAGING_CRM_URL" "Staging CRM URL" "https://crm.staging.menschlichkeit-oesterreich.at"
prompt "STAGING_FRONTEND_URL" "Staging Frontend URL" "https://staging.menschlichkeit-oesterreich.at"

echo "" >> "$ENV_FILE"
echo "# Database" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Database ===${NC}\n"

prompt "DATABASE_URL" "PostgreSQL Connection String" "postgresql://user:password@localhost:5432/dbname"
prompt "DB_BACKUP_DIR" "Database Backup Directory" "/var/backups/postgresql"

echo "" >> "$ENV_FILE"
echo "# CRM (Drupal + CiviCRM)" >> "$ENV_FILE"

echo -e "\n${BOLD}=== CRM (Drupal + CiviCRM) ===${NC}\n"

prompt "CRM_DB_HOST" "CRM Database Host" "external-mysql.menschlichkeit-oesterreich.at"
prompt "CRM_DB_PORT" "CRM Database Port" "3306"
prompt "CRM_DB_NAME" "CRM Database Name" "mo_crm"
prompt "CRM_DB_USER" "CRM Database User" "svc_crm"
prompt "CRM_DB_PASS" "CRM Database Password" "" "true"
prompt "CRM_BASE_URL" "CRM Base URL" "https://crm.menschlichkeit-oesterreich.at"
prompt "CRM_SITE_NAME" "CRM Site Name" "Menschlichkeit Österreich CRM"
prompt "CRM_ADMIN_USER" "CRM Admin Username" "admin"
prompt "CRM_ADMIN_PASS" "CRM Admin Password" "" "true"
prompt "CRM_ADMIN_MAIL" "CRM Admin Email" "crm@menschlichkeit-oesterreich.at"
prompt "CIVICRM_SITE_KEY" "CiviCRM Site Key" "" "true"
prompt "CRM_SMTP_HOST" "CRM SMTP Host" "localhost"
prompt "CRM_SMTP_PORT" "CRM SMTP Port" "587"
prompt "CRM_SMTP_USER" "CRM SMTP Username" "crm@menschlichkeit-oesterreich.at"
prompt "CRM_SMTP_PASS" "CRM SMTP Password" "" "true"
prompt "CRM_SMTP_PROTOCOL" "CRM SMTP Protocol (tls/ssl)" "tls"

echo "" >> "$ENV_FILE"
echo "# Plesk Configuration" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Plesk Configuration ===${NC}\n"

echo -e "${YELLOW}ℹ️  Optional: Nur wenn Plesk-Deployment verwendet wird${NC}\n"

prompt "PLESK_HOST" "Plesk Hostname" "menschlichkeit-oesterreich.at"
prompt "PLESK_API_KEY" "Plesk API Key" "" "true"
prompt "PLESK_DOMAIN_ID" "Plesk Domain ID" ""

echo "" >> "$ENV_FILE"
echo "# Alerting & Monitoring" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Alerting & Monitoring ===${NC}\n"

prompt "N8N_ALERT_WEBHOOK" "n8n Alert Webhook URL" "http://localhost:5678/webhook/deployment-alert"
prompt "SLACK_WEBHOOK" "Slack Webhook URL (optional)" ""
prompt "EMAIL_RECIPIENTS" "Email Recipients for Alerts" "devops@menschlichkeit-oesterreich.at"

echo "" >> "$ENV_FILE"
echo "# Quality Thresholds" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Quality Thresholds ===${NC}\n"

echo -e "${YELLOW}ℹ️  Press Enter to use defaults${NC}\n"

prompt "MIN_MAINTAINABILITY" "Minimum Maintainability (%)" "85"
prompt "MAX_DUPLICATION" "Maximum Code Duplication (%)" "2"
prompt "MIN_COVERAGE" "Minimum Test Coverage (%)" "80"
prompt "MIN_LIGHTHOUSE_SCORE" "Minimum Lighthouse Score" "90"
prompt "MAX_CVE_SCORE" "Maximum allowed CVE Score" "7.0"

echo "" >> "$ENV_FILE"
echo "# System Thresholds" >> "$ENV_FILE"

echo -e "\n${BOLD}=== System Resource Thresholds ===${NC}\n"

prompt "CPU_THRESHOLD" "CPU Usage Threshold (%)" "80"
prompt "MEMORY_THRESHOLD" "Memory Usage Threshold (%)" "85"
prompt "DISK_THRESHOLD" "Disk Usage Threshold (%)" "90"
prompt "ERROR_RATE_THRESHOLD" "Error Rate Threshold (0-1)" "0.01"
prompt "RESPONSE_TIME_THRESHOLD" "Response Time Threshold (seconds)" "0.5"

echo "" >> "$ENV_FILE"
echo "# Deployment Configuration" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Deployment Configuration ===${NC}\n"

prompt "MAX_DEPLOYMENT_TIME" "Maximum Deployment Time (seconds)" "1800"
prompt "ROLLBACK_SLA" "Rollback SLA (seconds)" "300"
prompt "BACKUP_RETENTION_HOURS" "Backup Retention Hours" "24"

echo "" >> "$ENV_FILE"
echo "# Feature Flags" >> "$ENV_FILE"

echo -e "\n${BOLD}=== Feature Flags ===${NC}\n"

prompt "AUTO_BACKUP_BEFORE_DEPLOY" "Auto-backup before deploy? (true/false)" "true"
prompt "SECRET_SCAN_ENABLED" "Enable secret scanning? (true/false)" "true"
prompt "TRIVY_SCAN_ENABLED" "Enable Trivy security scan? (true/false)" "true"
prompt "ALLOW_FORCE_PUSH" "Allow force push? (true/false)" "false"

###############################################################################
# Validation
###############################################################################
echo -e "\n${BOLD}=== Validating Configuration ===${NC}\n"

source "$ENV_FILE"

# Validate URLs
errors=0

if [[ -n "${API_URL:-}" ]] && ! validate_url "$API_URL"; then
    echo -e "${RED}✗ Invalid API_URL${NC}"
    ((errors++))
fi

if [[ -n "${CRM_BASE_URL:-}" ]] && ! validate_url "$CRM_BASE_URL"; then
    echo -e "${RED}✗ Invalid CRM_BASE_URL${NC}"
    ((errors++))
fi

if [[ -n "${DATABASE_URL:-}" ]] && [[ ! "$DATABASE_URL" =~ ^postgresql:// ]]; then
    echo -e "${RED}✗ Invalid DATABASE_URL (must start with postgresql://)${NC}"
    ((errors++))
fi

if [[ -n "${N8N_ALERT_WEBHOOK:-}" ]] && ! validate_url "$N8N_ALERT_WEBHOOK"; then
    echo -e "${YELLOW}⚠ N8N_ALERT_WEBHOOK may be invalid${NC}"
fi

if [[ -z "${CRM_DB_PASS:-}" ]]; then
    echo -e "${YELLOW}⚠ CRM_DB_PASS is empty – set a strong password before deploying${NC}"
fi

if [[ -z "${CIVICRM_SITE_KEY:-}" ]]; then
    echo -e "${YELLOW}⚠ CIVICRM_SITE_KEY is empty – generate a secure key for production${NC}"
fi

if [[ $errors -gt 0 ]]; then
    echo -e "\n${RED}Configuration has $errors error(s). Please review $ENV_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Configuration validated${NC}"

###############################################################################
# Create Example File
###############################################################################
echo -e "\n${BOLD}=== Creating Example File ===${NC}\n"

cat > "$ENV_EXAMPLE" <<'EOF'
# Deployment Environment Configuration
# Copy this file to .env.deployment and fill in your values

# Production URLs
API_URL="https://api.menschlichkeit-oesterreich.at"
CRM_URL="https://crm.menschlichkeit-oesterreich.at"
FRONTEND_URL="https://menschlichkeit-oesterreich.at"
ADMIN_URL="https://admin.menschlichkeit-oesterreich.at"

# Staging URLs
STAGING_API_URL="https://api.staging.menschlichkeit-oesterreich.at"
STAGING_CRM_URL="https://crm.staging.menschlichkeit-oesterreich.at"
STAGING_FRONTEND_URL="https://staging.menschlichkeit-oesterreich.at"

# Database
DATABASE_URL="postgresql://user:password@localhost:5432/dbname"
DB_BACKUP_DIR="/var/backups/postgresql"

# CRM (Drupal + CiviCRM)
CRM_DB_HOST="external-mysql.menschlichkeit-oesterreich.at"
CRM_DB_PORT="3306"
CRM_DB_NAME="mo_crm"
CRM_DB_USER="svc_crm"
CRM_DB_PASS=""
CRM_BASE_URL="https://crm.menschlichkeit-oesterreich.at"
CRM_SITE_NAME="Menschlichkeit Österreich CRM"
CRM_ADMIN_USER="admin"
CRM_ADMIN_PASS=""
CRM_ADMIN_MAIL="crm@menschlichkeit-oesterreich.at"
CIVICRM_SITE_KEY=""
CRM_SMTP_HOST="localhost"
CRM_SMTP_PORT="587"
CRM_SMTP_USER="crm@menschlichkeit-oesterreich.at"
CRM_SMTP_PASS=""
CRM_SMTP_PROTOCOL="tls"

# Plesk Configuration (optional)
PLESK_HOST="menschlichkeit-oesterreich.at"
PLESK_API_KEY="your-plesk-api-key"
PLESK_DOMAIN_ID="your-domain-id"

# Alerting & Monitoring
N8N_ALERT_WEBHOOK="http://localhost:5678/webhook/deployment-alert"
SLACK_WEBHOOK=""
EMAIL_RECIPIENTS="devops@menschlichkeit-oesterreich.at"

# Quality Thresholds
MIN_MAINTAINABILITY="85"
MAX_DUPLICATION="2"
MIN_COVERAGE="80"
MIN_LIGHTHOUSE_SCORE="90"
MAX_CVE_SCORE="7.0"

# System Thresholds
CPU_THRESHOLD="80"
MEMORY_THRESHOLD="85"
DISK_THRESHOLD="90"
ERROR_RATE_THRESHOLD="0.01"
RESPONSE_TIME_THRESHOLD="0.5"

# Deployment Configuration
MAX_DEPLOYMENT_TIME="1800"
ROLLBACK_SLA="300"
BACKUP_RETENTION_HOURS="24"

# Feature Flags
AUTO_BACKUP_BEFORE_DEPLOY="true"
SECRET_SCAN_ENABLED="true"
TRIVY_SCAN_ENABLED="true"
ALLOW_FORCE_PUSH="false"
EOF

echo -e "${GREEN}✓ Example file created: $ENV_EXAMPLE${NC}"

###############################################################################
# Add to .gitignore
###############################################################################
if ! grep -q "^.env.deployment$" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Deployment environment" >> .gitignore
    echo ".env.deployment" >> .gitignore
    echo ".env.deployment.backup.*" >> .gitignore
    echo -e "${GREEN}✓ Added $ENV_FILE to .gitignore${NC}"
fi

###############################################################################
# Summary
###############################################################################
echo -e "\n${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           ✅ SETUP COMPLETE                                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${BOLD}Created Files:${NC}"
echo "  - $ENV_FILE (your configuration)"
echo "  - $ENV_EXAMPLE (template for others)"
echo ""

echo -e "${BOLD}Next Steps:${NC}"
echo "  1. Review configuration: ${CYAN}cat $ENV_FILE${NC}"
echo "  2. Test deployment readiness: ${CYAN}npm run deploy:readiness${NC}"
echo "  3. Start deployment: ${CYAN}npm run deploy:staging${NC}"
echo ""

echo -e "${YELLOW}⚠️  Security:${NC}"
echo "  - $ENV_FILE contains sensitive data"
echo "  - Do NOT commit this file to Git"
echo "  - Store secrets securely (GitHub Secrets, Vault, etc.)"
echo ""

echo -e "${BOLD}To reload configuration in scripts:${NC}"
echo "  ${CYAN}source $ENV_FILE${NC}"
echo ""

echo -e "${GREEN}Happy Deploying! 🚀${NC}"
