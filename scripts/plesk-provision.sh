#!/usr/bin/env bash
set -euo pipefail

# Plesk Provisioning Script (Dry-Run by default)
# - Erstellt/aktualisiert Domains & Subdomains inkl. Docroots gemäß definierter Zuordnung
# - Idempotent: erstellt nur, wenn nicht vorhanden; aktualisiert www-root bei Drift
# - Optionales Let's Encrypt (wenn Flag und E-Mail gesetzt)
#
# Voraussetzungen:
# - SSH-Zugang mit sudo/plesk CLI-Rechten
# - Plesk CLI verfügbar (plesk bin site, plesk bin subdomain, plesk ext letsencrypt)
# - .env Variablen: PLESK_HOST, SSH_USER (optional), SSH_PORT (optional), SSH_KEY (optional), BASE_DOMAIN, PLESK_VHOSTS_BASE, LETSENCRYPT_EMAIL
#
# Nutzung:
#   scripts/plesk-provision.sh             # Plan (Dry-Run)
#   scripts/plesk-provision.sh --apply     # Änderungen anwenden
#   scripts/plesk-provision.sh --apply --letsencrypt   # inkl. LE-Zertifikaten

APPLY=false
LETSENCRYPT=false
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    --letsencrypt) LETSENCRYPT=true ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$ROOT_DIR/.env" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

PLESK_HOST=${PLESK_HOST:-}
SSH_USER=${SSH_USER:-root}
SSH_PORT=${SSH_PORT:-22}
SSH_KEY=${SSH_KEY:-}
BASE_DOMAIN=${BASE_DOMAIN:-menschlichkeit-oesterreich.at}
PLESK_VHOSTS_BASE=${PLESK_VHOSTS_BASE:-/var/www/vhosts/$BASE_DOMAIN}
LETSENCRYPT_EMAIL=${LETSENCRYPT_EMAIL:-admin@$BASE_DOMAIN}

if [[ -z "$PLESK_HOST" ]]; then
  echo "[ERROR] PLESK_HOST ist nicht gesetzt (.env). Abbruch." >&2
  exit 1
fi

SSH_OPTS=( -p "$SSH_PORT" )
[[ -n "$SSH_KEY" ]] && SSH_OPTS+=( -i "$SSH_KEY" )

run_ssh() {
  local cmd=$1
  if $APPLY; then
    echo "[EXEC] $cmd"
    ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "$cmd"
  else
    echo "[PLAN] $cmd"
  fi
}

# Domain-Zuordnung (FQDN TAB WWW_ROOT relativ zum vhosts Base)
# Hinweis: Für Hauptdomain wird www-root meist httpdocs sein
read -r -d '' MAP << 'EOF'
menschlichkeit-oesterreich.at	httpdocs
votes.menschlichkeit-oesterreich.at	subdomains/vote/httpdocs
support.menschlichkeit-oesterreich.at	subdomains/support/httpdocs
status.menschlichkeit-oesterreich.at	subdomains/status/httpdocs
s3.menschlichkeit-oesterreich.at	subdomains/s3/httpdocs
newsletter.menschlichkeit-oesterreich.at	subdomains/newsletter/httpdocs
n8n.menschlichkeit-oesterreich.at	subdomains/n8n/httpdocs
media.menschlichkeit-oesterreich.at	subdomains/media/httpdocs
logs.menschlichkeit-oesterreich.at	subdomains/logs/httpdocs
idp.menschlichkeit-oesterreich.at	subdomains/idp/httpdocs
hooks.menschlichkeit-oesterreich.at	subdomains/hooks/httpdocs
grafana.menschlichkeit-oesterreich.at	subdomains/grafana/httpdocs
games.menschlichkeit-oesterreich.at	subdomains/games/httpdocs
forum.menschlichkeit-oesterreich.at	subdomains/forum/httpdocs
docs.menschlichkeit-oesterreich.at	subdomains/docs/httpdocs
crm.menschlichkeit-oesterreich.at	subdomains/crm/httpdocs
consent.menschlichkeit-oesterreich.at	subdomains/consent/httpdocs
api.stg.menschlichkeit-oesterreich.at	subdomains/api.stg/httpdocs
analytics.menschlichkeit-oesterreich.at	subdomains/analytics/httpdocs
admin.stg.menschlichkeit-oesterreich.at	subdomains/admin.stg/httpdocs
EOF

