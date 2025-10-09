# 🎯 MCP Server in VS Code - Wo sind sie?

**WICHTIG:** MCP Server sind **KEINE Extensions!** Sie erscheinen im **GitHub Copilot Chat** als `@`-mentions.

---

## ❌ **NICHT HIER SUCHEN:**

```
VS Code Sidebar → Extensions (Cmd/Ctrl+Shift+X)
├── Prettier
├── ESLint
├── Python
├── Docker
└── ... ← MCP Server sind NICHT hier!
```

**MCP Server erscheinen NICHT in der Extensions-Liste!**

---

## ✅ **HIER FINDEST DU SIE:**

### **Schritt 1: GitHub Copilot Chat öffnen**

```
Tastenkombination: Cmd/Ctrl + Shift + I
Oder: Klick auf Copilot-Symbol in Sidebar
```

### **Schritt 2: "@" im Chat tippen**

```
GitHub Copilot Chat
┌─────────────────────────────────────┐
│ @github                             │ ← GitHub MCP Server
│ @memory                             │ ← Memory MCP Server
│ @sequential-thinking                │ ← Sequential Thinking MCP
│ @filesystem                         │ ← Filesystem MCP Server
│ @figma                              │ ← Figma MCP Server
│ @playwright                         │ ← Playwright MCP Server
│ @postgres                           │ ← PostgreSQL MCP Server
│ @mongodb                            │ ← MongoDB MCP Server
│ @slack                              │ ← Slack MCP Server
│ @aws                                │ ← AWS MCP Server
│ ... (47 Server total)               │
└─────────────────────────────────────┘
```

### **Schritt 3: MCP Server verwenden**

```
Im Chat eingeben:

@github list repositories for menschlichkeit-oesterreich

@figma get design tokens from production file

@postgres SELECT * FROM civicrm_contact WHERE consent_gdpr = true LIMIT 10

@slack send message to #dev-team: "Deployment successful!"

@sequential-thinking plan DSGVO compliance audit workflow
```

---

## 🔍 **Troubleshooting: Server nicht sichtbar?**

### **Checkliste (in dieser Reihenfolge!):**

#### ✅ **1. GitHub Copilot Extensions installiert?**

```
1. Öffne Extensions (Cmd/Ctrl+Shift+X)
2. Suche "GitHub Copilot"
3. Installiere BEIDE:
   ✅ GitHub Copilot (von GitHub)
   ✅ GitHub Copilot Chat (von GitHub)
```

**Wichtig:** Beide Extensions müssen installiert UND aktiviert sein!

#### ✅ **2. Copilot Subscription aktiv?**

```
1. Öffne: https://github.com/settings/copilot
2. Prüfe Status:
   ✅ "GitHub Copilot Individual" (Aktiv)
   ODER
   ✅ "GitHub Copilot Business" (Aktiv)
```

**Ohne aktives Abo funktioniert MCP NICHT!**

#### ✅ **3. MCP Feature in VS Code aktiviert?**

```
1. Öffne Settings (Cmd/Ctrl+,)
2. Suche: "github.copilot.mcp.enabled"
3. Aktiviere Checkbox: [✓] Enable MCP servers in Copilot
```

**Oder in settings.json:**

```json
{
  "github.copilot.mcp.enabled": true
}
```

#### ✅ **4. mcp.json existiert und ist valid?**

```bash
# Prüfe Existenz:
ls -la .vscode/mcp.json

# Erwartung:
.vscode/mcp.json  (existiert)

# Prüfe JSON Syntax:
cat .vscode/mcp.json | python3 -m json.tool

# Erwartung:
✅ JSON Syntax: VALID (kein Fehler)
```

#### ✅ **5. VS Code Reload durchgeführt?**

```
Cmd/Ctrl + Shift + P
→ Eingabe: "Developer: Reload Window"
→ Enter drücken
```

**KRITISCH:** Nach JEDER Änderung an mcp.json MUSS VS Code neu geladen werden!

---

## 🚀 **Quick Start Test:**

### **Test 1: Basis-Server (keine API-Keys nötig)**

```
Im Copilot Chat:

@github → sollte erscheinen
@memory → sollte erscheinen
@filesystem → sollte erscheinen
@sequential-thinking → sollte erscheinen
```

**Falls NICHT sichtbar:**
→ Checkliste oben durchgehen!

### **Test 2: Erste Query ausführen**

```
@github list repositories for menschlichkeit-oesterreich
```

**Erwartung:**

```
✅ Copilot zeigt Liste der Repositories
ODER
❌ "Server not available" → API-Key fehlt oder Server nicht gestartet
```

### **Test 3: Sequential Thinking**

```
@sequential-thinking plan workflow:
1. Analyze project structure
2. Identify main services
3. Suggest deployment strategy
```

