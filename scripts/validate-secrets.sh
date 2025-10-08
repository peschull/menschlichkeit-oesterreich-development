#!/bin/bash
# validate-secrets.sh
# Validiert alle Datenbankverbindungen und Service-Endpoints
# für Menschlichkeit Österreich

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Logging
LOG_FILE="validation-$(date +%Y%m%d_%H%M%S).log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
    log "$message"
}

print_header() {
    print_colored "$BLUE" "=" * 60
    print_colored "$BLUE" "$1"
    print_colored "$BLUE" "=" * 60
}

increment_test() {
    ((TOTAL_TESTS++))
}

mark_passed() {
    ((PASSED_TESTS++))
    print_colored "$GREEN" "✅ $1"
}

mark_failed() {
    ((FAILED_TESTS++))
    print_colored "$RED" "❌ $1"
}

# Lade Environment-Variablen
load_environment() {
    print_header "🔧 Loading Environment Configuration"
    
    # Suche nach .env-Dateien
    ENV_FILES=(".env.deployment" ".env.production.generated" ".env")
    ENV_LOADED=false
    
    for env_file in "${ENV_FILES[@]}"; do
        if [[ -f "$env_file" ]]; then
            print_colored "$GREEN" "📄 Loading: $env_file"
            set -a  # Export all variables
            source "$env_file"
            set +a  # Stop exporting
            ENV_LOADED=true
            break
        fi
    done
    
    if [[ "$ENV_LOADED" == false ]]; then
        print_colored "$RED" "❌ No environment file found. Looked for:"
        for env_file in "${ENV_FILES[@]}"; do
            print_colored "$RED" "   - $env_file"
        done
        exit 1
    fi
}

# Teste MySQL/MariaDB Verbindung
test_mysql_connection() {
    local name=$1
    local host=$2
    local port=$3
    local user=$4
    local password=$5
    local database=$6
    
    increment_test
    
    if command -v mysql >/dev/null 2>&1; then
        if mysql -h"$host" -P"$port" -u"$user" -p"$password" -e "SELECT 1;" "$database" >/dev/null 2>&1; then
            mark_passed "MySQL: $name ($host:$port/$database)"
        else
            mark_failed "MySQL: $name ($host:$port/$database) - Connection failed" 
        fi
    else
        print_colored "$YELLOW" "⚠️  MySQL client not found - skipping MySQL tests"
        return
    fi
}

# Teste PostgreSQL Verbindung
test_postgresql_connection() {
    local name=$1
    local host=$2
    local port=$3
    local user=$4
    local password=$5
    local database=$6
    
    increment_test
    
    if command -v psql >/dev/null 2>&1; then
        export PGPASSWORD="$password"
        if psql -h "$host" -p "$port" -U "$user" -d "$database" -c "SELECT 1;" >/dev/null 2>&1; then
            mark_passed "PostgreSQL: $name ($host:$port/$database)"
        else
            mark_failed "PostgreSQL: $name ($host:$port/$database) - Connection failed"
        fi
        unset PGPASSWORD
    else
        print_colored "$YELLOW" "⚠️  PostgreSQL client (psql) not found - skipping PostgreSQL tests"
        return
    fi
}

# Teste Redis Verbindung
test_redis_connection() {
    local name=$1
    local host=$2
    local port=$3
    local password=$4
    
    increment_test
    
    if command -v redis-cli >/dev/null 2>&1; then
        if redis-cli -h "$host" -p "$port" -a "$password" ping >/dev/null 2>&1; then
            mark_passed "Redis: $name ($host:$port)"
        else
            mark_failed "Redis: $name ($host:$port) - Connection failed"
        fi
    else
        print_colored "$YELLOW" "⚠️  Redis client not found - skipping Redis tests"
        return
    fi
}

# Teste HTTP-Endpoint
test_http_endpoint() {
    local name=$1
    local url=$2
    local expected_status=$3
    
    increment_test
    
    if command -v curl >/dev/null 2>&1; then
        local status_code
        status_code=$(curl -s -o /dev/null -w "%{http_code}" "$url" --max-time 10)
        
        if [[ "$status_code" == "$expected_status" ]]; then
            mark_passed "HTTP: $name ($url) - Status: $status_code"
        else
            mark_failed "HTTP: $name ($url) - Expected: $expected_status, Got: $status_code"
        fi
    else
        print_colored "$YELLOW" "⚠️  curl not found - skipping HTTP tests"
        return
    fi
}

