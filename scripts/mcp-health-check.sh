#!/usr/bin/env bash
# MCP Health Check (unified quick/deep)
# Updated: 2025-10-10
set -Eeuo pipefail
IFS=$'\n\t'

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_DIR="$ROOT_DIR/.vscode"
MCP_JSON="$VSCODE_DIR/mcp.json"
ENV_LOCAL="$ROOT_DIR/env/.env.local"

MODE="deep"; FORMAT="text"
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2;;
    --mode=*) MODE="${1#*=}"; shift;;
    --format) FORMAT="$2"; shift 2;;
    --format=*) FORMAT="${1#*=}"; shift;;
    *) shift;;
  esac
done

ok(){ echo -e "${GREEN}✓${NC} $*"; }
warn(){ echo -e "${YELLOW}⚠${NC} $*"; }
fail(){ echo -e "${RED}✗${NC} $*"; }
emit_json(){ jq -n --arg status "$1" --argjson summary "$2" '{status:$status, summary:$summary}'; }

oks=0; warns=0; errs=0

# 1) mcp.json Schema
if [[ -f "$MCP_JSON" ]]; then
  if jq empty "$MCP_JSON" >/dev/null 2>&1; then
    if jq -e '.servers and (.servers|type=="object")' "$MCP_JSON" >/dev/null; then
      ok "mcp.json: servers{} vorhanden"; ((++oks))
      if jq -e 'all(.servers[]; (has("type") and ((.type=="stdio" and has("command")) or (.type=="http" and has("url")))))' "$MCP_JSON" >/dev/null; then
        ok "mcp.json: Pflichtfelder je Server eingehalten"; ((++oks))
      else
        warn "mcp.json: fehlende Pflichtfelder je Server"; ((++warns))
      fi
    else
      fail "mcp.json: servers{} fehlt oder falscher Typ"; ((++errs))
    fi
  else
    fail "mcp.json: JSON-Syntax ungültig"; ((++errs))
  fi
else
  fail "$MCP_JSON fehlt"; ((++errs))
fi

# 2) settings.json: chat.mcp.access
SETTINGS_JSON="$VSCODE_DIR/settings.json"
if [[ -f "$SETTINGS_JSON" ]]; then
  val="$(jq -r '."chat.mcp.access" // empty' "$SETTINGS_JSON")"
  if [[ "$val" != "all" ]]; then
    warn "settings.json: chat.mcp.access ist nicht 'all' (aktuell: '${val:-unset}')"; ((++warns))
  else
    ok "settings.json: chat.mcp.access=all"; ((++oks))
  fi
else
  warn "settings.json fehlt – MCP evtl. eingeschränkt"; ((++warns))
fi

# 3) Quick vs. Deep Checks
if [[ "$MODE" == "quick" ]]; then
  srv_count="$(jq -r '.servers | keys | length' "$MCP_JSON" 2>/dev/null || echo 0)"
  ok "Quick: $srv_count Server konfiguriert"; ((++oks))
  for pair in "GitHub:https://api.github.com" "Figma:https://api.figma.com" "Notion:https://api.notion.com"; do
    name="${pair%%:*}"; url="${pair#*:}"
    if curl -fsSI --max-time 3 "$url" >/dev/null; then ok "API $name erreichbar"; ((++oks)); else warn "API $name nicht erreichbar"; ((++warns)); fi
  done
else
  # Security
  if [[ -f "$MCP_JSON" ]] && grep -E '(ghp_|sk_live_|xoxb-|AIzaSy|EAACEdEose0cBA)' "$MCP_JSON" >/dev/null 2>&1; then
    fail "mcp.json: Hartcodierte Tokens gefunden"; ((++errs))
  else
    ok "mcp.json: keine hartcodierten Tokens"; ((++oks))
  fi
  if [[ -f "$ROOT_DIR/.gitignore" ]] && grep -qE '^env/\\.env\\.local$' "$ROOT_DIR/.gitignore"; then
    ok ".gitignore schützt env/.env.local"; ((++oks))
  else
    warn ".gitignore ohne env/.env.local"; ((++warns))
  fi
  # Tooling
  command -v node >/dev/null 2>&1 && ok "node $(node --version)" || { warn "node nicht gefunden"; ((++warns)); }
  command -v npm  >/dev/null 2>&1 && ok "npm $(npm --version)"  || { warn "npm nicht gefunden";  ((++warns)); }
fi

# 4) Ausgabe & Exit
if [[ "$FORMAT" == "json" ]]; then
  status="ok"; (( errs>0 )) && status="error" || { (( warns>0 )) && status="warn"; }
  emit_json "$status" "$(jq -n --arg oks "$oks" --arg warns "$warns" --arg errs "$errs" '{oks:$oks|tonumber,warns:$warns|tonumber,errs:$errs|tonumber}')"
  case "$status" in ok) exit 0;; warn) exit 1;; *) exit 2;; esac
else
  if (( errs==0 && warns==0 )); then ok "ALLE CHECKS OK ($oks)"; exit 0
  elif (( errs==0 )); then warn "$warns Warnungen, $oks OK"; exit 1
  else fail "$errs Fehler, $warns Warnungen"; exit 2; fi
fi
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
