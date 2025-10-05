#!/bin/bash
# Database Quick-Start Guide - Menschlichkeit Österreich
# Automatisierte Provisionierung der kritischen Datenbanken

set -e  # Exit on error

echo "🗄️  Datenbank Quick-Start - Menschlichkeit Österreich"
echo "=================================================="
echo ""

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktion: Prüfe ob Variable gesetzt ist
check_env() {
    if [ -z "${!1}" ]; then
        echo -e "${RED}❌ Fehler: $1 nicht gesetzt${NC}"
        echo "   Bitte setzen: export $1='your-value'"
        return 1
    else
        echo -e "${GREEN}✓${NC} $1 gesetzt"
        return 0
    fi
}

echo "📋 Schritt 1: Umgebungsvariablen prüfen"
echo "---------------------------------------"

# MariaDB Admin-Credentials prüfen
MISSING=0
check_env "MYSQL_HOST" || MISSING=$((MISSING + 1))
check_env "MYSQL_ADMIN_USER" || MISSING=$((MISSING + 1))
check_env "MYSQL_ADMIN_PASS" || MISSING=$((MISSING + 1))

# PostgreSQL Admin-Credentials prüfen
check_env "PG_HOST" || MISSING=$((MISSING + 1))
check_env "PG_ADMIN_USER" || MISSING=$((MISSING + 1))
check_env "PG_ADMIN_PASS" || MISSING=$((MISSING + 1))

if [ $MISSING -gt 0 ]; then
    echo ""
    echo -e "${RED}⚠️  $MISSING Umgebungsvariablen fehlen!${NC}"
    echo ""
    echo "Beispiel für DigitalOcean Managed Database:"
    echo "  export MYSQL_HOST='db-mysql-fra1-12345.db.ondigitalocean.com'"
    echo "  export MYSQL_ADMIN_USER='doadmin'"
    echo "  export MYSQL_ADMIN_PASS='your-admin-password'"
    echo ""
    echo "  export PG_HOST='db-postgresql-fra1-67890.db.ondigitalocean.com'"
    echo "  export PG_ADMIN_USER='doadmin'"
    echo "  export PG_ADMIN_PASS='your-admin-password'"
    echo ""
    exit 1
fi

echo ""
echo "✅ Alle Admin-Credentials gesetzt!"
echo ""

# Passwörter generieren (falls nicht vorhanden)
generate_password() {
    openssl rand -base64 32 | tr -d "=+/" | cut -c1-32
}

echo "🔐 Schritt 2: Datenbank-Passwörter generieren"
echo "---------------------------------------------"

# MariaDB Passwörter
export MO_CRM_DB_PASS=${MO_CRM_DB_PASS:-$(generate_password)}
export MO_GAMES_DB_PASS=${MO_GAMES_DB_PASS:-$(generate_password)}
export MO_N8N_DB_PASS=${MO_N8N_DB_PASS:-$(generate_password)}
export MO_CONSENT_DB_PASS=${MO_CONSENT_DB_PASS:-$(generate_password)}
export MO_HOOKS_DB_PASS=${MO_HOOKS_DB_PASS:-$(generate_password)}
export MO_ANALYTICS_DB_PASS=${MO_ANALYTICS_DB_PASS:-$(generate_password)}
export MO_NEXTCLOUD_DB_PASS=${MO_NEXTCLOUD_DB_PASS:-$(generate_password)}
export MO_API_STG_DB_PASS=${MO_API_STG_DB_PASS:-$(generate_password)}
export MO_ADMIN_STG_DB_PASS=${MO_ADMIN_STG_DB_PASS:-$(generate_password)}

# PostgreSQL Passwörter
export PG_IDP_DB_PASS=${PG_IDP_DB_PASS:-$(generate_password)}
export PG_GRAFANA_DB_PASS=${PG_GRAFANA_DB_PASS:-$(generate_password)}
export PG_DISCOURSE_DB_PASS=${PG_DISCOURSE_DB_PASS:-$(generate_password)}

