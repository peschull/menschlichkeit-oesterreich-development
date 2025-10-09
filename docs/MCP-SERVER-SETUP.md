# MCP Server Setup - Menschlichkeit Österreich

## 📋 Installierte MCP Server

### 🎨 Design & Frontend

- **Figma MCP Server** (`@figma/mcp-server-figma`)
  - Design Token Synchronisation
  - Komponenten-Export
  - Erfordert: `FIGMA_ACCESS_TOKEN`

### 🔧 Development Tools

- **GitHub MCP Server** (`@modelcontextprotocol/server-github`)
  - Issues, PRs, Branches, Security Alerts
  - Erfordert: `GITHUB_TOKEN` (bereits vorhanden)

- **Filesystem MCP Server** (`@modelcontextprotocol/server-filesystem`)
  - Datei-Management im Workspace
  - Automatisch auf Workspace-Root konfiguriert

- **Playwright MCP Server** (`@executeautomation/playwright-mcp-server`)
  - E2E-Test-Automatisierung
  - Integration mit bestehenden Playwright-Tests

### 🗄️ Database & Backend

- **PostgreSQL MCP Server** (`@modelcontextprotocol/server-postgres`)
  - Prisma-Integration
  - Erfordert: `POSTGRES_CONNECTION_STRING`

### 🔍 Search & Knowledge

- **Brave Search MCP Server** (`@modelcontextprotocol/server-brave-search`)
  - Web-Recherche für Dokumentation
  - Erfordert: `BRAVE_API_KEY`

- **Memory MCP Server** (`@modelcontextprotocol/server-memory`)
  - Kontext-Persistenz zwischen Sessions
  - Keine Konfiguration erforderlich

### 📚 Documentation (bereits aktiviert via GitHub Copilot)

- **Microsoft Docs MCP** - Azure, TypeScript, .NET Dokumentation
- **Upstash Context7 MCP** - Library-spezifische Dokumentation
- **Notion MCP** - Projekt-Dokumentation (falls konfiguriert)
- **Stripe MCP** - Payment-Integration (für Spenden/Mitgliedschaften)

## 🚀 Installation & Setup

### 1. Basis-Installation (automatisch via npx)

Alle MCP-Server werden automatisch bei Verwendung via `npx -y` installiert.

### 2. Umgebungsvariablen konfigurieren

Erstellen Sie eine `.env` Datei im Root:

```bash
# Figma Design System Integration
FIGMA_ACCESS_TOKEN=your_figma_token_here

# PostgreSQL/Prisma (bereits konfiguriert in schema.prisma)
POSTGRES_CONNECTION_STRING=postgresql://user:password@localhost:5432/menschlichkeit

# Brave Search (optional, für erweiterte Web-Recherche)
BRAVE_API_KEY=your_brave_api_key_here

# GitHub (bereits vorhanden via gh CLI)
GITHUB_TOKEN=$GITHUB_TOKEN
```

### 3. Figma Token beschaffen

