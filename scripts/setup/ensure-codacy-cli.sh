#!/usr/bin/env bash
set -euo pipefail

# Ensures Codacy Analysis CLI is installed; otherwise tries to install via existing installer.
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"

if command -v codacy-analysis-cli >/dev/null 2>&1; then
  echo "[codacy] codacy-analysis-cli is already installed: $(command -v codacy-analysis-cli)"
  exit 0
fi

if [[ -x "$ROOT_DIR/scripts/install-codacy-cli.sh" ]]; then
  bash "$ROOT_DIR/scripts/install-codacy-cli.sh"
else
  echo "[codacy] Installer not found at scripts/install-codacy-cli.sh" >&2
  exit 1
fi