echo "✅ Passwörter generiert (32 Zeichen, sicher)"
echo ""

# Dry-Run Modus?
DRY_RUN=${DRY_RUN:-true}
if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}🔍 DRY-RUN Modus aktiviert (keine Änderungen)${NC}"
    echo "   Zum Ausführen: export DRY_RUN=false && bash $0"
    ACTION_FLAG="--dry-run"
else
    echo -e "${GREEN}✅ APPLY Modus - Datenbanken werden erstellt!${NC}"
    ACTION_FLAG="--apply"
fi
echo ""

echo "🚀 Schritt 3: MariaDB-Datenbanken provisionieren"
echo "------------------------------------------------"

MARIADB_DBS=(
    "mo_crm:svc_crm:$MO_CRM_DB_PASS:CRITICAL - CiviCRM"
    "mo_games:svc_games:$MO_GAMES_DB_PASS:HIGH - Educational Games"
    "mo_n8n:svc_n8n:$MO_N8N_DB_PASS:HIGH - n8n Automation"
    "mo_consent:svc_consent:$MO_CONSENT_DB_PASS:HIGH - DSGVO"
    "mo_hooks:svc_hooks:$MO_HOOKS_DB_PASS:MEDIUM - Webhooks"
    "mo_analytics:svc_analytics:$MO_ANALYTICS_DB_PASS:MEDIUM - Analytics"
    "mo_nextcloud:svc_nextcloud:$MO_NEXTCLOUD_DB_PASS:MEDIUM - Nextcloud"
    "mo_api_stg:svc_api_stg:$MO_API_STG_DB_PASS:LOW - API Staging"
    "mo_admin_stg:svc_admin_stg:$MO_ADMIN_STG_DB_PASS:LOW - Admin Staging"
)

for db_entry in "${MARIADB_DBS[@]}"; do
    IFS=':' read -r db_name db_user db_pass priority <<< "$db_entry"

    echo "  📦 $db_name ($priority)"

    if [ -f "scripts/db/provision-mariadb.sh" ]; then
        bash scripts/db/provision-mariadb.sh \
            $ACTION_FLAG \
            --db "$db_name" \
            --user "$db_user" \
            --pass "$db_pass" \
            --host "$MYSQL_HOST" \
            --admin-user "$MYSQL_ADMIN_USER" \
            --admin-pass "$MYSQL_ADMIN_PASS"
    else
        echo -e "${RED}     ❌ Script nicht gefunden: scripts/db/provision-mariadb.sh${NC}"
    fi
done

echo ""
echo "🐘 Schritt 4: PostgreSQL-Datenbanken provisionieren"
echo "---------------------------------------------------"

POSTGRES_DBS=(
    "mo_idp:svc_idp:$PG_IDP_DB_PASS:HIGH - Keycloak Identity"
    "mo_grafana:svc_grafana:$PG_GRAFANA_DB_PASS:MEDIUM - Monitoring"
    "mo_discourse:svc_discourse:$PG_DISCOURSE_DB_PASS:LOW - Forum"
)

for db_entry in "${POSTGRES_DBS[@]}"; do
    IFS=':' read -r db_name db_user db_pass priority <<< "$db_entry"

    echo "  📦 $db_name ($priority)"

    if [ -f "scripts/db/provision-postgres.sh" ]; then
        bash scripts/db/provision-postgres.sh \
            $ACTION_FLAG \
            --db "$db_name" \
            --user "$db_user" \
            --pass "$db_pass" \
            --host "$PG_HOST" \
            --admin-user "$PG_ADMIN_USER" \
            --admin-pass "$PG_ADMIN_PASS"
    else
        echo -e "${RED}     ❌ Script nicht gefunden: scripts/db/provision-postgres.sh${NC}"
    fi
done

echo ""
echo "📝 Schritt 5: Passwörter speichern"
echo "----------------------------------"

# Secrets-Datei erstellen (nicht committen!)
SECRETS_FILE="secrets/db-passwords-$(date +%Y%m%d).env"
mkdir -p secrets/

