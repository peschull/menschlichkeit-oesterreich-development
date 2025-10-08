#!/bin/bash
###############################################################################
# Comprehensive Script Analysis & Debugging Tool
# Menschlichkeit Österreich - Multi-Service Platform
###############################################################################

# Don't exit on errors - we want to report all findings
set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Counters
TOTAL_SCRIPTS=0
PASSED_SCRIPTS=0
FAILED_SCRIPTS=0
TOTAL_PYTHON=0
PASSED_PYTHON=0
FAILED_PYTHON=0

# Report file
REPORT_DIR="quality-reports"
REPORT_FILE="$REPORT_DIR/script-analysis-$(date +%Y%m%d_%H%M%S).md"

mkdir -p "$REPORT_DIR"

###############################################################################
# Helper Functions
###############################################################################

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $*"
}

success() {
    echo -e "${GREEN}✅ $*${NC}"
}

warn() {
    echo -e "${YELLOW}⚠️  $*${NC}"
}

error() {
    echo -e "${RED}❌ $*${NC}"
}

info() {
    echo -e "${CYAN}ℹ️  $*${NC}"
}

header() {
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BOLD}${MAGENTA} $*${NC}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${NC}"
    echo ""
}

write_report() {
    echo "$*" >> "$REPORT_FILE"
}

###############################################################################
# Analysis Functions
###############################################################################

analyze_bash_scripts() {
    header "🔍 BASH SCRIPT ANALYSIS"
    
    # Initialize counters
    local TOTAL_SCRIPTS=0
    local PASSED_SCRIPTS=0
    local FAILED_SCRIPTS=0
    
    write_report "# Bash Script Analysis Report"
    write_report ""
    write_report "**Generated:** $(date)"
    write_report ""
    write_report "## Summary"
    write_report ""
    
    log "Searching for all .sh files..."
    
    write_report "| Script | Status | Issues | Executable |"
    write_report "|--------|--------|--------|------------|"
    
    # Find all .sh files
    while IFS= read -r script; do
        if [[ -f "$script" ]]; then
                ((TOTAL_SCRIPTS++))
                
                local basename=$(basename "$script")
                local issues=""
                local status="✅ PASS"
                local executable="✅"
                
                # Syntax check (disable errexit temporarily)
                set +e
                if bash -n "$script" 2>/dev/null; then
                    ((PASSED_SCRIPTS++))
                else
                    ((FAILED_SCRIPTS++))
                    status="❌ FAIL"
                    issues="Syntax Error"
                    error "$script: Syntax error detected"
                fi
                set -e
                
                # Executable check
                if [[ ! -x "$script" ]]; then
                    executable="❌"
                    warn "$script: Not executable"
                else
                    success "$script: OK"
                fi
                
                write_report "| $basename | $status | $issues | $executable |"
            fi
    done < <(find . -type f -name "*.sh" 2>/dev/null)
    
    write_report ""
    write_report "**Total:** $TOTAL_SCRIPTS scripts"
    write_report "**Passed:** $PASSED_SCRIPTS"
    write_report "**Failed:** $FAILED_SCRIPTS"
    write_report ""
    
    info "Bash scripts analyzed: $TOTAL_SCRIPTS (Passed: $PASSED_SCRIPTS, Failed: $FAILED_SCRIPTS)"
}

analyze_python_scripts() {
    header "🐍 PYTHON SCRIPT ANALYSIS"
    
    write_report "## Python Script Analysis"
    write_report ""
    write_report "| Script | Syntax | Type Hints | Docstrings | Complexity |"
    write_report "|--------|--------|------------|------------|------------|"
    
    log "Analyzing Python scripts..."
    
    local py_patterns=(
        "scripts/*.py"
        "automation/n8n/*.py"
        "automation/privacy/*.py"
        "tests/*.py"
    )
    
    for pattern in "${py_patterns[@]}"; do
        for script in $pattern; do
            if [[ -f "$script" ]]; then
                ((TOTAL_PYTHON++))
                
                local basename=$(basename "$script")
                local syntax="❌"
                local hints="?"
                local docs="?"
                local complexity="?"
                
                # Syntax check (disable errexit temporarily)
                set +e
                if python3 -m py_compile "$script" 2>/dev/null; then
                    syntax="✅"
                    ((PASSED_PYTHON++))
                    success "$script: Syntax OK"
                else
                    ((FAILED_PYTHON++))
                    error "$script: Syntax error"
                fi
                set -e
                
                # Check for type hints
                if grep -q "def.*->.*:" "$script" || grep -q ": str\|: int\|: float\|: bool\|: Dict\|: List" "$script"; then
                    hints="✅"
                else
                    hints="❌"
                fi
                
                # Check for docstrings
                if grep -q '"""' "$script" || grep -q "'''" "$script"; then
                    docs="✅"
                else
                    docs="❌"
                fi
                
                # Estimate complexity (very simple: line count)
                local lines=$(wc -l < "$script")
                if [[ $lines -lt 200 ]]; then
                    complexity="Low"
                elif [[ $lines -lt 500 ]]; then
                    complexity="Medium"
                else
                    complexity="High"
                fi
                
                write_report "| $basename | $syntax | $hints | $docs | $complexity |"
            fi
        done
    done
    
    write_report ""
    write_report "**Total:** $TOTAL_PYTHON scripts"
    write_report "**Passed:** $PASSED_PYTHON"
    write_report "**Failed:** $FAILED_PYTHON"
    write_report ""
    
    info "Python scripts analyzed: $TOTAL_PYTHON (Passed: $PASSED_PYTHON, Failed: $FAILED_PYTHON)"
}

