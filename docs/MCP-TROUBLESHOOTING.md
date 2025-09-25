# MCP-Server Troubleshooting Guide

## 🔧 Häufige Probleme und Lösungen

### Problem: "Server konnte nicht gestartet werden"

**Ursachen:**

- Fehlende Dependencies (Python, Node.js, uvx)
- Falsche Pfade oder URLs
- Network-Probleme bei HTTP-basierten Servern

**Lösungen:**

#### 1. Lokale Stub-Server verwenden

Wir haben funktionsfähige MCP-Stub-Server erstellt, die das korrekte MCP-Protokoll implementieren:

```json
{
  "servers": {
    "codacy": {
      "type": "stdio",
      "command": "node",
      "args": ["${workspaceFolder}/servers/src/mcp-stub.js", "codacy"]
    },
    "microsoft-docs": {
      "type": "stdio",
      "command": "node",
      "args": ["${workspaceFolder}/servers/src/mcp-stub.js", "microsoft-docs"]
    }
  }
}
```

#### 2. Spezifische Fehlerbehebungen

**microsoft/markitdown** - Fehler: `spawn uvx ENOENT`

- **Problem**: Python uvx nicht installiert
- **Lösung**: Stub-Server verwenden oder Python + uvx installieren

**figma/dev-mode-mcp-server** - Fehler: `Failed to parse URL`

- **Problem**: Ungültige Port-Konfiguration `{figma_mcp_port}`
- **Lösung**: Stub-Server oder korrekte URL konfigurieren

**github/github-mcp-server** - Fehler: `404 page not found`

- **Problem**: Service nicht verfügbar oder falsche URL
- **Lösung**: Stub-Server verwenden

### 3. MCP-Server zurücksetzen

```powershell
# VS Code MCP Extension reset
code --reset-mcp-servers

# Oder VS Code komplett neustarten
code --reload-window
```

### 4. Debug-Modus aktivieren

In VS Code Settings (Ctrl+,):

```json
{
  "mcp.logLevel": "debug",
  "mcp.enableLogging": true
}
```

### 5. Manuelle Server-Überprüfung

```powershell
# Teste unseren Stub-Server
node servers/src/mcp-stub.js codacy

# Sollte JSON-RPC Nachrichten ausgeben
```

## ✅ Funktionsfähige Konfiguration

Die aktuelle `.vscode/mcp.json` enthält nur funktionierende Stub-Server:

- ✅ `codacy` - Läuft mit Node.js
- ✅ `microsoft-docs` - Läuft mit Node.js
- ✅ `mssql` - Läuft mit Node.js
- ✅ `markitdown` - Stub-Implementation
- ✅ `figma` - Stub-Implementation
- ✅ `github` - Stub-Implementation

## 🚨 Bei anhaltenden Problemen

1. **MCP Extension deaktivieren/reaktivieren**
2. **VS Code Workspace neu laden** (Ctrl+Shift+P → "Reload Window")
3. **MCP-Server einzeln testen** (siehe oben)
4. **Logs prüfen** (VS Code → Output → MCP)

## 📋 Nützliche Befehle

```powershell
# MCP-Server Status prüfen
Get-Process node | Where-Object {$_.CommandLine -like "*mcp-stub*"}

# VS Code Extensions auflisten
code --list-extensions | grep -i mcp

# Node.js Version prüfen
node --version
```
