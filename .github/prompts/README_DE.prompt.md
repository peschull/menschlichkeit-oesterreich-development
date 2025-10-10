Erstellt vollständige README-Dateien korrekt verlinkt in deutscher Sprache für das Repository'
mode: 'agent'
---

Ihre Aufgabe ist es, eine professionelle, umfassende `README.md` auf Deutsch für das Projekt `${workspaceFolderBasename}` zu erstellen. Analysieren Sie das gesamte Repository (#githubRepo), um Zweck, Architektur, Funktionen und Abhängigkeiten zu verstehen.

## 📚 Relevante Projektdokumentation

Integrieren Sie Informationen aus folgenden Markdown-Dateien im Root-Verzeichnis:

### Architektur & Setup
- **04_architecture.md** - Systemarchitektur, 8 Subsysteme (Website, API, CRM, Games, Frontend, n8n, MCP, Design System)
- **README-PROJECT.md** - Quick Start Guide, Multi-Service Platform Übersicht
- **DESIGN-SYSTEM-INTEGRATION.md** - Austrian Red Design System (Rot-Weiß-Rot), Figma Integration

### Deployment & Produktion
- **PRODUCTION-DEPLOYMENT-CHECKLIST.md** - MCP Production Deployment, 47 Server, Security Best Practices
- **DEPLOYMENT-QUICKSTART.md** - Deployment-Workflows, Multi-Service Deploy
- **PRODUCTION-READINESS-REPORT.json** - Quality Gates, Security Scans, Performance Metrics

### Entwicklung & Qualität
- **CHANGELOG.md** - Versionshistorie, aktuelle Features, Prompt-Schema-Validierung
- **TODO.md** - 60-Tage-Programm, Definition of Ready/Done, Quality Gates (Lighthouse ≥90, Coverage ≥80%)
- **.github/copilot-instructions.md** - DSGVO-First, Quality Gates, MCP Integration

### Setup & Troubleshooting
- **CODESPACE-TROUBLESHOOTING.md** - GitHub Codespaces Issues, Error 1302 Fixes
- **BRANCH-UMSTELLUNG-ANLEITUNG.md** - Branch-Strategie, Protection Rules
- **GITHUB-SECRETS-COMPLETE-SETUP.md** - Secrets Management, Environment Variables

### Migration & Status
- **MIGRATION-MAP-VALIDATION-REPORT.md** - 137/137 Legacy Prompts validiert & migriert
- **ENTERPRISE-SETUP-SUCCESS-REPORT.md** - Enterprise Upgrade, MCP Server Integration
- **DEPRECATED-STATUS-UPDATE-REPORT.md** - Deprecated Files Status

## 📋 README-Struktur

Die README sollte enthalten:

1. **Projektbeschreibung** 
   - Gemeinnütziger Fokus: Digitale Lösungen für österreichische NGOs
   - DSGVO-First: Vollständige EU-Datenschutz-Compliance
   - Multi-Service-Architektur: 5 Services (CRM, API, Frontend, Games, Automation)
   - Developer Experience: AI-gestützte Tools (GitHub Copilot, 21 MCP Server)

2. **Inhaltsverzeichnis** 
   - Strukturiert mit Emojis und Links zu allen Hauptabschnitten

3. **Installation**
   - **Quick Start:** `npm run setup:dev` → `npm run mcp:setup` → `npm run dev:all`
   - **Voraussetzungen:** Node.js ≥22, Python ≥3.11, PHP 8.1, PostgreSQL ≥15
   - **GitHub Codespaces:** Devcontainer-Setup mit Universal:2 Image
   - **MCP Server:** 21 Server (Figma, GitHub, Notion, Postgres, Trivy, etc.)

4. **Verwendung**
   - **Services starten:** `npm run dev:all` (CRM:8000, API:8001, Frontend:5173, Games:3000)
   - **Quality Gates:** `npm run quality:gates` (Codacy, Trivy, Gitleaks, Lighthouse, DSGVO)
   - **Tests:** `npm run test:unit`, `npm run test:e2e` (Playwright)
   - **Deployment:** `./build-pipeline.sh production` (Multi-Service mit n8n Webhooks)

5. **Architektur** (aus 04_architecture.md)
   - **8 Subsysteme:**
     - **Website & Frontend:** React 18 + Vite, Tailwind CSS 4.0, Austrian Red Design System
     - **API-Service:** FastAPI (Python 3.11+), PostgreSQL, Alembic Migrations
     - **CRM:** Drupal 10 + CiviCRM, PHP 8.1, Mitgliederverwaltung
     - **Games:** "Brücken Bauen" - Barrierefreies Lernspiel (Port 3000)
     - **Automation:** n8n Workflows (Double-Opt-In, Spendenquittungen, KPI-Reports)
     - **Design System:** Figma → JSON Tokens → Tailwind CSS (48 shadcn/ui + 53 Custom Components)
     - **MCP Server:** 21 AI-gestützte Tools (Filesystem, Memory, GitHub, Notion, Figma, etc.)
   - **Datenflüsse:** REST API (Frontend ↔ API), PostgreSQL (zentrale DB), CiviCRM Sync

6. **Beitragen** (aus TODO.md Quality Gates)
   - **Definition of Ready (DoR):** Ziel klar, Akzeptanzkriterien messbar, Teststrategie vorhanden
   - **Definition of Done (DoD):** 
     - `npm run typecheck && npm run lint && npm test` grün
     - Lighthouse Performance ≥90, FCP (mobil) <3s
     - Test Coverage: Backend ≥80%, Frontend ≥70%
     - Lint-Fehler: 0, TypeScript-Fehler: 0
   - **Branch-Namen:** `feature/`, `fix/`, `chore/`, `docs/`
   - **Commit-Messages:** Conventional Commits (feat:, fix:, chore:, docs:)
   - **Style-Guidelines:** `.github/prompts/GLOBAL-STYLE-GUIDE.md`, ESLint + Prettier

7. **Lizenz**
   - MIT License (siehe LICENSE Datei)

8. **Kontakt/Support**
   - **Issues:** GitHub Issues für Bugs und Feature Requests
   - **Discussions:** GitHub Discussions für Fragen
   - **Security:** SECURITY.md für Sicherheitslücken
   - **Email:** schuller_peter@icloud.com (Projekt-Maintainer)

## 🎯 Besondere Anforderungen

- **Österreichisches Deutsch** durchgehend verwenden
- **Emojis** für Struktur und Lesbarkeit (🎯, 🏗️, 🚀, 💻, 🧪, 🔒, etc.)
- **Badges** für Build Status, Quality Gates, DSGVO Compliance, Technologie-Versionen
- **Code-Beispiele** mit Syntax-Highlighting (bash, typescript, python)
- **Tabellen** für Service-Übersichten, Port-Mappings, Technologie-Stack
- **Links** zu wichtigen Dateien: CHANGELOG.md, TODO.md, CONTRIBUTING.md, .github/copilot-instructions.md
- **Screenshots/Diagramme** referenzieren wenn vorhanden (logo.JPG, Architektur-Diagramme)

Verwenden Sie klare Überschriften, listenartige Aufzählungen und stellen Sie sicher, dass die Datei für neue und bestehende Entwickler nützlich ist.