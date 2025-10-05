#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=${OUT_DIR:-./backups/mariadb}
DB_NAME=${DB_NAME:?"DB_NAME erforderlich"}
MYSQL_HOST=${MYSQL_HOST:?}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_USER=${MYSQL_USER:?}
MYSQL_PASS=${MYSQL_PASS:?}
mkdir -p "$OUT_DIR"
TS=$(date +%F)
MYSQL_PWD="$MYSQL_PASS" mysqldump -h "$MYSQL_HOST" -P "$MYSQL_PORT" -u "$MYSQL_USER" --single-transaction "$DB_NAME" | gzip > "$OUT_DIR/${DB_NAME}_$TS.sql.gz"
echo "Backup geschrieben: $OUT_DIR/${DB_NAME}_$TS.sql.gz"
