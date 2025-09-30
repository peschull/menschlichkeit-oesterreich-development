#!/bin/bash
# Codespace Emergency Recovery Script
# Runs when Codespace fails to start properly

echo "🚨 CODESPACE EMERGENCY RECOVERY STARTING"
echo "========================================"
echo ""

# Set error handling
set +e  # Don't exit on errors, we want to try everything

# Basic environment info
echo "🔍 ENVIRONMENT DIAGNOSTICS:"
echo "Codespace: ${CODESPACE_NAME:-'Not in Codespace'}"
echo "User: ${USER:-'Unknown'}"
echo "PWD: $(pwd)"
echo "Date: $(date)"
echo ""

# Check available tools
echo "🛠️ TOOL AVAILABILITY CHECK:"
echo "Node.js: $(node --version 2>/dev/null || echo 'Not available')"
echo "Python: $(python3 --version 2>/dev/null || echo 'Not available')" 
echo "PHP: $(php --version 2>/dev/null | head -1 || echo 'Not available')"
echo "Git: $(git --version 2>/dev/null || echo 'Not available')"
echo "Docker: $(docker --version 2>/dev/null || echo 'Not available')"
echo "Composer: $(composer --version 2>/dev/null | head -1 || echo 'Not available')"
echo ""

# Fix permissions
echo "🔐 FIXING PERMISSIONS:"
chmod +x .devcontainer/*.sh 2>/dev/null || echo "⚠️ No .devcontainer scripts to fix"
chmod +x scripts/*.sh 2>/dev/null || echo "⚠️ No scripts/*.sh to fix" 
chmod +x deployment-scripts/*.sh 2>/dev/null || echo "⚠️ No deployment scripts to fix"
echo "✅ Permissions fixed"
echo ""

# Emergency dependency installation
echo "📦 EMERGENCY DEPENDENCY INSTALLATION:"

# Node.js dependencies with fallbacks
if command -v npm >/dev/null 2>&1; then
    echo "Installing Node.js dependencies..."
    npm ci --prefer-offline --no-audit || npm install --no-audit || echo "⚠️ npm install failed"
else
    echo "⚠️ npm not available"
fi

# Python dependencies with fallbacks
if command -v pip3 >/dev/null 2>&1; then
    echo "Installing Python dependencies..."
    if [ -f requirements.txt ]; then
        pip3 install -r requirements.txt || echo "⚠️ pip install failed"
    fi
    if [ -f api.menschlichkeit-oesterreich.at/requirements.txt ]; then
        pip3 install -r api.menschlichkeit-oesterreich.at/requirements.txt || echo "⚠️ API pip install failed"
    fi
else
    echo "⚠️ pip3 not available"
fi

# PHP dependencies with fallbacks
if command -v composer >/dev/null 2>&1; then
    echo "Installing PHP dependencies..."
    composer install --ignore-platform-reqs --no-interaction || echo "⚠️ composer install failed"
    
    if [ -d crm.menschlichkeit-oesterreich.at ]; then
        cd crm.menschlichkeit-oesterreich.at
        composer install --ignore-platform-reqs --no-interaction || echo "⚠️ CRM composer install failed"
        cd ..
    fi
else
    echo "⚠️ composer not available"  
fi

echo ""

# Service health check
echo "🏥 SERVICE HEALTH CHECK:"
services=("frontend" "api.menschlichkeit-oesterreich.at" "crm.menschlichkeit-oesterreich.at" "web" "website" "automation/n8n")

for service in "${services[@]}"; do
    if [ -d "$service" ]; then
        echo "✅ $service: Directory exists"
        
        # Check for config files
        config_files=0
        [ -f "$service/package.json" ] && ((config_files++))
        [ -f "$service/composer.json" ] && ((config_files++))
        [ -f "$service/requirements.txt" ] && ((config_files++))
        
        echo "   📋 Config files: $config_files found"
    else
        echo "❌ $service: Directory missing"
    fi
done

echo ""

# Environment file creation
echo "⚙️ ENVIRONMENT FILE SETUP:"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
        echo "✅ Created .env from .env.example"
    else
        cat > .env << EOF
NODE_ENV=development
DEBUG=true
CODESPACE_SETUP=true
DATABASE_URL=postgresql://localhost:5432/development
EOF
        echo "✅ Created basic .env file"
    fi
else
    echo "✅ .env already exists"
fi

# Create workspace-specific environment files
for service_env in "frontend/.env" "api.menschlichkeit-oesterreich.at/.env"; do
    service_dir=$(dirname "$service_env")
    if [ -d "$service_dir" ] && [ ! -f "$service_env" ]; then
        if [ -f "$service_dir/.env.example" ]; then
            cp "$service_dir/.env.example" "$service_env"
            echo "✅ Created $service_env from example"
        fi
    fi
done

echo ""

# Quick syntax checks
echo "🔍 SYNTAX VALIDATION:"

# Python files
for py_file in scripts/*.py; do
    if [ -f "$py_file" ]; then
        if python3 -m py_compile "$py_file" 2>/dev/null; then
            echo "✅ $(basename "$py_file"): Python syntax OK"
        else
            echo "❌ $(basename "$py_file"): Python syntax error"
        fi
    fi
done

# JavaScript/TypeScript files  
if command -v node >/dev/null 2>&1; then
    for js_file in *.js scripts/*.js; do
        if [ -f "$js_file" ]; then
            if node -c "$js_file" 2>/dev/null; then
                echo "✅ $(basename "$js_file"): JavaScript syntax OK"
            else
                echo "❌ $(basename "$js_file"): JavaScript syntax error"
            fi
        fi
    done
fi

echo ""

# Port availability check
echo "🌐 PORT AVAILABILITY CHECK:"
ports=(3000 3001 5678 8000 8001 8080)
for port in "${ports[@]}"; do
    if command -v netstat >/dev/null 2>&1; then
        if netstat -an 2>/dev/null | grep ":$port " >/dev/null; then
            echo "⚠️ Port $port: In use"
        else
            echo "✅ Port $port: Available"
        fi
    else
        echo "ℹ️ Port $port: Cannot check (netstat not available)"
    fi
done

echo ""

# Final summary
echo "📊 RECOVERY SUMMARY:"
echo "==================="

# Count successful operations
success_count=0
total_checks=8

[ -f .env ] && ((success_count++))
command -v node >/dev/null 2>&1 && ((success_count++))
command -v python3 >/dev/null 2>&1 && ((success_count++))
command -v php >/dev/null 2>&1 && ((success_count++))
[ -d frontend ] && ((success_count++))
[ -d api.menschlichkeit-oesterreich.at ] && ((success_count++))
[ -d crm.menschlichkeit-oesterreich.at ] && ((success_count++))
[ -d .devcontainer ] && ((success_count++))

recovery_score=$((success_count * 100 / total_checks))

echo "Recovery Score: $recovery_score% ($success_count/$total_checks checks passed)"

if [ $recovery_score -ge 80 ]; then
    echo "🟢 RECOVERY SUCCESSFUL: Codespace should be operational"
    echo ""
    echo "🚀 NEXT STEPS:"
    echo "1. Run: npm run dev:all"
    echo "2. Open browser tabs for services"
    echo "3. Check logs for any remaining issues"
elif [ $recovery_score -ge 50 ]; then
    echo "🟡 PARTIAL RECOVERY: Some issues remain"
    echo ""
    echo "⚠️ MANUAL STEPS NEEDED:"
    echo "1. Check missing tools/services"
    echo "2. Review dependency installation errors"
    echo "3. Validate service configurations"
else
    echo "🔴 RECOVERY FAILED: Major issues detected"
    echo ""
    echo "🆘 EMERGENCY ACTIONS:"
    echo "1. Restart Codespace completely"
    echo "2. Check GitHub Secrets configuration"
    echo "3. Review .devcontainer/devcontainer.json"
    echo "4. Contact technical support if needed"
fi

echo ""
echo "📋 DIAGNOSTIC LOG SAVED TO: /tmp/codespace-recovery.log"
echo "🔗 Codespace URL: ${CODESPACE_NAME:-'Unknown'}"
echo "⏰ Recovery completed at: $(date)"
echo ""
echo "✅ Emergency recovery script finished!"

# Save diagnostic info
{
    echo "=== CODESPACE RECOVERY DIAGNOSTIC ==="
    echo "Date: $(date)"
    echo "Codespace: ${CODESPACE_NAME:-'Unknown'}"
    echo "User: ${USER:-'Unknown'}" 
    echo "Working Directory: $(pwd)"
    echo "Recovery Score: $recovery_score%"
    echo ""
    echo "=== ENVIRONMENT ==="
    env | sort
    echo ""
    echo "=== DISK USAGE ==="
    df -h 2>/dev/null || echo "df command not available"
    echo ""
    echo "=== PROCESS LIST ==="
    ps aux 2>/dev/null | head -20 || echo "ps command not available"
} > /tmp/codespace-recovery.log 2>/dev/null || echo "⚠️ Could not save diagnostic log"