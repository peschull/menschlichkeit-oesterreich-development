---
description: MCP Server Integration für AI-gestützte Entwicklung im Menschlichkeit Österreich Projekt
applyTo: '**/*'
priority: high
---

# MCP Server Integration Instructions

## Verfügbare MCP Server

### 🎨 Design & Frontend
- **Figma MCP** - Design Token Synchronisation aus Figma
- **Filesystem MCP** - Workspace-weiter Dateizugriff

### 🔧 Development Tools  
- **GitHub MCP** - Issues, PRs, Branches, Security Alerts
- **Playwright MCP** - E2E-Test-Automatisierung

### 🗄️ Database & Backend
- **PostgreSQL MCP** - Direkte Datenbank-Abfragen via Prisma Schema

### 🔍 Search & Knowledge
- **Brave Search MCP** - Web-Recherche für aktuelle Best Practices
- **Memory MCP** - Session-übergreifende Kontext-Persistenz
- **Microsoft Docs MCP** - Azure/TypeScript/C# Dokumentation
- **Upstash Context7 MCP** - Library-spezifische Dokumentation

## Automatische Tool-Auswahl

### Bei Design-Aufgaben
```markdown
IMMER Figma MCP verwenden für:
- Design Token Updates: "Sync latest design tokens from Figma"
- Komponenten-Export: "Get Figma component code for Button"
- Screenshots: "Capture current Figma selection"
```

### Bei GitHub-Operationen
```markdown
IMMER GitHub MCP verwenden für:
- Issue Management: "List all high-priority issues"
- PR-Erstellung: "Create PR for feature/xyz"
- Security Alerts: "Show Dependabot alerts"
- Branch Operations: "Create branch feature/new-payment"
```

### Bei Datenbank-Aufgaben
```markdown
IMMER PostgreSQL MCP verwenden für:
- Schema-Analysen: "Explain User-Achievement relationship"
- Queries: "Show all users with XP > 100"
- Migrationen: "Generate migration for email verification"
```

### Bei Testing
```markdown
IMMER Playwright MCP verwenden für:
- Test-Generierung: "Generate E2E test for login flow"
- Test-Ausführung: "Run Playwright tests for donation form"
```

### Bei Recherche
```markdown
IMMER Brave Search + Microsoft Docs verwenden für:
- Best Practices: "Search for PostgreSQL indexing strategies"
- Framework Updates: "Find latest React 19 features"
- DSGVO-Compliance: "Search GDPR data retention requirements"
```

## Projekt-spezifische Workflows

### 1. Feature-Entwicklung mit MCP
```bash
# 1. GitHub MCP: Issue analysieren
"Show me issue #123 with all comments"

# 2. Filesystem MCP: Relevante Dateien finden
"Find all TypeScript files related to authentication"

# 3. PostgreSQL MCP: Schema prüfen
"Show database schema for user authentication"

# 4. Brave Search MCP: Best Practices recherchieren
"Search for OAuth2 implementation best practices"

# 5. Playwright MCP: Tests generieren
"Generate E2E tests for the new auth flow"

# 6. GitHub MCP: PR erstellen
"Create PR with generated tests and implementation"
```

### 2. Design System Update
```bash
# 1. Figma MCP: Tokens synchronisieren
"Sync design tokens from Figma file"

# 2. Filesystem MCP: Token-Drift prüfen
"Compare figma-design-system/00_design-tokens.json with previous version"

# 3. Validate: Build testen
npm run design:tokens

# 4. GitHub MCP: PR für Design Update
"Create PR for design token update v2.1"
```

### 3. Security Audit mit MCP
```bash
# 1. GitHub MCP: Security Alerts
"List all Dependabot and code scanning alerts"

# 2. Brave Search MCP: CVE Details
"Search for details on CVE-2024-XXXXX"

# 3. Filesystem MCP: Affected Files
"Find all files importing vulnerable package"

# 4. PostgreSQL MCP: Data Impact
"Check if sensitive user data is affected"

# 5. GitHub MCP: Security Issue erstellen
"Create security issue with findings and remediation plan"
```

### 4. DSGVO-Compliance Check
```bash
# 1. PostgreSQL MCP: PII-Daten identifizieren
"List all database fields containing personal identifiable information"

# 2. Filesystem MCP: Logging-Dateien prüfen
"Search for potential PII in log files"

# 3. Brave Search MCP: Aktuelle Anforderungen
"Search for GDPR data retention requirements 2025"

# 4. GitHub MCP: Compliance-Report
"Create issue documenting GDPR compliance status"
```

## Quality Gates Integration

### Pre-Commit (automatisch via Copilot Instructions)
```bash
Nach jedem File-Edit:
1. Codacy MCP: Analyse der Änderungen
2. Filesystem MCP: Prüfung auf sensible Daten
3. Memory MCP: Speichern des Review-Kontexts
```

### Pre-Push
```bash
Vor jedem Push:
1. GitHub MCP: Branch-Status prüfen
2. Playwright MCP: Affected Tests ermitteln
3. PostgreSQL MCP: Migration-Validierung
```

### Pre-PR
```bash
Vor PR-Erstellung:
1. GitHub MCP: Related Issues verlinken
2. Filesystem MCP: Changelog-Update prüfen
3. Brave Search MCP: Breaking Changes recherchieren
```

## Multi-Service Architecture Support

