#!/bin/bash

# 🚨 CODESPACE EMERGENCY RECOVERY SCRIPT
# This script provides multiple recovery options for hanging Codespace

set -e

echo "🚨 STARTING EMERGENCY RECOVERY FOR CODESPACE..."
echo "⏰ Recovery started at: $(date)"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run with timeout
run_with_timeout() {
    timeout "$1" "$2" || echo "⚠️ Command timed out: $2"
}

echo ""
echo "🔍 PHASE 1: SYSTEM DIAGNOSTICS"
echo "=============================="

echo "📊 System Info:"
echo "- OS: $(uname -a)"
echo "- Memory: $(free -h | grep Mem || echo 'Memory info unavailable')"
echo "- Disk: $(df -h / | tail -1 || echo 'Disk info unavailable')"
echo "- User: $(whoami)"
echo "- PWD: $(pwd)"

echo ""
echo "🛠️ PHASE 2: TOOL AVAILABILITY CHECK"
echo "==================================="

# Check essential tools
TOOLS=("node" "npm" "python3" "pip3" "git" "curl" "wget")
AVAILABLE_TOOLS=0
MISSING_TOOLS=()

for tool in "${TOOLS[@]}"; do
    if command_exists "$tool"; then
        version=$(timeout 5 $tool --version 2>/dev/null | head -1 || echo "version unknown")
        echo "✅ $tool: $version"
        ((AVAILABLE_TOOLS++))
    else
        echo "❌ $tool: NOT AVAILABLE"
        MISSING_TOOLS+=("$tool")
    fi
done

echo ""
echo "📈 Tool Availability: $AVAILABLE_TOOLS/${#TOOLS[@]} tools available"

echo ""
echo "🚀 PHASE 3: DEPENDENCY INSTALLATION (EMERGENCY MODE)"
echo "==================================================="

# Install missing essential tools
if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "📦 Installing missing tools: ${MISSING_TOOLS[*]}"
    
    # Try apt-get first
    if command_exists apt-get; then
        echo "🔄 Using apt-get for installations..."
        run_with_timeout 300 "sudo apt-get update -qq"
        
        for tool in "${MISSING_TOOLS[@]}"; do
            case $tool in
                "node")
                    run_with_timeout 180 "sudo apt-get install -y nodejs"
                    ;;
                "npm")
                    run_with_timeout 180 "sudo apt-get install -y npm"
                    ;;
                "python3")
                    run_with_timeout 180 "sudo apt-get install -y python3"
                    ;;
                "pip3")
                    run_with_timeout 180 "sudo apt-get install -y python3-pip"
                    ;;
                *)
                    run_with_timeout 180 "sudo apt-get install -y $tool"
                    ;;
            esac
        done
    else
        echo "⚠️ apt-get not available, manual installation required"
    fi
fi

echo ""
echo "🔧 PHASE 4: PROJECT SETUP (MINIMAL)"
echo "===================================="

# Create essential directories
mkdir -p .vscode node_modules

# Create basic .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating basic .env file..."
    cat > .env << EOF
NODE_ENV=development
DEBUG=true
CODESPACE_EMERGENCY=true
JWT_SECRET=emergency-dev-secret
CIVI_SITE_KEY=emergency-dev-key
CIVI_API_KEY=emergency-dev-key
EOF
fi

# Install minimal npm dependencies if package.json exists
if [ -f package.json ] && command_exists npm; then
    echo "📦 Installing Node.js dependencies (timeout: 300s)..."
    timeout 300 npm install --no-audit --no-fund --prefer-offline || echo "⚠️ npm install timed out, continuing..."
fi

echo ""
echo "🏥 PHASE 5: HEALTH CHECK"
echo "========================"

HEALTH_SCORE=0
MAX_HEALTH=6

# Check Node.js
if command_exists node; then
    node --version >/dev/null 2>&1 && ((HEALTH_SCORE++)) && echo "✅ Node.js: Working"
else
    echo "❌ Node.js: Not available"
fi

# Check npm
if command_exists npm; then
    npm --version >/dev/null 2>&1 && ((HEALTH_SCORE++)) && echo "✅ npm: Working"
else
    echo "❌ npm: Not available"
fi

# Check Python
if command_exists python3; then
    python3 --version >/dev/null 2>&1 && ((HEALTH_SCORE++)) && echo "✅ Python3: Working"
else
    echo "❌ Python3: Not available"
fi

# Check pip
if command_exists pip3; then
    pip3 --version >/dev/null 2>&1 && ((HEALTH_SCORE++)) && echo "✅ pip3: Working"
else
    echo "❌ pip3: Not available"
fi

# Check git
if command_exists git; then
    git --version >/dev/null 2>&1 && ((HEALTH_SCORE++)) && echo "✅ git: Working"
else
    echo "❌ git: Not available"
fi

# Check file system access
if [ -w . ]; then
    ((HEALTH_SCORE++)) && echo "✅ File System: Writable"
else
    echo "❌ File System: Not writable"
fi

echo ""
echo "📊 RECOVERY SCORE: $HEALTH_SCORE/$MAX_HEALTH"

if [ $HEALTH_SCORE -ge 4 ]; then
    echo "🎉 RECOVERY SUCCESSFUL - Codespace is functional!"
    echo ""
    echo "🚀 AVAILABLE COMMANDS:"
    echo "  npm run dev:frontend  # Start React frontend"
    echo "  cd api.menschlichkeit-oesterreich.at && python app/main.py  # Start FastAPI"
    echo "  node --version        # Check Node.js"
    echo "  python3 --version     # Check Python"
elif [ $HEALTH_SCORE -ge 2 ]; then
    echo "⚠️ PARTIAL RECOVERY - Some tools available"
    echo "Manual setup may be required for full functionality"
else
    echo "❌ RECOVERY FAILED - Manual intervention required"
    echo "Try creating a new Codespace or contact support"
fi

echo ""
echo "🕐 Recovery completed at: $(date)"
echo "💾 Recovery log saved to: /tmp/codespace-recovery.log"

# Save recovery log
{
    echo "Codespace Emergency Recovery Log"
    echo "================================"
    echo "Date: $(date)"
    echo "Health Score: $HEALTH_SCORE/$MAX_HEALTH"
    echo "Available Tools: $AVAILABLE_TOOLS/${#TOOLS[@]}"
    echo "Missing Tools: ${MISSING_TOOLS[*]}"
} > /tmp/codespace-recovery.log

echo ""
echo "✅ EMERGENCY RECOVERY COMPLETE"
echo "Use 'cat /tmp/codespace-recovery.log' to view full recovery details"