**Erwartung:**

```
✅ Copilot erstellt detaillierten mehrstufigen Plan
```

---

## 🔧 **Häufige Probleme & Lösungen:**

### **Problem 1: "@github" erscheint nicht im Chat**

**Ursache:** Copilot Extensions nicht installiert oder MCP Feature deaktiviert

**Lösung:**

```
1. Extensions installieren (siehe oben)
2. MCP Feature aktivieren in Settings
3. VS Code Reload (Cmd/Ctrl+Shift+P → Reload Window)
```

---

### **Problem 2: "Server @postgres not available"**

**Ursache:** Environment Variable `POSTGRES_CONNECTION_STRING` nicht gesetzt

**Lösung:**

```bash
# In .bashrc oder .env:
export POSTGRES_CONNECTION_STRING="postgresql://user:pass@host:5432/db"

# Reload Environment:
source ~/.bashrc

# VS Code Reload:
Cmd/Ctrl+Shift+P → Reload Window
```

---

### **Problem 3: Server erscheinen kurz, verschwinden dann**

**Ursache:** NPM Package Installation schlägt fehl

**Lösung:**

```bash
# NPM Cache leeren:
npm cache clean --force

# Node Version prüfen (min. 18.0.0):
node --version

# Manual Test:
npx -y @modelcontextprotocol/server-github --version
```

---

### **Problem 4: VS Code Logs zeigen MCP Errors**

**Logs prüfen:**

```bash
# MCP Server Logs:
cat ~/.cache/github-copilot/logs/language-server.log | grep -i "mcp"

# Suche nach:
- "Failed to start MCP server"
- "Connection refused"
- "Invalid configuration"
```

**Häufige Fehler:**

- JSON Syntax Error in mcp.json → `python3 -m json.tool .vscode/mcp.json`
- NPM Package nicht gefunden → `npm view @modelcontextprotocol/server-github`
- Port bereits belegt → Server neu starten

---

## 📊 **MCP Server Status prüfen:**

### **Via VS Code Developer Tools:**

```
1. Cmd/Ctrl+Shift+P → "Developer: Toggle Developer Tools"
2. Console Tab öffnen
3. Filter: "mcp"
4. Suche nach:
   ✅ "MCP server started: github"
   ✅ "MCP server connected: figma"
   ❌ "MCP server failed: postgres" → Fehler!
```

---

## 🎯 **Zusammenfassung:**

| Check | Status | Aktion |
|-------|--------|--------|
| Copilot Extensions installiert? | ⏳ | Extensions → "GitHub Copilot" |
| Copilot Subscription aktiv? | ⏳ | <https://github.com/settings/copilot> |
| MCP Feature aktiviert? | ⏳ | Settings → "mcp.enabled" |
| mcp.json existiert? | ✅ | `.vscode/mcp.json` (47 Server) |
| JSON Syntax valid? | ✅ | `python3 -m json.tool` |
| VS Code Reload? | ⏳ | **Cmd/Ctrl+Shift+P → Reload** |
| Test "@github" im Chat? | ⏳ | Copilot Chat öffnen & testen |

---

## 🚀 **Erwartetes Verhalten nach erfolgreicher Konfiguration:**

### **Im Copilot Chat:**

```
Wenn du "@" tippst, erscheint:

GitHub Copilot Chat
┌─────────────────────────────────────┐
│ 📌 Suggested MCP Servers:           │
│                                     │
│ @github        - GitHub Repository  │
│ @memory        - Session Context    │
│ @sequential-   - Multi-Step Plan    │
│ @filesystem    - Workspace Files    │
│ @figma         - Design System      │
│ @postgres      - Database Queries   │
│ @slack         - Team Chat          │
│ ... (40 weitere Server)             │
└─────────────────────────────────────┘
```

### **Bei Query-Ausführung:**

```
User: @github list repositories for menschlichkeit-oesterreich

Copilot: 🔄 Querying GitHub MCP Server...

Result:
✅ menschlichkeit-oesterreich-development
   - Main: chore/figma-mcp-make
   - Current: release/quality-improvements-2025-10-08
   - Last commit: 2025-10-08 (270 files changed)

✅ menschlichkeit-oesterreich-website
   - Main: main
   - Last commit: 2025-09-28
```

---

## 📚 **Weitere Hilfe:**

- **VS Code MCP Docs:** <https://code.visualstudio.com/docs/copilot/mcp>
- **MCP Registry:** <https://github.com/mcp>
- **Troubleshooting Guide:** `quality-reports/MCP-AGENT-MODE-COMPLETE-2025-10-08.md`
- **Environment Template:** `.vscode/mcp-environment-template.sh`

---

**Status:** MCP Server sind konfiguriert, aber nur im Copilot Chat sichtbar (NICHT in Extensions)! 🎯
