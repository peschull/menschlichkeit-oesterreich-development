---
adr: 004
title: MCP‑Server Sicherheitsmodell (Sandboxing, Policies, Supply‑Chain)
status: Accepted
date: 2025-10-04
---

# MCP‑Server Sicherheitsmodell

Kontext
- MCP‑Server (file‑server u. a.) interagieren mit Workspace und Tools; Risiko: Datenabfluss, Path Traversal, Flooding.

Optionen
- Keine Isolation (nur Code‑Disziplin)
- Prozess‑Sandboxing (seccomp, namespaces) + Policy‑Layer (OPA)
- MicroVM‑Isolation (Firecracker) mit stark erhöhter Komplexität

Entscheidung
- Kurzfristig: Prozess‑Sandboxing + OPA‑Input/Output‑Gate, Rate‑Limiting, Circuit‑Breaker.
- Mittelfristig: Evaluierung MicroVM‑Optionen für besonders sensible Tools.

Konsequenzen
- Pro: Deutlich bessere Laufzeitkontrolle, nachweisbare Policy‑Durchsetzung.
- Contra: Overhead durch Sandbox/Policies, Pflege der Rego‑Regeln.
- Supply‑Chain: SBOM + Cosign‑Signaturen verpflichtend im Release‑Prozess.

Referenzen
- Policy: `mcp-servers/policies/opa/tool-io.rego`
- Seccomp: `mcp-servers/policies/seccomp/node-min.json`
- Runner: `scripts/run-mcp-file-server-seccomp.sh`
- Threat Model: `docs/security/MCP-SERVER-THREAT-MODEL.md`

