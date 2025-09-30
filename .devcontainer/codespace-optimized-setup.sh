#!/bin/bash
# 🚀 Optimized GitHub Codespace Setup for Austrian NGO Development
# Designed for fast, reliable initialization

set -e
echo "🔧 Starting optimized Codespace setup..."

# Environment setup
export DEBIAN_FRONTEND=noninteractive
export NODE_ENV=development
export CODESPACE_SETUP=true

# Function to log with timestamps
log() {
    echo "$(date '+%H:%M:%S') $1"
}

# Function to install with retry
install_with_retry() {
    local command="$1"
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        log "Attempt $attempt: $command"
        if eval "$command"; then
            log "✅ Success: $command"
            return 0
        else
            log "❌ Failed attempt $attempt: $command"
            attempt=$((attempt + 1))
            [ $attempt -le $max_attempts ] && sleep 2
        fi
    done
    
    log "⚠️ Failed after $max_attempts attempts: $command"
    return 1
}

# 1. Update system (fast)
log "📦 Updating system packages..."
sudo apt-get update -qq

# 2. Install essential tools
log "🛠️ Installing essential development tools..."
install_with_retry "sudo apt-get install -y curl wget git unzip zip jq build-essential"

# 3. Verify Node.js version (should be 20 from features)
log "🟢 Verifying Node.js installation..."
node_version=$(node --version)
log "Node.js version: $node_version"

if [[ "$node_version" != v20* ]]; then
    log "⚠️ Node.js version not 20, but continuing..."
fi

# 4. Verify Python version (should be 3.12 from features)  
log "🐍 Verifying Python installation..."
python_version=$(python3 --version)
log "Python version: $python_version"

# 5. Install global npm packages (essential only)
log "📦 Installing essential global npm packages..."
install_with_retry "npm install -g npm@latest"

# 6. Setup workspace-specific configurations
log "⚙️ Configuring workspace..."

# Create essential directories
mkdir -p logs quality-reports test-results

# Set proper permissions
chmod +x .devcontainer/*.sh 2>/dev/null || true

# 7. Quick dependency pre-check (don't install yet)
log "🔍 Pre-checking dependencies..."
if [ -f package.json ]; then
    log "✅ Root package.json found"
else
    log "⚠️ No root package.json found"
fi

if [ -f composer.json ]; then
    log "✅ Composer.json found"
else
    log "⚠️ No composer.json found"
fi

# 8. Setup git configuration
log "📝 Configuring Git for Codespace..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global user.name "GitHub Codespace" 2>/dev/null || true
git config --global user.email "codespace@github.local" 2>/dev/null || true

# 9. Create quick health check script
cat > /tmp/health-check.sh << 'EOF'
#!/bin/bash
echo "🏥 System Health Check:"
echo "Node.js: $(node --version)"
echo "NPM: $(npm --version)"  
echo "Python: $(python3 --version)"
echo "PHP: $(php --version | head -n1)"
echo "Git: $(git --version)"
echo "Working Directory: $(pwd)"
echo "✅ Basic health check completed"
EOF
chmod +x /tmp/health-check.sh

# 10. Finalization
log "🎉 Optimized setup completed!"
log "📋 Next steps will be handled by postCreateCommand"
log "🚀 Codespace is ready for Austrian NGO development"

# Run health check
/tmp/health-check.sh

exit 0