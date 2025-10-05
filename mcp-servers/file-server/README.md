MCP File Server – Hardening Notes

Security features
- Input schemas validated with Ajv for each tool
- Service allowlist and safe path resolution with realpath confinement
- Dotfile access disabled by default (`MCP_ALLOW_DOTFILES=false`)
- Blocked extensions and path patterns (configurable)
- Output redaction for common secrets (private keys, API keys)
- OPA integration for input/output gates; optional enforcement
- Rate limiting, circuit breakers, and concurrency limiting
- Per-call timeouts (default 5s)
 - OpenTelemetry spans for tool calls (tool, rid, durations, errors)

Environment variables
- `PROJECT_ROOT`: Base path for service directories
- `MCP_FS_MAX_FILE_BYTES`: Max readable file size (default 262144)
- `MCP_RATE_LIMIT`: Ops per interval (default 30)
- `MCP_RATE_INTERVAL_MS`: Interval ms (default 10000)
- `MCP_MAX_CONCURRENCY`: Max concurrent tool calls (default 4)
- `MCP_ALLOW_DOTFILES`: Allow dotfiles (default false)
- `MCP_MAX_LIST_ENTRIES`: Cap directory listing size (default 500)
- `MCP_BLOCKED_EXTS`: Comma list of blocked extensions (default ".key,.pem,.der,.p12,.crt,.kdbx")
- `MCP_BLOCKED_PATH_PATTERNS`: Comma list of blocked substrings (default "id_rsa,/secrets/,/private/,/keys/")
- `MCP_OPA_POLICY`: Rego policy for I/O guards (default policies/opa/tool-io.rego)
- `MCP_OPA_REQUIRED`: Deny if OPA not available (default false)
 - `MCP_OTEL_ENABLED`: Enable OpenTelemetry spans (default true)
 - Search limits:
   - `MCP_SEARCH_MAX_FILES` (default 100)
   - `MCP_SEARCH_MAX_MATCHES` (default 200)
   - `MCP_SEARCH_MAX_BYTES` (default 65536)
   - `MCP_SEARCH_MAX_DEPTH` (default 6)
   - `MCP_SEARCH_IGNORE_DIRS` (default `node_modules,.git,dist,build,coverage,vendor`)

Run locally
- Docker + seccomp: `scripts/run-mcp-file-server-seccomp.sh`
- Bubblewrap sandbox: `scripts/run-mcp-file-server-bwrap.sh`

Quick sanity check
1) Install deps: `cd mcp-servers/file-server && npm install`
2) Node load test: `node -e "require('./index.js'); console.log('OK')"`
