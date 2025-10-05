#!/usr/bin/env bash
set -euo pipefail

# Plesk Provisioning (CHROOT, no sudo)
# - Erstellt/vereinheitlicht Verzeichnisstruktur unterhalb des vhosts-Base
# - Legt optional Platzhalter (index.html), .htaccess (HTTPS + Security-Header) und robots.txt an
# - Dry-Run by default; idempotent (legt nur an, falls nicht vorhanden)
# - KEINE Domain-/Subdomain-Anlage über Plesk-CLI, keine Zertifikate (Admin erforderlich)
#
# Nutzung:
#   scripts/plesk-provision-chroot.sh                 # Plan (Dry-Run)
#   scripts/plesk-provision-chroot.sh --apply         # Ausführung
#   scripts/plesk-provision-chroot.sh --apply --no-htaccess  # ohne .htaccess
#   scripts/plesk-provision-chroot.sh --apply --no-index     # ohne index.html

APPLY=false
CREATE_HTACCESS=true
CREATE_INDEX=true
PRUNE=false
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=true ;;
    --no-htaccess) CREATE_HTACCESS=false ;;
    --no-index) CREATE_INDEX=false ;;
    --prune) PRUNE=true ;;
  esac
done

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$ROOT_DIR/.env" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

PLESK_HOST=${PLESK_HOST:-}
SSH_USER=${SSH_USER:-}
SSH_PORT=${SSH_PORT:-22}
SSH_KEY=${SSH_KEY:-}
BASE_DOMAIN=${BASE_DOMAIN:-menschlichkeit-oesterreich.at}
# In vielen Plesk-Setups: /var/www/vhosts/<base>/
PLESK_VHOSTS_BASE=${PLESK_VHOSTS_BASE:-/var/www/vhosts/$BASE_DOMAIN}

if [[ -z "$PLESK_HOST" || -z "$SSH_USER" ]]; then
  echo "[ERROR] PLESK_HOST und SSH_USER müssen in .env gesetzt sein." >&2
  exit 1
fi

SSH_OPTS=( -p "$SSH_PORT" )
[[ -n "$SSH_KEY" ]] && SSH_OPTS+=( -i "$SSH_KEY" )

ssh_run() {
  local cmd=$1
  if $APPLY; then
    echo "[EXEC] $cmd"
    ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "$cmd"
  else
    echo "[PLAN] $cmd"
  fi
}

# Domain→Pfad-Mapping (relativ zu PLESK_VHOSTS_BASE)
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

htaccess_template() {
  cat <<'EOT'
# --- BEGIN managed by plesk-provision-chroot ---
RewriteEngine On
# Force HTTPS
RewriteCond %{HTTPS} !=on
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Security Headers
<IfModule mod_headers.c>
  Header always set X-Content-Type-Options "nosniff"
  Header always set X-Frame-Options "SAMEORIGIN"
  Header always set Referrer-Policy "strict-origin-when-cross-origin"
  Header set X-XSS-Protection "1; mode=block"
  Header set Permissions-Policy "geolocation=(), camera=(), microphone=()"
</IfModule>
# --- END managed by plesk-provision-chroot ---
EOT
}

robots_disallow_all() {
  cat <<'EOT'
User-agent: *
Disallow: /
EOT
}

echo "== CHROOT Provisioning (APPLY=$APPLY, PRUNE=$PRUNE) =="
echo "Host: $PLESK_HOST  User: $SSH_USER  Port: $SSH_PORT"
echo "Base: $PLESK_VHOSTS_BASE  Domain: $BASE_DOMAIN"

