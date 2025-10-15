#!/usr/bin/env bash
# MCP Servers Health Check
# Verifies all configured MCP servers are accessible and functional

set -euo pipefail

echo "🔍 MCP Servers Health Check"
echo "============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0
SKIPPED=0

# Function to check if npx command exists
check_npx() {
    if ! command -v npx &> /dev/null; then
        echo -e "${RED}✗ npx not found${NC}"
        echo "  Please install Node.js and npm first"
        exit 1
    fi
    echo -e "${GREEN}✓ npx found${NC}"
    echo ""
}

# Function to test an MCP server
test_server() {
    local name=$1
    local package=$2
    local requires_env=$3
    
    TOTAL=$((TOTAL + 1))
    
    echo "Testing: $name ($package)"
    
    # Check if required env vars are set (if any)
    if [ ! -z "$requires_env" ]; then
        local missing_env=false
        for var in ${requires_env//,/ }; do
            if [ -z "${!var:-}" ]; then
                echo -e "  ${YELLOW}⚠ Missing env var: $var${NC}"
                missing_env=true
            fi
        done
        
        if [ "$missing_env" = true ]; then
            echo -e "  ${YELLOW}⊘ SKIPPED (missing credentials)${NC}"
            SKIPPED=$((SKIPPED + 1))
            echo ""
            return
        fi
    fi
    
    # Try to run the server with --version or --help
    if timeout 10 npx -y "$package" --version &> /dev/null || \
       timeout 10 npx -y "$package" --help &> /dev/null; then
        echo -e "  ${GREEN}✓ PASSED${NC}"
        PASSED=$((PASSED + 1))
    else
        echo -e "  ${RED}✗ FAILED${NC}"
        FAILED=$((FAILED + 1))
    fi
    
    echo ""
}

# Main health checks
check_npx

echo "📋 Testing MCP Servers..."
echo "-------------------------"
echo ""

# Test each approved server
test_server "GitHub" "@modelcontextprotocol/server-github" "GITHUB_PERSONAL_ACCESS_TOKEN"
test_server "Codacy" "@codacy/codacy-mcp-server" "CODACY_API_TOKEN"
test_server "Figma" "@modelcontextprotocol/server-figma" "FIGMA_PERSONAL_ACCESS_TOKEN"
test_server "Sentry" "@sentry/mcp-server" "SENTRY_AUTH_TOKEN,SENTRY_ORG"
test_server "Hugging Face" "@huggingface/mcp-server" "HUGGING_FACE_API_TOKEN"
test_server "Markitdown" "@microsoft/markitdown-mcp-server" ""

# Summary
echo "============================="
echo "📊 Health Check Summary"
echo "============================="
echo "Total servers:   $TOTAL"
echo -e "${GREEN}Passed:          $PASSED${NC}"
echo -e "${RED}Failed:          $FAILED${NC}"
echo -e "${YELLOW}Skipped:         $SKIPPED${NC}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo -e "${RED}❌ Some health checks failed!${NC}"
    echo "Please check server configurations and network connectivity."
    exit 1
elif [ $SKIPPED -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Some servers were skipped due to missing credentials.${NC}"
    echo "Set the required environment variables to test all servers."
    exit 0
else
    echo -e "${GREEN}✅ All health checks passed!${NC}"
    exit 0
fi
