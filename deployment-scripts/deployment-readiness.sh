#!/bin/bash
###############################################################################
# Deployment Readiness Checker
# Validiert alle Voraussetzungen vor Deployment
###############################################################################

set -euo pipefail

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

check_passed=0
check_failed=0
check_warning=0

pass() { 
    echo -e "${GREEN}[✓]${NC} $1"
    ((check_passed++))
}

fail() { 
    echo -e "${RED}[✗]${NC} $1"
    ((check_failed++))
}

warn() { 
    echo -e "${YELLOW}[!]${NC} $1"
    ((check_warning++))
}

info() { echo -e "${BLUE}[i]${NC} $1"; }

###############################################################################
# 1. Git Repository Checks
###############################################################################
check_git_status() {
    info "=== Git Repository Checks ==="
    
    # Clean working directory
    if [[ -z $(git status --porcelain) ]]; then
        pass "Working directory is clean"
    else
        fail "Uncommitted changes detected"
        git status --short
    fi
    
    # Current branch
    local branch=$(git branch --show-current)
    info "Current branch: $branch"
    if [[ "$branch" == "main" ]] || [[ "$branch" == "master" ]]; then
        pass "On production-ready branch"
    else
        warn "Not on main/master branch"
    fi
    
    # Remote sync
    git fetch origin &>/dev/null
    local local_commit=$(git rev-parse HEAD)
    local remote_commit=$(git rev-parse origin/$branch 2>/dev/null || echo "")
    
    if [[ "$local_commit" == "$remote_commit" ]]; then
        pass "Local branch in sync with remote"
    else
        warn "Local branch differs from remote"
    fi
    
    # Tag exists
    if git describe --tags &>/dev/null; then
        local tag=$(git describe --tags)
        pass "Latest tag: $tag"
    else
        warn "No git tags found"
    fi
}

###############################################################################
# 2. Quality Gates
###############################################################################
check_quality_gates() {
    info "=== Quality Gates ==="
    
    # Codacy Analysis
    if [[ -f "quality-reports/codacy-analysis.sarif" ]]; then
        local issues=$(jq '.runs[0].results | length' quality-reports/codacy-analysis.sarif 2>/dev/null || echo "0")
        if [[ $issues -eq 0 ]]; then
            pass "Codacy: 0 issues"
        else
            fail "Codacy: $issues issues found"
        fi
    else
        warn "Codacy report not found - run: npm run quality:codacy"
    fi
    
    # ESLint
    if npm run lint:all &>/dev/null; then
        pass "ESLint: No errors"
    else
        fail "ESLint: Errors detected"
    fi
    
    # PHPStan (if applicable)
    if [[ -f "phpstan.neon" ]]; then
        if composer exec phpstan analyse &>/dev/null; then
            pass "PHPStan: No errors"
        else
            fail "PHPStan: Errors detected"
        fi
    fi
    
    # Test Coverage
    if [[ -f "coverage/coverage-summary.json" ]]; then
        local coverage=$(jq -r '.total.lines.pct' coverage/coverage-summary.json 2>/dev/null || echo "0")
        if (( $(awk -v cov="$coverage" 'BEGIN { if (cov >= 80) print 1; else print 0 }') )); then
            pass "Test Coverage: ${coverage}%"
        else
            warn "Test Coverage: ${coverage}% (target: 80%)"
        fi
    fi
}

###############################################################################
# 3. Security Checks
###############################################################################
check_security() {
    info "=== Security Checks ==="
    
    # Trivy Scan
    if [[ -f "quality-reports/trivy-security.sarif" ]]; then
        local vulns=$(jq '.runs[0].results | length' quality-reports/trivy-security.sarif 2>/dev/null || echo "0")
        if [[ $vulns -eq 0 ]]; then
            pass "Trivy: 0 vulnerabilities"
        else
            fail "Trivy: $vulns vulnerabilities found"
        fi
    else
        warn "Trivy report not found - run: npm run security:trivy"
    fi
    
    # Gitleaks Secret Scan
    if [[ -f "quality-reports/secrets-scan.json" ]]; then
        local secrets=$(jq '. | length' quality-reports/secrets-scan.json 2>/dev/null || echo "0")
        if [[ $secrets -eq 0 ]]; then
            pass "Gitleaks: No secrets detected"
        else
            fail "Gitleaks: $secrets secrets found!"
        fi
    else
        warn "Gitleaks report not found - run: gitleaks detect"
    fi
    
    # npm audit
    if npm audit --audit-level=high --json &>/dev/null; then
        pass "npm audit: No high/critical vulnerabilities"
    else
        fail "npm audit: Vulnerabilities detected"
    fi
    
    # Dependency check
    if command -v safety &>/dev/null; then
        if safety check &>/dev/null; then
            pass "Python dependencies: Secure"
        else
            fail "Python dependencies: Vulnerabilities found"
        fi
    fi
}

