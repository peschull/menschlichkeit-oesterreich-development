#!/usr/bin/env bash
set -euo pipefail

# Git history cleanup using git-filter-repo
# DANGER: This rewrites history. Coordinate with your team and force-push.
#
# Usage examples:
#   FILES_TO_REMOVE=".env,.env.mcp" ./scripts/security/git-history-cleanup.sh
#   ./scripts/security/git-history-cleanup.sh --dry-run
#
# Requirements:
#   - Python 3 + git-filter-repo (pip install git-filter-repo)
#   - Clean working tree

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
cd "$ROOT_DIR"

DRY_RUN=${1:-}

if [ -n "$(git status --porcelain)" ]; then
  echo "Working tree not clean. Commit or stash changes first." >&2
  exit 1
fi

if ! command -v git-filter-repo >/dev/null 2>&1; then
  echo "git-filter-repo not found. Installing via pip..." >&2
  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user git-filter-repo || {
      echo "Failed to install git-filter-repo. Install manually and retry." >&2
      exit 1
    }
    export PATH="$HOME/.local/bin:$PATH"
  else
    echo "python3 not found; please install git-filter-repo manually." >&2
    exit 1
  fi
fi

BACKUP_DIR="../$(basename "$ROOT_DIR")-backup-$(date +%Y%m%d-%H%M%S)"
echo "Creating safety backup at: $BACKUP_DIR"
git clone --mirror . "$BACKUP_DIR.git" >/dev/null 2>&1 || true

# Prepare replace-text rules
REPLACE_FILE="/tmp/git-filter-replace-$$.txt"
cat > "$REPLACE_FILE" <<'RULES'
# Replace common token patterns
regex:ghp_[A-Za-z0-9]{36,}===>[REDACTED_GITHUB_PAT]
regex:AWS_SECRET_ACCESS_KEY\s*[:=]\s*[^\n\r]+===>AWS_SECRET_ACCESS_KEY=[REDACTED]
regex:x-api-key\s*[:=]\s*[^\n\r]+===>x-api-key: [REDACTED]
regex:authorization:\s*Bearer\s+[A-Za-z0-9\-_.~+/=]+===>authorization: Bearer [REDACTED]
regex:-----BEGIN [A-Z ]*PRIVATE KEY-----[\s\S]*?-----END [A-Z ]*PRIVATE KEY-----===>-----BEGIN PRIVATE KEY-----\n[REDACTED]\n-----END PRIVATE KEY-----
RULES

# Build file/path removal args
IFS=',' read -r -a FILES <<< "${FILES_TO_REMOVE:-}"
FILTER_ARGS=()
for f in "${FILES[@]}"; do
  [ -z "$f" ] && continue
  FILTER_ARGS+=( "--path" "$f" "--path-rename" "$f:REMOVED/$f" )
done

echo "About to rewrite history with rules:"
echo "  replace-text: $REPLACE_FILE"
if [ ${#FILTER_ARGS[@]} -gt 0 ]; then
  echo "  paths to rewrite: ${FILES[*]}"
fi

if [ "$DRY_RUN" = "--dry-run" ]; then
  echo "Dry-run mode: not rewriting history."
  exit 0
fi

git filter-repo \
  --force \
  --replace-text "$REPLACE_FILE" \
  "${FILTER_ARGS[@]}"

echo "History rewritten. Next steps:"
echo "  1) Force-push all branches:   git push --force --prune origin --all"
echo "  2) Force-push all tags:       git push --force --prune origin --tags"
echo "  3) Invalidate forks/old clones: communicate and re-clone"
echo "  4) Rotate any leaked credentials (PATs, API keys, etc.)"
