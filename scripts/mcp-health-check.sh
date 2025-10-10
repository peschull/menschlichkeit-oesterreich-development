#!/usr/bin/env bash
# MCP Health Check (unified quick/deep)
# Updated: 2025-10-10 (clean JSON output in --format=json)
set -Eeuo pipefail
IFS=$'\n\t'

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
VSCODE_DIR="$ROOT_DIR/.vscode"
MCP_JSON="$VSCODE_DIR/mcp.json"
ENV_LOCAL="$ROOT_DIR/env/.env.local"

MODE="deep"; FORMAT="text"; MD_OUT=""
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --mode) MODE="$2"; shift 2;;
    --mode=*) MODE="${1#*=}"; shift;;
    --format) FORMAT="$2"; shift 2;;
    --format=*) FORMAT="${1#*=}"; shift;;
    --markdown|--md)
      # Enable markdown output to stdout at the end (in addition to json/text exit code)
      MD_OUT="true"; shift;;
    *) shift;;
  esac
done

# In JSON-Mode schreiben wir Logs auf STDERR, um stdout für JSON freizuhalten
if [[ "$FORMAT" == "json" ]]; then
  ok(){ echo -e "${GREEN}✓${NC} $*" >&2; }
  warn(){ echo -e "${YELLOW}⚠${NC} $*" >&2; }
  fail(){ echo -e "${RED}✗${NC} $*" >&2; }
else
  ok(){ echo -e "${GREEN}✓${NC} $*"; }
  warn(){ echo -e "${YELLOW}⚠${NC} $*"; }
  fail(){ echo -e "${RED}✗${NC} $*"; }
fi
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

# 2) settings.json: chat.mcp.access (robuste Prüfung ohne JSONC-Parsing)
SETTINGS_JSON="$VSCODE_DIR/settings.json"
if [[ -f "$SETTINGS_JSON" ]]; then
  if grep -E '"chat\.mcp\.access"\s*:\s*"all"' "$SETTINGS_JSON" >/dev/null 2>&1; then
    ok "settings.json: chat.mcp.access=all"; ((++oks))
  else
    warn "settings.json: chat.mcp.access ist nicht 'all'"; ((++warns))
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
  json_summary="$(jq -n --arg oks "$oks" --arg warns "$warns" --arg errs "$errs" '{oks:$oks|tonumber,warns:$warns|tonumber,errs:$errs|tonumber}')"
  emit_json "$status" "$json_summary"
  # Optional Markdown to stdout after JSON if requested (separated by newline) – consumers should parse only the first JSON block
  if [[ -n "$MD_OUT" ]]; then
    echo ""
    echo "# MCP Health Check"
    echo "Status: \`$status\`  |  OK: $(echo "$json_summary" | jq -r .oks)  Warn: $(echo "$json_summary" | jq -r .warns)  Fehler: $(echo "$json_summary" | jq -r .errs)"
  fi
  case "$status" in ok) exit 0;; warn) exit 1;; *) exit 2;; esac
else
  if (( errs==0 && warns==0 )); then ok "ALLE CHECKS OK ($oks)"; exit 0
  elif (( errs==0 )); then warn "$warns Warnungen, $oks OK"; exit 1
  else fail "$errs Fehler, $warns Warnungen"; exit 2; fi
fi