# Teste SMTP-Verbindung
test_smtp_connection() {
    local name=$1
    local host=$2
    local port=$3
    local user=$4
    local password=$5
    
    increment_test
    
    if command -v telnet >/dev/null 2>&1; then
        # Einfacher Telnet-Test für SMTP-Port
        if timeout 5 telnet "$host" "$port" </dev/null >/dev/null 2>&1; then
            mark_passed "SMTP: $name ($host:$port) - Port accessible"
        else
            mark_failed "SMTP: $name ($host:$port) - Port not accessible"
        fi
    else
        print_colored "$YELLOW" "⚠️  telnet not found - skipping SMTP tests"
        return
    fi
}

# Teste SSH-Verbindung
test_ssh_connection() {
    local name=$1
    local host=$2
    local user=$3
    local port=$4
    
    increment_test
    
    if command -v ssh >/dev/null 2>&1; then
        # SSH-Test mit timeout
        if timeout 10 ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no -p "$port" "$user@$host" "echo 'SSH OK'" >/dev/null 2>&1; then
            mark_passed "SSH: $name ($user@$host:$port)"
        else
            mark_failed "SSH: $name ($user@$host:$port) - Connection failed"
        fi
    else
        print_colored "$YELLOW" "⚠️  SSH client not found - skipping SSH tests"
        return
    fi
}

