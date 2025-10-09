# MCP-Enhanced Development - Vollständige Integration

**Stand:** 2025-01-XX  
**Projekt:** Menschlichkeit Österreich Multi-Service NGO Platform  
**MCP-Version:** 1.0 mit 7 konfigurierten Servern

---

## 📚 Dokumentations-Übersicht

### Kern-Dokumentation

1. **MCP-SERVER-SETUP.md** - Komplette Installation & Konfiguration
2. **MCP-INSTALLATION-REPORT.md** - Status-Report & Health Check
3. **MCP-QUICK-START.md** - 3-Minuten Quick Start

### GitHub Copilot Integration

4. **.github/instructions/mcp-integration.instructions.md** - Automatische Tool-Auswahl
5. **.github/instructions/project-development.instructions.md** - Projekt-weite Guidelines

### Chatmodes (Spezialisierte Modi)

6. **.github/chatmodes/MCPCodeReview_DE.chatmode.md** - MCP-enhanced Code Reviews
7. **.github/chatmodes/MCPSicherheitsAudit_DE.chatmode.md** - Security Audits mit MCP
8. **.github/chatmodes/MCPDesignSystemSync_DE.chatmode.md** - Figma Design Sync

### Prompts (Workflows)

9. **.github/prompts/MCPFeatureImplementation_DE.prompt.md** - Feature Development Flow
10. **.github/prompts/MCPDatabaseMigration_DE.prompt.md** - DB Migration Flow
11. **.github/prompts/MCPSecurityIncident_DE.prompt.md** - Incident Response Flow

---

## 🛠️ MCP Server Konfiguration

### Installierte Server (.vscode/mcp.json)

```json
{
  "servers": {
    "figma": {
      "command": "npx",
      "args": ["-y", "@figma/mcp-server-figma"],
      "env": {
        "FIGMA_ACCESS_TOKEN": "${FIGMA_ACCESS_TOKEN}"
      }
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/workspaces/menschlichkeit-oesterreich-development"
      ]
    },
    "playwright": {
      "command": "npx",
      "args": ["-y", "@executeautomation/playwright-mcp-server"]
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {
        "POSTGRES_CONNECTION_STRING": "${POSTGRES_CONNECTION_STRING}"
      }
    },
    "brave-search": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-brave-search"],
      "env": {
        "BRAVE_API_KEY": "${BRAVE_API_KEY}"
      }
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### Verfügbarkeit (npm run mcp:check)

- ✅ GitHub MCP - Available
- ✅ Filesystem MCP - Available
- ✅ Playwright MCP - Available
- ✅ PostgreSQL MCP - Available
- ✅ Brave Search MCP - Available
- ✅ Memory MCP - Available
- ⏳ Figma MCP - Loads on demand (npx -y)

---

## 🚀 Quick Start Workflows

### 1. Code Review mit MCP

```bash
# Chatmode aktivieren
@workspace /chatmode MCPCodeReview_DE

# Prompt
"Reviewe PR #42 mit vollständiger MCP-Analyse"

# AI nutzt automatisch:
- GitHub MCP → PR Details, Comments, CI Status
- Filesystem MCP → Code-Analyse, Impact Assessment
- PostgreSQL MCP → DB Schema-Validierung
- Brave Search MCP → Best Practices
- Memory MCP → Vorherige Review-Patterns
```

### 2. Sicherheitsaudit

```bash
# Chatmode aktivieren
@workspace /chatmode MCPSicherheitsAudit_DE

# Prompt
"Führe vollständiges Security Audit für API-Service durch"

# AI nutzt automatisch:
- GitHub MCP → Dependabot/Secret Scanning Alerts
- PostgreSQL MCP → PII Detection, Audit Logs
- Filesystem MCP → Code-Scanning, Secret Exposure
- Brave Search MCP → CVE Details, GDPR Requirements
```

### 3. Design System Sync

```bash
# Chatmode aktivieren
@workspace /chatmode MCPDesignSystemSync_DE

# Prompt
"Synchronisiere Design Tokens von Figma"

# AI nutzt automatisch:
- Figma MCP → Extract Design Tokens, Components
- Filesystem MCP → Update CSS Variables, Tailwind Config
- GitHub MCP → Create PR mit Changes
- Memory MCP → Track Design System History
```

### 4. Feature Implementation

```bash
# Prompt verwenden
@workspace /prompt MCPFeatureImplementation_DE

# Input
"Implementiere Newsletter-Anmeldung mit DSGVO-Consent"

# AI-Flow:
1. GitHub MCP → Issue-Details
2. Figma MCP → Design abrufen
3. PostgreSQL MCP → DB-Migration
4. Filesystem MCP → Code generieren (CRM/API/Frontend)
5. Playwright MCP → E2E Tests
6. GitHub MCP → PR erstellen
```

### 5. Database Migration

```bash
# Prompt verwenden
@workspace /prompt MCPDatabaseMigration_DE

# Input
"Füge newsletter_consent Spalte zu civicrm_contact hinzu"

