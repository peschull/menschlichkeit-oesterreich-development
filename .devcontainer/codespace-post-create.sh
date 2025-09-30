#!/bin/bash
# 🏗️ Post-Create Command for Austrian NGO Codespace
# Handles dependency installation and service setup

# Use pipefail to catch errors in pipelines, but don't exit on first error
set -o pipefail
set +e
echo "🚀 Starting post-create setup for Austrian NGO platform..."

# Function to log with timestamps
log() {
    echo "$(date '+%H:%M:%S') $1"
}

# Function to install with progress
install_with_progress() {
    local command="$1"
    local description="$2"
    
    log "🔄 $description..."
    if eval "$command"; then
        log "✅ $description completed"
        return 0
    else
        log "❌ $description failed"
        return 1
    fi
}

# 1. Install root dependencies
if [ -f package.json ]; then
    log "📦 Installing root npm dependencies..."
    npm ci --prefer-offline --no-audit
fi

# 2. Install frontend dependencies
if [ -d frontend ] && [ -f frontend/package.json ]; then
    log "⚛️ Installing frontend dependencies..."
    cd frontend
    npm ci --prefer-offline --no-audit
    cd ..
fi

# 3. Install API dependencies  
if [ -d api.menschlichkeit-oesterreich.at ] && [ -f api.menschlichkeit-oesterreich.at/requirements.txt ]; then
    log "🐍 Installing Python API dependencies..."
    cd api.menschlichkeit-oesterreich.at
    python3 -m pip install -r requirements.txt
    cd ..
fi

# 4. Install PHP/Composer dependencies
if [ -f composer.json ]; then
    log "🐘 Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader
fi

# 5. Setup Prisma (if exists)
if [ -f schema.prisma ]; then
    log "🗄️ Setting up Prisma..."
    npx prisma generate
fi

# 6. Create development configuration
log "⚙️ Creating development configuration..."

# Create .env files if templates exist
if [ -d config-templates ]; then
    log "📋 Setting up configuration templates..."
    
    # API environment
    if [ -f config-templates/api-env-development.env ] && [ ! -f api.menschlichkeit-oesterreich.at/.env ]; then
        cp config-templates/api-env-development.env api.menschlichkeit-oesterreich.at/.env
        log "✅ API .env configured"
    fi
    
    # Frontend environment  
    if [ -f config-templates/frontend-env-development.env ] && [ ! -f frontend/.env ]; then
        cp config-templates/frontend-env-development.env frontend/.env
        log "✅ Frontend .env configured"
    fi
fi

# 7. Setup VS Code workspace settings
log "💻 Configuring VS Code workspace..."
mkdir -p .vscode

cat > .vscode/settings.json << 'EOF'
{
    "terminal.integrated.defaultProfile.linux": "bash",
    "python.defaultInterpreterPath": "/usr/local/bin/python3",
    "editor.formatOnSave": true,
    "editor.codeActionsOnSave": {
        "source.fixAll.eslint": "explicit"
    },
    "eslint.workingDirectories": ["frontend", "."],
    "files.exclude": {
        "**/node_modules": true,
        "**/vendor": true,
        "**/.git": true
    }
}
EOF

# 8. Create quick start script
cat > codespace-start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Austrian NGO Development Services in Codespace"

# Function to start service in background with logging
start_service() {
    local name=$1
    local port=$2
    local command=$3
    local dir=${4:-.}
    
    echo "Starting $name on port $port..."
    cd $dir
    nohup $command > ../logs/${name}.log 2>&1 &
    echo $! > ../logs/${name}.pid
    cd - > /dev/null
    echo "✅ $name started (PID: $(cat logs/${name}.pid))"
}

# Create logs directory
mkdir -p logs

echo "📋 Available services:"
echo "1. Frontend (React) - Port 3000"
echo "2. API (FastAPI) - Port 8001"  
echo "3. CRM Development Server - Port 8000"
echo "4. Games (Python HTTP) - Port 3000"

read -p "Start all services? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Starting all development services..."
    
    # Start Frontend
    if [ -d frontend ]; then
        start_service "frontend" 3000 "npm run dev" frontend
    fi
    
    # Start API
    if [ -d api.menschlichkeit-oesterreich.at ]; then
        start_service "api" 8001 "python3 -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload" api.menschlichkeit-oesterreich.at
    fi
    
    # Start CRM development
    if [ -d crm.menschlichkeit-oesterreich.at ]; then
        start_service "crm" 8000 "php -S 0.0.0.0:8000 -t httpdocs" crm.menschlichkeit-oesterreich.at
    fi
    
    echo "🎉 All services started!"
    echo "🔍 Check logs in ./logs/ directory"
    echo "🌐 Access services through VS Code port forwarding"
else
    echo "ℹ️ Run individual npm scripts as needed"
fi
EOF

chmod +x codespace-start.sh

# 9. Create service health check
cat > codespace-health.sh << 'EOF'
#!/bin/bash
echo "🏥 Austrian NGO Platform Health Check"
echo "====================================="

# Check processes
if [ -d logs ]; then
    for pidfile in logs/*.pid; do
        if [ -f "$pidfile" ]; then
            service=$(basename "$pidfile" .pid)
            pid=$(cat "$pidfile")
            if kill -0 "$pid" 2>/dev/null; then
                echo "✅ $service (PID: $pid) - Running"
            else
                echo "❌ $service (PID: $pid) - Not running"
            fi
        fi
    done
else
    echo "ℹ️ No services currently running"
fi

echo ""
echo "🌐 Port Status:"
netstat -tlnp 2>/dev/null | grep -E ':(3000|8000|8001|5678)' || echo "ℹ️ No services detected on standard ports"

echo ""
echo "💾 Disk Usage:"
df -h . | tail -n 1

echo ""
echo "🧠 Memory Usage:"
free -h
EOF

chmod +x codespace-health.sh

# 10. Final setup completion
log "🎯 Creating startup message..."
cat > .codespace-ready << 'EOF'
🎉 Austrian NGO Codespace Ready!

Quick Start Commands:
• ./codespace-start.sh     - Start all development services
• ./codespace-health.sh    - Check service health
• npm run dev:all          - Alternative service startup
• npm run quality:gates    - Run quality checks

Development Ports:
• 3000: Frontend (React)
• 8000: CRM Development  
• 8001: API (FastAPI)
• 5678: Debug ports

Next Steps:
1. Run ./codespace-start.sh to begin development
2. Access services through VS Code port forwarding
3. Use integrated terminal for git operations

Happy coding! 🚀
EOF

log "🎉 Post-create setup completed successfully!"
log "📋 Run 'cat .codespace-ready' for quick start guide"

exit 0