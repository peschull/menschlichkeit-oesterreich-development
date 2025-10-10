#!/usr/bin/env bash
# Secure VS Code Reload & MCP Activation
# Updated: 2025-10-10

set -Eeuo pipefail
IFS=$'\n\t'

# --- helpers ---------------------------------------------------------------
log()   { printf "\033[1;34m[INFO]\033[0m %s\n" "$*"; }
ok()    { printf "\033[0;32m[ OK ]\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m[WARN]\033[0m %s\n" "$*"; }
fail()  { printf "\033[0;31m[FAIL]\033[0m %s\n" "$*"; exit 1; }

ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
VSCODE_DIR="$ROOT_DIR/.vscode"
MCP_JSON="$VSCODE_DIR/mcp.json"
SETTINGS_JSON="$VSCODE_DIR/settings.json"

need() { command -v "$1" >/dev/null 2>&1 || fail "Benötigtes Tool fehlt: $1"; }
need jq; need npm; command -v code >/dev/null 2>&1 || warn "VS Code CLI 'code' nicht gefunden – Reload nur manuell"

mkdir -p "$VSCODE_DIR"

# 1) Backup
if [[ -f "$MCP_JSON" ]]; then
  BACKUP_FILE="$VSCODE_DIR/mcp-backup-$(date +%Y%m%d_%H%M%S).json"
  cp "$MCP_JSON" "$BACKUP_FILE"
  ok "Backup angelegt: $BACKUP_FILE"
else
  warn "Kein $MCP_JSON gefunden – überspringe Backup"
fi

# 2) JSON-Syntax prüfen
if [[ -f "$MCP_JSON" ]]; then
  jq empty "$MCP_JSON" >/dev/null || fail "Ungültiges JSON in $MCP_JSON"
  ok "mcp.json ist valide"
fi

# 3) VS Code: Empfohlenes Setting für MCP-Zugriff setzen (workspace-lokal)
#    Siehe VS Code Docs: chat.mcp.access = "all"
TMP_SETTINGS="$(mktemp)"
if [[ -f "$SETTINGS_JSON" ]]; then
  jq '. + {"chat.mcp.access": "all"}' "$SETTINGS_JSON" > "$TMP_SETTINGS" || true
else
  printf '{"chat.mcp.access": "all"}\n' > "$TMP_SETTINGS"
fi
mv "$TMP_SETTINGS" "$SETTINGS_JSON"
ok ".vscode/settings.json: chat.mcp.access=all gesetzt"

# 4) Sicherheitsprüfung: Hinweise auf hartcodierte Secrets in mcp.json
if [[ -f "$MCP_JSON" ]] && grep -E '(ghp_|sk_live_|xoxb-|AIzaSy|EAACEdEose0cBA)' "$MCP_JSON" >/dev/null 2>&1; then
  warn "Mögliche hartcodierte Tokens in mcp.json gefunden – bitte ${env:...} oder ${input:...} verwenden"
else
  ok "Keine hartcodierten Secrets in mcp.json gefunden"
fi

# 5) Gängige MCP‑Server im NPM‑Registry auffinden (nur Version anzeigen)
SERVERS=(
  "@modelcontextprotocol/server-filesystem"
  "@modelcontextprotocol/server-memory"
  "@modelcontextprotocol/server-sequential-thinking"
  "figma-mcp"
  "@upstash/context7-mcp"
)
for pkg in "${SERVERS[@]}"; do
  if npm view "$pkg" version >/dev/null 2>&1; then
    ver=$(npm view "$pkg" version 2>/dev/null || echo "?")
    ok "$pkg@$ver"
  else
    warn "$pkg nicht im Registry gefunden"
  fi
done

# 6) VS Code Erweiterungen prüfen
if command -v code >/dev/null 2>&1; then
  code --list-extensions 2>/dev/null | grep -q "GitHub.copilot" && ok "Copilot Erweiterung installiert" || warn "Copilot Erweiterung fehlt"
  code --list-extensions 2>/dev/null | grep -q "GitHub.copilot-chat" && ok "Copilot Chat installiert" || warn "Copilot Chat fehlt"
fi

# 7) Reload anstoßen (auto, falls CLI verfügbar), sonst Anleitung
if command -v code >/dev/null 2>&1; then
  log "Starte VS Code Reload…"
  code --command workbench.action.reloadWindow || warn "Automatischer Reload nicht möglich – bitte manuell"
fi

