#!/usr/bin/env bash
set -euo pipefail

OUT_DIR=${OUT_DIR:-./backups/postgres}
DB_NAME=${DB_NAME:?"DB_NAME erforderlich"}
PGHOST=${PGHOST:?}
PGPORT=${PGPORT:-5432}
PGUSER=${PGUSER:?}
PGPASSWORD=${PGPASSWORD:?}
export PGPASSWORD
mkdir -p "$OUT_DIR"
TS=$(date +%F)
pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -Fc -d "$DB_NAME" -f "$OUT_DIR/${DB_NAME}_$TS.dump"
echo "Backup geschrieben: $OUT_DIR/${DB_NAME}_$TS.dump"
