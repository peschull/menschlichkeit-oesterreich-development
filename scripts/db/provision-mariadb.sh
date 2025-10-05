#!/usr/bin/env bash
set -euo pipefail

# MariaDB Provisioning (extern) – Dry-Run by default
# Erzeugt Datenbanken und Service-User mit Grants lediglich für die Plesk-IP
# Nutzung:
#   scripts/db/provision-mariadb.sh                 # Plan
#   scripts/db/provision-mariadb.sh --apply         # Ausführen

APPLY=false
for arg in "$@"; do [[ "$arg" == "--apply" ]] && APPLY=true; done

# Admin-Verbindung (ENV, kein Secret im Repo!)
MYSQL_HOST=${MYSQL_HOST:?"MYSQL_HOST env erforderlich"}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_ADMIN_USER=${MYSQL_ADMIN_USER:?"MYSQL_ADMIN_USER env erforderlich"}
MYSQL_ADMIN_PASS=${MYSQL_ADMIN_PASS:?"MYSQL_ADMIN_PASS env erforderlich"}
PLESK_SERVER_IP=${PLESK_SERVER_IP:?"PLESK_SERVER_IP env erforderlich"}

# Optional TLS erzwingen, wenn der Server es verlangt
MYSQL_SSL_OPT=${MYSQL_SSL_OPT:---ssl-mode=PREFERRED}

# Mapping: DB_NAME USER
read -r -d '' MAP << 'EOF'
mo_crm         svc_crm
mo_n8n         svc_n8n
mo_hooks       svc_hooks
mo_consent     svc_consent
mo_games       svc_games
mo_analytics   svc_analytics
mo_api_stg     svc_api_stg
mo_admin_stg   svc_admin_stg
mo_nextcloud   svc_nextcloud
EOF

mysql_exec() {
  MYSQL_PWD="$MYSQL_ADMIN_PASS" mysql -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_ADMIN_USER" $MYSQL_SSL_OPT -e "$1"
}

echo "== MariaDB Provisioning (APPLY=$APPLY) Host=$MYSQL_HOST:$MYSQL_PORT =="
while read -r DB USER; do
  [[ -z "$DB" || -z "$USER" ]] && continue
  SQL=$(cat <<SQL
CREATE DATABASE IF NOT EXISTS \`$DB\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$USER'@'$PLESK_SERVER_IP' IDENTIFIED BY '${USER}_REPLACE_PASSWORD';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,ALTER,INDEX,REFERENCES ON \`$DB\`.* TO '$USER'@'$PLESK_SERVER_IP';
FLUSH PRIVILEGES;
SQL
)
  if $APPLY; then
    echo "[EXEC] $DB / $USER"
    mysql_exec "$SQL"
  else
    echo "[PLAN] $DB / $USER"
    echo "$SQL"
  fi
done <<< "$MAP"

echo "== Fertig (MariaDB) =="
