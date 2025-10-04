#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$ROOT_DIR/quality-reports"
mkdir -p "$REPORT_DIR"

if [[ -z "${CODACY_PROJECT_TOKEN:-}" ]]; then
  echo "Error: CODACY_PROJECT_TOKEN is not set. Export it before running this script." >&2
  exit 1
fi

docker pull codacy/codacy-analysis-cli:latest
docker run --rm -v "$ROOT_DIR:/src" -w /src \
  -e CODACY_PROJECT_TOKEN="$CODACY_PROJECT_TOKEN" \
  codacy/codacy-analysis-cli:latest analyze \
    --project-directory /src \
    --format sarif \
    --output /src/quality-reports/codacy-analysis.sarif || true

echo "Codacy analysis (if any) written to $REPORT_DIR/codacy-analysis.sarif"
