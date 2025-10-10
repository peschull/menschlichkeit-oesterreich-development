# MCP Cache Issue - Firecrawl Error Fix

## Problem
VS Code lädt auch `.backup` Dateien aus `.vscode/` Verzeichnis und versucht, die darin definierten MCP Server zu laden. Das führte zu Firecrawl JSON Schema Fehlern:

```
Das Tool "firecrawl_scrape" hat ungültige JSON-Parameter:
- The schema uses meta-schema features ($dynamicRef) that are not yet supported by the validator.
```

## Ursache
Die Datei `.vscode/mcp.json.backup` enthielt Firecrawl MCP Server aus der VS Code Gallery:
```json
"firecrawl/firecrawl-mcp-server": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "firecrawl-mcp@latest"],
  "env": { "FIRECRAWL_API_KEY": "${input:api_key}" }
}
```

Firecrawl verwendet JSON Schema Draft 2020-12 mit `$dynamicRef`, das von VS Code's Validator noch nicht unterstützt wird.

## Lösung
`.vscode/mcp.json.backup` → `.vscode/mcp.json.backup.OLD` umbenannt

VS Code lädt keine `.OLD` Dateien, daher ist das Problem behoben.

## Permanente Lösung
**Developer Window Reload** durchführen:
1. Cmd/Ctrl + Shift + P
2. "Developer: Reload Window"

Dies lädt nur die konsolidierte `mcp.json` im ROOT (21 Server, kein Firecrawl).

## Alternative
Falls Firecrawl wirklich benötigt wird:
- Warten auf VS Code Update mit JSON Schema Draft 2020-12 Support
- Oder Firecrawl MCP Server lokal patchen mit Draft-07 Schema

---
**Fix Applied:** 2025-10-10
**Status:** Bereit für Developer Window Reload
