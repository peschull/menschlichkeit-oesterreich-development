#!/usr/bin/env bash
set -euo pipefail

# postgres MCP wrapper
# - prüft DATABASE_URL, npx und Node
# - startet enhanced-postgres-mcp-server via npx
# - Self-Test: --self-test

if [[ "${1:-}" == "--self-test" ]]; then
  echo "Self-Test: postgres MCP wrapper"
  if [[ -z "${DATABASE_URL:-}" ]]; then
    echo "DATABASE_URL: MISSING"; exit 1
  else
    echo "DATABASE_URL: OK (hidden)"
  fi
  if command -v node >/dev/null 2>&1; then echo "node: OK"; else echo "node: MISSING"; exit 1; fi
  if command -v npx >/dev/null 2>&1; then echo "npx: OK"; else echo "npx: MISSING"; exit 1; fi
  exit 0
fi

if [[ -z "${DATABASE_URL:-}" ]]; then
  echo "ERROR: DATABASE_URL nicht gesetzt. Setze sie in env/.env.local und source sie." >&2
  exit 1
fi

# Übergibt die URL als Befehlszeilenargument, da der Server dies erwartet
exec npx -y enhanced-postgres-mcp-server "$DATABASE_URL"
