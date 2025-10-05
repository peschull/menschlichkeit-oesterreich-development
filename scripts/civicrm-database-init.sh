#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# CiviCRM Database Initialization Script
# ============================================================================
# Purpose: Initialize mo_crm database for Drupal 10 + CiviCRM
# Created: 05.10.2025
# Database: mo_crm (MariaDB 10.11 Docker Container)
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Load database credentials
if [[ -f "$PROJECT_ROOT/.env.database" ]]; then
    source "$PROJECT_ROOT/.env.database"
else
    echo "❌ Error: .env.database not found!"
    exit 1
fi

echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║       🏥 CiviCRM Database Initialization                          ║"
echo "║                                                                   ║"
echo "╠═══════════════════════════════════════════════════════════════════╣"
echo "║  Database: mo_crm (MariaDB 10.11)                                ║"
echo "║  User:     svc_crm                                               ║"
echo "║  Container: mo_mariadb                                            ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

# Check Docker container
if ! docker ps | grep -q "mo_mariadb"; then
    echo "❌ Error: mo_mariadb container not running!"
    echo "   Run: npm run db:start"
    exit 1
fi

echo "✅ Docker container mo_mariadb is running"
echo ""

# Test database connection
echo "🔍 Testing database connection..."
if docker exec mo_mariadb mysql -u"$MO_CRM_DB_USER" -p"$MO_CRM_DB_PASS" -e "USE mo_crm; SELECT 'Connection OK' AS status;" 2>/dev/null | grep -q "Connection OK"; then
    echo "✅ Database connection successful"
else
    echo "❌ Error: Cannot connect to mo_crm database"
    echo "   Check credentials in .env.database"
    exit 1
fi
echo ""

# Check if Drupal tables exist
echo "🔍 Checking Drupal installation status..."
TABLE_COUNT=$(docker exec mo_mariadb mysql -u"$MO_CRM_DB_USER" -p"$MO_CRM_DB_PASS" -D mo_crm -N -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'mo_crm';" 2>/dev/null || echo "0")

if [[ "$TABLE_COUNT" -gt 0 ]]; then
    echo "⚠️  Warning: mo_crm database contains $TABLE_COUNT tables"
    echo "   This may be an existing Drupal/CiviCRM installation"
    echo ""
    read -p "   Continue anyway? This may overwrite data (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted by user"
        exit 1
    fi
else
    echo "✅ Database is empty - ready for fresh installation"
fi
echo ""

# Navigate to CRM directory
CRM_DIR="$PROJECT_ROOT/crm.menschlichkeit-oesterreich.at"
if [[ ! -d "$CRM_DIR" ]]; then
    echo "❌ Error: CRM directory not found: $CRM_DIR"
    exit 1
fi

cd "$CRM_DIR"
echo "📂 Working directory: $CRM_DIR"
echo ""

# Check if Drush is available
if [[ ! -f "vendor/bin/drush" ]]; then
    echo "⚠️  Warning: Drush not found. Installing dependencies..."
    composer install --no-interaction --optimize-autoloader
    echo ""
fi

echo "🚀 Starting Drupal installation..."
echo ""
echo "   This will:"
echo "   1. Install Drupal 10 core"
echo "   2. Create admin user"
echo "   3. Configure database settings"
echo "   4. Initialize CiviCRM"
echo ""

# Run Drupal installation
./vendor/bin/drush site:install standard \
    --db-url="mysql://svc_crm:${MO_CRM_DB_PASS}@localhost:3306/mo_crm" \
    --site-name="Menschlichkeit Österreich CRM" \
    --account-name=admin \
    --account-pass="${DRUPAL_ADMIN_PASS:-Admin123!Secure}" \
    --account-mail=admin@menschlichkeit-oesterreich.at \
    --locale=de \
    --yes

echo ""
echo "✅ Drupal installation complete"
echo ""

# Install CiviCRM module (if available)
if ./vendor/bin/drush pm-list | grep -q "civicrm"; then
    echo "🔧 Installing CiviCRM module..."
    ./vendor/bin/drush pm-enable civicrm --yes
    echo "✅ CiviCRM module enabled"
else
    echo "⚠️  CiviCRM module not found in Drupal"
    echo "   Install manually via: composer require civicrm/civicrm-drupal-8"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════════╗"
echo "║                                                                   ║"
echo "║       ✅ CiviCRM Database Initialization Complete!                ║"
echo "║                                                                   ║"
echo "╠═══════════════════════════════════════════════════════════════════╣"
echo "║  Access CRM:  https://crm.menschlichkeit-oesterreich.at          ║"
echo "║  Admin User:  admin                                              ║"
echo "║  Admin Pass:  ${DRUPAL_ADMIN_PASS:-Admin123!Secure}             ║"
echo "║                                                                   ║"
echo "║  Database:    mo_crm                                             ║"
echo "║  Tables:      Run: npm run db:shell:mariadb                      ║"
echo "║               Then: USE mo_crm; SHOW TABLES;                     ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Next Steps:"
echo "   1. Deploy to Plesk: ./deployment-scripts/deploy-crm-plesk.sh"
echo "   2. Configure CiviCRM extensions"
echo "   3. Import member data"
echo "   4. Setup SEPA payment integration"
echo ""
