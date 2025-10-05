#!/usr/bin/env node
const { NodeSDK } = require('@opentelemetry/sdk-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');
const { trace } = require('@opentelemetry/api');

const endpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318';
const serviceName = process.env.OTEL_SERVICE_NAME || 'mcp-file-server-dev';

const exporter = new OTLPTraceExporter({ url: `${endpoint}/v1/traces` });
const sdk = new NodeSDK({
  traceExporter: exporter,
  resource: new (require('@opentelemetry/resources').Resource)({
    'service.name': serviceName,
  }),
});

sdk.start().then(async () => {
  const tracer = trace.getTracer('test');
  const span = tracer.startSpan('test-span');
  span.setAttribute('demo', true);
  span.end();
  // allow flush
  setTimeout(async () => {
    await sdk.shutdown();
    console.log('Test-Span gesendet.');
  }, 1000);
}).catch(err => {
  console.error('OTel SDK start error', err);
  process.exit(1);
});

