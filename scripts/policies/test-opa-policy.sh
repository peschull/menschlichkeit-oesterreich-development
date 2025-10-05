#!/usr/bin/env bash
set -euo pipefail

POLICY_DIR="mcp-servers/policies/opa"
QUERY_ALLOW='data.mcp.policies.allow'
QUERY_TOOLIO_IN='data.mcp.policy.toolio.allow_input'

if ! command -v opa >/dev/null 2>&1; then
  echo "opa CLI nicht gefunden. Installation erforderlich (https://www.openpolicyagent.org/docs/latest/#running-opa)." >&2
  exit 1
fi

cat > /tmp/mcp-policy-input.json <<'JSON'
{
  "tool": {"name": "get_code"},
  "params": {"fileKey": "mTlUSy9BQk4326cvwNa8zQ", "nodeId": "1:2", "options": {"screenshot": true}}
}
JSON

echo "== Allowlist decision (mcp.policies.allow) =="
opa eval -b "$POLICY_DIR" -i /tmp/mcp-policy-input.json -f pretty "$QUERY_ALLOW"

cat > /tmp/mcp-toolio-input.json <<'JSON'
{
  "service": "frontend",
  "filePath": "README.md"
}
JSON

echo "== Tool I/O input decision (mcp.policy.toolio.allow_input) =="
opa eval -b "$POLICY_DIR" -i /tmp/mcp-toolio-input.json -f pretty "$QUERY_TOOLIO_IN"
