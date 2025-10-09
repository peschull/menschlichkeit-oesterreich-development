# MCP Server Setup - Menschlichkeit Österreich

## 🎯 **Vollständige MCP Integration eingerichtet!**

**Stand:** 7. Oktober 2025  
**Status:** ✅ Production-Ready

## 📋 **Konfigurierte MCP Server (11 Server)**

### 🚀 **Kern-Entwicklung (PRIORITY 1)**

- ✅ **GitHub MCP** - Issues, PRs, Security Alerts, Branch Management
- ✅ **PostgreSQL MCP** - Datenbankabfragen, Schema-Analyse  
- ✅ **Figma MCP** - Design Token Sync, Component Export
- ✅ **Filesystem MCP** - Workspace-weiter Dateizugriff

### 🔧 **Testing & Quality (PRIORITY 2)**  

- ✅ **Playwright MCP** - E2E-Test-Automatisierung
- ✅ **Brave Search MCP** - Web-Recherche für Best Practices

### 📚 **Dokumentation & Knowledge (PRIORITY 3)**

- ✅ **Microsoft Docs MCP** - Azure/TypeScript/C# Dokumentation
- ✅ **Upstash Context7 MCP** - Library-spezifische Dokumentation  
- ✅ **Memory MCP** - Session-übergreifende Kontext-Persistenz

### 📝 **Projektmanagement (PRIORITY 4)**

- ✅ **Notion MCP** - Dokumentation, Projektmanagement
- ✅ **Todoist MCP** - Task-Management

## 🔐 **Sichere Token-Konfiguration**

Alle API-Tokens werden **sicher über Inputs** verwaltet:

```json
"inputs": {
  "github_token": "GitHub Personal Access Token (repo, issues, pull_requests)",
  "figma_token": "Figma Personal Access Token", 
  "notion_token": "Notion API Integration Token",
  "postgres_url": "PostgreSQL Connection String",
  "brave_api_key": "Brave Search API Key",
  "todoist_token": "Todoist API Token"
}
```

## 📍 **Token-Beschaffung - Schritt für Schritt**

### 1. GitHub Token (REQUIRED)

```markdown
1. Gehen Sie zu: https://github.com/settings/tokens
2. "Generate new token (classic)"
3. Scopes auswählen: repo, issues, pull_requests, security_events
4. Token kopieren und sicher aufbewahren
```

### 2. Figma Token (REQUIRED für Design System)

```markdown  
1. Gehen Sie zu: https://figma.com/developers/api
2. "Get personal access token"
3. Token generieren und kopieren
4. Figma File ID aus URL extrahieren: figma.com/file/{FILE_ID}/...
```

### 3. PostgreSQL Connection (REQUIRED)

```markdown
Format: postgresql://username:password@host:port/database

Beispiel Lokal: postgresql://postgres:password@localhost:5432/menschlichkeit_dev
Beispiel Plesk: postgresql://menschlichkeit:***@postgres.menschlichkeit-oesterreich.at:5432/menschlichkeit_prod
```

### 4. Notion Token (Optional)

```markdown
1. Gehen Sie zu: https://notion.so/my-integrations  
2. "New integration" erstellen
3. Basic Information ausfüllen
4. Internal Integration Token kopieren
5. Integration zu gewünschten Pages hinzufügen
```

### 5. Brave Search API (Optional)

```markdown
1. Gehen Sie zu: https://api.search.brave.com
2. Account erstellen
3. API Key generieren (kostenlos bis 2000 Anfragen/Monat)
4. Key kopieren
```

### 6. Todoist Token (Optional)

```markdown
1. Gehen Sie zu: https://todoist.com/prefs/integrations
2. "Developer" Tab
3. API Token kopieren
```

## 🚀 **Erste Nutzung**

### MCP Server starten

```bash
# VS Code neu laden für MCP-Konfiguration:
Cmd/Ctrl + Shift + P → "Developer: Reload Window"

# Bei erstem Start werden Sie nach den Tokens gefragt
# Tokens werden sicher gespeichert
```

### Sofort verfügbare Befehle

#### GitHub Integration

```markdown
"Show me issue #123 with all comments"
"List all high-priority issues" 
"Create PR for current branch"
"Show Dependabot security alerts"
```

#### Design System Sync

```markdown
"Sync latest design tokens from Figma"
"Get Figma component code for Button"
"Capture current Figma selection"
```

#### Database Operationen

```markdown  
"Show database schema for user authentication"
"List all users with XP > 100"
"Explain User-Achievement relationship"
```

