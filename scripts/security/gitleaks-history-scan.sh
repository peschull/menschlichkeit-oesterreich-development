#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
REPORT_DIR="$ROOT_DIR/quality-reports/private"
mkdir -p "$REPORT_DIR"

# Full history scan. Use with care; can be slow on large repos.
# Redact to avoid pushing secrets to logs; use allowlist .gitleaks.toml
GITLEAKS_CONFIG="$ROOT_DIR/.gitleaks.toml"
OUTPUT="$REPORT_DIR/secrets-scan-history.json"

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "[gitleaks] gitleaks not found on PATH." >&2
  exit 0
fi

cd "$ROOT_DIR"

echo "[gitleaks] Scanning full git history..."
gitleaks detect --redact --report-format json --report-path "$OUTPUT" --config "$GITLEAKS_CONFIG" || true

echo "[gitleaks] History scan report: $OUTPUT"
