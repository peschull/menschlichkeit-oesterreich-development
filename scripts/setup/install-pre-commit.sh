#!/usr/bin/env bash
set -euo pipefail

if ! command -v pre-commit >/dev/null 2>&1; then
  echo "Installing pre-commit (requires Python/pip).";
  if command -v python3 >/dev/null 2>&1; then
    python3 -m pip install --user pre-commit
    export PATH="$HOME/.local/bin:$PATH"
  else
    echo "python3 not found; please install pre-commit manually: https://pre-commit.com/#install" >&2
    exit 1
  fi
fi

pre-commit install
pre-commit autoupdate || true
echo "pre-commit installed and hooks configured."
