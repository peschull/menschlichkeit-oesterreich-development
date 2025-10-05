#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
REPORT_DIR="$ROOT_DIR/quality-reports"
mkdir -p "$REPORT_DIR"

# Try Codacy CLI; if missing, attempt ensure; fallback to ESLint SARIF
if ! command -v codacy-analysis-cli >/dev/null 2>&1; then
  if [[ -x "$ROOT_DIR/scripts/setup/ensure-codacy-cli.sh" ]]; then
    bash "$ROOT_DIR/scripts/setup/ensure-codacy-cli.sh" || true
  fi
fi

if command -v codacy-analysis-cli >/dev/null 2>&1; then
  echo "[codacy] Running Codacy Analysis CLI..."
  codacy-analysis-cli analyze --format sarif --output "$REPORT_DIR/codacy-analysis.sarif" || true
elif [[ -n "${CODACY_PROJECT_TOKEN:-}" ]]; then
  echo "[codacy] Falling back to Docker CLI (token provided)..."
  bash "$ROOT_DIR/scripts/codacy-cli-docker.sh" || true
else
  echo "[codacy] CLI not available and no token. Falling back to ESLint SARIF."
  (cd "$ROOT_DIR" && npx --yes eslint . -f sarif -o "$REPORT_DIR/eslint.sarif" || true)
fi
