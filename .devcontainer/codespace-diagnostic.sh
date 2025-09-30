#!/bin/bash
# 🔍 Codespace Diagnostic Tool
# Prüft alle wichtigen Komponenten und gibt detaillierte Informationen

echo "🔍 CODESPACE DIAGNOSTICS"
echo "========================"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    local status=$1
    local message=$2
    
    if [ "$status" = "OK" ]; then
        echo -e "${GREEN}✅${NC} $message"
    elif [ "$status" = "WARN" ]; then
        echo -e "${YELLOW}⚠️${NC} $message"
    else
        echo -e "${RED}❌${NC} $message"
    fi
}

# 1. Environment Check
echo "🌍 ENVIRONMENT"
echo "--------------"

if [ ! -z "$CODESPACE_NAME" ]; then
    print_status "OK" "Running in GitHub Codespace: $CODESPACE_NAME"
    print_status "OK" "Codespace URL: https://$CODESPACE_NAME-3000.preview.app.github.dev"
else
    print_status "WARN" "Not running in GitHub Codespace (local development)"
fi

echo ""

# 2. System Tools
echo "🛠️  SYSTEM TOOLS"
echo "---------------"

command -v node &>/dev/null && print_status "OK" "Node.js: $(node --version)" || print_status "FAIL" "Node.js not found"
command -v npm &>/dev/null && print_status "OK" "NPM: $(npm --version)" || print_status "FAIL" "NPM not found"
command -v python3 &>/dev/null && print_status "OK" "Python: $(python3 --version)" || print_status "FAIL" "Python not found"
command -v php &>/dev/null && print_status "OK" "PHP: $(php --version | head -n1)" || print_status "FAIL" "PHP not found"
command -v composer &>/dev/null && print_status "OK" "Composer: $(composer --version | head -n1)" || print_status "FAIL" "Composer not found"
command -v git &>/dev/null && print_status "OK" "Git: $(git --version)" || print_status "FAIL" "Git not found"
command -v docker &>/dev/null && print_status "OK" "Docker: $(docker --version)" || print_status "FAIL" "Docker not found"

echo ""

# 3. Configuration Files
echo "📄 CONFIGURATION FILES"
echo "---------------------"

[ -f .devcontainer/devcontainer.json ] && print_status "OK" "devcontainer.json exists" || print_status "FAIL" "devcontainer.json missing"
[ -f package.json ] && print_status "OK" "package.json exists" || print_status "FAIL" "package.json missing"
[ -f composer.json ] && print_status "OK" "composer.json exists" || print_status "FAIL" "composer.json missing"
[ -f .env.example ] && print_status "OK" ".env.example exists" || print_status "FAIL" ".env.example missing"
[ -f .env ] && print_status "OK" ".env exists" || print_status "WARN" ".env missing (will be created)"

echo ""

# 4. Scripts
echo "📜 SCRIPTS"
echo "---------"

scripts=(".devcontainer/codespace-optimized-setup.sh" ".devcontainer/codespace-post-create.sh" ".devcontainer/post-start.sh" ".devcontainer/quick-fix.sh" "codespace-start.sh")

for script in "${scripts[@]}"; do
    if [ -f "$script" ]; then
        if [ -x "$script" ]; then
            print_status "OK" "$script (executable)"
        else
            print_status "WARN" "$script (not executable - will be fixed)"
            chmod +x "$script" 2>/dev/null
        fi
    else
        print_status "FAIL" "$script missing"
    fi
done

echo ""

# 5. Dependencies
echo "📦 DEPENDENCIES"
echo "--------------"

[ -d node_modules ] && print_status "OK" "node_modules installed" || print_status "WARN" "node_modules not installed (run npm install)"
[ -d vendor ] && print_status "OK" "vendor (composer) installed" || print_status "WARN" "vendor not installed (run composer install)"

# Check if frontend dependencies exist
if [ -d frontend ]; then
    [ -d frontend/node_modules ] && print_status "OK" "frontend dependencies installed" || print_status "WARN" "frontend dependencies missing"
fi

echo ""

# 6. Required npm scripts
echo "🎯 NPM SCRIPTS"
echo "-------------"

required_scripts=("dev:all" "codespace:setup" "codespace:fix" "codespace:health" "codespace:post-start")

