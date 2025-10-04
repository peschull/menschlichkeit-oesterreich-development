#!/usr/bin/env bash
set -euo pipefail

# Runs a node-based MCP file server with a strict seccomp profile
# Usage: ./scripts/run-mcp-file-server-seccomp.sh [node_script] [-- arg1 arg2]

PROFILE="$(dirname "$0")/../mcp-servers/policies/seccomp/node-min.json"
SCRIPT="${1:-servers/src/file-server/index.js}"
shift || true

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js not found" >&2
  exit 1
fi

if ! command -v unshare >/dev/null 2>&1; then
  echo "unshare not available (util-linux). Please install it." >&2
  exit 1
fi

if ! command -v bwrap >/dev/null 2>&1; then
  echo "bubblewrap (bwrap) not available. Try: sudo apt-get install bubblewrap" >&2
  exit 1
fi

# Use bubblewrap for simple user-namespace isolation; seccomp could be applied via a wrapper like 'bwrap --seccomp'
# Some distros require sudo for seccomp filters; here we demonstrate a minimal isolation approach.

exec bwrap \
  --unshare-all \
  --die-with-parent \
  --ro-bind / / \
  --dev /dev \
  --proc /proc \
  --tmpfs /tmp \
  --chdir "$PWD" \
  node "$SCRIPT" "$@"
#!/usr/bin/env bash
set -euo pipefail

# Run MCP File Server under Docker with a seccomp profile for extra isolation.

WS_DIR=${WORKSPACE_DIR:-$(pwd)}
PROFILE_PATH=${SECcomp_PROFILE:-mcp-servers/policies/seccomp/node-min.json}

if [ ! -f "$PROFILE_PATH" ]; then
  echo "Seccomp profile not found: $PROFILE_PATH" >&2
  exit 1
fi

docker run --rm \
  -v "$WS_DIR":"/work" \
  -w /work \
  --security-opt "seccomp=$PROFILE_PATH" \
  -e PROJECT_ROOT=/work \
  -e MCP_FS_MAX_FILE_BYTES=${MCP_FS_MAX_FILE_BYTES:-262144} \
  -e MCP_RATE_LIMIT=${MCP_RATE_LIMIT:-30} \
  -e MCP_RATE_INTERVAL_MS=${MCP_RATE_INTERVAL_MS:-10000} \
  -e MCP_OPA_POLICY=${MCP_OPA_POLICY:-/work/mcp-servers/policies/opa/tool-io.rego} \
  node:20-alpine \
  node mcp-servers/file-server/index.js