# Validiere alle Datenbank-Verbindungen
validate_databases() {
    print_header "🗄️  Database Connection Tests"
    
    # Plesk MariaDB (localhost)
    print_colored "$BLUE" "📍 Testing Plesk MariaDB (localhost)..."
    
    if [[ -n "${MO_CRM_DB_HOST:-}" ]]; then
        test_mysql_connection "CRM" "${MO_CRM_DB_HOST}" "3306" "${MO_CRM_DB_USER:-}" "${MO_CRM_DB_PASS:-}" "${MO_CRM_DB_NAME:-}"
    fi
    
    if [[ -n "${MO_WEBSITE_DB_HOST:-}" ]]; then
        test_mysql_connection "Website" "${MO_WEBSITE_DB_HOST:-localhost}" "3306" "${MO_WEBSITE_DB_USER:-}" "${MO_WEBSITE_DB_PASS:-}" "${MO_WEBSITE_DB_NAME:-}"
    fi
    
    if [[ -n "${MO_N8N_LOCAL_DB_HOST:-}" ]]; then
        test_mysql_connection "n8n Local" "${MO_N8N_LOCAL_DB_HOST:-localhost}" "3306" "${MO_N8N_LOCAL_DB_USER:-}" "${MO_N8N_LOCAL_DB_PASS:-}" "${MO_N8N_LOCAL_DB_NAME:-}"
    fi
    
    if [[ -n "${MO_ANALYTICS_DB_HOST:-}" ]]; then
        test_mysql_connection "Analytics" "${MO_ANALYTICS_DB_HOST:-localhost}" "3306" "${MO_ANALYTICS_DB_USER:-}" "${MO_ANALYTICS_DB_PASS:-}" "${MO_ANALYTICS_DB_NAME:-}"
    fi
    
    if [[ -n "${MO_BACKUPS_DB_HOST:-}" ]]; then
        test_mysql_connection "Backups" "${MO_BACKUPS_DB_HOST:-localhost}" "3306" "${MO_BACKUPS_DB_USER:-}" "${MO_BACKUPS_DB_PASS:-}" "${MO_BACKUPS_DB_NAME:-}"
    fi
    
    # External MariaDB
    print_colored "$BLUE" "🌐 Testing External MariaDB..."
    
    local external_host="${EXTERNAL_DB_HOST:-}"
    if [[ -n "$external_host" ]]; then
        test_mysql_connection "CRM Staging" "$external_host" "3306" "${MO_CRM_STAGING_DB_USER:-}" "${MO_CRM_STAGING_DB_PASS:-}" "${MO_CRM_STAGING_DB_NAME:-}"
        test_mysql_connection "Web Staging" "$external_host" "3306" "${MO_WEB_STAGING_DB_USER:-}" "${MO_WEB_STAGING_DB_PASS:-}" "${MO_WEB_STAGING_DB_NAME:-}"
        test_mysql_connection "Cache" "$external_host" "3306" "${MO_CACHE_DB_USER:-}" "${MO_CACHE_DB_PASS:-}" "${MO_CACHE_DB_NAME:-}"
        test_mysql_connection "Sessions" "$external_host" "3306" "${MO_SESSIONS_DB_USER:-}" "${MO_SESSIONS_DB_PASS:-}" "${MO_SESSIONS_DB_NAME:-}"
        test_mysql_connection "Logs" "$external_host" "3306" "${MO_LOGS_DB_USER:-}" "${MO_LOGS_DB_PASS:-}" "${MO_LOGS_DB_NAME:-}"
        test_mysql_connection "Queue" "$external_host" "3306" "${MO_QUEUE_DB_USER:-}" "${MO_QUEUE_DB_PASS:-}" "${MO_QUEUE_DB_NAME:-}"
        test_mysql_connection "Search" "$external_host" "3306" "${MO_SEARCH_DB_USER:-}" "${MO_SEARCH_DB_PASS:-}" "${MO_SEARCH_DB_NAME:-}"
        test_mysql_connection "Reports" "$external_host" "3306" "${MO_REPORTS_DB_USER:-}" "${MO_REPORTS_DB_PASS:-}" "${MO_REPORTS_DB_NAME:-}"
        test_mysql_connection "Monitoring" "$external_host" "3306" "${MO_MONITORING_DB_USER:-}" "${MO_MONITORING_DB_PASS:-}" "${MO_MONITORING_DB_NAME:-}"
    fi
    
    # PostgreSQL
    print_colored "$BLUE" "🐘 Testing PostgreSQL..."
    
    local pg_host="${PG_HOST:-}"
    local pg_port="${PG_PORT:-5432}"
    if [[ -n "$pg_host" ]]; then
        test_postgresql_connection "Games" "$pg_host" "$pg_port" "${MO_GAMES_DB_USER:-}" "${MO_GAMES_DB_PASS:-}" "${MO_GAMES_DB_NAME:-}"
        test_postgresql_connection "Analytics PG" "$pg_host" "$pg_port" "${MO_ANALYTICS_PG_DB_USER:-}" "${MO_ANALYTICS_PG_DB_PASS:-}" "${MO_ANALYTICS_PG_DB_NAME:-}"
        test_postgresql_connection "API Data" "$pg_host" "$pg_port" "${MO_API_DATA_DB_USER:-}" "${MO_API_DATA_DB_PASS:-}" "${MO_API_DATA_DB_NAME:-}"
    fi
    
    # Redis (optional)
    if [[ -n "${REDIS_HOST:-}" ]]; then
        print_colored "$BLUE" "🔴 Testing Redis..."
        test_redis_connection "Redis Main" "${REDIS_HOST}" "${REDIS_PORT:-6379}" "${REDIS_PASSWORD:-}"
    fi
}

# Validiere Service-Endpoints
validate_services() {
    print_header "🌐 Service Endpoint Tests"
    
    # Hauptdomains
    test_http_endpoint "Main Website" "https://menschlichkeit-oesterreich.at" "200"
    test_http_endpoint "CRM" "${CRM_BASE_URL:-https://crm.menschlichkeit-oesterreich.at}" "200"
    test_http_endpoint "API Health" "${API_BASE_URL:-https://api.menschlichkeit-oesterreich.at}/health" "200"
    test_http_endpoint "Games Platform" "https://games.menschlichkeit-oesterreich.at" "200"
    
    # n8n
    if [[ -n "${N8N_BASE_URL:-}" ]]; then
        test_http_endpoint "n8n" "${N8N_BASE_URL}" "200"
    fi
}

