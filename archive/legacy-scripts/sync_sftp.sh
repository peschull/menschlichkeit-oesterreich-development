#!/usr/bin/env bash
set -euo pipefail

# ====== Server-Zugang ======
HOST="5.183.217.146"
USER="dmpl20230054"
SSH_KEY="C:/Users/schul/.ssh/id_ed25519"   # ggf. anpassen

# ====== Remote-Webroots (Plesk chroot) ======
REMOTE_WEBROOT_MAIN="/httpdocs"
REMOTE_WEBROOT_API="/api.menschlichkeit-oesterreich.at"
REMOTE_WEBROOT_CRM="/crm.menschlichkeit-oesterreich.at"

# ====== Lokales Monorepo-Ziel ======
BASE_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="${BASE_DIR}/menschlichkeit-oesterreich-monorepo"

mkdir -p "${REPO_DIR}/httpdocs" \
         "${REPO_DIR}/api.menschlichkeit-oesterreich.at" \
         "${REPO_DIR}/crm.menschlichkeit-oesterreich.at"

echo "→ Pull: Hauptdomain (WordPress) nach ${REPO_DIR}/httpdocs"
# HINWEIS: SFTP kann keine Excludes. Wir holen gezielt nur das Nötige.
sftp -i "$SSH_KEY" -b - "${USER}@${HOST}" <<EOF
lcd ${REPO_DIR}/httpdocs
cd ${REMOTE_WEBROOT_MAIN}
get -r index.php
get -r wp-admin
get -r wp-includes
get -r wp-config.php
get -r wp-content/themes
get -r wp-content/plugins
# get -r wp-content/uploads   # bewusst NICHT (liegt im .gitignore)
EOF

echo "→ Pull: API (Laravel) nach ${REPO_DIR}/api.menschlichkeit-oesterreich.at"
sftp -i "$SSH_KEY" -b - "${USER}@${HOST}" <<EOF
lcd ${REPO_DIR}/api.menschlichkeit-oesterreich.at
cd ${REMOTE_WEBROOT_API}
get -r *
EOF

echo "→ Pull: CRM (CiviCRM) nach ${REPO_DIR}/crm.menschlichkeit-oesterreich.at"
sftp -i "$SSH_KEY" -b - "${USER}@${HOST}" <<EOF
lcd ${REPO_DIR}/crm.menschlichkeit-oesterreich.at
cd ${REMOTE_WEBROOT_CRM}
get -r *
EOF

echo "✓ Sync fertig."
