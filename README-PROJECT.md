# Menschlichkeit Österreich - Development Environment

**Multi-Service Austrian NGO Platform** mit Enterprise-Grade DevOps, DSGVO-Compliance und Design System Integration.

---

## 🚀 Quick Start

```bash
# 1. Development Environment setup
npm run setup:dev

# 2. MCP Server installieren & konfigurieren
npm run mcp:setup

# 3. Alle Services starten
npm run dev:all
```

📖 **Detaillierte Anleitung:** [docs/MCP-QUICK-START.md](docs/MCP-QUICK-START.md)

---

## 🏗️ Projekt-Architektur

### Multi-Service Platform

| Service | URL | Technologie | Port |
|---------|-----|------------|------|
| **Main Website** | menschlichkeit-oesterreich.at | WordPress/HTML | - |
| **API Backend** | api.menschlichkeit-oesterreich.at | FastAPI/Python | 8001 |
| **CRM System** | crm.menschlichkeit-oesterreich.at | Drupal 10 + CiviCRM | 8000 |
| **Gaming Platform** | `web/` | Prisma + PostgreSQL | 3000 |
| **Frontend** | `frontend/` | React/TypeScript | 3000 |
| **Automation** | `automation/n8n/` | Docker/n8n | 5678 |

### Tech Stack

- **Frontend:** React, TypeScript, Tailwind CSS (mit Design Tokens)
- **Backend:** FastAPI (Python), Drupal 10, CiviCRM
- **Database:** PostgreSQL mit Prisma ORM
- **Gaming:** Educational web games mit XP/Achievement System
- **Automation:** n8n Workflows (Docker)
- **Infrastructure:** Plesk Hosting, Docker (lokal)
- **CI/CD:** GitHub Actions, Quality Gates, Security Scanning

---

## 🤖 MCP Server Integration

**7 konfigurierte MCP Server** für AI-gestützte Entwicklung:

### 🎨 Design & Frontend
- **Figma MCP** - Design Token Synchronisation
- **Filesystem MCP** - Workspace-Datei-Management

### 🔧 Development Tools
- **GitHub MCP** - Issues, PRs, Security Alerts
- **Playwright MCP** - E2E-Test-Automatisierung

### 🗄️ Database & Backend
- **PostgreSQL MCP** - Datenbank-Zugriff via Prisma

### 🔍 Search & Knowledge
- **Brave Search MCP** - Web-Recherche
- **Memory MCP** - Session-Persistenz

**Plus:** Microsoft Docs, Notion, Stripe, Codacy (via GitHub Copilot)

📖 **Setup-Anleitung:** [docs/MCP-SERVER-SETUP.md](docs/MCP-SERVER-SETUP.md)

---

## 📋 Verfügbare npm Scripts

### Development
```bash
npm run dev:all          # Alle Services starten (CRM, API, Frontend, Games)
npm run dev:crm          # Nur CRM (PHP Server auf Port 8000)
npm run dev:api          # Nur API (FastAPI auf Port 8001)
npm run dev:frontend     # Nur Frontend (React auf Port 3000)
npm run dev:games        # Nur Gaming Platform (Port 3000)
```

### Build & Deploy
```bash
npm run build:all        # Alle Services bauen
npm run deploy:all       # Vollständiges Deployment
./scripts/safe-deploy.sh --dry-run  # Deployment-Simulation
```

### Quality & Testing
```bash
npm run quality:gates    # Alle Quality Gates prüfen
npm run security:scan    # Security-Scan (Trivy + Gitleaks)
npm run test:e2e         # E2E-Tests (Playwright)
npm run performance:lighthouse  # Performance-Audit
npm run compliance:dsgvo # DSGVO-Compliance Check
```

### MCP Server Management
```bash
npm run mcp:setup        # MCP Server installieren
npm run mcp:check        # Health Check
npm run mcp:list         # Konfigurierte Server auflisten
npm run mcp:docs         # Dokumentation anzeigen
```

