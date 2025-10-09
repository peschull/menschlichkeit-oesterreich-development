# 🚀 MCP Server Quick Start

**Sofort loslegen mit den konfigurierten MCP Servern!**

---

## ⚡ 3-Schritte-Setup

### 1️⃣ Umgebungsvariablen konfigurieren

Kopieren Sie das Template und füllen Sie die Werte aus:

```bash
# .env erstellen (falls nicht vorhanden)
cp .env.mcp.template .env
```

Mindestanforderungen in `.env`:

```bash
# Erforderlich für Figma Design System
FIGMA_ACCESS_TOKEN=figd_xxx...

# Bereits konfiguriert via schema.prisma
POSTGRES_CONNECTION_STRING=postgresql://postgres:postgres@localhost:5432/menschlichkeit_gaming

# Optional: Web-Recherche
BRAVE_API_KEY=BSA...
```

**Figma Token holen:**

1. 🔗 Gehen Sie zu <https://www.figma.com/settings>
2. ➕ Klicken Sie auf "Personal Access Tokens" → "Generate new token"
3. 📋 Kopieren Sie den Token in `.env`

### 2️⃣ VS Code neu starten

```bash
# In VS Code:
# Cmd/Ctrl + Shift + P
# Tippen Sie: "Developer: Reload Window"
# Enter drücken
```

### 3️⃣ MCP Server testen

Öffnen Sie GitHub Copilot Chat und testen Sie:

```text
"List all open issues in this repository"
```

✅ Wenn Sie eine Antwort erhalten, funktioniert der GitHub MCP Server!

---

## 🧪 Weitere Tests

### Figma MCP Server

```bash
# Terminal:
npm run figma:sync

# Oder via Copilot Chat:
"Sync design tokens from Figma"
```

### Playwright MCP Server

```bash
# Copilot Chat:
"Generate an E2E test for the login flow"
"Run Playwright tests for the donation form"
```

### PostgreSQL MCP Server

```bash
# Copilot Chat:
"Show me the database schema"
"Query all users with XP > 100"
"Explain the User-Achievement relationship"
```

### Filesystem MCP Server

```bash
# Copilot Chat:
"Show me all TypeScript files in the frontend"
"Find configuration files in the project"
```

### Brave Search MCP Server

```bash
# Copilot Chat:
"Search web for PostgreSQL indexing best practices"
"Find latest React 19 features"
```

---

## 📋 Verfügbare npm Scripts

```bash
# Setup & Health Check
npm run mcp:setup          # Installiert alle MCP Server
npm run mcp:check          # Prüft MCP Server Status
npm run mcp:list           # Listet konfigurierte Server
npm run mcp:docs           # Zeigt vollständige Dokumentation

# Figma Integration
npm run figma:sync         # Synchronisiert Design Tokens
npm run design:tokens      # Sync + Frontend Build

# Testing
npm run test:e2e           # E2E-Tests mit Playwright MCP
npm run quality:gates      # Alle Quality Checks (inkl. MCP)

# Development
npm run dev:all            # Alle Services starten
npm run dev:frontend       # Frontend mit MCP-Unterstützung
```

---

## 🎯 Typische Use Cases

### 1. **Design System Update**

```bash
# Designer hat Figma aktualisiert
npm run figma:sync

# Prüfen Sie die Changes:
git diff figma-design-system/00_design-tokens.json

# Frontend neu bauen mit neuen Tokens:
npm run design:tokens
```

### 2. **GitHub Issue bearbeiten**

```bash
# Via Copilot Chat:
"Show me all high-priority issues"
"Create a new issue for implementing feature XYZ"
"Add a comment to issue #123 about the API changes"
```

### 3. **E2E-Test schreiben**

```bash
# Via Copilot Chat:
"Generate a Playwright test that:
1. Opens the donation page
2. Fills in the form with test data
3. Submits and verifies success message"

# Test ausführen:
npm run test:e2e
```

### 4. **Datenbank-Analyse**

```bash
# Via Copilot Chat:
"Show me all achievements with reward type 'BADGE'"
"Explain how the XP system works in the database"
"Generate a migration to add email verification"
```

### 5. **Code-Recherche**

```bash
# Via Copilot Chat mit Brave Search:
"Search for best practices for GDPR-compliant user data deletion"
"Find examples of CiviCRM API integration with FastAPI"
"Latest security recommendations for PostgreSQL 16"
```

---

## 🔍 Health Check

Prüfen Sie jederzeit den Status aller MCP Server:

```bash
npm run mcp:check
```

**Erwartete Ausgabe:**

```text
🔍 MCP Server Health Check

📊 Gefundene MCP Server: 7

✅ Verfügbar: 6
⚠️  Nicht installiert (wird bei Bedarf geladen): 1

💡 Hinweis: MCP Server mit npx -y werden automatisch bei Bedarf installiert.
```

---

## 🆘 Probleme?

### MCP Server reagiert nicht

```bash
# 1. Logs prüfen
cat ~/.cache/github-copilot/logs/language-server.log | grep -i error

# 2. VS Code komplett neu starten
# 3. MCP-Konfiguration prüfen
cat .vscode/mcp.json | jq '.'
```

### Umgebungsvariablen fehlen

```bash
# .env prüfen
cat .env | grep -E "FIGMA|POSTGRES|BRAVE"

# Template vergleichen
diff .env .env.mcp.template
```

### Figma Sync schlägt fehl

```bash
# Token validieren (muss mit 'figd_' beginnen)
echo $FIGMA_ACCESS_TOKEN

# Token in Figma erneuern und .env aktualisieren
```

---

## 📚 Weiterführende Dokumentation

- 📖 **Vollständige Anleitung:** `docs/MCP-SERVER-SETUP.md`
- 📊 **Installation Report:** `docs/MCP-INSTALLATION-REPORT.md`
- 🔧 **Setup Script:** `scripts/setup-mcp-servers.sh`
- 🩺 **Health Check:** `scripts/check-mcp-servers.js`

---

## ✨ Pro-Tipps

1. **Multi-Server Anfragen kombinieren:**

   ```
   "Use GitHub to find issue #42, then search web for solutions to that problem"
   ```

2. **Design + Code synchron halten:**

   ```bash
   # Nach jedem Figma-Update:
   npm run figma:sync && npm run build:frontend
   ```

3. **Datenbank-Queries optimieren:**

   ```
   "Show me the Prisma schema for User, then suggest indexes for performance"
   ```

4. **Automatisierte Tests generieren:**

   ```
   "Analyze the login component, then generate comprehensive Playwright tests"
   ```

5. **Context-Aware Development:**

   ```
   "Remember: This project uses Austrian German for UI text. 
    Generate a form with proper DSGVO-compliant consent checkboxes."
   ```

---

**🎉 Viel Erfolg mit den MCP Servern!**

Bei Fragen: GitHub Issues im Repository erstellen