# Validiere SMTP-Konfiguration
validate_smtp() {
    print_header "📧 SMTP Configuration Tests"
    
    if [[ -n "${SMTP_HOST:-}" ]]; then
        test_smtp_connection "Main SMTP" "${SMTP_HOST}" "${SMTP_PORT:-587}" "${SMTP_USER:-}" "${SMTP_PASS:-}"
    fi
    
    if [[ -n "${CRM_SMTP_HOST:-}" ]]; then
        test_smtp_connection "CRM SMTP" "${CRM_SMTP_HOST}" "${CRM_SMTP_PORT:-587}" "${CRM_SMTP_USER:-}" "${CRM_SMTP_PASS:-}"
    fi
}

# Validiere SSH-Zugang
validate_ssh() {
    print_header "🔐 SSH Connection Tests"
    
    if [[ -n "${SSH_HOST:-}" ]] && [[ -n "${SSH_USER:-}" ]]; then
        test_ssh_connection "Plesk Server" "${SSH_HOST}" "${SSH_USER}" "${SSH_PORT:-22}"
    fi
}

# Validiere wichtige Umgebungsvariablen
validate_environment_vars() {
    print_header "🔧 Environment Variables Validation"
    
    local critical_vars=(
        "JWT_SECRET"
        "CIVICRM_SITE_KEY"
        "CIVICRM_API_KEY"
        "N8N_ENCRYPTION_KEY"
    )
    
    for var in "${critical_vars[@]}"; do
        increment_test
        if [[ -n "${!var:-}" ]]; then
            local value="${!var}"
            local length=${#value}
            
            if [[ $length -ge 16 ]]; then
                mark_passed "Environment Variable: $var (length: $length)"
            else
                mark_failed "Environment Variable: $var - Too short (length: $length)"
            fi
        else
            mark_failed "Environment Variable: $var - Not set"
        fi
    done
}

# Drucke Zusammenfassung
print_summary() {
    print_header "📊 Validation Summary"
    
    print_colored "$BLUE" "📋 Test Results:"
    print_colored "$GREEN" "✅ Passed: $PASSED_TESTS"
    print_colored "$RED" "❌ Failed: $FAILED_TESTS"
    print_colored "$BLUE" "📊 Total: $TOTAL_TESTS"
    
    local success_rate=0
    if [[ $TOTAL_TESTS -gt 0 ]]; then
        success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    fi
    
    print_colored "$BLUE" "📈 Success Rate: ${success_rate}%"
    print_colored "$BLUE" "📄 Log File: $LOG_FILE"
    
    if [[ $FAILED_TESTS -gt 0 ]]; then
        print_colored "$RED" "\n⚠️  Some tests failed. Check configuration and connectivity."
        exit 1
    else
        print_colored "$GREEN" "\n🎉 All tests passed! Configuration looks good."
        exit 0
    fi
}

# Cleanup-Funktion
cleanup() {
    print_colored "$YELLOW" "\n🧹 Cleaning up..."
    # Sensitive environment variables löschen
    unset PGPASSWORD 2>/dev/null || true
}

# Trap für Cleanup
trap cleanup EXIT

# Hauptprogramm
main() {
    print_header "🔐 Secrets & Configuration Validator"
    print_colored "$BLUE" "📅 Started: $(date)"
    print_colored "$BLUE" "📁 Working Directory: $(pwd)"
    print_colored "$BLUE" "📋 Log File: $LOG_FILE"
    
    # Abhängigkeiten prüfen
    print_colored "$YELLOW" "🔍 Checking dependencies..."
    local missing_deps=()
    
    for cmd in mysql psql redis-cli curl telnet ssh; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        print_colored "$YELLOW" "⚠️  Missing optional dependencies: ${missing_deps[*]}"
        print_colored "$YELLOW" "   Some tests will be skipped."
    fi
    
    # Tests ausführen
    load_environment
    validate_environment_vars
    validate_databases
    validate_services
    validate_smtp
    validate_ssh
    
    print_summary
}

# Script-Argumente verarbeiten
case "${1:-all}" in
    "databases"|"db")
        load_environment
        validate_databases
        print_summary
        ;;
    "services"|"endpoints")
        load_environment
        validate_services
        print_summary
        ;;
    "smtp"|"email")
        load_environment
        validate_smtp
        print_summary
        ;;
    "ssh")
        load_environment
        validate_ssh
        print_summary
        ;;
    "env"|"environment")
        load_environment
        validate_environment_vars
        print_summary
        ;;
    "all"|*)
        main
        ;;
esac