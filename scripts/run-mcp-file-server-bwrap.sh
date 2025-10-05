#!/usr/bin/env bash
set -euo pipefail

# Runs the node-based MCP file server with user-namespace isolation via bubblewrap (bwrap).
# Usage: ./scripts/run-mcp-file-server-bwrap.sh [node_script] [-- arg1 arg2]

SCRIPT="${1:-mcp-servers/file-server/index.js}"
shift || true

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found" >&2
  exit 1
fi

if ! command -v bwrap >/dev/null 2>&1; then
  echo "bubblewrap (bwrap) not available. Try: sudo apt-get install bubblewrap" >&2
  exit 1
fi

exec bwrap \
  --unshare-all \
  --die-with-parent \
  --ro-bind / / \
  --dev /dev \
  --proc /proc \
  --tmpfs /tmp \
  --chdir "$PWD" \
  node "$SCRIPT" "$@"

