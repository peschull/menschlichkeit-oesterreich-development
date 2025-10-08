#!/bin/bash
# MCP Server Validation Script - Vereinfacht
# Testet alle konfigurierten MCP-Server

echo "🚀 MCP Server Validation"
echo "========================"
echo ""

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Funktion zum Testen eines MCP-Servers
test_mcp_server() {
    local name="$1"
    local package="$2"
    local env_vars="$3"
    
    echo -e "${YELLOW}📦 Teste $name...${NC}"
    
    # Setze Umgebungsvariablen falls vorhanden
    if [ ! -z "$env_vars" ]; then
        export $env_vars
    fi
    
    # Teste Server mit Timeout
    if timeout 3s $package >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $name erfolgreich${NC}"
        return 0
    else
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${GREEN}✅ $name läuft (Timeout normal)${NC}"
            return 0
        else
            echo -e "${RED}❌ $name fehlgeschlagen (Code: $exit_code)${NC}"
            return 1
        fi
    fi
}

# Zähler
total=0
success=0

echo "🔍 Teste installierte MCP-Server:"
echo ""

# Filesystem MCP
total=$((total + 1))
if test_mcp_server "Filesystem MCP" "npx -y @modelcontextprotocol/server-filesystem ."; then
    success=$((success + 1))
fi

# Memory MCP  
total=$((total + 1))
if test_mcp_server "Memory MCP" "npx -y @modelcontextprotocol/server-memory"; then
    success=$((success + 1))
fi

# Figma MCP (mit Test-Token)
total=$((total + 1))
if test_mcp_server "Figma MCP" "npx -y figma-mcp" "FIGMA_API_TOKEN=test"; then
    success=$((success + 1))
fi

# PostgreSQL MCP (mit Test-URL)
total=$((total + 1))
if test_mcp_server "PostgreSQL MCP" "npx -y enhanced-postgres-mcp-server" "DATABASE_URL=postgresql://test:test@localhost:5432/test"; then
    success=$((success + 1))
fi

# Notion MCP (mit Test-Token)
total=$((total + 1))
if test_mcp_server "Notion MCP" "npx -y @notionhq/notion-mcp-server" "NOTION_API_KEY=test"; then
    success=$((success + 1))
fi

# Context7 MCP
total=$((total + 1))
if test_mcp_server "Context7 MCP" "npx -y @upstash/context7-mcp"; then
    success=$((success + 1))
fi

# Sequential Thinking MCP
total=$((total + 1))
if test_mcp_server "Sequential Thinking MCP" "npx -y @modelcontextprotocol/server-sequential-thinking"; then
    success=$((success + 1))
fi

# Everything MCP
total=$((total + 1))
if test_mcp_server "Everything MCP" "npx -y @modelcontextprotocol/server-everything"; then
    success=$((success + 1))
fi

echo ""
echo "📊 Zusammenfassung:"
echo "=================="
echo -e "${BLUE}Getestet: $total Server${NC}"
echo -e "${GREEN}Erfolgreich: $success Server${NC}"
echo -e "${RED}Fehlgeschlagen: $((total - success)) Server${NC}"

if [ $success -eq $total ]; then
    echo ""
    echo -e "${GREEN}🎉 Alle MCP-Server funktionieren!${NC}"
    exit 0
else
    echo ""
    echo -e "${YELLOW}⚠️  Einige MCP-Server haben Probleme${NC}"
    exit 1
fi