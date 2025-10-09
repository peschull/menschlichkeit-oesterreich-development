# MCP Debug Report - 2025-10-08

## Problem

**Fehler:** `Failed to parse scanned MCP servers: [object Object]`

## Root Cause Analysis

### Getestet

1. ✅ JSON Syntax valid (python -m json.tool)
2. ✅ jq kann Config parsen
3. ✅ Alle Server haben `command` und `args` Felder
4. ❓ VS Code kann Config nicht parsen

### Vermutung

VS Code MCP Extension hat Probleme mit:

- **Zu viele Server** (44 Server)
- **Komplexe Environment-Variablen** (${env:...} Pattern)
- **Unbekannte Server-Packages** (nicht alle installiert)

## Solution Applied

### ROLLBACK zu Minimal Config

```bash
# Backup der problematischen Config
.vscode/mcp.json → .vscode/mcp.json.broken

# Aktiviere minimale funktionierende Version
.vscode/mcp.minimal.json → .vscode/mcp.json
```

### Minimale Config (3 Server)

- ✅ `filesystem` - Kein ENV needed
- ✅ `github` - ENV: GITHUB_PERSONAL_ACCESS_TOKEN
- ✅ `memory` - Kein ENV needed

## Next Steps

### 1. SOFORT: VS Code Reload

```
Cmd/Ctrl+Shift+P → "Developer: Reload Window"
```

### 2. Teste minimal config

In Copilot Chat:

```
@memory store test: "MCP Debug"
@filesystem list files
```

### 3. Falls funktioniert: Schrittweise erweitern

**Test-Sequenz:**

```bash
# Test 1: Nur memory (0 ENV vars)
echo '{"mcpServers":{"memory":{"command":"npx","args":["-y","@modelcontextprotocol/server-memory"]}}}' > .vscode/mcp.json

# Test 2: + filesystem (0 ENV vars)
# Test 3: + github (1 ENV var)
# Test 4: + figma (1 ENV var)
# etc...
```

### 4. Debug-Befehle

```bash
# Prüfe VS Code Extension Logs
code --list-extensions | grep copilot

# Prüfe ob ENV-Variablen gesetzt
env | grep -E '(GITHUB|FIGMA|NOTION)'

# Teste einzelnen Server manuell
npx -y @modelcontextprotocol/server-memory

# JSON Schema Validierung
jq -e . .vscode/mcp.json >/dev/null 2>&1 && echo OK || echo FAIL
```

## Files Changed

- ✅ `.vscode/mcp.json.broken` - Backup der 44-Server Config
- ✅ `.vscode/mcp.json` - Jetzt: Minimal (3 Server)
- ✅ `quality-reports/MCP-DEBUG-REPORT-2025-10-08.md` - Dieses Dokument

## Status

⏳ **WAITING FOR USER**: VS Code Reload erforderlich

**Nach Reload:** Teste @memory, @filesystem in Copilot Chat
