#!/bin/bash
# MCP Server Setup Script für Menschlichkeit Österreich
# Installiert und konfiguriert alle erforderlichen MCP Server

set -e

echo "🚀 MCP Server Setup für Menschlichkeit Österreich"
echo "=================================================="
echo ""

# Farben für Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Funktion zum Prüfen ob ein Command existiert
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Funktion zum Installieren eines MCP Servers
install_mcp_server() {
    local server_name=$1
    local package_name=$2
    
    echo -e "${YELLOW}📦 Installiere ${server_name}...${NC}"
    npx -y "$package_name" --help >/dev/null 2>&1 && \
        echo -e "${GREEN}✅ ${server_name} erfolgreich installiert${NC}" || \
        echo -e "${RED}❌ ${server_name} Installation fehlgeschlagen${NC}"
}

# Prüfe Voraussetzungen
echo "🔍 Prüfe Voraussetzungen..."
echo ""

if ! command_exists node; then
    echo -e "${RED}❌ Node.js ist nicht installiert. Bitte installieren Sie Node.js 18 oder höher.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}❌ npm ist nicht installiert. Bitte installieren Sie npm.${NC}"
    exit 1
fi

if ! command_exists npx; then
    echo -e "${RED}❌ npx ist nicht installiert. Bitte installieren Sie npx.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Alle Voraussetzungen erfüllt${NC}"
echo ""

# Erstelle .env aus Template falls nicht vorhanden
if [ ! -f .env ]; then
    if [ -f .env.mcp.template ]; then
        echo "📝 Erstelle .env aus Template..."
        cp .env.mcp.template .env
        echo -e "${YELLOW}⚠️  Bitte konfigurieren Sie .env mit Ihren Tokens!${NC}"
        echo ""
    fi
fi

# Installiere MCP Server
echo "📦 Installiere MCP Server..."
echo ""

install_mcp_server "Figma MCP Server" "@figma/mcp-server-figma"
install_mcp_server "GitHub MCP Server" "@modelcontextprotocol/server-github"
install_mcp_server "Filesystem MCP Server" "@modelcontextprotocol/server-filesystem"
install_mcp_server "Playwright MCP Server" "@executeautomation/playwright-mcp-server"
install_mcp_server "PostgreSQL MCP Server" "@modelcontextprotocol/server-postgres"
install_mcp_server "Brave Search MCP Server" "@modelcontextprotocol/server-brave-search"
install_mcp_server "Memory MCP Server" "@modelcontextprotocol/server-memory"

echo ""
echo "🔧 Konfiguration..."
echo ""

# Prüfe ob .vscode/mcp.json existiert
if [ ! -f .vscode/mcp.json ]; then
    echo -e "${RED}❌ .vscode/mcp.json nicht gefunden${NC}"
    exit 1
fi

echo -e "${GREEN}✅ MCP-Konfiguration gefunden: .vscode/mcp.json${NC}"

# Prüfe Umgebungsvariablen
echo ""
echo "🔍 Prüfe Umgebungsvariablen..."
echo ""

missing_vars=0

if [ -z "$FIGMA_ACCESS_TOKEN" ]; then
    echo -e "${YELLOW}⚠️  FIGMA_ACCESS_TOKEN nicht gesetzt${NC}"
    echo "   Holen Sie sich einen Token von: https://www.figma.com/settings"
    missing_vars=$((missing_vars + 1))
fi

if [ -z "$POSTGRES_CONNECTION_STRING" ]; then
    echo -e "${YELLOW}⚠️  POSTGRES_CONNECTION_STRING nicht gesetzt${NC}"
    echo "   Verwenden Sie: postgresql://user:password@localhost:5432/database"
    missing_vars=$((missing_vars + 1))
fi

if [ -z "$BRAVE_API_KEY" ]; then
    echo -e "${YELLOW}ℹ️  BRAVE_API_KEY nicht gesetzt (optional)${NC}"
    echo "   Holen Sie sich einen kostenlosen Key von: https://brave.com/search/api/"
fi

if [ -z "$GITHUB_TOKEN" ]; then
    echo -e "${YELLOW}ℹ️  GITHUB_TOKEN wird automatisch von GitHub CLI bereitgestellt${NC}"
fi

echo ""

if [ $missing_vars -gt 0 ]; then
    echo -e "${YELLOW}⚠️  ${missing_vars} erforderliche Umgebungsvariable(n) fehlen${NC}"
    echo -e "${YELLOW}   Bitte konfigurieren Sie .env und führen Sie das Script erneut aus${NC}"
    echo ""
fi

# Zusammenfassung
echo "📊 Setup-Zusammenfassung"
echo "========================"
echo ""
echo "✅ Installierte MCP Server:"
echo "   - Figma MCP Server (Design System Integration)"
echo "   - GitHub MCP Server (Issues, PRs, Security)"
echo "   - Filesystem MCP Server (Datei-Management)"
echo "   - Playwright MCP Server (E2E-Tests)"
echo "   - PostgreSQL MCP Server (Datenbank-Zugriff)"
echo "   - Brave Search MCP Server (Web-Recherche)"
echo "   - Memory MCP Server (Kontext-Persistenz)"
echo ""
echo "📂 Konfigurationsdateien:"
echo "   - .vscode/mcp.json (MCP Server Konfiguration)"
echo "   - .env (Umgebungsvariablen)"
echo "   - docs/MCP-SERVER-SETUP.md (Dokumentation)"
echo ""
echo "🔗 Nächste Schritte:"
echo "   1. Konfigurieren Sie .env mit Ihren Tokens"
echo "   2. Starten Sie VS Code neu (Cmd/Ctrl + Shift + P -> 'Reload Window')"
echo "   3. Testen Sie die MCP Server mit GitHub Copilot Chat"
echo "   4. Lesen Sie docs/MCP-SERVER-SETUP.md für Details"
echo ""
echo -e "${GREEN}✅ MCP Server Setup abgeschlossen!${NC}"
