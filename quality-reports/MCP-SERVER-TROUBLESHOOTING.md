# MCP Server Troubleshooting Guide

**Problem:** MCP Server werden nicht angezeigt und nicht aktiviert in VS Code  
**Status:** 🔴 CRITICAL - P0  
**Erstellt:** 2025-10-08  
**Ziel:** 6 MCP Server vollständig funktionsfähig

---

## 🎯 Erwartetes Verhalten

### Konfigurierte Server (.vscode/mcp.json)
1. ✅ **memory** - Session-übergreifende Kontext-Persistenz
2. ✅ **sequential-thinking** - Komplexe Problemlösung
3. ✅ **figma** - Design Token Sync
4. ✅ **github** - Repository Management
5. ✅ **filesystem** - Workspace-Operationen
6. ✅ **upstash-context7** - Library-Dokumentation

### Was funktionieren sollte
- MCP Server erscheinen in GitHub Copilot Chat
- Server antworten auf Tool-Aufrufe
- Environment Variables werden korrekt geladen
- Keine Timeout-Fehler

---

## 🔍 Diagnose-Schritte

### 1. VS Code Neustart
```bash
# Vollständiger Neustart
Cmd/Ctrl + Shift + P → "Developer: Reload Window"

# ODER Terminal:
code --force-restart
```

### 2. MCP Server Status prüfen
```bash
# Prüfe ob mcp.json korrekt geladen wird
cat .vscode/mcp.json | jq .

# Prüfe Environment Variables
echo "FIGMA_ACCESS_TOKEN: ${FIGMA_ACCESS_TOKEN:0:20}..."
echo "GITHUB_TOKEN: ${GITHUB_TOKEN:0:20}..."
```

### 3. Copilot Logs analysieren
```bash
# Logs-Verzeichnis öffnen
ls -la ~/.vscode/extensions/github.copilot-*/

# Aktuelle Logs anzeigen
tail -f ~/.cache/github-copilot/logs/language-server.log | grep -i mcp
```

### 4. MCP Extension Status
```bash
# Prüfe ob GitHub Copilot MCP Extension installiert ist
code --list-extensions | grep -i copilot

# Erwartete Extensions:
# - github.copilot
# - github.copilot-chat
```

---

## 🔧 Lösungsansätze

### LÖSUNG 1: VS Code Settings prüfen
```json
// .vscode/settings.json
{
  "github.copilot.mcp.enabled": true,
  "github.copilot.mcp.configPath": "${workspaceFolder}/.vscode/mcp.json"
}
```

**Action:**
```bash
# Prüfe aktuelle Settings
cat .vscode/settings.json | jq '.["github.copilot.mcp"]'

# Falls fehlt, hinzufügen:
jq '. + {"github.copilot.mcp.enabled": true}' .vscode/settings.json > /tmp/settings.json
mv /tmp/settings.json .vscode/settings.json
```

### LÖSUNG 2: MCP Server manuell testen
```bash
# Teste einzelne Server
node -e "
const { spawn } = require('child_process');
const server = spawn('npx', ['-y', '@modelcontextprotocol/server-memory']);
server.stdout.on('data', (data) => console.log('OUT:', data.toString()));
server.stderr.on('data', (data) => console.error('ERR:', data.toString()));
setTimeout(() => server.kill(), 5000);
"
```

### LÖSUNG 3: Environment Variables neu setzen
```bash
# Lade Environment neu
source ~/.bashrc

# Exportiere kritische Variablen
export FIGMA_ACCESS_TOKEN="${FIGMA_ACCESS_TOKEN}"
export GITHUB_TOKEN="${GITHUB_TOKEN}"

# Validiere
env | grep -E "(FIGMA|GITHUB)_"
```

### LÖSUNG 4: MCP JSON neu generieren
```bash
# Backup erstellen
cp .vscode/mcp.json .vscode/mcp-backup-$(date +%Y%m%d_%H%M%S).json

# Minimale Konfiguration testen
cat > .vscode/mcp-minimal.json << 'EOF'
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
EOF

# Temporär verwenden und VS Code neustarten
mv .vscode/mcp.json .vscode/mcp-full.json
mv .vscode/mcp-minimal.json .vscode/mcp.json
```

### LÖSUNG 5: GitHub Copilot MCP Feature aktivieren
```bash
# GitHub Account Settings prüfen
# URL: https://github.com/settings/copilot/features

# Sicherstellen dass aktiviert:
# ☑ Enable MCP servers in Copilot
```

---

## 🐛 Bekannte Probleme & Workarounds

### Problem: "Server not found" Fehler
**Ursache:** npm package nicht installiert  
**Lösung:**
```bash
# Installiere MCP Server global
npm install -g @modelcontextprotocol/server-memory
npm install -g @modelcontextprotocol/server-sequential-thinking
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-filesystem

# Figma & Context7 sind spezielle Packages
npm install -g figma-mcp
npm install -g @upstash/mcp-server-context7
```

### Problem: "Environment variable not set"
**Ursache:** Variables nicht in VS Code Session verfügbar  
**Lösung:**
```bash
# .vscode/settings.json erweitern
{
  "terminal.integrated.env.linux": {
    "FIGMA_ACCESS_TOKEN": "${env:FIGMA_ACCESS_TOKEN}",
    "GITHUB_TOKEN": "${env:GITHUB_TOKEN}"
  }
}
```

