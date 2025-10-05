#!/usr/bin/env bash
set -euo pipefail

DOCROOT=${DOCROOT:?"DOCROOT erforderlich (Nextcloud Pfad)"}
PHP_BIN=${PHP_BIN:-php}

cd "$DOCROOT"

# Erwartete ENV Variablen (Beispiele):
# NC_BASE_URL, NC_TRUSTED_DOMAINS, NC_DB_HOST, NC_DB_NAME, NC_DB_USER, NC_DB_PASS
# NC_REDIS_HOST, NC_REDIS_PORT, NC_REDIS_PASS
# NC_OIDC_ISSUER, NC_OIDC_CLIENT_ID, NC_OIDC_CLIENT_SECRET

echo "== Nextcloud OCC Maintenance Install =="
$PHP_BIN occ maintenance:install \
  --database "mysql" \
  --database-host "${NC_DB_HOST}" \
  --database-name "${NC_DB_NAME}" \
  --database-user "${NC_DB_USER}" \
  --database-pass "${NC_DB_PASS}" \
  --admin-user "${NC_ADMIN_USER:-admin}" \
  --admin-pass "${NC_ADMIN_PASS:-change-me}" || true

echo "== Basic Config setzen =="
$PHP_BIN occ config:system:set trusted_domains 0 --value="${NC_TRUSTED_DOMAINS}"
$PHP_BIN occ config:system:set overwrite.cli.url --value="${NC_BASE_URL}"

echo "== Redis setzen (optional) =="
if [[ -n "${NC_REDIS_HOST:-}" ]]; then
  $PHP_BIN occ config:system:set memcache.locking --value="\\OC\\Memcache\\Redis"
  $PHP_BIN occ config:system:set memcache.distributed --value="\\OC\\Memcache\\Redis"
  $PHP_BIN occ config:system:set redis host --value="${NC_REDIS_HOST}"
  $PHP_BIN occ config:system:set redis port --value="${NC_REDIS_PORT:-6379}" --type=integer
  [[ -n "${NC_REDIS_PASS:-}" ]] && $PHP_BIN occ config:system:set redis password --value="${NC_REDIS_PASS}"
fi

echo "== OIDC App vorbereiten =="
$PHP_BIN occ app:install oidc_login || true
$PHP_BIN occ app:enable oidc_login || true
$PHP_BIN occ config:app:set oidc_login provider-url --value="${NC_OIDC_ISSUER}"
$PHP_BIN occ config:app:set oidc_login client-id --value="${NC_OIDC_CLIENT_ID}"
$PHP_BIN occ config:app:set oidc_login client-secret --value="${NC_OIDC_CLIENT_SECRET}"
$PHP_BIN occ config:app:set oidc_login auto-provision --value=1

echo "== Fertig (Nextcloud) =="
