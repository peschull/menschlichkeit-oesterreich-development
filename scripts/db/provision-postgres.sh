#!/usr/bin/env bash
set -euo pipefail

# PostgreSQL Provisioning (extern) – Dry-Run by default
# Erzeugt Datenbanken und Service-User
# Nutzung:
#   scripts/db/provision-postgres.sh                 # Plan
#   scripts/db/provision-postgres.sh --apply         # Ausführen

APPLY=false
for arg in "$@"; do [[ "$arg" == "--apply" ]] && APPLY=true; done

PGHOST=${PGHOST:?"PGHOST env erforderlich"}
PGPORT=${PGPORT:-5432}
PGUSER=${PGADMIN_USER:?"PGADMIN_USER env erforderlich"}
PGPASSWORD=${PGADMIN_PASS:?"PGADMIN_PASS env erforderlich"}
export PGPASSWORD

read -r -d '' MAP << 'EOF'
mo_idp        svc_idp
mo_grafana    svc_grafana
mo_discourse  svc_discourse
EOF

psql_exec() {
  psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -v ON_ERROR_STOP=1 -At -c "$1"
}

echo "== PostgreSQL Provisioning (APPLY=$APPLY) Host=$PGHOST:$PGPORT =="
while read -r DB USER; do
  [[ -z "$DB" || -z "$USER" ]] && continue
  SQL=$(cat <<SQL
DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_user WHERE usename = '$USER') THEN
    CREATE USER $USER WITH ENCRYPTED PASSWORD '${USER}_REPLACE_PASSWORD';
  END IF;
END$$;
CREATE DATABASE $DB OWNER $USER;
SQL
)
  if $APPLY; then
    echo "[EXEC] $DB / $USER"
    psql_exec "$SQL"
  else
    echo "[PLAN] $DB / $USER"
    echo "$SQL"
  fi
done <<< "$MAP"

echo "== Fertig (PostgreSQL) =="