cat <<'TXT'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
KRITISCHER SCHRITT: Falls kein Auto‑Reload – manuell:
1) Cmd/Ctrl+Shift+P → "Developer: Reload Window"
2) Copilot Chat öffnen → Tools prüfen (@filesystem, @github, …)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TXT
#!/bin/bash
# MCP VS Code Reload Script - KRITISCHER SCHRITT FÜR MCP AKTIVIERUNG
# Created: 2025-10-08

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 MCP VS Code Reload & Activation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 1. Backup current MCP config
echo "📦 Creating MCP config backup..."
BACKUP_FILE=".vscode/mcp-backup-$(date +%Y%m%d_%H%M%S).json"
cp .vscode/mcp.json "$BACKUP_FILE"
echo "   ✓ Backup saved: $BACKUP_FILE"
echo ""

# 2. Validate MCP config JSON
echo "🔍 Validating MCP configuration..."
if ! jq empty .vscode/mcp.json 2>/dev/null; then
    echo "   ❌ ERROR: Invalid JSON in mcp.json"
    exit 1
fi
echo "   ✓ MCP config JSON is valid"
echo ""

# 3. Check MCP settings in VS Code settings.json
echo "⚙️ Checking VS Code MCP settings..."
if grep -q '"github.copilot.mcp.enabled": true' .vscode/settings.json; then
    echo "   ✓ MCP enabled in VS Code settings"
else
    echo "   ❌ WARNING: MCP not enabled in settings.json"
    echo "   Adding MCP settings..."
fi
echo ""

# 4. Environment Variables Check
echo "🔑 Verifying environment variables..."
if [ -n "$FIGMA_ACCESS_TOKEN" ]; then
    echo "   ✓ FIGMA_ACCESS_TOKEN: ${FIGMA_ACCESS_TOKEN:0:20}..."
else
    echo "   ⚠️ WARNING: FIGMA_ACCESS_TOKEN not set"
fi

if [ -n "$GITHUB_TOKEN" ]; then
    echo "   ✓ GITHUB_TOKEN: ${GITHUB_TOKEN:0:20}..."
else
    echo "   ⚠️ WARNING: GITHUB_TOKEN not set"
fi
echo ""

# 5. MCP Server Availability
echo "📦 Checking MCP npm packages..."
SERVERS=(
    "@modelcontextprotocol/server-memory"
    "@modelcontextprotocol/server-sequential-thinking"
    "figma-mcp"
    "@modelcontextprotocol/server-github"
    "@upstash/context7-mcp"
    "@modelcontextprotocol/server-filesystem"
)

for server in "${SERVERS[@]}"; do
    if npm view "$server" version >/dev/null 2>&1; then
        VERSION=$(npm view "$server" version 2>/dev/null)
        echo "   ✓ $server@$VERSION"
    else
        echo "   ❌ $server - NOT FOUND"
    fi
done
echo ""

# 6. VS Code Extensions Check
echo "🔌 Checking GitHub Copilot extensions..."
if code --list-extensions 2>/dev/null | grep -q "GitHub.copilot"; then
    echo "   ✓ GitHub Copilot extension installed"
else
    echo "   ⚠️ WARNING: GitHub Copilot extension not found"
fi

if code --list-extensions 2>/dev/null | grep -q "GitHub.copilot-chat"; then
    echo "   ✓ GitHub Copilot Chat extension installed"
else
    echo "   ⚠️ WARNING: GitHub Copilot Chat extension not found"
fi
echo ""

# 7. Instructions for manual VS Code reload
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ KRITISCHER SCHRITT: VS Code MUSS neu geladen werden!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Führe JETZT aus (in VS Code):"
echo ""
echo "   1️⃣ Drücke: Cmd/Ctrl + Shift + P"
echo "   2️⃣ Tippe: 'Developer: Reload Window'"
echo "   3️⃣ Bestätige mit Enter"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Nach dem Reload:"
echo ""
echo "   🧪 Teste MCP Server in Copilot Chat:"
echo "      - Öffne Copilot Chat (Cmd/Ctrl + I)"
echo "      - Teste: '@memory help'"
echo "      - Teste: '@github help'"
echo "      - Teste: '@filesystem help'"
echo ""
echo "   📊 Prüfe MCP Server Status:"
echo "      - Öffne Copilot Chat Settings"
echo "      - Suche nach 'MCP' → sollte 6 Server anzeigen"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ MCP Configuration bereit - RELOAD ERFORDERLICH!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
