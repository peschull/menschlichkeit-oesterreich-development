#!/usr/bin/env bash
set -euo pipefail

# Install Playwright Chromium with dependencies to enable Lighthouse in dev containers
if command -v npx >/dev/null 2>&1; then
  echo "[browsers] Installing Playwright Chromium (with deps if supported)..."
  npx playwright install --with-deps chromium || npx playwright install chromium || true
else
  echo "[browsers] npx not found; skipping Playwright installation."
fi
