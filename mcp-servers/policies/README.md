MCP Server Security Policies

Overview
- Sandbox and policy artifacts for securing MCP tool executions.
- Applies to processes launched by MCP servers (e.g., file-server) and their tool wrappers.

Contents
- OPA policies:
  - Allowlist for Figma tools: `opa/allowlist.rego` (query: `data.mcp.policies.allow`)
  - Tool I/O guards: `opa/tool-io.rego` (queries: `data.mcp.policy.toolio.allow_input`, `allow_output`)
- Seccomp profile: Minimal syscall set for Node subprocesses: `seccomp/node-min.json`
- OPA test script: `scripts/policies/test-opa-policy.sh`
- Runners:
  - Docker + seccomp: `scripts/run-mcp-file-server-seccomp.sh`
  - bwrap isolation: `scripts/run-mcp-file-server-bwrap.sh`

Usage
- OPA: Evaluate policies before and after each tool call.
  - Input gate: deny on oversize, illegal patterns, or disallowed service paths
  - Output gate: deny exfiltration patterns and secrets
- Seccomp: Apply via container runtime or sandbox (e.g., `--security-opt seccomp=...`).

Environment variables
- `MCP_OPA_POLICY`: Path to Rego policy file (default: `mcp-servers/policies/opa/tool-io.rego`)
- `MCP_FS_MAX_FILE_BYTES`: Max bytes allowed for file reads (default: 262144)
- `MCP_RATE_LIMIT`: Max operations per interval (default: 30)
- `MCP_RATE_INTERVAL_MS`: Interval in ms for rate limiting (default: 10000)

Notes
- Defaults are conservative; tailor to your environment and CI runners.
- Keep policies under version control and wire them into CI to prevent regressions.
