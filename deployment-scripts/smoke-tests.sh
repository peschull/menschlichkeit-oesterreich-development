#!/bin/bash
###############################################################################
# Smoke Tests für Post-Deployment Validation
# Kritische User-Flows testen nach Deployment
###############################################################################

set -euo pipefail

# Source utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/deployment-config.sh"
source "$SCRIPT_DIR/health-check-utils.sh"

ENVIRONMENT="${1:-production}"
SMOKE_TEST_REPORT="quality-reports/smoke-tests-$(date +%Y%m%d_%H%M%S).md"

# Test counters
TESTS_TOTAL=0
TESTS_PASSED=0
TESTS_FAILED=0

###############################################################################
# Test Helpers
###############################################################################
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    ((TESTS_TOTAL++))
    
    log "Running test: $test_name"
    
    if eval "$test_command"; then
        success "✓ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        error "✗ $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

###############################################################################
# API Smoke Tests
###############################################################################
test_api_health() {
    local api_url="$API_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && api_url="$STAGING_API_URL"
    
    curl -f -s -m 5 "$api_url/health" | jq -e '.status == "ok"' &>/dev/null
}

test_api_version() {
    local api_url="$API_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && api_url="$STAGING_API_URL"
    
    curl -f -s -m 5 "$api_url/version" | jq -e '.version' &>/dev/null
}

test_api_database_connection() {
    local api_url="$API_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && api_url="$STAGING_API_URL"
    
    curl -f -s -m 5 "$api_url/health/db" | jq -e '.database == "connected"' &>/dev/null
}

###############################################################################
# CRM Smoke Tests
###############################################################################
test_crm_home() {
    local crm_url="$CRM_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && crm_url="$STAGING_CRM_URL"
    
    check_http_health "$crm_url" 10 200
}

test_crm_login_page() {
    local crm_url="$CRM_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && crm_url="$STAGING_CRM_URL"
    
    curl -f -s -m 10 "$crm_url/user/login" | grep -q "login" || grep -q "anmelden"
}

test_crm_civicrm() {
    local crm_url="$CRM_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && crm_url="$STAGING_CRM_URL"
    
    # Check if CiviCRM is accessible (even if redirects to login)
    curl -s -m 10 "$crm_url/civicrm" -w "%{http_code}" | grep -qE "200|302|303"
}

###############################################################################
# Frontend Smoke Tests
###############################################################################
test_frontend_home() {
    local frontend_url="$FRONTEND_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && frontend_url="$STAGING_FRONTEND_URL"
    
    check_http_health "$frontend_url" 10 200
}

test_frontend_static_assets() {
    local frontend_url="$FRONTEND_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && frontend_url="$STAGING_FRONTEND_URL"
    
    # Check if main CSS/JS loads
    local html
    html=$(curl -f -s -m 10 "$frontend_url")
    
    echo "$html" | grep -qE '<link.*\.css|<script.*\.js'
}

test_frontend_meta_tags() {
    local frontend_url="$FRONTEND_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && frontend_url="$STAGING_FRONTEND_URL"
    
    local html
    html=$(curl -f -s -m 10 "$frontend_url")
    
    # Check for basic SEO meta tags
    echo "$html" | grep -qE '<title>.*Menschlichkeit|<meta.*description'
}

###############################################################################
# Database Smoke Tests
###############################################################################
test_database_connection() {
    check_database_health "$DATABASE_URL"
}

test_database_migrations() {
    # Check if all migrations are applied
    if command -v npx &>/dev/null; then
        npx prisma migrate status 2>&1 | grep -q "Database is up to date"
    else
        warn "Prisma not available, skipping migration check"
        return 0
    fi
}

test_database_critical_tables() {
    # Check if critical tables exist
    local tables=("User" "Achievement" "GameSession")
    
    for table in "${tables[@]}"; do
        if ! psql "$DATABASE_URL" -t -c "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = '$table');" | grep -q "t"; then
            error "Critical table missing: $table"
            return 1
        fi
    done
    
    return 0
}

###############################################################################
# Security Smoke Tests
###############################################################################
test_https_redirect() {
    local domain="menschlichkeit-oesterreich.at"
    [[ "$ENVIRONMENT" == "staging" ]] && domain="staging.menschlichkeit-oesterreich.at"
    
    # Check if HTTP redirects to HTTPS
    local response
    response=$(curl -s -I -m 5 "http://$domain" | head -n 1)
    
    echo "$response" | grep -qE "301|302"
}

test_security_headers() {
    local frontend_url="$FRONTEND_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && frontend_url="$STAGING_FRONTEND_URL"
    
    local headers
    headers=$(curl -s -I -m 5 "$frontend_url")
    
    # Check for basic security headers
    echo "$headers" | grep -iq "X-Content-Type-Options" && \
    echo "$headers" | grep -iq "X-Frame-Options"
}

test_no_sensitive_data_exposed() {
    local api_url="$API_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && api_url="$STAGING_API_URL"
    
    local response
    response=$(curl -s -m 5 "$api_url/health")
    
    # Ensure no credentials or sensitive data in health endpoint
    ! echo "$response" | grep -qiE "password|secret|token|key"
}