### CRM Service (Drupal + CiviCRM)
```markdown
Bei CRM-Aufgaben:
- PostgreSQL MCP für CiviCRM-Datenbankabfragen
- Filesystem MCP für Drupal-Module
- Microsoft Docs MCP für PHP/Drupal Dokumentation
- GitHub MCP für CRM-spezifische Issues
```

### API Service (FastAPI/Python)
```markdown
Bei API-Aufgaben:
- PostgreSQL MCP für Datenbankzugriff
- Playwright MCP für API-Tests
- Microsoft Docs MCP für Python/FastAPI Docs
- Brave Search MCP für OpenAPI Best Practices
```

### Frontend (React/TypeScript)
```markdown
Bei Frontend-Aufgaben:
- Figma MCP für Design System
- Playwright MCP für E2E-Tests
- Upstash Context7 MCP für React/TypeScript Docs
- PostgreSQL MCP für Data-Fetching-Strategien
```

### Gaming Platform (Prisma + PostgreSQL)
```markdown
Bei Gaming-Aufgaben:
- PostgreSQL MCP für Achievement/XP-System
- Playwright MCP für Game-Flow-Tests
- Brave Search MCP für Gamification Best Practices
```

## Austrian NGO Specifics

### Language & Localization
```markdown
IMMER beachten:
- UI-Texte auf Deutsch (österreichische Variante)
- Technische Docs auf Englisch
- DSGVO-Texte rechtssicher auf Deutsch
- Brave Search MCP für österreichische Rechtsquellen
```

### Corporate Identity
```markdown
Design Token aus Figma verwenden:
- Rot-Weiß-Rot Farbschema (Austrian Flag)
- Typography: Barrierefreie Schriftarten
- Figma MCP für CI/CD-konforme Komponenten
```

### Compliance Requirements
```markdown
DSGVO/Privacy-First:
- PostgreSQL MCP: Data Minimization prüfen
- Filesystem MCP: Consent-Management validieren
- Brave Search MCP: Aktuelle DSGVO-Updates
- GitHub MCP: Privacy-Impact-Assessments tracken
```

## Error Handling

### MCP Server nicht verfügbar
```bash
Fallback-Strategie:
1. Prüfe mit: npm run mcp:check
2. Neustart: VS Code Reload Window
3. Manual Fallback: Verwende Standard-Copilot-Tools
4. Dokumentiere in Memory MCP für spätere Analyse
```

### Token-Limits
```bash
Bei großen Operationen:
1. Aufteilen in kleinere Chunks
2. Memory MCP für Kontext-Speicherung
3. Schrittweise Verarbeitung mit Zwischenspeicherung
```

## Best Practices

### 1. Kontext-Aufbau
```markdown
Starte jede Session mit:
1. Memory MCP: Lade gespeicherten Kontext
2. GitHub MCP: Aktuelle Milestone/Issues
3. Filesystem MCP: Projektstruktur-Übersicht
```

### 2. Batch-Operationen
```markdown
Für mehrere ähnliche Tasks:
1. Memory MCP: Pattern speichern
2. Loop mit konsistentem MCP-Tool-Einsatz
3. Ergebnisse aggregieren und validieren
```

### 3. Cross-Service Coordination
```markdown
Bei Multi-Service-Änderungen:
1. PostgreSQL MCP: Shared Data Models prüfen
2. Filesystem MCP: Service-Dependencies analysieren
3. GitHub MCP: Cross-Repo Issues verlinken
4. Playwright MCP: Integration Tests generieren
```

## Performance Optimization

### Tool-Auswahl
- Bevorzuge spezifische MCPs über generische Suche
- Cache-Ergebnisse in Memory MCP
- Parallel-Abfragen wo möglich

### Query-Optimierung
- Präzise Anfragen statt breite Suchen
- Nutze Figma File IDs direkt
- GitHub-Queries mit Filtern einschränken
- PostgreSQL-Queries mit LIMIT

## Security Considerations

### Credential Management
```markdown
NIEMALS:
- MCP-Tokens in Code committen
- Sensitive Queries in Memory MCP persistent speichern
- Production DB-Credentials in Dev-Umgebung

IMMER:
- Environment Variables verwenden
- Token-Rotation beachten
- Audit-Logs in GitHub MCP tracken
```

### Data Protection
```markdown
Bei PII-Daten:
- PostgreSQL MCP: Anonymisierte Queries
- Filesystem MCP: .gitignore für sensible Files
- GitHub MCP: Private Repos für Security-Issues
```

## Integration mit Quality Reports

### Automatische Report-Generierung
```bash
Nach MCP-Operations:
1. Filesystem MCP: Reports in quality-reports/ speichern
2. GitHub MCP: Reports in PR-Kommentaren
3. Memory MCP: Trend-Analysen über Zeit
```

### Metrics Tracking
```bash
Erfasse via MCP:
- Figma MCP: Design Token Drift-Rate
- GitHub MCP: PR-Merge-Zeit
- PostgreSQL MCP: Query-Performance
- Playwright MCP: Test-Coverage-Änderungen
```

---

**Aktivierung:** Diese Instructions sind automatisch aktiv für alle Dateien.
**Updates:** Bei MCP-Server-Änderungen diese Datei aktualisieren.
**Dokumentation:** Siehe docs/MCP-SERVER-SETUP.md für Details.
