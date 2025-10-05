#!/usr/bin/env bash
set -euo pipefail

CFG=${1:-observability/otel-collector/config-dev.yaml}

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker nicht gefunden." >&2
  exit 1
fi

docker rm -f otel-collector >/dev/null 2>&1 || true
docker run -d --name otel-collector \
  -p 4317:4317 -p 4318:4318 \
  -v "$(pwd)/$CFG":/etc/otelcol/config.yaml \
  otel/opentelemetry-collector:0.104.0 \
  --config /etc/otelcol/config.yaml

echo "Collector läuft. Logs: docker logs -f otel-collector"

