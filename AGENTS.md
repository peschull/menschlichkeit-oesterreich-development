# AGENTS.md – Workspace-weite KI-Agent Anweisungen

## Zweck
Diese Datei enthält zentrale, workspace-weite Anweisungen für alle KI-Agenten (GitHub Copilot, Claude, etc.) im Menschlichkeit Österreich Monorepo. Diese Regeln gelten automatisch für alle Chat-Anfragen im Arbeitsbereich.

## Aktivierung
**Voraussetzung:** Die Einstellung `chat.useAgentsMdFile` muss in VS Code aktiviert sein.

---

## 🎯 Projekt-Kontext

**Menschlichkeit Österreich** ist ein Non-Profit Monorepo mit 5 Services:
- **CRM** (Drupal 10 + CiviCRM, PHP 8.1, Port 8000)
- **API** (FastAPI, Python 3.11+, Alembic, Port 8001)
- **Frontend** (React 18 + TypeScript + Vite, Port 5173)
- **Games** (Prisma, lokaler Python-Server, Port 3000)
- **Automation** (n8n, Docker, Port 5678)

**Gemeinsame PostgreSQL-Datenbank** (≥15) via `DATABASE_URL`.

---

## 🔒 Sicherheit & DSGVO (HÖCHSTE PRIORITÄT)

1. **KEINE PII in Logs**: E-Mail, IBAN, Namen, Adressen müssen IMMER maskiert/redacted werden
   - E-Mail: `test@example.com` → `t**@example.com`
   - IBAN: `AT61 1904 3002 3457 3201` → `AT61***`
   - Verwende vorhandene PII-Sanitizer:
     - API: `app/lib/pii_sanitizer.py` + Middleware
     - CRM: `web/modules/custom/pii_sanitizer/`
     - n8n: `automation/n8n/custom-nodes/pii-sanitizer/`

2. **Secrets Management**:
   - NIEMALS Secrets/Tokens/Passwörter in Code committen
   - Gitleaks blockt Push bei Secret-Leaks
   - Verwende Environment Variables oder `.env` (gitignored)

3. **Supply Chain Security**:
   - SBOM-Generation via CycloneDX (`.github/workflows/sbom-generation.yml`)
   - Cosign-Signatur für Artefakte (OIDC keyless)
   - Trivy-Scans müssen CRITICAL/HIGH = 0 erreichen

---

## 💻 Code-Konventionen

### TypeScript/JavaScript
- **Strict Types**: Verwende `strict: true` in tsconfig.json
- **Naming**: camelCase für Variablen/Funktionen, PascalCase für Komponenten/Klassen, UPPER_SNAKE_CASE für Konstanten
- **React**: Functional Components mit Hooks (kein Class Components)
- **ESLint**: Folge `eslint.config.js` (Flat Config)
  - `react-hooks/rules-of-hooks`: error
  - `react-hooks/exhaustive-deps`: warn
  - `no-undef` ist für TS deaktiviert (TypeScript prüft bereits)
- **Error Handling**: Niemals leere catch-Blöcke; verwende `catch { /* comment */ }` oder benenne Variable mit `_`

### Python
- **PEP 8 Compliance**
- **FastAPI**: Async/await für IO-Operationen
- **Alembic**: Migrations IMMER versioniert und getestet
- **Type Hints**: Verwende für alle öffentlichen APIs

### PHP (CRM/Drupal)
- **PSR-12 Coding Standards**
- **Drupal Coding Standards**: Verwende `phpcs` und `phpstan`
- **CiviCRM**: Nutze offizielle APIs, keine direkten DB-Queries

---

## 🎨 Design System & UI

1. **Design Tokens**: `figma-design-system/00_design-tokens.json`
   - NIEMALS Farben/Spacing hardcoden
   - Tokens werden in `frontend/tailwind.config.cjs` generiert
   - Sync via `npm run figma:sync`

2. **Österreichisches Deutsch**: Alle UI-Texte auf Deutsch (Österreich)
   - Rot-Weiß-Rot Branding (nationale Identität)
   - Accessibility: WCAG 2.1 AA minimum

