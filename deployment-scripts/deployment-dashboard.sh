#!/bin/bash
###############################################################################
# Interactive Deployment Dashboard
# Terminal UI für Deployment Management
###############################################################################

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Emoji (falls Terminal unterstützt)
CHECK="✓"
CROSS="✗"
WARN="!"
ROCKET="🚀"
GEAR="⚙️"
CHART="📊"
SHIELD="🛡️"
ROLLBACK="🔙"

clear

###############################################################################
# Header
###############################################################################
show_header() {
    echo -e "${BLUE}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           🚀 DEPLOYMENT DASHBOARD                            ║"
    echo "║           Menschlichkeit Österreich Platform                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

###############################################################################
# Status Display
###############################################################################
show_status() {
    echo -e "${CYAN}${BOLD}📊 Current System Status${NC}"
    echo "════════════════════════════════════════════════════════════════"
    
    # Git Status
    local branch=$(git branch --show-current)
    local commit=$(git rev-parse --short HEAD)
    local tag=$(git describe --tags --always 2>/dev/null || echo "no tags")
    
    echo -e "${BOLD}Git:${NC}"
    echo -e "  Branch:  ${GREEN}$branch${NC}"
    echo -e "  Commit:  $commit"
    echo -e "  Tag:     $tag"
    
    if [[ -z $(git status --porcelain) ]]; then
        echo -e "  Status:  ${GREEN}${CHECK} Clean${NC}"
    else
        echo -e "  Status:  ${YELLOW}${WARN} Uncommitted changes${NC}"
    fi
    echo ""
    
    # Service Health
    echo -e "${BOLD}Services:${NC}"
    
    declare -A services=(
        ["API"]="http://localhost:8001/health"
        ["CRM"]="http://localhost:8000"
        ["Frontend"]="http://localhost:3000"
    )
    
    for service in "${!services[@]}"; do
        if curl -f -m 2 "${services[$service]}" &>/dev/null; then
            echo -e "  $service: ${GREEN}${CHECK} Running${NC}"
        else
            echo -e "  $service: ${RED}${CROSS} Stopped${NC}"
        fi
    done
    echo ""
    
    # Quality Gates
    echo -e "${BOLD}Quality Gates:${NC}"
    
    if [[ -f "quality-reports/codacy-analysis.sarif" ]]; then
        local issues=$(jq '.runs[0].results | length' quality-reports/codacy-analysis.sarif 2>/dev/null || echo "?")
        if [[ "$issues" == "0" ]]; then
            echo -e "  Codacy:     ${GREEN}${CHECK} $issues issues${NC}"
        else
            echo -e "  Codacy:     ${YELLOW}${WARN} $issues issues${NC}"
        fi
    else
        echo -e "  Codacy:     ${YELLOW}${WARN} Not run${NC}"
    fi
    
    if [[ -f "quality-reports/trivy-security.sarif" ]]; then
        local vulns=$(jq '.runs[0].results | length' quality-reports/trivy-security.sarif 2>/dev/null || echo "?")
        if [[ "$vulns" == "0" ]]; then
            echo -e "  Security:   ${GREEN}${CHECK} $vulns vulnerabilities${NC}"
        else
            echo -e "  Security:   ${RED}${CROSS} $vulns vulnerabilities${NC}"
        fi
    else
        echo -e "  Security:   ${YELLOW}${WARN} Not run${NC}"
    fi
    
    echo ""
    echo "════════════════════════════════════════════════════════════════"
    echo ""
}

###############################################################################
# Main Menu
###############################################################################
show_menu() {
    echo -e "${MAGENTA}${BOLD}Select Action:${NC}"
    echo ""
    echo "  ${BOLD}Pre-Deployment:${NC}"
    echo "    1) ${SHIELD} Run Deployment Readiness Check"
    echo "    2) ${GEAR} Run Quality Gates"
    echo "    3) ${SHIELD} Run Security Scan"
    echo ""
    echo "  ${BOLD}Deployment:${NC}"
    echo "    4) ${ROCKET} Deploy to Staging"
    echo "    5) ${ROCKET} Deploy to Production"
    echo "    6) ${ROCKET} Blue-Green Deployment (Zero-Downtime)"
    echo ""
    echo "  ${BOLD}Monitoring:${NC}"
    echo "    7) ${CHART} Start Post-Deployment Monitoring"
    echo "    8) ${CHART} Run E2E Tests"
    echo "    9) ${CHART} Performance Audit (Lighthouse)"
    echo ""
    echo "  ${BOLD}Emergency:${NC}"
    echo "    10) ${ROLLBACK} Rollback to Previous Version"
    echo "    11) ${ROLLBACK} Rollback to Specific Version"
    echo ""
    echo "  ${BOLD}Utilities:${NC}"
    echo "    12) 📋 View Latest Deployment Report"
    echo "    13) 📊 View System Metrics"
    echo "    14) 🔄 Refresh Status"
    echo ""
    echo "    0) Exit"
    echo ""
    echo -n "Enter choice [0-14]: "
}

###############################################################################
# Action Handlers
###############################################################################

action_readiness() {
    echo -e "\n${BLUE}${BOLD}Running Deployment Readiness Check...${NC}\n"
    bash deployment-scripts/deployment-readiness.sh
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_quality_gates() {
    echo -e "\n${BLUE}${BOLD}Running Quality Gates...${NC}\n"
    npm run quality:gates
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_security_scan() {
    echo -e "\n${BLUE}${BOLD}Running Security Scan...${NC}\n"
    npm run security:scan
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_deploy_staging() {
    echo -e "\n${YELLOW}${BOLD}⚠️  Deploying to STAGING...${NC}\n"
    
    echo -n "Are you sure? (yes/no): "
    read confirm
    
    if [[ "$confirm" == "yes" ]]; then
        npm run deploy:staging
    else
        echo "Deployment cancelled."
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_deploy_production() {
    echo -e "\n${RED}${BOLD}⚠️  DEPLOYING TO PRODUCTION!${NC}\n"
    
    # Safety checks
    if [[ $(git branch --show-current) != "main" ]]; then
        echo -e "${RED}ERROR: Not on 'main' branch. Production deployments must be from main.${NC}"
        echo -e "\n${GREEN}Press Enter to continue...${NC}"
        read
        return
    fi
    
    echo -e "${YELLOW}This will deploy to PRODUCTION environment.${NC}"
    echo -n "Type 'DEPLOY' to confirm: "
    read confirm
    
    if [[ "$confirm" == "DEPLOY" ]]; then
        npm run deploy:production
    else
        echo "Deployment cancelled."
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_blue_green() {
    echo -e "\n${BLUE}${BOLD}Blue-Green Deployment (Zero-Downtime)${NC}\n"
    
    echo -n "Proceed with blue-green deployment? (yes/no): "
    read confirm
    
    if [[ "$confirm" == "yes" ]]; then
        npm run deploy:blue-green
    else
        echo "Deployment cancelled."
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_monitor() {
    echo -e "\n${BLUE}${BOLD}Starting Post-Deployment Monitoring...${NC}\n"
    
    echo -n "Duration in seconds (default: 3600 = 1 hour): "
    read duration
    duration=${duration:-3600}
    
    npm run deploy:monitor -- "$duration"
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_e2e_tests() {
    echo -e "\n${BLUE}${BOLD}Running E2E Tests...${NC}\n"
    npm run test:e2e
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_lighthouse() {
    echo -e "\n${BLUE}${BOLD}Running Lighthouse Performance Audit...${NC}\n"
    npm run performance:lighthouse
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_rollback() {
    echo -e "\n${RED}${BOLD}🔙 ROLLBACK TO PREVIOUS VERSION${NC}\n"
    
    echo -e "${YELLOW}This will rollback ALL services to the previous deployment.${NC}"
    echo -n "Type 'ROLLBACK' to confirm: "
    read confirm
    
    if [[ "$confirm" == "ROLLBACK" ]]; then
        npm run deploy:rollback
    else
        echo "Rollback cancelled."
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_rollback_specific() {
    echo -e "\n${RED}${BOLD}🔙 ROLLBACK TO SPECIFIC VERSION${NC}\n"
    
    echo "Available versions (git tags):"
    git tag -l | tail -10
    echo ""
    
    echo -n "Enter version tag (e.g., v2.1.0): "
    read version
    
    echo -e "${YELLOW}This will rollback to version: $version${NC}"
    echo -n "Type 'ROLLBACK' to confirm: "
    read confirm
    
    if [[ "$confirm" == "ROLLBACK" ]]; then
        npm run deploy:rollback -- "$version"
    else
        echo "Rollback cancelled."
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_view_report() {
    echo -e "\n${BLUE}${BOLD}Latest Deployment Report:${NC}\n"
    
    local latest_report=$(ls -t quality-reports/deployment-*.md 2>/dev/null | head -1)
    
    if [[ -n "$latest_report" ]]; then
        cat "$latest_report"
    else
        echo "No deployment reports found."
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

action_view_metrics() {
    echo -e "\n${BLUE}${BOLD}System Metrics:${NC}\n"
    
    echo -e "${BOLD}CPU Usage:${NC}"
    top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print "  " 100 - $1 "%"}'
    
    echo -e "\n${BOLD}Memory Usage:${NC}"
    free -h | awk 'NR==2{printf "  %s / %s (%.0f%%)\n", $3, $2, $3/$2*100}'
    
    echo -e "\n${BOLD}Disk Usage:${NC}"
    df -h / | awk 'NR==2{printf "  %s / %s (%s)\n", $3, $2, $5}'
    
    if command -v psql &>/dev/null && [[ -n "${DATABASE_URL:-}" ]]; then
        echo -e "\n${BOLD}Database Connections:${NC}"
        psql "$DATABASE_URL" -t -c "SELECT count(*) || ' active connections' FROM pg_stat_activity;" 2>/dev/null || echo "  Unable to connect"
    fi
    
    echo -e "\n${BOLD}Docker Containers:${NC}"
    if command -v docker &>/dev/null; then
        docker ps --format "  {{.Names}}: {{.Status}}" 2>/dev/null || echo "  Docker not running"
    else
        echo "  Docker not installed"
    fi
    
    echo -e "\n${GREEN}Press Enter to continue...${NC}"
    read
}

###############################################################################
# Main Loop
###############################################################################
main() {
    while true; do
        clear
        show_header
        show_status
        show_menu
        
        read choice
        
        case $choice in
            1) action_readiness ;;
            2) action_quality_gates ;;
            3) action_security_scan ;;
            4) action_deploy_staging ;;
            5) action_deploy_production ;;
            6) action_blue_green ;;
            7) action_monitor ;;
            8) action_e2e_tests ;;
            9) action_lighthouse ;;
            10) action_rollback ;;
            11) action_rollback_specific ;;
            12) action_view_report ;;
            13) action_view_metrics ;;
            14) continue ;;  # Refresh (loop restarts)
            0) 
                echo -e "\n${GREEN}Goodbye!${NC}\n"
                exit 0
                ;;
            *)
                echo -e "\n${RED}Invalid choice. Please try again.${NC}"
                sleep 2
                ;;
        esac
    done
}

# Run
main "$@"