for script_name in "${required_scripts[@]}"; do
    if cat package.json | grep -q "\"$script_name\""; then
        print_status "OK" "Script '$script_name' defined"
    else
        print_status "FAIL" "Script '$script_name' missing in package.json"
    fi
done

echo ""

# 7. Port Status
echo "🌐 PORTS"
echo "-------"

ports=(3000 3001 5678 8000 8001 8080)

for port in "${ports[@]}"; do
    if lsof -i:$port &>/dev/null; then
        pid=$(lsof -ti:$port)
        process=$(ps -p $pid -o comm= 2>/dev/null)
        print_status "OK" "Port $port: IN USE by $process (PID: $pid)"
    else
        print_status "WARN" "Port $port: AVAILABLE"
    fi
done

echo ""

# 8. Running Services
echo "🚀 SERVICES"
echo "----------"

if pgrep -f "node.*dev" > /dev/null; then
    print_status "OK" "Node.js development server running"
else
    print_status "WARN" "No Node.js development server detected"
fi

if pgrep -f "uvicorn" > /dev/null; then
    print_status "OK" "FastAPI (uvicorn) running"
else
    print_status "WARN" "FastAPI not running"
fi

if pgrep -f "php.*-S" > /dev/null; then
    print_status "OK" "PHP development server running"
else
    print_status "WARN" "PHP development server not running"
fi

echo ""

# 9. Database
echo "🗄️  DATABASE"
echo "-----------"

if command -v systemctl &>/dev/null; then
    if sudo systemctl is-active --quiet mariadb 2>/dev/null; then
        print_status "OK" "MariaDB service running"
    else
        print_status "WARN" "MariaDB not running (run: sudo systemctl start mariadb)"
    fi
else
    print_status "WARN" "systemctl not available (WSL/Container environment)"
fi

echo ""

# 10. SSH Configuration
echo "🔐 SSH"
echo "-----"

[ -d ~/.ssh ] && print_status "OK" "~/.ssh directory exists" || print_status "WARN" "~/.ssh directory missing"
[ -f ~/.ssh/id_ed25519 ] && print_status "OK" "SSH private key found" || print_status "WARN" "SSH private key not configured"
[ ! -z "$SSH_PRIVATE_KEY" ] && print_status "OK" "SSH_PRIVATE_KEY secret available" || print_status "WARN" "SSH_PRIVATE_KEY secret not set"
[ ! -z "$PLESK_HOST" ] && print_status "OK" "PLESK_HOST configured: $PLESK_HOST" || print_status "WARN" "PLESK_HOST not configured"

echo ""

# 11. Git Status
echo "📚 GIT REPOSITORY"
echo "----------------"

git_branch=$(git branch --show-current 2>/dev/null)
[ ! -z "$git_branch" ] && print_status "OK" "Current branch: $git_branch" || print_status "FAIL" "Not a git repository"

git_status=$(git status --porcelain 2>/dev/null | wc -l)
if [ "$git_status" -eq 0 ]; then
    print_status "OK" "Working directory clean"
else
    print_status "WARN" "Uncommitted changes: $git_status files"
fi

echo ""

# 12. Disk Space
echo "💾 DISK SPACE"
echo "------------"

disk_usage=$(df -h . | tail -n 1 | awk '{print $5}' | sed 's/%//')
if [ "$disk_usage" -lt 80 ]; then
    print_status "OK" "Disk usage: ${disk_usage}%"
elif [ "$disk_usage" -lt 90 ]; then
    print_status "WARN" "Disk usage: ${disk_usage}% (getting full)"
else
    print_status "FAIL" "Disk usage: ${disk_usage}% (critically full)"
fi

echo ""

# Summary
echo "📊 SUMMARY"
echo "---------"
echo ""
echo "🎯 Quick Actions:"
echo ""
echo "  Setup Codespace:        npm run codespace:setup"
echo "  Fix Issues:             npm run codespace:fix"
echo "  Start All Services:     npm run dev:all"
echo "  Health Check:           npm run codespace:health"
echo ""
echo "📖 More Help:"
echo ""
echo "  Quick Start:            cat .devcontainer/CODESPACE-QUICK-START.md"
echo "  Troubleshooting:        cat .devcontainer/CODESPACE-TROUBLESHOOTING.md"
echo "  Full Guide:             cat .devcontainer/CODESPACE-ANLEITUNG.md"
echo ""
echo "✅ Diagnostic complete!"