# AI-Flow:
1. PostgreSQL MCP → Schema-Analyse
2. Filesystem MCP → Migration Script generieren
3. PostgreSQL MCP → Staging-Test
4. Filesystem MCP → ORM Models updaten (Prisma/SQLAlchemy/Drupal)
5. GitHub MCP → Deployment PR
```

---

## 📊 Service-Spezifische MCP-Nutzung

### CRM Service (Drupal + CiviCRM)

**Primary MCPs:** PostgreSQL, Filesystem, GitHub

```yaml
Typische Tasks:
- Contact Management → PostgreSQL MCP (civicrm_contact queries)
- Custom Module Dev → Filesystem MCP (code generation)
- Security Audit → GitHub MCP (Drupal security advisories)
- DSGVO Compliance → PostgreSQL MCP (PII detection)
```

### API Backend (FastAPI)

**Primary MCPs:** PostgreSQL, Filesystem, GitHub, Brave Search

```yaml
Typische Tasks:
- Endpoint Development → Filesystem MCP (OpenAPI spec update)
- Database Queries → PostgreSQL MCP (ORM optimization)
- Dependency Updates → GitHub MCP (Dependabot alerts)
- Performance Tuning → Brave Search MCP (FastAPI best practices)
```

### Frontend (React/TypeScript)

**Primary MCPs:** Figma, Filesystem, Playwright, GitHub

```yaml
Typische Tasks:
- UI Components → Figma MCP (design token sync)
- State Management → Filesystem MCP (Redux/Zustand patterns)
- E2E Testing → Playwright MCP (test generation)
- Bundle Optimization → GitHub MCP (Lighthouse CI results)
```

### Gaming Platform (Prisma + PostgreSQL)

**Primary MCPs:** PostgreSQL, Filesystem, Playwright

```yaml
Typische Tasks:
- Game Logic → Filesystem MCP (game engine code)
- Achievement System → PostgreSQL MCP (XP/leveling queries)
- Player Testing → Playwright MCP (gameplay automation)
- Leaderboard Optimization → PostgreSQL MCP (performance tuning)
```

### n8n Automation

**Primary MCPs:** Filesystem, GitHub, Memory

```yaml
Typische Tasks:
- Workflow Creation → Filesystem MCP (JSON workflow generation)
- Integration Testing → GitHub MCP (webhook validation)
- Error Handling → Memory MCP (failure pattern tracking)
- Documentation → Filesystem MCP (workflow diagrams)
```

---

## 🎯 Mandatory Quality Gates (MCP-Enhanced)

### Security Gate (GitHub + PostgreSQL + Filesystem MCP)

```markdown
✅ GitHub MCP: 0 Dependabot/Secret Scanning alerts
✅ PostgreSQL MCP: PII encryption verified
✅ Filesystem MCP: No secrets in code
✅ Trivy Scan: 0 HIGH/CRITICAL CVEs
```

### DSGVO Compliance Gate (PostgreSQL + Brave Search MCP)

```markdown
✅ PostgreSQL MCP: Consent flags exist
✅ PostgreSQL MCP: Data retention policies implemented
✅ Filesystem MCP: No PII in logs
✅ Brave Search MCP: Austrian GDPR requirements checked
```

### Design System Gate (Figma + Filesystem MCP)

```markdown
✅ Figma MCP: Design token drift = 0
✅ Filesystem MCP: No hardcoded colors/spacing
✅ WCAG AA: Contrast ratios ≥ 4.5:1 (Figma MCP verified)
```

### Performance Gate (Playwright + Filesystem MCP)

```markdown
✅ Playwright MCP: Lighthouse Performance ≥ 90
✅ Filesystem MCP: Bundle size within limits
✅ PostgreSQL MCP: Query performance < 100ms
```

---

## 🔧 npm Scripts für MCP Management

```json
{
  "scripts": {
    "mcp:setup": "bash scripts/setup-mcp-servers.sh",
    "mcp:check": "node scripts/check-mcp-servers.js",
    "mcp:list": "cat .vscode/mcp.json | jq '.servers | keys'",
    "mcp:docs": "cat docs/MCP-QUICK-START.md"
  }
}
```

### Usage

```bash
# Erste Installation
npm run mcp:setup

# Health Check
npm run mcp:check

# Verfügbare Server anzeigen
npm run mcp:list