# Hilfsfunktionen für Plesk CLI Interaktion
exists_domain() {
  local fqdn=$1
  run_ssh "plesk bin site -i $fqdn >/dev/null 2>&1 || exit 10" | cat >/dev/null || return 1
  # Bei Dry-Run können wir Existenz nicht prüfen; daher heuristisch: immer true
  $APPLY && ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "plesk bin site -i $fqdn >/dev/null 2>&1"
}

exists_subdomain() {
  local name=$1
  local base=$2
  $APPLY && ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "plesk bin subdomain -i $name -domain $base >/dev/null 2>&1"
}

ensure_dir() {
  local path=$1
  run_ssh "mkdir -p '$path' && chown -R root:root '$path' || true"
}

update_domain_wwwroot() {
  local fqdn=$1
  local www=$2
  run_ssh "plesk bin site -u $fqdn -www-root '$www'"
}

create_subdomain() {
  local name=$1 base=$2 www=$3
  run_ssh "plesk bin subdomain --create $name -domain $base -www-root '$www'"
}

update_subdomain_wwwroot() {
  local name=$1 base=$2 www=$3
  run_ssh "plesk bin subdomain --update $name -domain $base -www-root '$www'"
}

issue_letsencrypt() {
  local fqdn=$1
  if $LETSENCRYPT; then
    # Versuche modernes CLI, fallback auf legacy
    run_ssh "plesk ext letsencrypt --version >/dev/null 2>&1 && plesk ext letsencrypt issue -d $fqdn -m $LETSENCRYPT_EMAIL -a --force || plesk bin extension --exec letsencrypt cli.php -d $fqdn -m $LETSENCRYPT_EMAIL -y"
  fi
}

echo "== Plesk Provisioning (APPLY=$APPLY, LETSENCRYPT=$LETSENCRYPT) =="
echo "Host: $PLESK_HOST  User: $SSH_USER  Port: $SSH_PORT"
echo "Vhosts Base: $PLESK_VHOSTS_BASE  Base Domain: $BASE_DOMAIN"

while IFS=$'\t' read -r FQDN WWWROOT; do
  [[ -z "$FQDN" || -z "$WWWROOT" ]] && continue
  FULL_PATH="$PLESK_VHOSTS_BASE/$WWWROOT"
  echo "-- $FQDN -> $WWWROOT"

  if [[ "$FQDN" == "$BASE_DOMAIN" ]]; then
    ensure_dir "$FULL_PATH"
    update_domain_wwwroot "$FQDN" "$WWWROOT"
    issue_letsencrypt "$FQDN"
  else
    # Subdomainname extrahieren relativ zur Base Domain
    # z.B. games.menschlichkeit-oesterreich.at -> name=games (oder api.stg)
    NAME="${FQDN%.$BASE_DOMAIN}"
    # Entferne trailing dot, falls vorhanden
    NAME="${NAME%.}"
    ensure_dir "$FULL_PATH"
    if $APPLY; then
      if ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "plesk bin subdomain -i '$NAME' -domain '$BASE_DOMAIN' >/dev/null 2>&1"; then
        update_subdomain_wwwroot "$NAME" "$BASE_DOMAIN" "$WWWROOT"
      else
        create_subdomain "$NAME" "$BASE_DOMAIN" "$WWWROOT"
      fi
    else
      # Plan-Ausgabe
      echo "[PLAN] ensure subdomain $NAME (domain $BASE_DOMAIN) with www-root '$WWWROOT'"
    fi
    issue_letsencrypt "$FQDN"
  fi
done <<< "$MAP"

echo "== Fertig =="
