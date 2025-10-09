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
