#!/usr/bin/env bash
set -euo pipefail

# Installs Codacy Analysis CLI in the default location used by the wrapper JAR download.
# Safe to run multiple times.

if command -v codacy-analysis-cli >/dev/null 2>&1; then
  echo "codacy-analysis-cli already installed."
  exit 0
fi

OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)

case "$ARCH" in
  x86_64|amd64) ARCH=amd64 ;;
  aarch64|arm64) ARCH=arm64 ;;
esac

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

echo "Downloading Codacy Analysis CLI..."
curl -sSL -o "$TMP/codacy-analysis-cli" "https://github.com/codacy/codacy-analysis-cli/releases/latest/download/codacy-analysis-cli-$OS-$ARCH"

chmod +x "$TMP/codacy-analysis-cli"
sudo mv "$TMP/codacy-analysis-cli" /usr/local/bin/codacy-analysis-cli || {
  echo "No sudo? Falling back to user bin";
  mkdir -p "$HOME/.local/bin"
  mv "$TMP/codacy-analysis-cli" "$HOME/.local/bin/codacy-analysis-cli"
  echo "Ensure $HOME/.local/bin is on PATH"
}

echo "Codacy CLI installed."
