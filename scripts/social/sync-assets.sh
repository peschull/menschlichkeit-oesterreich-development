#!/usr/bin/env bash
set -euo pipefail

# Sync social images from figma exports to website assets, normalizing filenames.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SRC_DIR="$ROOT_DIR/figma-design-system/exports/social"
DST_DIR="$ROOT_DIR/website/assets/social"
FORCE=false

usage() {
  echo "Usage: $0 [--force]";
}

for arg in "$@"; do
  case "$arg" in
    --force) FORCE=true ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $arg"; usage; exit 1 ;;
  esac
done

if [[ ! -d "$SRC_DIR" ]]; then
  echo "❌ Source not found: $SRC_DIR"; exit 1;
fi
mkdir -p "$DST_DIR"

shopt -s nullglob
changed=0
for f in "$SRC_DIR"/*.{png,PNG,jpg,JPG,jpeg,JPEG}; do
  base="$(basename "$f")"
  norm="${base,,}"               # lower case
  norm="${norm// /-}"             # spaces -> hyphen
  src="$f"
  dst="$DST_DIR/$norm"
  if [[ -f "$dst" && $FORCE == false ]]; then
    echo "↷ Skip (exists): $norm"
    continue
  fi
  cp -f "$src" "$dst"
  echo "✅ Copied: $base -> $norm"
  changed=$((changed+1))
done

if [[ $changed -eq 0 ]]; then
  echo "No new files copied. Use --force to overwrite.";
fi

