## Menschlichkeit Österreich – Copilot Leitfaden (kurz & praxisnah)

Dieser Monorepo bündelt 5 Services mit gemeinsamer PostgreSQL-DB und DSGVO-First-Default. Ziel: Security > Datenintegrität > Stabilität > Velocity.

### Architektur (Big Picture)
- CRM: `crm.menschlichkeit-oesterreich.at/` (Drupal 10 + CiviCRM, PHP 8.1) – Port 8000
- API: `api.menschlichkeit-oesterreich.at/` (FastAPI, Python 3.11+, Alembic) – Port 8001
- Frontend: `frontend/` (React 18 + TS + Vite, Design Tokens) – Port 5173
- Games: `web/` (Prisma-Schema im Repo; lokaler Dev-Server via Python) – Port 3000
- Automation: `automation/n8n/` (Docker, Webhooks) – Port 5678
Gemeinsame DB (PostgreSQL ≥15) via `DATABASE_URL`. Schema-Änderungen: koordinieren (API Alembic vs. Games Prisma).

### Daily Dev (Node 22+ zwingend)
- Setup: `npm run setup:dev`
- Start alle: `npm run dev:all` (oder einzeln: `dev:crm`, `dev:api`, `dev:frontend`, `dev:games`)
- Wichtige Ports: CRM 8000 · API 8001 · Frontend 5173 · Games 3000 · n8n 5678

### Qualität & Tests (PR-blocking Gates)
- Alles auf einmal: `npm run quality:gates`
	- Code Quality (Codacy), Security (Trivy+Gitleaks), Performance (Lighthouse), DSGVO-Checks, Reports
- Einzeltests: `npm run test:unit` (Vitest), `npm run test:e2e` (Playwright), Python: `pytest tests/test_pii_sanitizer.py`

### DSGVO/PII (Projekt-spezifische Patterns)
- FastAPI: Middleware `api.../app/middleware/pii_middleware.py` + Lib `app/lib/pii_sanitizer.py`
- Drupal: Custom Modul `crm.../web/modules/custom/pii_sanitizer/` (Watchdog/Forms/Mails/CiviCRM)
- Regeln: Keine PII in Logs; E-Mail-Masking (`t**@example.com`), IBAN-Redaction (`AT61***`). Tests: `tests/test_pii_sanitizer.py`.

### Frontend Konventionen
- Design Tokens: `figma-design-system/00_design-tokens.json` – niemals Farben/Spacing hardcoden
	- Nutzung: `frontend/tailwind.config.cjs`, `frontend/scripts/generate-design-tokens.mjs`
- Routing/Fallback: `frontend/src/App.tsx` nutzt `<AITestPage />` als sichere Fallback-Route
- Performance-Audit: `npm run performance:lighthouse` (nutzt Frontend-Workspace)

### API & DB Flows
- OpenAPI: `api.menschlichkeit-oesterreich.at/openapi.yaml` (halten in Sync mit Endpunkten)
- Migrations (API): Alembic – Beispiel: `alembic upgrade head`
- Prisma (Games): Schema im `schema.prisma`; gängig: `npx prisma generate` / `npx prisma migrate dev`

### Build/Deploy (mit n8n Webhooks)
- Pipeline: `./build-pipeline.sh staging|production [--skip-tests|--force]` (sendet Webhooks via `automation/n8n/webhook-client.js`)
- Multi-Service Deploy: `deployment-scripts/multi-service-deploy.sh`
- Rollback & Health: `npm run deploy:rollback` · `npm run deploy:health-check`

### MCP-Integration (für AI-Workflows)
- Setup/Status: `npm run mcp:setup` · `npm run mcp:check` · `npm run mcp:list`
- Typische Nutzung: Figma-Sync (Design Tokens), GitHub (PRs/Security), Filesystem (Repo-Operationen), Context7 (Lib-Doks)

### Do/Don’t (projektspezifisch)
- Do: UI-Texte auf Österreichisches Deutsch, Tokens verwenden, Gates lokal ausführen, OpenAPI/Alembic/Prisma aktuell halten
- Don’t: PII loggen, Farben/Spacing hardcoden, DB ohne Migration ändern, Secrets commiten (Gitleaks blockt)

### Quick Links (Schlüsseldateien)
- Scripts/Orchestrierung: `package.json` (Workflows), `build-pipeline.sh`
- DSGVO/PII: `api.../app/lib/pii_sanitizer.py`, `crm.../modules/custom/pii_sanitizer/`
- Frontend: `frontend/src/App.tsx`, `frontend/tailwind.config.cjs`
- Design System: `figma-design-system/00_design-tokens.json`
- DB: `schema.prisma`, `api.menschlichkeit-oesterreich.at/alembic/`
- Anleitungen (kuratiert, .github/instructions/core):
	- dsgvo-compliance.instructions.md
	- quality-gates.instructions.md
	- project-development.instructions.md
	- mcp-integration.instructions.md
- **Migration:** `.github/prompts/MIGRATION_MAP.json` (✅ 137/137 validiert, siehe `MIGRATION-MAP-VALIDATION-REPORT.md`)

