#!/bin/bash
#
# Automatisiertes Setup für Drupal 10 + CiviCRM
# Führt composer install, Drush Site-Install und CiviCRM-Installation aus.
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
CRM_PROJECT_DIR="$ROOT_DIR/crm.menschlichkeit-oesterreich.at/httpdocs"
DRUSH_BIN="$CRM_PROJECT_DIR/vendor/bin/drush"

if [[ ! -d "$CRM_PROJECT_DIR" ]]; then
    echo "❌ CRM-Projektverzeichnis nicht gefunden: $CRM_PROJECT_DIR" >&2
    exit 1
fi

# .env.deployment einlesen, falls vorhanden
if [[ -f "$ROOT_DIR/.env.deployment" ]]; then
    set -a
    # shellcheck disable=SC1090
    source "$ROOT_DIR/.env.deployment"
    set +a
fi

# Hilfsfunktion zum URL-Encoden (Passwörter/Benutzer)
urlencode() {
    python3 - <<'PY' "$1"
import sys, urllib.parse
print(urllib.parse.quote(sys.argv[1], safe=''))
PY
}

# Pflichtvariablen mit sinnvollen Defaults
CRM_DB_HOST=${CRM_DB_HOST:-${MYSQL_HOST:-localhost}}
CRM_DB_PORT=${CRM_DB_PORT:-3306}
CRM_DB_NAME=${CRM_DB_NAME:-mo_crm}
CRM_DB_USER=${CRM_DB_USER:-svc_crm}
CRM_DB_PASS=${CRM_DB_PASS:-}
CRM_BASE_URL=${CRM_BASE_URL:-https://crm.menschlichkeit-oesterreich.at}
CRM_SITE_NAME=${CRM_SITE_NAME:-Menschlichkeit Österreich CRM}
CRM_ADMIN_USER=${CRM_ADMIN_USER:-admin}
CRM_ADMIN_PASS=${CRM_ADMIN_PASS:-}
CRM_ADMIN_MAIL=${CRM_ADMIN_MAIL:-crm@menschlichkeit-oesterreich.at}
CIVICRM_SITE_KEY=${CIVICRM_SITE_KEY:-}

missing=()
[[ -z "$CRM_DB_PASS" ]] && missing+=("CRM_DB_PASS")
[[ -z "$CIVICRM_SITE_KEY" ]] && missing+=("CIVICRM_SITE_KEY")
[[ -z "$CRM_ADMIN_PASS" ]] && missing+=("CRM_ADMIN_PASS")

if (( ${#missing[@]} > 0 )); then
    echo "❌ Fehlende Variablen: ${missing[*]}" >&2
    echo "    Bitte .env.deployment ergänzen oder Umgebungsvariablen setzen." >&2
    exit 1
fi

ENC_DB_USER="$(urlencode "$CRM_DB_USER")"
ENC_DB_PASS="$(urlencode "$CRM_DB_PASS")"
DRUPAL_DB_URL="mysql://${ENC_DB_USER}:${ENC_DB_PASS}@${CRM_DB_HOST}:${CRM_DB_PORT}/${CRM_DB_NAME}"

echo "📦 Installiere Composer-Abhängigkeiten…"
pushd "$CRM_PROJECT_DIR" >/dev/null
composer install --no-interaction --no-progress

if [[ ! -x "$DRUSH_BIN" ]]; then
    echo "❌ Drush wurde nicht gefunden unter $DRUSH_BIN" >&2
    exit 1
fi

echo "🔍 Prüfe bestehenden Drupal-Status…"
drupal_bootstrap_status="not-installed"
if "$DRUSH_BIN" status --format=json --fields=bootstrap >/tmp/drush_status.json 2>/dev/null; then
    if python3 -c "import json,sys; data=json.load(open('/tmp/drush_status.json')); print(data.get('bootstrap','').lower())" | grep -q 'successful'; then
        drupal_bootstrap_status="installed"
    fi
fi
rm -f /tmp/drush_status.json 2>/dev/null || true

if [[ "$drupal_bootstrap_status" != "installed" ]]; then
    echo "🚀 Installiere Drupal (site:install)…"
    "$DRUSH_BIN" site:install standard \
        --yes \
        --site-name="$CRM_SITE_NAME" \
        --account-name="$CRM_ADMIN_USER" \
        --account-pass="$CRM_ADMIN_PASS" \
        --account-mail="$CRM_ADMIN_MAIL" \
        --db-url="$DRUPAL_DB_URL"
else
    echo "ℹ️  Drupal ist bereits installiert – überspringe site:install."
fi

echo "📋 Aktualisiere Basis-Konfiguration…"
"$DRUSH_BIN" config:set system.site name "$CRM_SITE_NAME" --yes --input-format=string
"$DRUSH_BIN" config:set system.site mail "$CRM_ADMIN_MAIL" --yes --input-format=string
"$DRUSH_BIN" config:set system.performance css.preprocess 1 --yes
"$DRUSH_BIN" config:set system.performance js.preprocess 1 --yes

echo "🔑 Setze CiviCRM Site Key in civicrm.local.php…"
mkdir -p "$CRM_PROJECT_DIR/web/sites/default"
cat > "$CRM_PROJECT_DIR/web/sites/default/civicrm.local.php" <<PHP
<?php
if (!defined('CIVICRM_SITE_KEY')) {
    define('CIVICRM_SITE_KEY', '${CIVICRM_SITE_KEY}');
}
PHP

echo "🧩 Installiere CiviCRM…"
composer civicrm:install --no-interaction

echo "🧼 Leere Caches…"
"$DRUSH_BIN" cr

echo "✅ CiviCRM Setup abgeschlossen!"
echo "   Basis-URL: ${CRM_BASE_URL}"
echo "   Admin Login: ${CRM_ADMIN_USER}"
echo ""
echo "Nächste Schritte:"
echo "  1. Drush-Status prüfen: vendor/bin/drush status"
echo "  2. Login testen: ${CRM_BASE_URL}"
echo "  3. Backup anlegen & Secrets sicher speichern"
popd >/dev/null