3. **Responsive Design**: Mobile-First, Breakpoints via Tailwind

---

## 🧪 Testing & Quality Gates

### Vor jedem Commit/Push:
```bash
npm run quality:gates  # Läuft: Codacy, Trivy, Lighthouse, DSGVO-Checks
```

### Test-Arten:
- **Unit**: `npm run test:unit` (Vitest)
- **E2E**: `npm run test:e2e` (Playwright)
- **PII Sanitizer**: `pytest tests/test_pii_sanitizer.py`

### Performance:
- **Lighthouse Score**: ≥90 für alle Kategorien
- **Core Web Vitals**: LCP <2.5s, FID <100ms, CLS <0.1

---

## 📦 Build & Deploy

1. **Build Pipeline**: `./build-pipeline.sh staging|production`
   - Sendet n8n Webhooks via `automation/n8n/webhook-client.js`
   - Flags: `--skip-tests`, `--force`

2. **Multi-Service Deploy**: `deployment-scripts/multi-service-deploy.sh`

3. **Rollback**: `npm run deploy:rollback`

4. **Health Check**: `npm run deploy:health-check`

---

## 🗄️ Datenbank-Migrationen

### API (Alembic):
```bash
cd api.menschlichkeit-oesterreich.at
alembic revision --autogenerate -m "description"
alembic upgrade head
```

### Games (Prisma):
```bash
npx prisma migrate dev --name description
npx prisma generate
```

**WICHTIG**: Koordiniere Schema-Änderungen zwischen API (Alembic) und Games (Prisma), da beide dieselbe DB nutzen!

---

## 🤖 MCP (Model Context Protocol)

### Verfügbare Server:
- **File Server**: `mcp-servers/file-server/` (Path Traversal Guard, Rate Limiting, Circuit Breaker)
- **ChatGPT App**: `mcp-servers/chatgpt-app-server/` (User Registration, SEPA Mandate, GDPR Deletion)
- **Figma**: Design Token Sync
- **GitHub**: PR/Security Management
- **Context7**: Library Documentation

### Setup:
```bash
npm run mcp:setup
npm run mcp:check
npm run mcp:list
```

---

## 📋 Dokumentation