###############################################################################
# 4. DSGVO/Compliance
###############################################################################
check_dsgvo_compliance() {
    info "=== DSGVO Compliance ==="
    
    # PII in logs check
    if grep -r "email\|password\|ssn" logs/ 2>/dev/null | grep -v "email_sent" &>/dev/null; then
        fail "Potential PII found in logs!"
    else
        pass "No PII detected in logs"
    fi
    
    # Privacy Policy updated
    if [[ -f "website/privacy-policy.md" ]]; then
        local last_update=$(git log -1 --format="%cd" --date=short -- website/privacy-policy.md 2>/dev/null || echo "unknown")
        info "Privacy Policy last updated: $last_update"
        
        # Check if updated in last 6 months
        local six_months_ago=$(date -d "6 months ago" +%Y-%m-%d)
        if [[ "$last_update" > "$six_months_ago" ]]; then
            pass "Privacy Policy recently updated"
        else
            warn "Privacy Policy may need review (last update: $last_update)"
        fi
    fi
    
    # Cookie Consent Implementation
    if grep -r "cookie-consent" frontend/src/ &>/dev/null; then
        pass "Cookie consent implementation found"
    else
        warn "Cookie consent implementation not detected"
    fi
}

###############################################################################
# 5. Performance Benchmarks
###############################################################################
check_performance() {
    info "=== Performance Benchmarks ==="
    
    # Lighthouse scores
    if [[ -f "lighthouse-report.json" ]]; then
        local perf=$(jq -r '.categories.performance.score * 100' lighthouse-report.json 2>/dev/null || echo "0")
        local a11y=$(jq -r '.categories.accessibility.score * 100' lighthouse-report.json 2>/dev/null || echo "0")
        local seo=$(jq -r '.categories.seo.score * 100' lighthouse-report.json 2>/dev/null || echo "0")
        
        if (( $(awk -v score="$perf" 'BEGIN { if (score >= 90) print 1; else print 0 }') )); then
            pass "Lighthouse Performance: $perf"
        else
            fail "Lighthouse Performance: $perf (target: ≥90)"
        fi
        
        if (( $(awk -v score="$a11y" 'BEGIN { if (score >= 90) print 1; else print 0 }') )); then
            pass "Lighthouse Accessibility: $a11y"
        else
            fail "Lighthouse Accessibility: $a11y (target: ≥90)"
        fi
        
        if (( $(awk -v score="$seo" 'BEGIN { if (score >= 90) print 1; else print 0 }') )); then
            pass "Lighthouse SEO: $seo"
        else
            warn "Lighthouse SEO: $seo (target: ≥90)"
        fi
    else
        warn "Lighthouse report not found - run: npm run performance:lighthouse"
    fi
    
    # Bundle size
    if [[ -d "frontend/dist" ]]; then
        local bundle_size=$(du -sh frontend/dist | awk '{print $1}')
        info "Frontend bundle size: $bundle_size"
        
        local bundle_bytes=$(du -sb frontend/dist | awk '{print $1}')
        if [[ $bundle_bytes -lt 204800 ]]; then  # 200KB
            pass "Bundle size within limits"
        else
            warn "Bundle size exceeds 200KB"
        fi
    fi
}