analyze_deployment_scripts() {
    header "🚀 DEPLOYMENT SCRIPTS ANALYSIS"
    
    write_report "## Deployment Scripts Details"
    write_report ""
    
    local deploy_scripts=(
        "deployment-scripts/multi-service-deploy.sh"
        "deployment-scripts/blue-green-deploy.sh"
        "deployment-scripts/deployment-monitoring.sh"
        "deployment-scripts/rollback.sh"
        "deployment-scripts/deployment-readiness.sh"
        "deployment-scripts/deployment-dashboard.sh"
        "deployment-scripts/smoke-tests.sh"
        "deployment-scripts/health-check-utils.sh"
        "deployment-scripts/deployment-config.sh"
        "deployment-scripts/setup-environment.sh"
    )
    
    write_report "### Critical Deployment Scripts"
    write_report ""
    
    for script in "${deploy_scripts[@]}"; do
        if [[ -f "$script" ]]; then
            local basename=$(basename "$script")
            local lines=$(wc -l < "$script")
            local functions=$(grep -c "^function\|^[a-zA-Z_][a-zA-Z0-9_]*() {" "$script" || echo 0)
            local todos=$(grep -c "# TODO\|# FIXME\|# XXX" "$script" || echo 0)
            
            write_report "#### $basename"
            write_report "- **Lines:** $lines"
            write_report "- **Functions:** $functions"
            write_report "- **TODOs:** $todos"
            
            # Check for critical patterns
            if grep -q "set -euo pipefail" "$script"; then
                write_report "- **Error Handling:** ✅ Strict mode enabled"
            else
                write_report "- **Error Handling:** ⚠️ No strict mode"
            fi
            
            if grep -q "trap.*EXIT\|trap.*ERR" "$script"; then
                write_report "- **Cleanup:** ✅ Trap handlers present"
            else
                write_report "- **Cleanup:** ⚠️ No trap handlers"
            fi
            
            write_report ""
        else
            warn "$script not found"
        fi
    done
}

analyze_security_patterns() {
    header "🔒 SECURITY PATTERN ANALYSIS"
    
    write_report "## Security Analysis"
    write_report ""
    write_report "### Potential Security Issues"
    write_report ""
    
    local issues_found=0
    
    # Check for hardcoded secrets
    log "Checking for hardcoded secrets..."
    if grep -r "password\s*=\s*['\"]" scripts/ deployment-scripts/ 2>/dev/null | grep -v ".git" | grep -v "test_" | grep -v "example" > /dev/null; then
        ((issues_found++))
        warn "Found potential hardcoded passwords"
        write_report "- ⚠️ **Hardcoded passwords detected**"
    fi
    
    # Check for API keys
    if grep -r "api_key\s*=\s*['\"]" scripts/ deployment-scripts/ 2>/dev/null | grep -v ".git" | grep -v "test_" | grep -v "example" > /dev/null; then
        ((issues_found++))
        warn "Found potential hardcoded API keys"
        write_report "- ⚠️ **Hardcoded API keys detected**"
    fi
    
    # Check for eval usage
    if grep -r "eval " scripts/ deployment-scripts/ 2>/dev/null | grep -v ".git" > /dev/null; then
        ((issues_found++))
        warn "Found 'eval' usage (potential security risk)"
        write_report "- ⚠️ **'eval' usage detected (security risk)**"
    fi
    
    # Check for curl without SSL verification
    if grep -r "curl.*-k\|curl.*--insecure" scripts/ deployment-scripts/ 2>/dev/null | grep -v ".git" > /dev/null; then
        ((issues_found++))
        warn "Found curl with SSL verification disabled"
        write_report "- ⚠️ **curl with disabled SSL verification**"
    fi
    
    if [[ $issues_found -eq 0 ]]; then
        success "No major security issues detected"
        write_report "- ✅ **No major security issues detected**"
    fi
    
    write_report ""
}

