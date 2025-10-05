// Minimal OpenTelemetry SDK Bootstrap for MCP File Server
// Enables OTLP trace export if environment variables are set.

const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');

// Only start if not explicitly disabled and an endpoint is provided or default should be used
const disabled = String(process.env.MCP_OTEL_SDK_DISABLED || 'false').toLowerCase() === 'true';

if (!disabled) {
  const exporter = new OTLPTraceExporter();
  const sdk = new NodeSDK({ traceExporter: exporter });
  sdk
    .start()
    .then(() => {
      // eslint-disable-next-line no-console
      console.log('[otel] SDK started');
    })
    .catch(err => {
      // eslint-disable-next-line no-console
      console.error('[otel] SDK start error', err);
    });
}

