#!/usr/bin/env bash
set -euo pipefail

# Plesk Sync Helper
# - sichere Excludes für Secrets/ENV
# - optionales Site-Mapping via PLESK_SITE Env
# - Guard gegen Push vom Repo-Root

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "$ROOT_DIR/.env" ]]; then
  # shellcheck disable=SC1090
  source "$ROOT_DIR/.env"
fi

ACTION="${1:-help}"
APPLY="${2:-}"

# SSH target
USER_PREFIX=""
if [[ -n "${SSH_USER:-}" ]]; then
  USER_PREFIX="${SSH_USER}@"
fi

# Remote Pfad ermitteln
REMOTE_BASE="${PLESK_REMOTE_BASE:-/var/www/vhosts/menschlichkeit-oesterreich.at}"
resolve_subdomain_dir() {
  case "${1:-main}" in
    ""|main) echo "httpdocs" ;;
    votes) echo "subdomains/vote/httpdocs" ;;
    *) echo "subdomains/${1}/httpdocs" ;;
  esac
}

_remote_path_default="$REMOTE_BASE/$(resolve_subdomain_dir "${PLESK_SITE:-main}")"
REMOTE_PATH="${PLESK_REMOTE_PATH:-$_remote_path_default}"
REMOTE="${USER_PREFIX}${PLESK_HOST:-plesk}:${REMOTE_PATH}"

# Lokaler Webroot
LOCAL="${LOCAL_WEBROOT:-$ROOT_DIR}"

SSH_OPTS=()
[[ -n "${SSH_PORT:-}" ]] && SSH_OPTS+=( -p "$SSH_PORT" )
[[ -n "${SSH_KEY:-}" ]] && SSH_OPTS+=( -i "$SSH_KEY" )

EXCLUDES=(
  "--exclude=.git"
  "--exclude=.github"
  "--exclude=.DS_Store"
  "--exclude=node_modules"
  "--exclude=vendor"
  "--exclude=web/sites/*/files"
  "--exclude=tmp"
  "--exclude=cache"
  "--exclude=logs"
  # Sicherheitsrelevant
  "--exclude=secrets"
  "--exclude=.env*"
  "--exclude=**/*.env"
  "--exclude=**/*.key"
  "--exclude=**/*.pem"
  "--exclude=**/*.p12"
  "--exclude=**/*.pfx"
  "--exclude=**/*.crt"
  "--exclude=quality-reports/private"
  "--exclude=website/Plesk daten mit passwörter.txt"
)

RSYNC_BASE=(rsync -az --delete --partial --info=progress2 -e "ssh ${SSH_OPTS[*]}" "${EXCLUDES[@]}")

case "$ACTION" in
  pull)
    echo ">> Dry-Run Pull von $REMOTE nach $LOCAL (site='${PLESK_SITE:-main}')"
    "${RSYNC_BASE[@]}" --dry-run "$REMOTE/" "$LOCAL/"
    if [[ "$APPLY" == "--apply" ]]; then
      echo ">> AUSFÜHRUNG: Pull"
      "${RSYNC_BASE[@]}" "$REMOTE/" "$LOCAL/"
    fi
    ;;
  push)
    # Guard: kein Push vom Repo-Root ohne explizite Freigabe
    if [[ "$LOCAL" == "$ROOT_DIR" && "${ALLOW_ROOT_SYNC:-false}" != "true" ]]; then
      echo "Abbruch: LOCAL_WEBROOT zeigt auf Repo-Root ($ROOT_DIR)."
      echo "Bitte LOCAL_WEBROOT auf den Site-Ordner setzen (z. B. 'website' oder 'crm.menschlichkeit-oesterreich.at/httpdocs')."
      echo "Oder ALLOW_ROOT_SYNC=true exportieren, um diese Schutzmaßnahme zu übergehen."
      exit 2
    fi
    if [[ ! -d "$LOCAL" ]]; then
      echo "Abbruch: Lokaler Pfad existiert nicht: $LOCAL"
      exit 3
    fi
    echo ">> Dry-Run Push von $LOCAL nach $REMOTE (site='${PLESK_SITE:-main}')"
    "${RSYNC_BASE[@]}" --dry-run "$LOCAL/" "$REMOTE/"
    if [[ "$APPLY" == "--apply" ]]; then
      echo ">> AUSFÜHRUNG: Push"
      "${RSYNC_BASE[@]}" "$LOCAL/" "$REMOTE/"
    fi
    ;;
  *)
    echo "Nutzung: scripts/plesk-sync.sh [pull|push] [--apply]"
    echo "ENV: SSH_USER, PLESK_HOST, PLESK_SITE (z. B. main, votes, crm), PLESK_REMOTE_BASE, LOCAL_WEBROOT"
    exit 1
    ;;
esac
