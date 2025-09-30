#!/bin/bash
# 🚀 Codespace Quick Start Script for Austrian NGO Platform

set -e
echo "🚀 Starting Austrian NGO Development Services..."

# Function to log with colors and timestamps
log() {
    echo "[$(date '+%H:%M:%S')] $1"
}

log_success() {
    echo -e "[$(date '+%H:%M:%S')] \033[32m✅ $1\033[0m"
}

log_info() {
    echo -e "[$(date '+%H:%M:%S')] \033[34mℹ️ $1\033[0m"
}

log_warning() {
    echo -e "[$(date '+%H:%M:%S')] \033[33m⚠️ $1\033[0m"
}

# Create logs directory
mkdir -p logs

# Function to start service in background with logging
start_service() {
    local name=$1
    local port=$2
    local command=$3
    local dir=${4:-.}
    
    log_info "Starting $name on port $port..."
    
    cd "$dir"
    nohup $command > "../logs/${name}.log" 2>&1 &
    local pid=$!
    echo $pid > "../logs/${name}.pid"
    cd - > /dev/null
    
    # Wait a moment and check if process is still running
    sleep 2
    if kill -0 $pid 2>/dev/null; then
        log_success "$name started successfully (PID: $pid)"
        return 0
    else
        log_warning "$name failed to start (check logs/${name}.log)"
        return 1
    fi
}

# Function to check if port is available
check_port() {
    local port=$1
    if lsof -i:$port &>/dev/null; then
        return 1  # Port is busy
    else
        return 0  # Port is available
    fi
}

# Check and stop existing services
log_info "Checking for existing services..."
pkill -f "uvicorn\|node\|python.*server\|php.*server" 2>/dev/null || true
sleep 2

# Check system requirements
log_info "Verifying system requirements..."

# Check Node.js
if ! command -v node &> /dev/null; then
    log_warning "Node.js not found. Please install Node.js 20+"
    exit 1
fi

# Check Python
if ! command -v python3 &> /dev/null; then
    log_warning "Python3 not found. Please install Python 3.12+"
    exit 1
fi

# Check dependencies
log_info "Checking dependencies..."

if [ ! -d "node_modules" ]; then
    log_info "Installing Node.js dependencies..."
    npm ci
fi

# Start services based on available directories
log_info "Starting available services..."

services_started=0

# 1. Start API (FastAPI) - Port 8001
if [ -d "api.menschlichkeit-oesterreich.at" ] && [ -f "api.menschlichkeit-oesterreich.at/app/main.py" ]; then
    if check_port 8001; then
        log_info "Starting FastAPI server..."
        if start_service "fastapi" 8001 "python -m uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload" "api.menschlichkeit-oesterreich.at"; then
            services_started=$((services_started + 1))
        fi
    else
        log_warning "Port 8001 is busy, skipping FastAPI"
    fi
else
    log_info "FastAPI directory not found, skipping"
fi

# 2. Start Frontend (React) - Port 3000
if [ -d "frontend" ] && [ -f "frontend/package.json" ]; then
    if check_port 3000; then
        log_info "Starting React frontend..."
        cd frontend
        if [ ! -d "node_modules" ]; then
            log_info "Installing frontend dependencies..."
            npm ci
        fi
        cd ..
        if start_service "frontend" 3000 "npm run dev" "frontend"; then
            services_started=$((services_started + 1))
        fi
    else
        log_warning "Port 3000 is busy, skipping Frontend"
    fi
else
    log_info "Frontend directory not found, skipping"
fi

# 3. Start CRM Development Server - Port 8000
if [ -d "crm.menschlichkeit-oesterreich.at" ]; then
    if check_port 8000; then
        log_info "Starting CRM development server..."
        if start_service "crm" 8000 "php -S 0.0.0.0:8000 -t httpdocs" "crm.menschlichkeit-oesterreich.at"; then
            services_started=$((services_started + 1))
        fi
    else
        log_warning "Port 8000 is busy, skipping CRM"
    fi
else
    log_info "CRM directory not found, skipping"
fi

# 4. Start Games Platform - Port 3001
if [ -d "web/games" ]; then
    if check_port 3001; then
        log_info "Starting Games platform..."
        if start_service "games" 3001 "python3 -m http.server 3001" "web/games"; then
            services_started=$((services_started + 1))
        fi
    else
        log_warning "Port 3001 is busy, skipping Games"
    fi
else
    log_info "Games directory not found, skipping"
fi

# 5. Start Website Development Server - Port 8080
if [ -d "website" ]; then
    if check_port 8080; then
        log_info "Starting Website development server..."
        if start_service "website" 8080 "python3 -m http.server 8080" "website"; then
            services_started=$((services_started + 1))
        fi
    else
        log_warning "Port 8080 is busy, skipping Website"
    fi
else
    log_info "Website directory not found, skipping"
fi

# Wait for services to fully start
log_info "Waiting for services to initialize..."
sleep 5

# Service status summary
log_success "Service startup completed!"
echo ""
echo "📊 SERVICES STARTED: $services_started"
echo "=================================="

# Check service health
services_healthy=0

if curl -s http://localhost:3000 &>/dev/null; then
    echo "✅ Frontend (React): http://localhost:3000"
    services_healthy=$((services_healthy + 1))
fi

if curl -s http://localhost:8001/health &>/dev/null || curl -s http://localhost:8001 &>/dev/null; then
    echo "✅ API (FastAPI): http://localhost:8001"
    echo "  📚 Docs: http://localhost:8001/docs"
    services_healthy=$((services_healthy + 1))
fi

if curl -s http://localhost:8000 &>/dev/null; then
    echo "✅ CRM Development: http://localhost:8000"
    services_healthy=$((services_healthy + 1))
fi

if curl -s http://localhost:3001 &>/dev/null; then
    echo "✅ Games Platform: http://localhost:3001"
    services_healthy=$((services_healthy + 1))
fi

if curl -s http://localhost:8080 &>/dev/null; then
    echo "✅ Website: http://localhost:8080"
    services_healthy=$((services_healthy + 1))
fi

echo ""
echo "🌐 PORT FORWARDING (VS Code):"
echo "=================================="
echo "In VS Code, these ports should be automatically forwarded:"
echo "• 3000 → Frontend (will open preview automatically)"
echo "• 8001 → API + Documentation"
echo "• 8000 → CRM Development"
echo "• 3001 → Games Platform"
echo "• 8080 → Website"
echo ""

if [ $services_healthy -eq 0 ]; then
    log_warning "No services are responding. Check logs in ./logs/"
    echo "🐛 Troubleshooting:"
    echo "• Check logs: ls -la logs/"
    echo "• Health check: ./codespace-health.sh"
    echo "• Manual restart: pkill -f 'uvicorn|node|python.*server' && ./codespace-start.sh"
elif [ $services_healthy -lt $services_started ]; then
    log_warning "Some services may need more time to start or have issues."
    echo "ℹ️ Check individual service logs in ./logs/"
else
    log_success "All services are healthy and responding!"
    echo "🎉 Austrian NGO Development Environment is ready!"
fi

echo ""
echo "📚 USEFUL COMMANDS:"
echo "=================================="
echo "• Health check: ./codespace-health.sh"
echo "• Stop all: pkill -f 'uvicorn|node|python.*server'"
echo "• View logs: tail -f logs/[service].log"
echo "• Restart service: kill \$(cat logs/[service].pid) && ./codespace-start.sh"
echo ""

log_success "Startup script completed!"
echo "Happy coding! 🇦🇹💻"