### Problem: JSON-RPC Parse Error
**Ursache:** Ungültige mcp.json Syntax  
**Lösung:**
```bash
# Validiere JSON
jq empty .vscode/mcp.json && echo "✅ Valid JSON" || echo "❌ Invalid JSON"

# Formatiere JSON
jq . .vscode/mcp.json > /tmp/mcp-formatted.json
mv /tmp/mcp-formatted.json .vscode/mcp.json
```

---

## 📊 Validierungs-Checklist

### Pre-Validation
- [ ] `.vscode/mcp.json` existiert und ist valid JSON
- [ ] `FIGMA_ACCESS_TOKEN` in Environment verfügbar
- [ ] `GITHUB_TOKEN` in Environment verfügbar
- [ ] VS Code Version ≥ 1.95.0
- [ ] GitHub Copilot Extension installiert

### Post-Restart Validation
- [ ] VS Code ohne Fehler neugestartet
- [ ] Copilot Chat zeigt MCP Server an
- [ ] `@memory` Tool-Aufruf funktioniert
- [ ] `@github` Tool-Aufruf funktioniert
- [ ] Keine Timeout-Fehler in Logs

---

## 🔬 Detaillierte Diagnostics

### MCP Health Check Script
```bash
#!/bin/bash
# scripts/mcp-health-check.sh

echo "🔍 MCP Server Health Check"
echo "=========================="

# 1. JSON Validation
echo "1️⃣ Validating mcp.json..."
if jq empty .vscode/mcp.json 2>/dev/null; then
  echo "   ✅ Valid JSON"
else
  echo "   ❌ Invalid JSON - Fix syntax errors first!"
  exit 1
fi

# 2. Environment Variables
echo "2️⃣ Checking Environment Variables..."
if [ -n "$FIGMA_ACCESS_TOKEN" ]; then
  echo "   ✅ FIGMA_ACCESS_TOKEN: ${FIGMA_ACCESS_TOKEN:0:15}..."
else
  echo "   ⚠️ FIGMA_ACCESS_TOKEN not set"
fi

if [ -n "$GITHUB_TOKEN" ]; then
  echo "   ✅ GITHUB_TOKEN: ${GITHUB_TOKEN:0:15}..."
else
  echo "   ⚠️ GITHUB_TOKEN not set"
fi

# 3. NPM Packages
echo "3️⃣ Checking NPM Packages..."
packages=(
  "@modelcontextprotocol/server-memory"
  "@modelcontextprotocol/server-sequential-thinking"
  "@modelcontextprotocol/server-github"
  "@modelcontextprotocol/server-filesystem"
  "figma-mcp"
  "@upstash/mcp-server-context7"
)

for pkg in "${packages[@]}"; do
  if npm list -g "$pkg" &>/dev/null || npx --version "$pkg" &>/dev/null; then
    echo "   ✅ $pkg"
  else
    echo "   ⚠️ $pkg not found (will be downloaded by npx)"
  fi
done

# 4. VS Code Settings
echo "4️⃣ Checking VS Code Settings..."
if grep -q "github.copilot.mcp.enabled" .vscode/settings.json 2>/dev/null; then
  echo "   ✅ MCP enabled in settings.json"
else
  echo "   ⚠️ MCP not explicitly enabled"
fi

echo ""
echo "=========================="
echo "✅ Health Check Complete"
```

---

## 🚀 Schnell-Fix (Copy & Paste)

```bash
# COMPLETE MCP RESET & RESTART

# 1. Backup
cp .vscode/mcp.json .vscode/mcp-backup-$(date +%Y%m%d_%H%M%S).json

# 2. Validate JSON
jq empty .vscode/mcp.json || echo "❌ Fix JSON first!"

# 3. Environment Check
echo "FIGMA_TOKEN: ${FIGMA_ACCESS_TOKEN:0:20}..."
echo "GITHUB_TOKEN: ${GITHUB_TOKEN:0:20}..."

# 4. VS Code Settings Update
jq '. + {"github.copilot.mcp.enabled": true}' .vscode/settings.json > /tmp/settings.json
mv /tmp/settings.json .vscode/settings.json

# 5. VS Code Restart
code --force-restart

# 6. Test in Copilot Chat
# Öffne Chat und teste: "@memory help"
```

---

## 📝 Next Steps

### Wenn immer noch nicht funktioniert:
1. **GitHub Support kontaktieren** - Copilot MCP ist Beta-Feature
2. **VS Code Insiders testen** - Neueste MCP Features
3. **Alternative: .vscode/tasks.json** - MCP Server als Tasks starten
4. **Logs an GitHub senden** - Copilot Feedback-Tool verwenden

### Erfolg? Dann:
1. ✅ TODO als erledigt markieren
2. ✅ Dokumentation aktualisieren
3. ✅ MCP Integration Tests schreiben
4. ✅ Team über funktionierende Setup informieren

---

## 📚 Referenzen

- **MCP Specification:** https://modelcontextprotocol.io/
- **GitHub Copilot MCP Docs:** https://github.com/features/copilot/mcp
- **VS Code Settings:** https://code.visualstudio.com/docs/getstarted/settings
- **Troubleshooting Logs:** `~/.cache/github-copilot/logs/`

---

**Status nach Durchführung dokumentieren in:**
- `quality-reports/MCP-SERVER-STATUS.md`
- GitHub Issue mit Label `mcp`, `bug`, `p0-critical`
