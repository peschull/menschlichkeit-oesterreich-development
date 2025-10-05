#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# Start All Services Script
# ============================================================================
# Purpose: Start API, n8n, and Frontend Development Servers
# Created: 05.10.2025
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║       🚀 Starting All Services                                     ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Load environment
if [[ -f "$PROJECT_ROOT/.env.database" ]]; then
    source "$PROJECT_ROOT/.env.database"
else
    echo "⚠️  Warning: .env.database not found - some services may fail"
fi

# Function to check if port is in use
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0  # Port is in use
    else
        return 1  # Port is free
    fi
}

# ============================================================================
# 1. API Service (FastAPI on port 8000)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 Starting API Service (FastAPI)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if check_port 8000; then
    echo "⚠️  Port 8000 already in use - skipping API start"
else
    cd "$PROJECT_ROOT/api.menschlichkeit-oesterreich.at"

    # Export environment variables
    export DATABASE_URL="mysql://svc_api_stg:${MO_API_STG_DB_PASS:-password}@localhost:3306/mo_api_stg"
    export JWT_SECRET="${JWT_SECRET:-$(openssl rand -base64 32)}"
    export ENVIRONMENT="development"
    export DEBUG="true"

    echo "Starting uvicorn in background..."
    nohup uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload > "$PROJECT_ROOT/api-service.log" 2>&1 &
    API_PID=$!
    echo "✅ API started (PID: $API_PID)"
    echo "   URL: http://localhost:8000"
    echo "   Docs: http://localhost:8000/docs"
    echo "   Logs: tail -f $PROJECT_ROOT/api-service.log"
fi
echo ""

# ============================================================================
# 2. n8n Automation (Docker on port 5678)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Starting n8n Automation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if check_port 5678; then
    echo "⚠️  Port 5678 already in use - skipping n8n start"
else
    if [[ -f "$PROJECT_ROOT/automation/n8n/docker-compose.yml" ]]; then
        cd "$PROJECT_ROOT/automation/n8n"
        echo "Starting n8n via docker-compose..."
        docker-compose up -d
        echo "✅ n8n started"
        echo "   URL: http://localhost:5678"
        echo "   Login: admin / Admin123!Secure"
        echo "   Logs: docker-compose logs -f"
    else
        echo "⚠️  docker-compose.yml not found - skipping n8n"
    fi
fi
echo ""

# ============================================================================
# 3. Frontend (Vite on port 5173)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚛️  Starting Frontend Development Server"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if check_port 5173; then
    echo "⚠️  Port 5173 already in use - skipping frontend start"
else
    cd "$PROJECT_ROOT/frontend"
    echo "Starting Vite dev server in background..."
    nohup npm run dev > "$PROJECT_ROOT/frontend-dev.log" 2>&1 &
    FRONTEND_PID=$!
    echo "✅ Frontend started (PID: $FRONTEND_PID)"
    echo "   URL: http://localhost:5173"
    echo "   Logs: tail -f $PROJECT_ROOT/frontend-dev.log"
fi
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║       ✅ All Services Started Successfully!                        ║"
echo "║                                                                    ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║                                                                    ║"
echo "║  📊 Service Overview:                                             ║"
echo "║                                                                    ║"
echo "║  🔌 API Service:        http://localhost:8000                     ║"
echo "║     Swagger UI:         http://localhost:8000/docs                ║"
echo "║                                                                    ║"
echo "║  🔄 n8n Automation:     http://localhost:5678                     ║"
echo "║     Login:              admin / Admin123!Secure                   ║"
echo "║                                                                    ║"
echo "║  ⚛️  Frontend:           http://localhost:5173                     ║"
echo "║                                                                    ║"
echo "║  🗄️  Database Admin:                                              ║"
echo "║     phpMyAdmin:         http://localhost:8080                     ║"
echo "║     pgAdmin:            http://localhost:8081                     ║"
echo "║                                                                    ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║                                                                    ║"
echo "║  🛑 To Stop All Services:                                         ║"
echo "║     pkill -f uvicorn                                              ║"
echo "║     pkill -f vite                                                 ║"
echo "║     cd automation/n8n && docker-compose down                      ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Wait a moment for services to fully start
sleep 3

# Show running processes
echo "🔍 Running Service Processes:"
echo ""
ps aux | grep -E "uvicorn|node.*vite|docker.*n8n" | grep -v grep || echo "   (checking...)"
echo ""

echo "✨ All services are running! Open your browser and test the URLs above."
echo ""