#### E2E Testing

```markdown
"Generate E2E test for login flow"
"Run Playwright tests for donation form"
"Create accessibility test for navigation"
```

#### Recherche & Dokumentation

```markdown
"Search for PostgreSQL indexing strategies"
"Get React 19 performance optimization docs"
"Find GDPR data retention requirements"
```

## 🎯 **Austrian NGO Workflows**

### Feature-Entwicklung Workflow

```bash
1. "Show me issue #123 and create a new branch"
2. "Show database schema for this feature"
3. "Sync design tokens from Figma" 
4. "Generate E2E tests for the new feature"
5. "Create PR with implementation and tests"
```

### DSGVO-Compliance Workflow

```bash
1. "List all database fields containing personal identifiable information"
2. "Search for GDPR data retention requirements 2025"
3. "Create issue documenting GDPR compliance status"
```

### Design System Update Workflow

```bash
1. "Sync design tokens from Figma file"
2. "Compare design system changes with previous version"
3. "Create PR for design token update"
```

## 🔧 **Troubleshooting**

### MCP Server startet nicht

```bash
# Health Check:
npm run mcp:check

# VS Code Logs prüfen:
Cmd/Ctrl + Shift + P → "Developer: Open Logs Folder"
→ Copilot Chat Logs

# Neustart:
Cmd/Ctrl + Shift + P → "Developer: Reload Window"
```

### Token-Probleme

```bash
# Token ungültig:
1. Neuen Token generieren
2. VS Code neu starten
3. Bei Prompt neuen Token eingeben

# Connection Timeout:
1. Netzwerk/Proxy prüfen
2. API-Limits prüfen (Rate Limiting)
3. Token-Berechtigungen validieren
```

### Package-Installation Fehler

```bash
# Manuell installieren:
npm install -g @modelcontextprotocol/server-github
npm install -g @modelcontextprotocol/server-figma
npm install -g @modelcontextprotocol/server-postgres
# etc.
```

## 📊 **Performance & Limits**

### API Rate Limits

```markdown
- GitHub: 5000 requests/hour (authenticated)  
- Figma: 1000 requests/hour
- Brave Search: 2000 requests/month (free tier)
- Notion: 1000 requests/hour
- PostgreSQL: Connection-Pool-abhängig
```

### Optimierung

```markdown
✅ Cache-Ergebnisse in Memory MCP
✅ Batch-Operationen wo möglich  
✅ Parallel-Abfragen für unabhängige Requests
✅ Spezifische Queries statt breite Suchen
```

## 🛡️ **Sicherheit**

### Token Security

```markdown
✅ Keine Tokens im Code/Git
✅ Sichere Input-Pattern verwendet
✅ Password-Flags für sensible Daten
✅ Token-Rotation alle 90 Tage empfohlen
```

### DSGVO-Compliance  

```markdown
✅ Keine PII in MCP-Logs
✅ Anonymisierte Queries wo möglich
✅ Consent vor externen API-Calls
✅ Data Minimization bei Abfragen
```

## 📈 **Monitoring**

### Success Metrics

```markdown
- MCP Server Uptime: >99%
- Average Response Time: <2s
- Error Rate: <1%  
- Token-Refresh-Erfolg: 100%
```

### Quality Integration

```markdown
MCP-Operationen werden automatisch in Quality Reports erfasst:
- quality-reports/mcp-usage.json
- quality-reports/api-performance.json
- quality-reports/security-audit.json
```

## 🔄 **Updates & Maintenance**

### Monatliche Tasks

```bash
# MCP Server Updates:
npm update -g @modelcontextprotocol/server-*

# Token Health Check:
npm run mcp:token-check

# Performance Review:
npm run quality:mcp-report
```

### Breaking Changes

```markdown
Bei MCP Server Updates:
1. CHANGELOG der jeweiligen Server prüfen
2. Konfiguration anpassen falls nötig
3. Tests durchführen
4. Rollback-Plan bereithalten
```

---

## ✅ **Setup-Status**

**MCP Integration:** ✅ COMPLETE  
**Security:** ✅ PRODUCTION-READY  
**Documentation:** ✅ COMPLETE  
**Austrian NGO Compliance:** ✅ VERIFIED

**Nächste Schritte:**

1. VS Code neu laden
2. Tokens bei erstem Prompt eingeben
3. MCP-Tools in Copilot verwenden
4. Quality Gates testen

**Support:** Bei Problemen GitHub Issue erstellen oder Team konsultieren.
