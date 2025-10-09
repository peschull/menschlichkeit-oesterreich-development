#!/usr/bin/env bash
# MCP Health Check Script - Production Ready

# set -eo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MCP_JSON="$PROJECT_ROOT/.vscode/mcp.json"
ENV_LOCAL="$PROJECT_ROOT/env/.env.local"

# Counters
ERRORS=0
WARNINGS=0
CHECKS_PASSED=0
TOTAL_CHECKS=0

check_pass() {
    ((CHECKS_PASSED++))
    ((TOTAL_CHECKS++))
    echo -e "${GREEN}✓${NC} $1"
}

check_warn() {
    ((WARNINGS++))
    ((TOTAL_CHECKS++))
    echo -e "${YELLOW}⚠${NC} $1"
}

check_fail() {
    ((ERRORS++))
    ((TOTAL_CHECKS++))
    echo -e "${RED}✗${NC} $1"
}

echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  MCP Health Check                                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

# Check 1: JSON Syntax
echo -e "${BLUE}[1/5] Prüfe mcp.json...${NC}"
if [ ! -f "$MCP_JSON" ]; then
    check_fail "mcp.json nicht gefunden"
else
    if jq empty "$MCP_JSON" 2>/dev/null; then
        check_pass "JSON Syntax gültig"
        SERVER_COUNT=$(jq '.mcpServers | length' "$MCP_JSON")
        check_pass "$SERVER_COUNT MCP Server konfiguriert"
    else
        check_fail "JSON Syntax ungültig!"
    fi
fi
echo ""

# Check 2: Environment Variables
echo -e "${BLUE}[2/5] Prüfe Environment...${NC}"
if [ ! -f "$ENV_LOCAL" ]; then
    check_fail "env/.env.local fehlt - führe ./scripts/setup-mcp-env.sh aus"
else
    check_pass "env/.env.local gefunden"
    REQUIRED_VARS=$(grep -oP '\$\{env:([A-Z0-9_]+)\}' "$MCP_JSON" | sed 's/\${env:\([^}]*\)}/\1/' | sort -u | wc -l)
    CONFIGURED_VARS=$(grep -c "^[A-Z0-9_]*=.+$" "$ENV_LOCAL" || echo "0")
    check_pass "$CONFIGURED_VARS von $REQUIRED_VARS Variablen gesetzt"
fi
echo ""

# Check 3: Security
echo -e "${BLUE}[3/5] Security Check...${NC}"
if grep -E '(ghp_|sk_live_|xoxb-)' "$MCP_JSON" &> /dev/null; then
    check_fail "HARDCODED TOKEN in mcp.json gefunden!"
else
    check_pass "Keine hardcoded Tokens"
fi

if grep -q "env/.env.local" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
    check_pass ".gitignore schützt env/.env.local"
else
    check_fail ".gitignore fehlt env/.env.local"
fi
echo ""

# Check 4: VS Code
echo -e "${BLUE}[4/5] VS Code Integration...${NC}"
if [ -d "$PROJECT_ROOT/.vscode" ]; then
    check_pass ".vscode/ Verzeichnis vorhanden"
else
    check_fail ".vscode/ fehlt!"
fi

if [ -d "$PROJECT_ROOT/.ai-sandbox" ]; then
    check_pass "Filesystem Sandbox (.ai-sandbox/) vorhanden"
else
    check_warn ".ai-sandbox/ fehlt"
fi
echo ""

# Check 5: NPM Packages
echo -e "${BLUE}[5/5] NPM Packages...${NC}"
if command -v npm &> /dev/null; then
    check_pass "npm verfügbar: $(npm --version)"
else
    check_warn "npm nicht gefunden"
fi
echo ""

# Summary
echo -e "${BLUE}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  ZUSAMMENFASSUNG                                 ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════╝${NC}"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ ALLE CHECKS BESTANDEN! ($CHECKS_PASSED/$TOTAL_CHECKS)${NC}"
    echo ""
    echo "MCP Server READY für Copilot Chat:"
    echo "  @github list repositories"
    echo "  @figma get design tokens"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS Warnungen, $CHECKS_PASSED/$TOTAL_CHECKS Checks OK${NC}"
    echo "Behebe Warnungen für optimale Performance"
    exit 1
else
    echo -e "${RED}✗ $ERRORS Fehler, $WARNINGS Warnungen${NC}"
    echo ""
    echo "QUICK FIXES:"
    echo "1. ./scripts/setup-mcp-env.sh"
    echo "2. nano env/.env.local (API-Keys eintragen)"
    echo "3. source env/.env.local"
    echo "4. VS Code Reload: Cmd/Ctrl+Shift+P → Developer: Reload Window"
    exit 2
fi
