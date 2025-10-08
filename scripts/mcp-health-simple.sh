#!/bin/bash
# MCP Server Health Check - Vereinfachte Version
# Stand: 7. Oktober 2025

echo "🔍 MCP Server Health Check"
echo "=========================="

# Check installed packages
echo -e "\n📦 Installed MCP Servers:"
npm list -g --depth=0 2>/dev/null | grep -E "(filesystem|memory|figma|notion|postgres|context7)" || echo "No MCP servers found"

echo -e "\n⚙️  MCP Configuration:"
if [[ -f "mcp.json" ]]; then
    echo "✅ mcp.json found"
    echo "Configured servers: $(grep -c '"type": "stdio"' mcp.json || echo "0")"
else
    echo "❌ mcp.json not found"
fi

echo -e "\n🌐 API Tests:"
echo -n "GitHub API: "
curl -s --max-time 3 https://api.github.com >/dev/null && echo "✅" || echo "❌"

echo -n "Figma API: "
curl -s --max-time 3 https://api.figma.com >/dev/null && echo "✅" || echo "❌"

echo -n "Notion API: "
curl -s --max-time 3 https://api.notion.com >/dev/null && echo "✅" || echo "❌"

echo -e "\n✅ Health Check Complete!"
echo "Next: Reload VS Code to activate MCP servers"