### Figma & Design System
```bash
npm run figma:sync       # Design Tokens synchronisieren
npm run design:tokens    # Sync + Frontend Build
```

### Automation (n8n)
```bash
npm run n8n:start        # n8n starten (Docker)
npm run n8n:stop         # n8n stoppen
npm run n8n:logs         # Logs anzeigen
```

---

## 🔐 MANDATORY Quality Gates

**PR-Blocking Anforderungen:**

- **Security:** 0 open issues (Codacy, Trivy, Secret-Scan)
- **Maintainability:** ≥85% | **Duplication:** ≤2%
- **Performance:** Lighthouse P≥90, A11y≥90, BP≥95, SEO≥90
- **UX/UI:** 0 Broken Links, WCAG AA
- **GDPR:** 0 PII in logs, dokumentierte Consent/Retention
- **License:** Vollständige SPDX + Third-Party Notices
- **Supply Chain:** SBOM generiert & verifiziert

---

## 🚦 Quality Checks ausführen

```bash
# Vollständiger Quality Check
npm run quality:gates

# Einzelne Checks
npm run lint:all         # Linting (JS, PHP, Markdown)
npm run format:all       # Formatierung (Prettier, PHP-CS-Fixer)
npm run quality:codacy   # Codacy-Analyse
npm run security:trivy   # Trivy Security Scan
```

**Automatische Code-Qualität:** Nach jedem File-Edit wird automatisch Codacy MCP ausgeführt (via Copilot Instructions).

---

## 📁 Projekt-Struktur

```
menschlichkeit-oesterreich-development/
├── .vscode/                      # VS Code Konfiguration + MCP Server
│   ├── mcp.json                 # MCP Server Konfiguration
│   └── settings.json            # Workspace Settings
├── api.menschlichkeit-oesterreich.at/  # FastAPI Backend
├── crm.menschlichkeit-oesterreich.at/  # Drupal + CiviCRM
├── frontend/                     # React/TypeScript Frontend
├── web/                          # Educational Gaming Platform
├── website/                      # WordPress Main Site
├── automation/n8n/              # n8n Workflows
├── figma-design-system/         # Design Tokens (auto-sync)
├── scripts/                      # Build & Deployment Scripts
├── docs/                         # Dokumentation
│   ├── MCP-QUICK-START.md       # MCP Quick Start Guide
│   ├── MCP-SERVER-SETUP.md      # Vollständige MCP-Anleitung
│   └── MCP-INSTALLATION-REPORT.md # Installation Report
├── quality-reports/             # Quality Gate Reports
├── playwright-results/          # E2E-Test-Ergebnisse
├── schema.prisma                # Prisma Database Schema
├── package.json                 # npm Scripts & Dependencies
└── .env                         # Umgebungsvariablen (nicht committen!)
```

---

## 🔧 Setup & Installation

### 1. Repository klonen
```bash
git clone https://github.com/peschull/menschlichkeit-oesterreich-development.git
cd menschlichkeit-oesterreich-development
```

### 2. Dependencies installieren
```bash
npm run setup:dev
# Installiert: npm packages, Composer, Python requirements
```

### 3. MCP Server konfigurieren
```bash
# Setup-Script ausführen
npm run mcp:setup

# .env konfigurieren (siehe .env.mcp.template)
cp .env.mcp.template .env
# FIGMA_ACCESS_TOKEN, POSTGRES_CONNECTION_STRING, etc. eintragen
```

### 4. Datenbank initialisieren
```bash
npx prisma generate
npx prisma db push
```

### 5. VS Code neustarten
```
Cmd/Ctrl + Shift + P -> "Developer: Reload Window"
```

### 6. Development starten
```bash
npm run dev:all
```

---

## 🧪 Testing

### E2E-Tests (Playwright)
```bash
npm run test:e2e
# Ergebnisse in: playwright-results/
```

### Unit Tests (Vitest)
```bash
npm run test:unit
```