1. Gehen Sie zu [Figma Account Settings](https://www.figma.com/settings)
2. Scrollen Sie zu "Personal Access Tokens"
3. Klicken Sie auf "Generate new token"
4. Kopieren Sie den Token in `.env`

### 4. Brave API Key (optional)

1. Gehen Sie zu [Brave Search API](https://brave.com/search/api/)
2. Registrieren Sie sich für den kostenlosen Plan
3. Kopieren Sie den API Key in `.env`

### 5. PostgreSQL Connection String

Verwenden Sie die bestehende Datenbank-Konfiguration:

```bash
# Lokal (aus schema.prisma)
POSTGRES_CONNECTION_STRING="postgresql://postgres:postgres@localhost:5432/menschlichkeit_gaming"

# Produktion (Plesk)
POSTGRES_CONNECTION_STRING="postgresql://plesk_user:password@db.menschlichkeit-oesterreich.at:5432/production_db"
```

## 🔄 MCP Server Verwaltung

### Via VS Code Settings

Die MCP-Server werden in `.vscode/mcp.json` konfiguriert und automatisch geladen.

### Via npm Scripts

```bash
# Alle MCP-relevanten Dependencies installieren
npm run setup:dev

# Figma Design Tokens synchronisieren
npm run figma:sync

# E2E-Tests mit Playwright
npm run test:e2e
```

### Manuelle Installation (falls erforderlich)

```bash
# Figma MCP Server
npx -y @figma/mcp-server-figma

# GitHub MCP Server
npx -y @modelcontextprotocol/server-github

# Playwright MCP Server
npx -y @executeautomation/playwright-mcp-server

# PostgreSQL MCP Server
npx -y @modelcontextprotocol/server-postgres

# Filesystem MCP Server
npx -y @modelcontextprotocol/server-filesystem /workspaces/menschlichkeit-oesterreich-development

# Brave Search MCP Server
npx -y @modelcontextprotocol/server-brave-search

# Memory MCP Server
npx -y @modelcontextprotocol/server-memory
```

## 🧪 Testen der MCP-Server

### 1. GitHub MCP Server

```bash
# Testen Sie mit GitHub Copilot Chat:
# "List all open issues in this repository"
# "Create a new branch for feature XYZ"
# "Show me the latest security alerts"
```

### 2. Figma MCP Server

```bash
# Testen Sie mit:
npm run figma:sync

# Oder via Copilot:
# "Sync design tokens from Figma"
# "Show me the latest design system updates"
```

### 3. Playwright MCP Server

```bash
# Testen Sie mit:
npm run test:e2e

# Oder via Copilot:
# "Run E2E tests for the login flow"
# "Generate a Playwright test for the donation form"
```

### 4. PostgreSQL MCP Server

```bash
# Testen Sie via Copilot:
# "Show me the database schema"
# "Query all users with XP > 100"
# "Explain the relationship between User and Achievement tables"
```

## 📊 Integration mit Quality Gates

Die MCP-Server sind in die bestehenden Quality Gates integriert:

```bash
# Vollständiger Quality Check (inkl. MCP-basierter Analysen)
npm run quality:gates

# Security Scan (nutzt GitHub MCP für Security Alerts)
npm run security:scan

# Performance Audit (Playwright MCP für E2E-Performance)
npm run performance:lighthouse
```

## 🔐 Sicherheitshinweise

1. **Tokens niemals committen**: Alle Tokens gehören in `.env` (ist in `.gitignore`)
2. **GitHub Token**: Verwenden Sie Fine-Grained Tokens mit minimalen Permissions
3. **Figma Token**: Read-Only, nur für Design-System-Dateien
4. **PostgreSQL**: Verwenden Sie separate Credentials für Dev/Staging/Prod

## 🚨 Troubleshooting

### MCP Server startet nicht

```bash
# Prüfen Sie die Logs
cat ~/.cache/github-copilot/logs/language-server.log | grep -i mcp

# Neustart von VS Code
# Cmd/Ctrl + Shift + P -> "Developer: Reload Window"
```

### Figma Token ungültig

```bash
# Token erneuern in Figma Settings
# .env aktualisieren
# VS Code neustarten
```

### PostgreSQL Connection fehlgeschlagen

```bash
# Prüfen Sie die Connection String
echo $POSTGRES_CONNECTION_STRING

# Testen Sie die Verbindung
npx prisma db pull --schema=schema.prisma
```

## 📈 Nächste Schritte

1. ✅ Figma Token konfigurieren für Design System Sync
2. ✅ Brave API Key für erweiterte Recherche (optional)
3. ✅ PostgreSQL Connection String validieren
4. ⏳ Codacy MCP Server Integration (automatisch via Copilot Instructions)
5. ⏳ n8n Webhook MCP Integration

## 🔗 Ressourcen

- [MCP Server Documentation](https://modelcontextprotocol.io/docs)
- [Figma MCP Server](https://github.com/figma/mcp-server-figma)
- [GitHub Copilot MCP Guide](https://docs.github.com/en/copilot/using-github-copilot/using-extensions)
- [Playwright MCP Server](https://github.com/executeautomation/playwright-mcp-server)

---

**Stand:** 2025-10-06
**Projekt:** Menschlichkeit Österreich Development
**Maintainer:** DevOps Team
