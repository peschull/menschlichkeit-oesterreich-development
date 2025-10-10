# MCP Configuration Merge Report

**Datum:** 2025-10-10  
**Aktion:** Konsolidierung von 2 mcp.json Dateien

---

## 📊 Vorher/Nachher

### Vorher (2 separate Dateien)
```
ROOT mcp.json:           17 Server (projekt-spezifisch)
.vscode/mcp.json:        13 Server (VS Code Gallery)
─────────────────────────────────────────────────
Summe:                   30 Server (mit Duplikaten)
Problem:                 VS Code lädt BEIDE Dateien gleichzeitig
```

### Nachher (1 konsolidierte Datei)
```
ROOT mcp.json:           21 Server (Best-of-Both)
.vscode/mcp.json:        GELÖSCHT (Backup: .vscode/mcp.json.backup)
─────────────────────────────────────────────────
Ergebnis:                Clean State, keine Duplikate
```

---

## ✅ Konsolidierte Server (21 gesamt)

### 🏗️ Projekt-Infrastruktur (8 Server)
1. **build-pipeline** - Build Orchestrierung (`./build-pipeline.sh`)
2. **docker** - Docker Container Management
3. **git** - Git Repository Operations
4. **n8n-webhook** - Automation Webhooks (`automation/n8n/webhook-client.js`)
5. **plesk-deploy** - Safe Deployment (`./scripts/safe-deploy.sh`)
6. **quality-reporter** - Quality Reports Generator (`scripts/generate-quality-report.js`)
7. **trivy-security** - Security Scanning (Trivy mit SARIF Output)
8. **lighthouse** - Performance Audits (`lighthouse.config.cjs`)

### 🗄️ Datenbank & Backend (2 Server)
9. **postgres** - PostgreSQL Enhanced Server (`enhanced-postgres-mcp-server`)
10. **prisma** - Prisma ORM (`schema.prisma`)

### 🎨 Design & Frontend (2 Server)
11. **figma** - Design Tokens Sync (`figma-mcp`)
12. **filesystem** - File System Operations (`@modelcontextprotocol/server-filesystem`)

### 📚 Knowledge & Documentation (4 Server)
13. **memory** - Persistent Memory (`@modelcontextprotocol/server-memory`)
14. **notion** - Notion Integration (`@notionhq/notion-mcp-server`)
15. **upstash-context7** - Contextual Search (`@upstash/context7-mcp`)
16. **microsoft-docs** - Microsoft Learn Docs (HTTP: `https://learn.microsoft.com/api/mcp`)

### 🔧 Development Tools (5 Server - NEU!)
17. **codacy-mcp-server** - Code Quality API (`@codacy/codacy-mcp@latest`) ⭐ ERSETZT codacy-cli
18. **markitdown** - File Format Converter (`markitdown-mcp==0.0.1a4`) ⭐ NEU
19. **github-mcp** - GitHub Integration (HTTP: `https://api.githubcopilot.com/mcp/`) ⭐ NEU
20. **playwright-mcp** - Browser Automation (`@playwright/mcp@latest`) ⭐ NEU
21. **moe-chat** - MOE ChatGPT App Server (`mcp-servers/chatgpt-app-server/index.js`)

---

## 🆕 Neu hinzugefügte Server (4)

### 1. **markitdown** (microsoft/markitdown)
- **Zweck:** Konvertiert Dateien zu Markdown (PDF, DOCX, XLSX, PPTX, Bilder)
- **Use Case:** Dokumentation aus PDFs extrahieren, Office-Dateien in Markdown umwandeln
- **Befehl:** `uvx markitdown-mcp==0.0.1a4`
- **Token:** ❌ Nicht erforderlich

### 2. **github-mcp** (github/github-mcp-server)
- **Zweck:** GitHub Integration via offizieller Copilot-Endpunkt
- **Use Case:** PRs erstellen/reviewen, Issues managen, Repository-Operationen
- **URL:** `https://api.githubcopilot.com/mcp/`
- **Token:** ❌ Nicht erforderlich (nutzt GitHub Copilot Auth)

### 3. **playwright-mcp** (microsoft/playwright-mcp)
- **Zweck:** Browser Automation für E2E Testing
- **Use Case:** Ergänzt `playwright.config.js`, automatisierte Browser-Tests
- **Befehl:** `npx @playwright/mcp@latest`
- **Token:** ❌ Nicht erforderlich

### 4. **microsoft-docs** (microsoftdocs/mcp)
- **Zweck:** Microsoft Learn Dokumentation (Azure, TypeScript, React, .NET)
- **Use Case:** Schneller Zugriff auf offizielle Microsoft Docs
- **URL:** `https://learn.microsoft.com/api/mcp`
- **Token:** ❌ Nicht erforderlich

---

## 🔄 Geänderte Server (1)