analyze_code_quality() {
    header "📊 CODE QUALITY METRICS"
    
    write_report "## Code Quality Metrics"
    write_report ""
    
    # Total lines of code
    local total_bash_lines=$(find scripts deployment-scripts -name "*.sh" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    local total_python_lines=$(find scripts automation tests -name "*.py" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    
    write_report "| Metric | Value |"
    write_report "|--------|-------|"
    write_report "| Bash Scripts | $TOTAL_SCRIPTS |"
    write_report "| Bash LOC | $total_bash_lines |"
    write_report "| Python Scripts | $TOTAL_PYTHON |"
    write_report "| Python LOC | $total_python_lines |"
    write_report "| Total LOC | $((total_bash_lines + total_python_lines)) |"
    write_report ""
    
    info "Total Lines of Code: $((total_bash_lines + total_python_lines))"
}

test_critical_scripts() {
    header "🧪 TESTING CRITICAL SCRIPTS"
    
    write_report "## Critical Script Tests"
    write_report ""
    
    # Test deployment config
    log "Testing deployment-config.sh..."
    if source deployment-scripts/deployment-config.sh 2>/dev/null; then
        success "deployment-config.sh: Loads successfully"
        write_report "- ✅ deployment-config.sh loads correctly"
    else
        error "deployment-config.sh: Failed to load"
        write_report "- ❌ deployment-config.sh load failed"
    fi
    
    # Test health check utils
    log "Testing health-check-utils.sh..."
    if source deployment-scripts/health-check-utils.sh 2>/dev/null; then
        success "health-check-utils.sh: Loads successfully"
        write_report "- ✅ health-check-utils.sh loads correctly"
        
        # Test if key functions are defined
        if declare -f check_http_health >/dev/null; then
            success "check_http_health function defined"
            write_report "  - ✅ check_http_health function available"
        fi
    else
        error "health-check-utils.sh: Failed to load"
        write_report "- ❌ health-check-utils.sh load failed"
    fi
    
    write_report ""
}

generate_recommendations() {
    header "💡 RECOMMENDATIONS"
    
    write_report "## Recommendations"
    write_report ""
    
    write_report "### High Priority"
    write_report ""
    
    if [[ $FAILED_SCRIPTS -gt 0 ]]; then
        write_report "- 🔴 **Fix $FAILED_SCRIPTS failing bash scripts**"
    fi
    
    if [[ $FAILED_PYTHON -gt 0 ]]; then
        write_report "- 🔴 **Fix $FAILED_PYTHON failing Python scripts**"
    fi
    
    write_report ""
    write_report "### Medium Priority"
    write_report ""
    write_report "- 🟡 Add comprehensive error handling to all scripts"
    write_report "- 🟡 Implement logging framework across all scripts"
    write_report "- 🟡 Add integration tests for deployment scripts"
    write_report ""
    
    write_report "### Low Priority"
    write_report ""
    write_report "- 🟢 Add type hints to all Python functions"
    write_report "- 🟢 Improve documentation and docstrings"
    write_report "- 🟢 Standardize naming conventions"
    write_report ""
}

###############################################################################
# Main Execution
###############################################################################

main() {
    clear
    
    header "🔬 COMPREHENSIVE SCRIPT ANALYSIS"
    info "Analyzing all scripts in the Menschlichkeit Österreich codebase"
    echo ""
    
    # Run analyses
    analyze_bash_scripts
    analyze_python_scripts
    analyze_deployment_scripts
    analyze_security_patterns
    analyze_code_quality
    test_critical_scripts
    generate_recommendations
    
    # Final summary
    header "📋 ANALYSIS COMPLETE"
    
    echo ""
    echo -e "${BOLD}Summary:${NC}"
    echo -e "  Bash Scripts:   $PASSED_SCRIPTS/$TOTAL_SCRIPTS passed"
    echo -e "  Python Scripts: $PASSED_PYTHON/$TOTAL_PYTHON passed"
    echo ""
    echo -e "${BOLD}Report saved to:${NC} $REPORT_FILE"
    echo ""
    
    if [[ $FAILED_SCRIPTS -gt 0 ]] || [[ $FAILED_PYTHON -gt 0 ]]; then
        warn "Some scripts have issues. Please review the report."
        return 1
    else
        success "All scripts passed basic validation!"
        return 0
    fi
}

# Run main
main "$@"