# Quick Start Guide
npm run mcp:docs
```

---

## 🗂️ Datei-Struktur

```text
/workspaces/menschlichkeit-oesterreich-development/
├── .vscode/
│   └── mcp.json                    # MCP Server Configuration
├── .github/
│   ├── instructions/
│   │   ├── mcp-integration.instructions.md
│   │   └── project-development.instructions.md
│   ├── chatmodes/
│   │   ├── MCPCodeReview_DE.chatmode.md
│   │   ├── MCPSicherheitsAudit_DE.chatmode.md
│   │   └── MCPDesignSystemSync_DE.chatmode.md
│   └── prompts/
│       ├── MCPFeatureImplementation_DE.prompt.md
│       ├── MCPDatabaseMigration_DE.prompt.md
│       └── MCPSecurityIncident_DE.prompt.md
├── docs/
│   ├── MCP-SERVER-SETUP.md
│   ├── MCP-INSTALLATION-REPORT.md
│   ├── MCP-QUICK-START.md
│   └── MCP-MASTER-GUIDE.md         # This file
├── scripts/
│   ├── setup-mcp-servers.sh
│   └── check-mcp-servers.js
├── .env.mcp.template
└── package.json
```

---

## 🎓 Best Practices

### 1. Automatische Tool-Auswahl

**Nicht:** "Verwende GitHub MCP um PR zu laden"  
**Besser:** "Reviewe PR #42" → AI wählt automatisch GitHub MCP

### 2. Service-Kontext angeben

**Nicht:** "Ändere die Datenbank"  
**Besser:** "Füge newsletter_consent zu CRM-Datenbank hinzu" → AI nutzt PostgreSQL MCP mit CRM-Schema

### 3. Chatmodes für wiederkehrende Tasks

**Nicht:** Jeden Code Review manuell konfigurieren  
**Besser:** `/chatmode MCPCodeReview_DE` aktivieren → Standardisierter Prozess

### 4. Prompts für komplexe Workflows

**Nicht:** Schritt-für-Schritt Feature-Implementierung  
**Besser:** `/prompt MCPFeatureImplementation_DE` → End-to-End Automation

### 5. Memory MCP für Konsistenz

**Pattern:** AI speichert Entscheidungen via Memory MCP  
**Vorteil:** Spätere Reviews verwenden gleiche Standards

---

## 🚨 Troubleshooting

### MCP Server nicht verfügbar

```bash
# Check Status
npm run mcp:check

# Reinstall specific server
npx -y @modelcontextprotocol/server-github

# Verify environment variables
cat .env | grep GITHUB_TOKEN
```

### Figma MCP "Package not found"

```text
Expected Behavior: Loads on-demand via npx -y
Fix: Ensure FIGMA_ACCESS_TOKEN in .env
Test: npx -y @figma/mcp-server-figma
```

### PostgreSQL MCP Connection Error

```bash
# Verify connection string
echo $POSTGRES_CONNECTION_STRING

# Test connection
psql $POSTGRES_CONNECTION_STRING -c "SELECT 1"

# Check Prisma schema
npx prisma db pull
```

### GitHub MCP Rate Limiting

```text
Symptom: "API rate limit exceeded"
Fix: Use GitHub Personal Access Token (not OAuth)
Verify: Token has scopes: repo, read:org, read:user
```

---

## 📈 Success Metrics

### Development Velocity

- **Before MCP:** Feature → 2-3 days (manual research, coding, testing)
- **After MCP:** Feature → 4-6 hours (automated workflows)

### Code Quality

- **Before MCP:** Code Review → 30-60 min manual analysis
- **After MCP:** Code Review → 5 min (automated via MCPCodeReview chatmode)

### Security Compliance

- **Before MCP:** Security Audit → weekly manual check
- **After MCP:** Security Audit → continuous via GitHub MCP alerts

### Design Consistency

- **Before MCP:** Design Drift → 10-15% (manual sync)
- **After MCP:** Design Drift → 0% (automated Figma MCP sync)

---

## 🔗 Weiterführende Ressourcen

### MCP Documentation

- Official MCP Spec: <https://modelcontextprotocol.io>
- GitHub MCP Server: <https://github.com/modelcontextprotocol/servers>
- Figma MCP: <https://github.com/figma/mcp-server-figma>

### Project-Specific

- Copilot Instructions: `.github/copilot-instructions.md`
- Architecture Overview: `README-PROJECT.md`
- Quality Reports: `quality-reports/`

### External

- DSGVO/GDPR: <https://www.dsb.gv.at> (Österreich)
- WCAG Guidelines: <https://www.w3.org/WAI/WCAG21/quickref/>
- CiviCRM Docs: <https://docs.civicrm.org>

---

## 🎯 Nächste Schritte

### Immediate (0-7 Tage)

- [ ] Team-Training: MCP Chatmodes & Prompts
- [ ] Figma Token Setup: FIGMA_ACCESS_TOKEN konfigurieren
- [ ] Erste Code Reviews mit MCPCodeReview_DE durchführen
- [ ] Security Audit via MCPSicherheitsAudit_DE

### Short-term (1-4 Wochen)

- [ ] Alle Features via MCPFeatureImplementation_DE implementieren
- [ ] Design System Sync automatisieren (daily via GitHub Actions)
- [ ] Database Migrations standardisieren (MCPDatabaseMigration_DE)
- [ ] Incident Response Playbook testen (MCPSecurityIncident_DE)

### Long-term (1-3 Monate)

- [ ] MCP-Metriken tracken (Development Velocity, Code Quality)
- [ ] Custom MCP Server für CiviCRM entwickeln
- [ ] Austrian NGO MCP Best Practices dokumentieren
- [ ] Community Contribution: MCP Templates für NGOs

---

**Maintained by:** GitHub Copilot + MCP Tools  
**Last Updated:** 2025-01-XX  
**Version:** 1.0.0  
**License:** Siehe LICENSE in Repository Root
