#!/bin/bash
# MCP Server Health Check - Comprehensive Diagnostics
# Usage: ./scripts/mcp-health-check-complete.sh

set -e

echo "🔍 MCP Server Health Check"
echo "============================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# 1. JSON Validation
echo "1️⃣ Validating mcp.json..."
if [ ! -f ".vscode/mcp.json" ]; then
  echo -e "   ${RED}❌ .vscode/mcp.json not found!${NC}"
  ((ERRORS++))
else
  if jq empty .vscode/mcp.json 2>/dev/null; then
    echo -e "   ${GREEN}✅ Valid JSON${NC}"
    
    # Count configured servers
    SERVER_COUNT=$(jq '.mcpServers | length' .vscode/mcp.json)
    echo -e "   ${GREEN}✅ $SERVER_COUNT servers configured${NC}"
  else
    echo -e "   ${RED}❌ Invalid JSON - Fix syntax errors first!${NC}"
    ((ERRORS++))
  fi
fi
echo ""

# 2. Environment Variables
echo "2️⃣ Checking Environment Variables..."
if [ -n "$FIGMA_ACCESS_TOKEN" ]; then
  echo -e "   ${GREEN}✅ FIGMA_ACCESS_TOKEN: ${FIGMA_ACCESS_TOKEN:0:15}...${NC}"
else
  echo -e "   ${YELLOW}⚠️ FIGMA_ACCESS_TOKEN not set${NC}"
  ((WARNINGS++))
fi

if [ -n "$GITHUB_TOKEN" ]; then
  echo -e "   ${GREEN}✅ GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}...${NC}"
else
  echo -e "   ${YELLOW}⚠️ GITHUB_TOKEN not set${NC}"
  ((WARNINGS++))
fi
echo ""

# 3. NPM Global Packages
echo "3️⃣ Checking NPM Packages..."
packages=(
  "@modelcontextprotocol/server-memory"
  "@modelcontextprotocol/server-sequential-thinking"
  "@modelcontextprotocol/server-github"
  "@modelcontextprotocol/server-filesystem"
)

for pkg in "${packages[@]}"; do
  if npm list -g "$pkg" &>/dev/null; then
    version=$(npm list -g "$pkg" --depth=0 2>/dev/null | grep "$pkg" | awk '{print $2}')
    echo -e "   ${GREEN}✅ $pkg@$version${NC}"
  else
    echo -e "   ${YELLOW}⚠️ $pkg not installed globally (will use npx)${NC}"
    ((WARNINGS++))
  fi
done

# Check special packages
if command -v figma-mcp &>/dev/null || npm list -g figma-mcp &>/dev/null; then
  echo -e "   ${GREEN}✅ figma-mcp${NC}"
else
  echo -e "   ${YELLOW}⚠️ figma-mcp not found${NC}"
  ((WARNINGS++))
fi

if npm list -g @upstash/mcp-server-context7 &>/dev/null; then
  echo -e "   ${GREEN}✅ @upstash/mcp-server-context7${NC}"
else
  echo -e "   ${YELLOW}⚠️ @upstash/mcp-server-context7 not found${NC}"
  ((WARNINGS++))
fi
echo ""

# 4. VS Code Settings
echo "4️⃣ Checking VS Code Settings..."
if [ -f ".vscode/settings.json" ]; then
  if grep -q "github.copilot.mcp" .vscode/settings.json 2>/dev/null; then
    echo -e "   ${GREEN}✅ MCP settings found in settings.json${NC}"
    
    # Check if enabled
    if grep -q '"github.copilot.mcp.enabled": *true' .vscode/settings.json 2>/dev/null; then
      echo -e "   ${GREEN}✅ MCP explicitly enabled${NC}"
    else
      echo -e "   ${YELLOW}⚠️ MCP not explicitly enabled${NC}"
      ((WARNINGS++))
    fi
  else
    echo -e "   ${YELLOW}⚠️ No MCP settings in settings.json${NC}"
    ((WARNINGS++))
  fi
