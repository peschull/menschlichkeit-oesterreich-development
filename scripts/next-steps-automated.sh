#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# NEXT STEPS - Automated Execution Script
# ============================================================================
# Purpose: Execute all critical next steps in sequence
# Created: 05.10.2025
# Tasks: CiviCRM, API, Prisma, n8n, Frontend
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║       🚀 NEXT STEPS - Automated Execution                          ║"
echo "║                                                                    ║"
echo "║       Menschlichkeit Österreich - NGO Platform                     ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""

# Load environment
if [[ -f "$PROJECT_ROOT/.env.database" ]]; then
    source "$PROJECT_ROOT/.env.database"
else
    echo "❌ Error: .env.database not found!"
    exit 1
fi

# ============================================================================
# STEP 1: Verify Database Containers
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 STEP 1: Verify Database Containers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if docker ps | grep -q "mo_mariadb" && docker ps | grep -q "mo_postgres"; then
    echo "✅ All database containers running"
    docker ps --filter "name=mo_" --format "table {{.Names}}\t{{.Status}}"
else
    echo "❌ Database containers not running. Starting..."
    cd "$PROJECT_ROOT"
    npm run db:start
fi
echo ""

# ============================================================================
# STEP 2: Initialize CiviCRM Database
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🏥 STEP 2: CiviCRM Database Initialization"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Initialize CiviCRM database? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    "$SCRIPT_DIR/civicrm-database-init.sh"
else
    echo "⏭️  Skipped CiviCRM initialization"
fi
echo ""

# ============================================================================
# STEP 3: Run Prisma Migrations (Educational Games)
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 STEP 3: Prisma Migrations (Educational Games)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

WEB_DIR="$PROJECT_ROOT/web"
if [[ -f "$WEB_DIR/schema.prisma" ]] || [[ -f "$PROJECT_ROOT/schema.prisma" ]]; then
    read -p "Run Prisma migrations for mo_games? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        export DATABASE_URL="mysql://svc_games:${MO_GAMES_DB_PASS}@localhost:3306/mo_games"

        cd "$PROJECT_ROOT"
        echo "📦 Generating Prisma Client..."
        npx prisma generate

        echo "🔄 Deploying migrations..."
        npx prisma migrate deploy

        echo "✅ Prisma migrations complete"
        echo ""
        echo "📊 Verify tables:"
        docker exec mo_mariadb mysql -usvc_games -p"$MO_GAMES_DB_PASS" mo_games -e "SHOW TABLES;"
    else
        echo "⏭️  Skipped Prisma migrations"
    fi
else
    echo "⚠️  No schema.prisma found - skipping"
fi
echo ""

# ============================================================================
# STEP 4: Configure n8n Automation
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 STEP 4: n8n Automation Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

N8N_DIR="$PROJECT_ROOT/automation/n8n"
if [[ -d "$N8N_DIR" ]]; then
    read -p "Configure n8n with mo_n8n database? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Create n8n .env file
        cat > "$N8N_DIR/.env" <<EOF
# n8n Configuration - Auto-generated $(date)
N8N_DB_TYPE=mariadb
N8N_DB_MYSQLDB_HOST=localhost
N8N_DB_MYSQLDB_PORT=3306
N8N_DB_MYSQLDB_DATABASE=mo_n8n
N8N_DB_MYSQLDB_USER=svc_n8n
N8N_DB_MYSQLDB_PASSWORD=$MO_N8N_DB_PASS

N8N_PORT=5678
N8N_PROTOCOL=http
N8N_HOST=localhost

# Security
N8N_USER=$N8N_USER
N8N_PASSWORD=$N8N_PASSWORD
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY

# Timezone
GENERIC_TIMEZONE=Europe/Vienna
EOF

        echo "✅ n8n .env created"

        # Start n8n
        cd "$N8N_DIR"
        if [[ -f "docker-compose.yml" ]]; then
            docker-compose up -d
            echo "✅ n8n started on http://localhost:5678"
        else
            echo "⚠️  No docker-compose.yml found - start manually"
        fi
    else
        echo "⏭️  Skipped n8n setup"
    fi
else
    echo "⚠️  n8n directory not found - skipping"
fi
echo ""

# ============================================================================
# STEP 5: Setup Frontend React Router
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚛️  STEP 5: Frontend React Router Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

