# MCP Policies

Diese Policies härten die MCP-Toolausführung:

- OPA Policy (Input/Output Guards): `opa/tool-io.rego`
- Seccomp Profil (Syscall-Minimum): `seccomp/node-min.json`
- Testskript OPA: `scripts/policies/test-opa-policy.sh`
- Runner (bwrap Isolation): `scripts/run-mcp-file-server-seccomp.sh`

Hinweise:
- OPA eval: `opa eval -b mcp-servers/policies/opa -i input.json 'data.mcp.policies.allow'`
- Seccomp: Einsatz je nach Umgebung; Profil als Startpunkt verstehen und iterativ härten.
MCP Server Security Policies

Overview
- Sandbox and policy artifacts for securing MCP tool executions.
- Applies to processes launched by MCP servers (e.g., file-server) and their tool wrappers.

Contents
- OPA policies: Input/Output validation and operation allowlists
- Seccomp profile: Minimal syscall set for Node subprocesses

Usage
- OPA: Evaluate policies before and after each tool call.
  - Input gate: deny on oversize, illegal patterns, or disallowed service paths
  - Output gate: redact secrets and deny exfiltration patterns
- Seccomp: Apply via container runtime or sandbox (e.g., `--security-opt seccomp=...`)

Environment variables
- `MCP_OPA_POLICY`: Path to Rego policy file (default: `mcp-servers/policies/opa/tool-io.rego`)
- `MCP_FS_MAX_FILE_BYTES`: Max bytes allowed for file reads (default: 262144)
- `MCP_RATE_LIMIT`: Max operations per interval (default: 30)
- `MCP_RATE_INTERVAL_MS`: Interval in ms for rate limiting (default: 10000)

Notes
- These are conservative defaults. Tailor to your environment and CI runners.
- Keep policies under version control and wire them into CI to prevent regressions.