Unklarheiten oder Lücken? Nenne konkrete Aufgaben/Dateien – ich erweitere die Anleitung gezielt (kurz & operativ).
# Menschlichkeit Österreich – AI Coding Agent Guide# Menschlichkeit Österreich – AI Coding Agent Guide# Menschlichkeit Österreich – Copilot Leitfaden

## Menschlichkeit Österreich – Copilot Leitfaden (kurz & praxisnah)

Dieser Monorepo bündelt 5 Services mit gemeinsamer PostgreSQL-DB und DSGVO-First-Default. Priorität: Sicherheit > Datenintegrität > Stabilität > Velocity.

## Architektur (Big Picture)

- CRM: crm.menschlichkeit-oesterreich.at (Drupal 10 + CiviCRM, PHP 8.1) – Port 8000
- API: api.menschlichkeit-oesterreich.at (FastAPI, Python 3.11+, Alembic) – Port 8001
- Frontend: frontend (React 18 + TypeScript + Vite) – Port 5173
- Games: web (Prisma-Schema im Repo; lokaler Dev-Server via Python) – Port 3000
- Automation: automation/n8n (Docker, Webhooks) – Port 5678

Gemeinsame DB (PostgreSQL ≥ 15) via DATABASE_URL. Schema-Änderungen immer koordinieren (API: Alembic · Games: Prisma).

## Daily Dev (Node 22+ zwingend)

- Setup: npm run setup:dev
- Start (alle): npm run dev:all  · Einzeln: dev:crm · dev:api · dev:frontend · dev:games
- Wichtige Ports: CRM 8000 · API 8001 · Frontend 5173 · Games 3000 · n8n 5678

## Qualität & Tests (PR-blocking Gates)

- Alles auf einmal: npm run quality:gates
	- Code Quality (Codacy), Security (Trivy + Gitleaks), Performance (Lighthouse), DSGVO-Checks, Reports
- Einzeltests: npm run test:unit (Vitest), npm run test:e2e (Playwright)
- Python (PII): pytest tests/test_pii_sanitizer.py

## DSGVO/PII (verbindliche Regeln)

- Keine PII in Logs. Masking/Redaction verpflichtend:
	- E-Mail: test@example.com → t**@example.com
	- IBAN: AT61 1904 3002 3457 3201 → AT61***
- FastAPI: api.menschlichkeit-oesterreich.at/app/middleware/pii_middleware.py + app/lib/pii_sanitizer.py
- Drupal: crm.../web/modules/custom/pii_sanitizer/ (Watchdog/Forms/Mails/CiviCRM)
- Tests: tests/test_pii_sanitizer.py

## Frontend Konventionen

- Design Tokens: figma-design-system/00_design-tokens.json (niemals Farben/Spacing hardcoden)
	- Nutzung: frontend/tailwind.config.cjs · Frontend-Scripts für Token-Generierung
- Routing/Fallback: frontend/src/App.tsx nutzt <AITestPage /> als sichere Fallback-Route
- Performance-Audit: npm run performance:lighthouse

## API & DB Flows

- OpenAPI: api.menschlichkeit-oesterreich.at/openapi.yaml aktuell halten
- API-Migrationen: Alembic (z. B. alembic upgrade head)
- Games (Prisma): schema.prisma · npx prisma generate · npx prisma migrate dev

## Build & Deploy (mit n8n-Webhooks)

- Pipeline: ./build-pipeline.sh staging|production [--skip-tests|--force]
- Multi-Service Deploy: deployment-scripts/multi-service-deploy.sh
- Rollback & Health: npm run deploy:rollback · npm run deploy:health-check

## MCP-Integration (AI-gestützte Workflows)

- Setup/Status: npm run mcp:setup · npm run mcp:check · npm run mcp:list
- Typische Nutzung: Figma-Sync (Design Tokens), GitHub (PR/Security), Filesystem (Repo-Operationen), Context7 (Lib-Dokus)

## Do / Don’t (projektspezifisch)

- Do: Österreichisches Deutsch verwenden, Design Tokens nutzen, Quality Gates lokal ausführen, OpenAPI/Alembic/Prisma aktuell halten
- Don’t: PII loggen, Farben/Spacing hardcoden, DB ohne Migration ändern, Secrets commiten (Gitleaks blockt)

## Quick Links (Schlüsseldateien)

- Orchestrierung: package.json (Workflows), build-pipeline.sh
- DSGVO/PII: api.../app/lib/pii_sanitizer.py · crm.../modules/custom/pii_sanitizer/
- Frontend: frontend/src/App.tsx · frontend/tailwind.config.cjs · figma-design-system/00_design-tokens.json
- Datenbank: schema.prisma · api.menschlichkeit-oesterreich.at/alembic/
- Anleitungen (kuratiert, .github/instructions/core):
	- dsgvo-compliance.instructions.md
	- quality-gates.instructions.md
	- project-development.instructions.md
	- mcp-integration.instructions.md

Unklarheiten oder Lücken? Nenne konkrete Aufgaben/Dateien – ich erweitere die Anleitung gezielt (kurz & operativ).
- **Design System:** Figma tokens in `figma-design-system/00_design-tokens.json` auto-sync to frontend (Austrian branding: Rot-Weiß-Rot)- **Security:** Trivy (HIGH/CRITICAL = 0), Gitleaks (0 Secrets), npm audit.