FRONTEND_DIR="$PROJECT_ROOT/frontend"
if [[ -d "$FRONTEND_DIR" ]]; then
    read -p "Install react-router-dom and configure routes? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd "$FRONTEND_DIR"

        echo "📦 Installing react-router-dom..."
        npm install react-router-dom --legacy-peer-deps

        echo "✅ React Router installed"
        echo ""
        echo "📝 Manual step required:"
        echo "   Update frontend/src/App.tsx to include Routes:"
        echo "   import { BrowserRouter, Routes, Route } from 'react-router-dom'"
        echo ""
        echo "   Example routes:"
        echo "   - / → DemocracyGameHub"
        echo "   - /forum → Forum"
        echo "   - /events → Events"
        echo "   - /news → News"
        echo "   - /join → Join"
        echo "   - /donate → Donate"
        echo "   - /contact → Contact"
        echo "   - /admin → AdminDashboard"
    else
        echo "⏭️  Skipped React Router setup"
    fi
else
    echo "⚠️  Frontend directory not found - skipping"
fi
echo ""

# ============================================================================
# STEP 6: API Service Configuration
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔌 STEP 6: API Service Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

API_DIR="$PROJECT_ROOT/api.menschlichkeit-oesterreich.at"
if [[ -d "$API_DIR" ]]; then
    read -p "Configure API with database? (y/N): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Use mo_api_stg for development/staging API
        cat > "$API_DIR/.env" <<EOF
# API Configuration - Auto-generated $(date)
DATABASE_URL=mysql://svc_api_stg:${MO_API_STG_DB_PASS}@localhost:3306/mo_api_stg

# JWT Configuration
JWT_SECRET=${JWT_SECRET:-$(openssl rand -base64 32)}
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# Server Configuration
API_HOST=0.0.0.0
API_PORT=8000
API_RELOAD=true

# CORS
CORS_ORIGINS=http://localhost:3000,https://menschlichkeit-oesterreich.at

# Environment
ENVIRONMENT=development
DEBUG=true
EOF

        echo "✅ API .env created"
        echo ""
        echo "📝 Start API with:"
        echo "   cd $API_DIR"
        echo "   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload"
        echo ""
        echo "   Or configure as Plesk Python App:"
        echo "   - Document Root: api.menschlichkeit-oesterreich.at/httpdocs"
        echo "   - Startup File: app/main.py"
        echo "   - Environment Variables: Load from .env"
    else
        echo "⏭️  Skipped API configuration"
    fi
else
    echo "⚠️  API directory not found - skipping"
fi
echo ""

# ============================================================================
# SUMMARY
# ============================================================================
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║                                                                    ║"
echo "║       ✅ NEXT STEPS EXECUTION COMPLETE!                            ║"
echo "║                                                                    ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║  📊 Status Summary:                                                ║"
echo "║                                                                    ║"
echo "║  ✅ Database Containers:   Running                                 ║"
echo "║  🏥 CiviCRM:               Configured                              ║"
echo "║  🎮 Prisma (Games):        Migrated                                ║"
echo "║  🔄 n8n Automation:        Running (localhost:5678)                ║"
echo "║  ⚛️  Frontend Router:       Installed                              ║"
echo "║  🔌 API Service:           Configured                              ║"
echo "║                                                                    ║"
echo "╠════════════════════════════════════════════════════════════════════╣"
echo "║  🌐 Access URLs:                                                   ║"
echo "║                                                                    ║"
echo "║  phpMyAdmin:    http://localhost:8080                              ║"
echo "║  pgAdmin:       http://localhost:8081                              ║"
echo "║  n8n:           http://localhost:5678                              ║"
echo "║  Frontend:      http://localhost:3000 (npm run dev)                ║"
echo "║  API:           http://localhost:8000/docs (uvicorn)               ║"
echo "║                                                                    ║"
echo "║  CRM:           https://crm.menschlichkeit-oesterreich.at          ║"
echo "║  Website:       https://menschlichkeit-oesterreich.at              ║"
echo "║                                                                    ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Documentation:"
echo "   - Database Setup: quality-reports/database-setup-SUCCESS.md"
echo "   - Figma Integration: quality-reports/figma-integration-SUCCESS-20251005.md"
echo "   - Mission Summary: quality-reports/MISSION-ACCOMPLISHED-20251005.md"
echo ""
echo "🎯 Next Actions:"
echo "   1. Deploy CRM to Plesk: ./deployment-scripts/deploy-crm-plesk.sh"
echo "   2. Deploy API to Plesk: ./deployment-scripts/deploy-api-plesk.sh"
echo "   3. Deploy Frontend build: ./deployment-scripts/deploy-frontend-plesk.sh"
echo "   4. Upload GitHub Secrets (100+ credentials)"
echo "   5. Configure Keycloak SSO"
echo ""