###############################################################################
# 6. Database Checks
###############################################################################
check_database() {
    info "=== Database Checks ==="
    
    # Prisma migrations
    if command -v npx &>/dev/null; then
        if npx prisma migrate status &>/dev/null; then
            pass "Prisma migrations up to date"
        else
            warn "Pending Prisma migrations detected"
        fi
    fi
    
    # Database connection (if credentials available)
    if [[ -n "${DATABASE_URL:-}" ]]; then
        if command -v psql &>/dev/null; then
            if psql "$DATABASE_URL" -c "SELECT 1;" &>/dev/null; then
                pass "Database connection successful"
            else
                fail "Database connection failed"
            fi
        fi
    else
        warn "DATABASE_URL not set - cannot test connection"
    fi
    
    # Backup exists
    if [[ -d "backups" ]] && [[ -n "$(ls -A backups/ 2>/dev/null)" ]]; then
        local latest_backup=$(ls -t backups/*.dump 2>/dev/null | head -1)
        if [[ -n "$latest_backup" ]]; then
            local backup_age=$(( ($(date +%s) - $(stat -c %Y "$latest_backup")) / 86400 ))
            if [[ $backup_age -lt 7 ]]; then
                pass "Recent database backup exists (${backup_age}d old)"
            else
                warn "Latest backup is ${backup_age} days old"
            fi
        fi
    else
        warn "No database backups found"
    fi
}

###############################################################################
# 7. Environment Configuration
###############################################################################
check_environment() {
    info "=== Environment Configuration ==="
    
    # Required env files
    local env_files=(
        "api.menschlichkeit-oesterreich.at/.env.production"
        "frontend/.env.production"
        "crm.menschlichkeit-oesterreich.at/sites/default/settings.php"
    )
    
    for env_file in "${env_files[@]}"; do
        if [[ -f "$env_file" ]]; then
            pass "Config exists: $env_file"
        else
            fail "Missing config: $env_file"
        fi
    done
    
    # No .env in git
    if git ls-files | grep -q "\.env$"; then
        fail ".env files tracked in git!"
    else
        pass "No .env files in git"
    fi
    
    # Node version
    local node_version=$(node --version 2>/dev/null || echo "not found")
    info "Node.js version: $node_version"
    if [[ "$node_version" =~ ^v(1[8-9]|2[0-9]) ]]; then
        pass "Node.js version compatible"
    else
        warn "Node.js version may be incompatible"
    fi
}

###############################################################################
# 8. Service Dependencies
###############################################################################
check_dependencies() {
    info "=== Service Dependencies ==="
    
    # Docker
    if command -v docker &>/dev/null; then
        if docker ps &>/dev/null; then
            pass "Docker available and running"
        else
            warn "Docker installed but not running"
        fi
    else
        warn "Docker not installed"
    fi
    
    # PostgreSQL
    if command -v psql &>/dev/null; then
        pass "PostgreSQL client available"
    else
        warn "PostgreSQL client not installed"
    fi
    
    # PHP (for CRM)
    if command -v php &>/dev/null; then
        local php_version=$(php --version | head -1 | awk '{print $2}')
        info "PHP version: $php_version"
        if [[ "$php_version" =~ ^8\. ]]; then
            pass "PHP version compatible"
        else
            warn "PHP version may be incompatible"
        fi
    else
        warn "PHP not installed"
    fi
    
    # Python (for API)
    if command -v python3 &>/dev/null; then
        local python_version=$(python3 --version | awk '{print $2}')
        info "Python version: $python_version"
        pass "Python available"
    else
        fail "Python3 not installed"
    fi
}

###############################################################################
# 9. CI/CD Integration
###############################################################################
check_cicd() {
    info "=== CI/CD Integration ==="
    
    # GitHub Actions
    if [[ -d ".github/workflows" ]]; then
        local workflow_count=$(ls .github/workflows/*.yml 2>/dev/null | wc -l)
        pass "GitHub Actions workflows: $workflow_count"
    else
        warn "No GitHub Actions workflows found"
    fi
    
    # n8n Workflows
    if [[ -d "automation/n8n/workflows" ]]; then
        local n8n_count=$(ls automation/n8n/workflows/*.json 2>/dev/null | wc -l)
        pass "n8n workflows: $n8n_count"
    fi
    
    # Deployment scripts
    local deploy_scripts=(
        "deployment-scripts/multi-service-deploy.sh"
        "deployment-scripts/blue-green-deploy.sh"
        "deployment-scripts/rollback.sh"
    )
    
    for script in "${deploy_scripts[@]}"; do
        if [[ -f "$script" ]] && [[ -x "$script" ]]; then
            pass "Deployment script: $script"
        else
            warn "Missing or not executable: $script"
        fi
    done
}

###############################################################################
# Summary & Report
###############################################################################
generate_summary() {
    echo ""
    info "=========================================="
    info "Deployment Readiness Summary"
    info "=========================================="
    echo -e "${GREEN}Passed:${NC} $check_passed"
    echo -e "${YELLOW}Warnings:${NC} $check_warning"
    echo -e "${RED}Failed:${NC} $check_failed"
    info "=========================================="
    
    if [[ $check_failed -eq 0 ]]; then
        echo -e "${GREEN}✓ DEPLOYMENT READY${NC}"
        echo ""
        echo "Next steps:"
        echo "  1. Review warnings above"
        echo "  2. Run: ./deployment-scripts/multi-service-deploy.sh staging"
        echo "  3. Monitor: ./deployment-scripts/deployment-monitoring.sh"
        return 0
    else
        echo -e "${RED}✗ DEPLOYMENT BLOCKED${NC}"
        echo ""
        echo "Fix the following issues before deploying:"
        echo "  - $check_failed critical issues detected"
        echo "  - Review failed checks above"
        return 1
    fi
}

###############################################################################
# Main Execution
###############################################################################
main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║  Deployment Readiness Checker            ║"
    echo "║  Menschlichkeit Österreich Platform      ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
    
    check_git_status
    echo ""
    check_quality_gates
    echo ""
    check_security
    echo ""
    check_dsgvo_compliance
    echo ""
    check_performance
    echo ""
    check_database
    echo ""
    check_environment
    echo ""
    check_dependencies
    echo ""
    check_cicd
    echo ""
    
    generate_summary
}

# Ausführung
main "$@"
