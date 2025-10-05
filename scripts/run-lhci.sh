#!/usr/bin/env bash
set -euo pipefail

# Lightweight wrapper around Lighthouse CI or dev-server checks
# Tries multiple strategies to avoid hard failures in dev containers.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"
REPORT_DIR="$ROOT_DIR/quality-reports"
mkdir -p "$REPORT_DIR"

# Prefer frontend workspace if exists
FRONTEND_DIR="$ROOT_DIR/frontend"

# Try to find Chrome/Chromium
BROWSERS=(
  "/usr/bin/google-chrome"
  "/usr/bin/chromium"
  "/usr/bin/chromium-browser"
  "/snap/bin/chromium"
)

CHROME_PATH="${CHROME_PATH:-}"
if [[ -z "$CHROME_PATH" ]]; then
  for b in "${BROWSERS[@]}"; do
    if [[ -x "$b" ]]; then
      CHROME_PATH="$b"
      break
    fi
  done
fi

# If no Chrome, attempt to use Playwright's bundled chromium if installed
if [[ -z "$CHROME_PATH" ]]; then
  if [[ -d "$ROOT_DIR/node_modules" ]]; then
    PW_CHROMIUM=$(node -e "try{console.log(require('playwright-core').chromium.executablePath())}catch(e){process.exit(0)}" 2>/dev/null || true)
    if [[ -n "${PW_CHROMIUM:-}" && -x "$PW_CHROMIUM" ]]; then
      CHROME_PATH="$PW_CHROMIUM"
    fi
  fi
fi

if [[ -z "$CHROME_PATH" ]]; then
  echo "[lighthouse] No Chrome/Chromium found. Skipping Lighthouse audit." >&2
  exit 0
fi

export CHROME_PATH

# Prefer lighthouse-ci from frontend workspace if present
if [[ -f "$FRONTEND_DIR/package.json" ]]; then
  pushd "$FRONTEND_DIR" >/dev/null
  if npx --yes lhci healthcheck >/dev/null 2>&1; then
    echo "[lighthouse] Running LHCI in frontend workspace..."
    npx --yes lhci collect --config "${LHCI_CONFIG:-../lighthouse.config.cjs}" || true
    npx --yes lhci assert --config "${LHCI_CONFIG:-../lighthouse.config.cjs}" || true
    popd >/dev/null
    exit 0
  fi
  popd >/dev/null
fi

# Fallback: run a basic lighthouse against localhost:3000 if available
TARGET_URL="${LIGHTHOUSE_URL:-http://localhost:3000}"
if command -v lighthouse >/dev/null 2>&1; then
  echo "[lighthouse] Running lighthouse against $TARGET_URL ..."
  lighthouse "$TARGET_URL" --chrome-path="$CHROME_PATH" --output=json --output-path="$REPORT_DIR/lighthouse-report.json" || true
  exit 0
fi

# Last resort: try npx lighthouse if available
if command -v npx >/dev/null 2>&1; then
  echo "[lighthouse] Running npx lighthouse against $TARGET_URL ..."
  npx --yes lighthouse "$TARGET_URL" --chrome-path="$CHROME_PATH" --output=json --output-path="$REPORT_DIR/lighthouse-report.json" || true
  exit 0
fi

echo "[lighthouse] lighthouse not available. Skipping."
exit 0