else
  echo -e "   ${YELLOW}⚠️ .vscode/settings.json not found${NC}"
  ((WARNINGS++))
fi
echo ""

# 5. VS Code Extensions
echo "5️⃣ Checking VS Code Extensions..."
if command -v code &>/dev/null; then
  if code --list-extensions | grep -q "github.copilot"; then
    echo -e "   ${GREEN}✅ GitHub Copilot extension installed${NC}"
  else
    echo -e "   ${RED}❌ GitHub Copilot extension NOT installed${NC}"
    ((ERRORS++))
  fi
  
  if code --list-extensions | grep -q "github.copilot-chat"; then
    echo -e "   ${GREEN}✅ GitHub Copilot Chat extension installed${NC}"
  else
    echo -e "   ${YELLOW}⚠️ GitHub Copilot Chat extension NOT installed${NC}"
    ((WARNINGS++))
  fi
else
  echo -e "   ${YELLOW}⚠️ 'code' command not available${NC}"
  ((WARNINGS++))
fi
echo ""

# 6. Node.js Version
echo "6️⃣ Checking Node.js Version..."
if command -v node &>/dev/null; then
  NODE_VERSION=$(node -v)
  MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1 | sed 's/v//')
  
  if [ "$MAJOR_VERSION" -ge 18 ]; then
    echo -e "   ${GREEN}✅ Node.js $NODE_VERSION (>= 18 required)${NC}"
  else
    echo -e "   ${RED}❌ Node.js $NODE_VERSION (need >= 18)${NC}"
    ((ERRORS++))
  fi
else
  echo -e "   ${RED}❌ Node.js not installed${NC}"
  ((ERRORS++))
fi
echo ""

# 7. Test Server Execution
echo "7️⃣ Testing Server Execution..."
echo "   Testing @modelcontextprotocol/server-memory..."

timeout 5s npx -y @modelcontextprotocol/server-memory --help &>/dev/null
if [ $? -eq 0 ] || [ $? -eq 124 ]; then
  echo -e "   ${GREEN}✅ Memory server executable${NC}"
else
  echo -e "   ${RED}❌ Memory server failed to execute${NC}"
  ((ERRORS++))
fi
echo ""

# 8. Copilot Logs
echo "8️⃣ Checking Copilot Logs..."
COPILOT_LOGS="$HOME/.cache/github-copilot/logs"
if [ -d "$COPILOT_LOGS" ]; then
  LATEST_LOG=$(ls -t "$COPILOT_LOGS"/*.log 2>/dev/null | head -1)
  if [ -n "$LATEST_LOG" ]; then
    echo -e "   ${GREEN}✅ Copilot logs found${NC}"
    echo "      Latest: $(basename $LATEST_LOG)"
    
    # Check for MCP errors in recent logs
    if tail -100 "$LATEST_LOG" 2>/dev/null | grep -i "mcp.*error" >/dev/null; then
      echo -e "   ${YELLOW}⚠️ MCP errors found in logs${NC}"
      echo "      Run: tail -100 $LATEST_LOG | grep -i mcp"
      ((WARNINGS++))
    fi
  else
    echo -e "   ${YELLOW}⚠️ No log files found${NC}"
    ((WARNINGS++))
  fi
else
  echo -e "   ${YELLOW}⚠️ Copilot logs directory not found${NC}"
  ((WARNINGS++))
fi
echo ""

# Summary
echo "============================"
echo "📊 Summary"
echo "============================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ ALL CHECKS PASSED!${NC}"
  echo ""
  echo "MCP Servers should work correctly."
  echo "If not, try: code --force-restart"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️ $WARNINGS warnings found${NC}"
  echo ""
  echo "MCP Servers might work, but check warnings."
  echo "See: quality-reports/MCP-SERVER-TROUBLESHOOTING.md"
  exit 0
else
  echo -e "${RED}❌ $ERRORS errors, $WARNINGS warnings${NC}"
  echo ""
  echo "Fix errors before MCP servers can work!"
  echo "See: quality-reports/MCP-SERVER-TROUBLESHOOTING.md"
  exit 1
fi