### Integration Tests
```bash
npm run test:integration
```

---

## 🚢 Deployment

### Dry-Run (empfohlen)
```bash
./scripts/safe-deploy.sh --dry-run
```

### Production Deployment
```bash
# Build-Pipeline ausführen
./build-pipeline.sh production

# Deployment zu Plesk
./deployment-scripts/deploy-crm-plesk.sh
./deployment-scripts/deploy-api-plesk.sh
```

---

## 📊 Datenbank-Synchronisation

```bash
# Remote → Local (Dry-Run)
./scripts/plesk-sync.sh pull

# Remote → Local (Ausführen)
./scripts/plesk-sync.sh pull --apply

# Local → Remote (GEFÄHRLICH!)
./scripts/plesk-sync.sh push --apply
```

---

## 🔐 Secrets Management

**⚠️ NIEMALS Secrets committen!**

- Alle Tokens in `.env` (bereits in `.gitignore`)
- Template verwenden: `.env.mcp.template`
- PowerShell Scripts für Encryption: `scripts/secrets-decrypt.ps1`
- GitHub Secrets für CI/CD

---

## 📚 Dokumentation

### Für Entwickler
- 🚀 [MCP Quick Start](docs/MCP-QUICK-START.md) - Sofort loslegen
- 📖 [MCP Server Setup](docs/MCP-SERVER-SETUP.md) - Vollständige Anleitung
- 📊 [Installation Report](docs/MCP-INSTALLATION-REPORT.md) - Setup-Bericht
- 🎨 [Figma Integration](docs/ADMIN-FIGMA-INTEGRATION.md) - Design System

### Für DevOps
- 🏗️ [Build Pipeline](build-pipeline.sh) - CI/CD Pipeline
- 🚢 [Safe Deploy](scripts/safe-deploy.sh) - Deployment-Script
- 🔄 [Plesk Sync](scripts/plesk-sync.sh) - Server-Synchronisation
- 📋 [Quality Reports](quality-reports/) - Automatische Reports

### Compliance & Security
- 🛡️ [Security Scanning](security/) - Trivy, Gitleaks
- 🔐 [DSGVO Compliance](scripts/dsgvo-check.ps1) - Privacy Checks
- 📜 [License Audit](scripts/license-audit.js) - SPDX Reports

---

## 🆘 Troubleshooting

### MCP Server Probleme
```bash
npm run mcp:check  # Health Check
cat ~/.cache/github-copilot/logs/language-server.log | grep -i mcp
```

### Build-Fehler
```bash
npm run clean      # Workspace aufräumen
npm run setup:dev  # Neu installieren
```

### Database Connection
```bash
echo $POSTGRES_CONNECTION_STRING
npx prisma db pull  # Test Connection
```

### Mehr Hilfe
- 📖 [Troubleshooting Guide](docs/CODESPACE-TROUBLESHOOTING.md)
- 💬 GitHub Issues im Repository
- 📧 DevOps Team kontaktieren

---

## 🤝 Contributing

1. Branch erstellen: `git checkout -b feature/xyz`
2. Quality Gates prüfen: `npm run quality:gates`
3. Commit mit konventionellem Format: `feat: ...`, `fix: ...`
4. Push und PR erstellen
5. Warten auf Review + CI/CD

**Branch Protection aktiv!** Alle Quality Gates müssen grün sein.

---

## 📄 License

MIT License - siehe [LICENSE](LICENSE)

---

## 👥 Team & Kontakt

**Projekt:** Menschlichkeit Österreich  
**Repository:** [peschull/menschlichkeit-oesterreich-development](https://github.com/peschull/menschlichkeit-oesterreich-development)  
**Maintainer:** DevOps Team  
**Issues:** [GitHub Issues](https://github.com/peschull/menschlichkeit-oesterreich-development/issues)

---

**Stand:** 2025-10-06  
**Version:** 1.0.0  
**MCP Server:** ✅ Konfiguriert & Einsatzbereit