### ADR (Architecture Decision Records):
- Speichere in `docs/architecture/ADRs/`
- Generiere Index mit `npm run docs:adr-index`
- Format: [MADR Template](https://adr.github.io/madr/)

### API Dokumentation:
- **OpenAPI**: `api.menschlichkeit-oesterreich.at/openapi.yaml`
- IMMER synchron mit Endpunkten halten

### Threat Models:
- Haupt-Analyse: `analysis/phase-0/threat-model/STRIDE-LINDDUN-ANALYSIS.md`
- Frontend: `docs/security/FRONTEND-THREAT-MODEL.md`
- MCP Server: `docs/security/MCP-SERVER-THREAT-MODEL.md`

---

## 🚨 Fehlerbehandlung & Logging

1. **Strukturierte Logs**: JSON-Format mit `timestamp`, `level`, `message`, `context`
2. **Error Objects**: Immer mit `code`, `message`, `statusCode`
3. **PII Redaction**: Automatisch via Middleware (API) oder Custom Module (CRM)
4. **Monitoring**: Performance-Logs via `scripts/performance/web-vitals-tracker.js`

---

## 🔄 Git Workflow

### Branch-Namenskonvention:
- `feature/beschreibung`
- `fix/beschreibung`
- `chore/beschreibung`
- `release/yyyy-mm-dd`

### Commit Messages:
```
<type>: <subject>

<body>

<footer>
```
**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`, `build`

### PR-Beschreibung:
- **Kurzbeschreibung** (1-2 Sätze)
- **Änderungen** (Bullet Points)
- **Breaking Changes** (falls vorhanden)
- **Tests** (welche durchgeführt wurden)
- **Screenshots** (bei UI-Änderungen)

---

## ⚙️ Wichtige Befehle

### Development:
```bash
npm run setup:dev        # Initialisierung
npm run dev:all          # Alle Services starten
npm run dev:crm          # Nur CRM
npm run dev:api          # Nur API
npm run dev:frontend     # Nur Frontend
npm run dev:games        # Nur Games
```

### Quality & Testing:
```bash
npm run quality:gates    # Alle Gates
npm run lint             # ESLint
npm run test:unit        # Unit Tests
npm run test:e2e         # E2E Tests
npm run performance:lighthouse  # Lighthouse Audit
```

### Deployment:
```bash
./build-pipeline.sh staging
./build-pipeline.sh production --force
npm run deploy:multi-service
npm run deploy:rollback
```

---

## 🎯 Prioritäten (in dieser Reihenfolge)

1. **Sicherheit** (DSGVO, Secrets, PII-Maskierung)
2. **Datenintegrität** (DB-Migrationen koordiniert)
3. **Stabilität** (Tests, Quality Gates)
4. **Velocity** (Neue Features nur nach 1-3)

---

## 📚 Wichtige Dateien/Verzeichnisse

### Root:
- `package.json` – Workspace-Scripts
- `build-pipeline.sh` – CI/CD Pipeline
- `schema.prisma` – Prisma Schema (Games)
- `mcp.json` – MCP Server Konfiguration

### DSGVO/PII:
- `api.menschlichkeit-oesterreich.at/app/lib/pii_sanitizer.py`
- `api.menschlichkeit-oesterreich.at/app/middleware/pii_middleware.py`
- `crm.menschlichkeit-oesterreich.at/web/modules/custom/pii_sanitizer/`
- `automation/n8n/custom-nodes/pii-sanitizer/`
- `tests/test_pii_sanitizer.py`

### Frontend:
- `frontend/src/App.tsx` – Router + Fallback
- `frontend/tailwind.config.cjs` – Design Tokens Integration
- `figma-design-system/00_design-tokens.json` – Figma Tokens

### Security:
- `gitleaks.toml` – Secret Scanning Config
- `trivy.yaml` – Vulnerability Scanning Config
- `security/sbom/` – SBOM Artefakte (CycloneDX)
- `.github/workflows/sbom-generation.yml` – SBOM Workflow

### Anleitungen:
- `.github/instructions/core/dsgvo-compliance.instructions.md`
- `.github/instructions/core/quality-gates.instructions.md`
- `.github/instructions/core/project-development.instructions.md`
- `.github/instructions/core/mcp-integration.instructions.md`

---

## 🚫 Verbotene Praktiken

1. ❌ PII in Logs schreiben
2. ❌ Secrets in Code committen
3. ❌ Farben/Spacing hardcoden (nutze Design Tokens)
4. ❌ DB ohne Migration ändern
5. ❌ Drupal/CiviCRM Core-Dateien patchen
6. ❌ Leere catch-Blöcke ohne Kommentar
7. ❌ Deprecated APIs verwenden (check OpenAPI Spec)
8. ❌ Breaking Changes ohne Migrationsanleitung

---

## 📞 Hilfe & Support

### Bei Unklarheiten:
1. Prüfe [`.github/copilot-instructions.md`](.github/copilot-instructions.md)
2. Konsultiere projektspezifische `.instructions.md` Dateien
3. Lies [README-PROJECT.md](README-PROJECT.md)

### Nützliche Links:
- [Migration Map](.github/prompts/MIGRATION_MAP.json) – 137/137 validiert
- [Deployment Quickstart](DEPLOYMENT-QUICKSTART.md)
- [Design System Integration](DESIGN-SYSTEM-INTEGRATION.md)
- [Branch Protection Setup](BRANCH-PROTECTION-SETUP.md)

---

## 🔄 Wartung dieser Datei

- **Review**: Bei Major-Releases oder Convention-Änderungen
- **Changelog**: Änderungen in Commit-Messages dokumentieren
- **Versionierung**: Datei ist im Git-Repository getrackt

---

*Letzte Aktualisierung: 2025-10-09*  
*Node-Version: ≥22.20.0 (zwingend)*  
*Projekt-Status: Active Development – PR #62 Quality Improvements*