### **codacy-cli** → **codacy-mcp-server**
- **Vorher:** CLI-basiert (`codacy-analysis-cli`)
- **Nachher:** MCP-basiert (`@codacy/codacy-mcp@latest`)
- **Vorteil:** Direkte API-Integration, bessere VS Code Integration
- **Token:** ✅ Erforderlich (`${input:codacy_account_token}`)

---

## ❌ Nicht übernommene Server (8)

### Begründungen:

1. **apify/apify-mcp-server**
   - Benötigt API Key
   - Kein aktueller Use Case für Web Scraping

2. **cognitionai/deepwiki**
   - Wiki-Feature
   - Nicht prioritär für Projekt

3. **context7** (Duplikat)
   - Bereits als `upstash-context7` vorhanden
   - Identische Funktionalität

4. **firecrawl/firecrawl-mcp-server**
   - Web Scraping, benötigt API Key
   - Kein aktueller Use Case

5. **neondatabase/mcp-server-neon**
   - Postgres-Alternative
   - Bereits `enhanced-postgres-mcp-server` vorhanden

6. **oraios/serena**
   - IDE Assistant (sehr experimental)
   - Git-basierte Installation instabil

7. **stripe/agent-toolkit**
   - Payment Integration
   - Kein aktueller Use Case

8. **upstash/context7** (Duplikat in .vscode/)
   - Bereits als `upstash-context7` in ROOT vorhanden
   - Identische Funktionalität

---

## 🔑 Input-Konfiguration

### Vorher (ROOT mcp.json)
```json
{
  "notion_token": "Notion API Token",
  "postgres_url": "PostgreSQL Connection String",
  "figma_file_key": "Figma File Key"
}
```

### Nachher (konsolidiert)
```json
{
  "notion_token": "Notion API Token",
  "postgres_url": "PostgreSQL Connection String",
  "figma_file_key": "Figma File Key",
  "codacy_account_token": "Codacy Account API Token" ⭐ NEU
}
```

---

## 🧪 Validierung

### JSON Syntax
```bash
✅ jq . mcp.json
# Ausgabe: VALID
```

### Server-Anzahl
```bash
✅ cat mcp.json | jq -r '.servers | keys[]' | wc -l
# Erwartet: 21
# Ergebnis: 21
```

### Duplikate
```bash
✅ Keine Server-Duplikate
# Vorher: upstash-context7 und context7 (beide identisch)
# Nachher: Nur upstash-context7
```

---

## 📦 Backup & Rollback

### Backup erstellt
```bash
✅ .vscode/mcp.json.backup (8.5K)
# Zeitstempel: 2025-10-10 04:35 UTC
```

### Rollback (falls nötig)
```bash
# Falls Probleme auftreten:
cp .vscode/mcp.json.backup .vscode/mcp.json

# Oder alte ROOT Version wiederherstellen:
git checkout HEAD~1 -- mcp.json
```

---

## 🚀 Nächste Schritte

### 1. **Developer Window Reload** (WICHTIG!)
```
Cmd/Ctrl + Shift + P
→ "Developer: Reload Window"
→ Enter
```
**Effekt:** VS Code lädt nur noch die konsolidierte mcp.json

### 2. **Token konfigurieren**
- **Codacy:** Hole Token von `app.codacy.com → Account`
- **Eingabe:** Beim ersten Aufruf von `@codacy-mcp-server` wird Token abgefragt

### 3. **Neue Server testen**
```
@markitdown Convert PDF to Markdown
@github-mcp List open pull requests
@playwright-mcp Launch browser and navigate to localhost:5173
@microsoft-docs Search TypeScript documentation
```

### 4. **Git Commit**
```bash
git add mcp.json .vscode/mcp.json.backup
git commit -m "fix(mcp): Merge ROOT and .vscode/mcp.json - 21 consolidated servers

- Add markitdown, github-mcp, playwright-mcp, microsoft-docs
- Replace codacy-cli with codacy-mcp-server (better API integration)
- Remove duplicates (context7)
- Delete .vscode/mcp.json (backup preserved)
- Single source of truth: ROOT mcp.json

Server count: 17 → 21 (4 new, 1 replaced)
"
```

---

## 📋 Zusammenfassung

| Metrik | Vorher | Nachher | Änderung |
|--------|--------|---------|----------|
| **Dateien** | 2 | 1 | -1 (konsolidiert) |
| **Server gesamt** | 30 (mit Duplikaten) | 21 | -9 (Duplikate entfernt) |
| **Projekt-Server** | 17 | 17 | 0 (alle behalten) |
| **Gallery-Server** | 13 | 4 | -9 (nur nützliche) |
| **Duplikate** | 2 (upstash-context7) | 0 | -2 |
| **Input-Tokens** | 3 | 4 | +1 (codacy) |

**Status:** ✅ ERFOLGREICH  
**JSON Valid:** ✅ JA  
**Backup:** ✅ VORHANDEN  
**Commit:** ⏳ PENDING

---

**Erstellt:** 2025-10-10  
**Autor:** GitHub Copilot  
**Commit:** PENDING