while IFS=$'\t' read -r FQDN WWWROOT; do
  [[ -z "$FQDN" || -z "$WWWROOT" ]] && continue
  FULL_PATH="$PLESK_VHOSTS_BASE/$WWWROOT"
  echo "-- $FQDN -> $FULL_PATH"

  # dirs
  ssh_run "mkdir -p '$FULL_PATH/.well-known/acme-challenge'"

  # index.html (nur wenn nicht vorhanden)
  if $CREATE_INDEX; then
    ssh_run "[ -f '$FULL_PATH/index.html' ] || echo '<!doctype html><meta charset=\"utf-8\"><title>$FQDN</title><h1>$FQDN</h1><p>Provisioned via chroot script.</p>' > '$FULL_PATH/index.html'"
  fi

  # .htaccess (nur wenn nicht vorhanden; wir überschreiben bestehende nicht)
  if $CREATE_HTACCESS; then
    ssh_run "[ -f '$FULL_PATH/.htaccess' ] || cat > '$FULL_PATH/.htaccess' <<'HTX'\n$(htaccess_template)\nHTX"
  fi

  # robots.txt: für offensichtliche Staging-Subdomains sperren
  if [[ "$FQDN" == *".stg."* ]] || [[ "$FQDN" == staging.* ]] ; then
    ssh_run "[ -f '$FULL_PATH/robots.txt' ] || cat > '$FULL_PATH/robots.txt' <<'RBT'\n$(robots_disallow_all)\nRBT"
  fi

  # Healthcheck-Datei aktualisieren
  NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  ssh_run "echo '$NOW' > '$FULL_PATH/healthz.txt'"

done <<< "$MAP"

# Optionales Aufräumen: Subdomains-Verzeichnisse, die nicht im MAP vorkommen
if $PRUNE; then
  echo "== Prüfe Subdomain-Verzeichnisse auf nicht gemappte Einträge =="
  # Erzeuge erlaubte Liste der Subdomain-Ordner (z. B. subdomains/games)
  ALLOWED_SUBDIRS=()
  while IFS=$'\t' read -r FQDN WWWROOT; do
    [[ -z "$FQDN" || -z "$WWWROOT" ]] && continue
    case "$WWWROOT" in
      subdomains/*)
        # Extrahiere subdomains/<name>
        part="${WWWROOT%%/httpdocs}"
        [[ -n "$part" ]] && ALLOWED_SUBDIRS+=("$part")
        ;;
    esac
  done <<< "$MAP"

  # Remote: Liste aktueller Subdomain-Verzeichnisse bestimmen
  # Wir berücksichtigen nur erste Ebene unter subdomains/
  LIST_CMD="if [ -d '$PLESK_VHOSTS_BASE/subdomains' ]; then ls -1d $PLESK_VHOSTS_BASE/subdomains/* 2>/dev/null || true; fi"
  if $APPLY; then
    REMOTE_LIST=$(ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "$LIST_CMD" || true)
  else
    echo "[PLAN] $LIST_CMD"
    REMOTE_LIST=$(ssh "${SSH_OPTS[@]}" "$SSH_USER@$PLESK_HOST" "$LIST_CMD" 2>/dev/null || true)
  fi

  # Vergleiche und plane Löschung nicht erfasster Ordner
  IFS=$'\n' read -r -d '' -a REMOTE_DIRS < <(printf '%s\n' "$REMOTE_LIST" && printf '\0') || true
  for dir in "${REMOTE_DIRS[@]:-}"; do
    [[ -z "$dir" ]] && continue
    # Normalisiere zu relativem Pfad subdomains/<name>
    rel="${dir#"$PLESK_VHOSTS_BASE/"}"
    # Nur subdomains/<name>
    case "$rel" in
      subdomains/*)
        keep=false
        for allowed in "${ALLOWED_SUBDIRS[@]:-}"; do
          if [[ "$rel" == "$allowed" ]]; then
            keep=true; break
          fi
        done
        if ! $keep; then
          echo "[PRUNE] Entferne unbekanntes Verzeichnis: $dir"
          if $APPLY; then
            ssh_run "rm -rf '$dir'"
          fi
        fi
        ;;
    esac
  done
fi

echo "== Fertig (CHROOT) =="
