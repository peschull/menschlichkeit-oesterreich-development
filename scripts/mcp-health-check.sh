#!/bin/bash
# MCP Server Health Check für Menschlichkeit Österreich
# Stand: 7. Oktober 2025

set -eo pipefail

echo "🔍 MCP Server Health Check wird gestartet..."
echo "=================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Health Check Results
TOTAL_SERVERS=6
HEALTHY_SERVERS=0
FAILED_SERVERS=0

# Function to check MCP server package
check_mcp_package() {
    local package_name=$1
    local display_name=$2
    
    echo -n "Checking $display_name... "
    
    if npm list -g "$package_name" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Installed${NC}"
        ((HEALTHY_SERVERS++))
    else
        echo -e "${RED}❌ Not Found${NC}"
        echo "  → Install: npm install -g $package_name"
        ((FAILED_SERVERS++))
    fi
}

# MCP Server Checks
echo -e "\n📦 MCP Server Package Status:"
echo "----------------------------------------"

check_mcp_package "@modelcontextprotocol/server-filesystem" "Filesystem MCP"
check_mcp_package "@modelcontextprotocol/server-memory" "Memory MCP"
check_mcp_package "figma-mcp" "Figma MCP"
check_mcp_package "@notionhq/notion-mcp-server" "Notion MCP"
check_mcp_package "enhanced-postgres-mcp-server" "PostgreSQL MCP"
check_mcp_package "@upstash/context7-mcp" "Upstash Context7 MCP"

# Configuration Check
echo -e "\n⚙️  Configuration Status:"
echo "----------------------------------------"

if [[ -f "mcp.json" ]]; then
    echo -e "mcp.json: ${GREEN}✅ Found${NC}"
    
    # Check if inputs are defined
    if grep -q '"inputs"' mcp.json; then
        echo -e "Token Inputs: ${GREEN}✅ Configured${NC}"
    else
        echo -e "Token Inputs: ${RED}❌ Missing${NC}"
    fi
    
    # Check server count
    server_count=$(grep -c '"type": "stdio"' mcp.json || echo "0")
    echo -e "MCP Servers in Config: ${GREEN}$server_count${NC}"
    
else
    echo -e "mcp.json: ${RED}❌ Not Found${NC}"
fi

# VS Code Check
echo -e "\n🔧 VS Code Integration:"
echo "----------------------------------------"

if command -v code >/dev/null 2>&1; then
    echo -e "VS Code CLI: ${GREEN}✅ Available${NC}"
else
    echo -e "VS Code CLI: ${YELLOW}⚠️  Not in PATH${NC}"
fi

# Network Connectivity Check
echo -e "\n🌐 API Connectivity:"
echo "----------------------------------------"

check_api_connectivity() {
    local api_url=$1
    local api_name=$2
    
    echo -n "Testing $api_name... "
    
    if curl -s --max-time 5 "$api_url" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Reachable${NC}"
    else
        echo -e "${YELLOW}⚠️  Timeout/Unreachable${NC}"
    fi
}

check_api_connectivity "https://api.github.com" "GitHub API"
check_api_connectivity "https://api.figma.com" "Figma API"
check_api_connectivity "https://api.search.brave.com" "Brave Search API"
check_api_connectivity "https://api.notion.com" "Notion API"

# Summary
echo -e "\n📊 Health Check Summary:"
echo "=================================================="
echo -e "Total MCP Servers: $TOTAL_SERVERS"
echo -e "Healthy Servers: ${GREEN}$HEALTHY_SERVERS${NC}"
echo -e "Failed Servers: ${RED}$FAILED_SERVERS${NC}"

if [[ $FAILED_SERVERS -eq 0 ]]; then
    echo -e "\n🎉 ${GREEN}All MCP Servers are healthy!${NC}"
    echo -e "You can now use all MCP tools in GitHub Copilot."
    exit 0
else
    echo -e "\n⚠️  ${YELLOW}Some MCP Servers need attention.${NC}"
    echo -e "Run: ${YELLOW}npm run mcp:install${NC} to install missing packages."
    exit 0
fi