###############################################################################
# Performance Smoke Tests
###############################################################################
test_api_response_time() {
    local api_url="$API_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && api_url="$STAGING_API_URL"
    
    local response_time
    response_time=$(measure_response_time "$api_url/health")
    
    # Should be under 500ms
    (( $(echo "$response_time < 0.5" | bc -l) ))
}

test_frontend_load_time() {
    local frontend_url="$FRONTEND_URL"
    [[ "$ENVIRONMENT" == "staging" ]] && frontend_url="$STAGING_FRONTEND_URL"
    
    local load_time
    load_time=$(measure_response_time "$frontend_url")
    
    # Should be under 2 seconds
    (( $(echo "$load_time < 2.0" | bc -l) ))
}

###############################################################################
# Main Test Suite
###############################################################################
main() {
    log "🧪 Starting Smoke Tests for $ENVIRONMENT environment"
    echo ""
    
    # API Tests
    echo "=== API Service Tests ==="
    run_test "API Health Endpoint" "test_api_health"
    run_test "API Version Endpoint" "test_api_version"
    run_test "API Database Connection" "test_api_database_connection"
    run_test "API Response Time" "test_api_response_time"
    echo ""
    
    # CRM Tests
    echo "=== CRM Service Tests ==="
    run_test "CRM Home Page" "test_crm_home"
    run_test "CRM Login Page" "test_crm_login_page"
    run_test "CiviCRM Accessible" "test_crm_civicrm"
    echo ""
    
    # Frontend Tests
    echo "=== Frontend Tests ==="
    run_test "Frontend Home Page" "test_frontend_home"
    run_test "Static Assets Load" "test_frontend_static_assets"
    run_test "Meta Tags Present" "test_frontend_meta_tags"
    run_test "Frontend Load Time" "test_frontend_load_time"
    echo ""
    
    # Database Tests
    echo "=== Database Tests ==="
    run_test "Database Connection" "test_database_connection"
    run_test "Database Migrations" "test_database_migrations"
    run_test "Critical Tables Exist" "test_database_critical_tables"
    echo ""
    
    # Security Tests
    echo "=== Security Tests ==="
    run_test "HTTPS Redirect" "test_https_redirect"
    run_test "Security Headers" "test_security_headers"
    run_test "No Sensitive Data Exposed" "test_no_sensitive_data_exposed"
    echo ""
    
    # Summary
    echo "========================================"
    echo "SMOKE TEST RESULTS"
    echo "========================================"
    echo "Total Tests:  $TESTS_TOTAL"
    echo "Passed:       $TESTS_PASSED ($(( TESTS_PASSED * 100 / TESTS_TOTAL ))%)"
    echo "Failed:       $TESTS_FAILED"
    echo "========================================"
    
    # Generate Report
    generate_report
    
    # Exit code
    if [[ $TESTS_FAILED -eq 0 ]]; then
        success "All smoke tests passed! ✓"
        return 0
    else
        error "Some smoke tests failed! ✗"
        return 1
    fi
}

###############################################################################
# Report Generation
###############################################################################
generate_report() {
    cat > "$SMOKE_TEST_REPORT" <<EOF
# Smoke Test Report

**Date:** $(date +'%Y-%m-%d %H:%M:%S')  
**Environment:** $ENVIRONMENT  
**Status:** $([ $TESTS_FAILED -eq 0 ] && echo "✅ PASSED" || echo "❌ FAILED")

---

## Summary

| Metric | Value |
|--------|-------|
| Total Tests | $TESTS_TOTAL |
| Passed | $TESTS_PASSED ($(( TESTS_PASSED * 100 / TESTS_TOTAL ))%) |
| Failed | $TESTS_FAILED |

---

## Test Categories

### API Service Tests
- Health Endpoint
- Version Endpoint
- Database Connection
- Response Time

### CRM Service Tests
- Home Page
- Login Page
- CiviCRM Access

### Frontend Tests
- Home Page
- Static Assets
- Meta Tags
- Load Time

### Database Tests
- Connection
- Migrations Status
- Critical Tables

### Security Tests
- HTTPS Redirect
- Security Headers
- Sensitive Data Exposure

---

## Next Steps

$(if [[ $TESTS_FAILED -eq 0 ]]; then
    echo "✅ All smoke tests passed. Deployment validated successfully."
    echo ""
    echo "Recommended actions:"
    echo "- Start post-deployment monitoring: \`npm run deploy:monitor\`"
    echo "- Run full E2E test suite: \`npm run test:e2e\`"
    echo "- Verify analytics and logging"
else
    echo "❌ Some smoke tests failed. Immediate action required!"
    echo ""
    echo "Recommended actions:"
    echo "- Review failed tests above"
    echo "- Check service logs for errors"
    echo "- Consider rollback if critical: \`npm run deploy:rollback\`"
fi)

---

**Report Location:** $SMOKE_TEST_REPORT
EOF

    log "Report generated: $SMOKE_TEST_REPORT"
}

# Run tests
main "$@"