cat > "$SECRETS_FILE" << EOF
# Datenbank-Passwörter - Generiert am $(date)
# ⚠️ ACHTUNG: Diese Datei ist in .gitignore und darf NICHT committed werden!

# MariaDB Admin
export MYSQL_HOST='$MYSQL_HOST'
export MYSQL_ADMIN_USER='$MYSQL_ADMIN_USER'
export MYSQL_ADMIN_PASS='$MYSQL_ADMIN_PASS'

# PostgreSQL Admin
export PG_HOST='$PG_HOST'
export PG_ADMIN_USER='$PG_ADMIN_USER'
export PG_ADMIN_PASS='$PG_ADMIN_PASS'

# MariaDB Service Passwords
export MO_CRM_DB_PASS='$MO_CRM_DB_PASS'
export MO_GAMES_DB_PASS='$MO_GAMES_DB_PASS'
export MO_N8N_DB_PASS='$MO_N8N_DB_PASS'
export MO_CONSENT_DB_PASS='$MO_CONSENT_DB_PASS'
export MO_HOOKS_DB_PASS='$MO_HOOKS_DB_PASS'
export MO_ANALYTICS_DB_PASS='$MO_ANALYTICS_DB_PASS'
export MO_NEXTCLOUD_DB_PASS='$MO_NEXTCLOUD_DB_PASS'
export MO_API_STG_DB_PASS='$MO_API_STG_DB_PASS'
export MO_ADMIN_STG_DB_PASS='$MO_ADMIN_STG_DB_PASS'

# PostgreSQL Service Passwords
export PG_IDP_DB_PASS='$PG_IDP_DB_PASS'
export PG_GRAFANA_DB_PASS='$PG_GRAFANA_DB_PASS'
export PG_DISCOURSE_DB_PASS='$PG_DISCOURSE_DB_PASS'

# Connection Strings (Beispiele)
# CiviCRM: mysql://svc_crm:$MO_CRM_DB_PASS@$MYSQL_HOST:3306/mo_crm
# Games:   postgresql://svc_games:$MO_GAMES_DB_PASS@$PG_HOST:5432/mo_games
EOF

chmod 600 "$SECRETS_FILE"

echo "✅ Passwörter gespeichert in: $SECRETS_FILE"
echo "   (chmod 600 - nur für dich lesbar)"
echo ""

echo "📋 Schritt 6: GitHub Secrets Checkliste"
echo "---------------------------------------"
echo "Kopiere diese Secrets in GitHub Repository Settings:"
echo ""
echo "  Repository → Settings → Secrets and variables → Actions"
echo ""
echo "  MariaDB Admin:"
echo "    - MYSQL_HOST"
echo "    - MYSQL_ADMIN_USER"
echo "    - MYSQL_ADMIN_PASS"
echo ""
echo "  PostgreSQL Admin:"
echo "    - PG_HOST"
echo "    - PG_ADMIN_USER"
echo "    - PG_ADMIN_PASS"
echo ""
echo "  Service Passwords (MariaDB):"
echo "    - MO_CRM_DB_PASS"
echo "    - MO_GAMES_DB_PASS"
echo "    - MO_N8N_DB_PASS"
echo "    - MO_CONSENT_DB_PASS"
echo "    - (weitere siehe $SECRETS_FILE)"
echo ""
echo "  Service Passwords (PostgreSQL):"
echo "    - PG_IDP_DB_PASS"
echo "    - PG_GRAFANA_DB_PASS"
echo "    - PG_DISCOURSE_DB_PASS"
echo ""

if [ "$DRY_RUN" = "true" ]; then
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}🔍 DRY-RUN abgeschlossen - keine Änderungen${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Zum Ausführen:"
    echo "  export DRY_RUN=false"
    echo "  bash $0"
else
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✅ Datenbank-Provisionierung abgeschlossen!${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi

echo ""
echo "📖 Weitere Dokumentation:"
echo "  - quality-reports/database-status-20251005.md"
echo "  - quality-reports/secret-inventory-20251005.md"
echo ""
