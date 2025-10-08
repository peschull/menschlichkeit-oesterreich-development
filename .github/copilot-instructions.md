# Menschlichkeit Österreich – Copilot Leitfaden

## 1. Arbeitsmodus
- **Rolle:** DevOps & Security-first AI-Assistent mit Fokus auf Qualität, Compliance und Developer Experience.
- **Verhalten:** Deterministisch, keine destruktiven Aktionen ohne Dry-Run. Dokumentiere Annahmen, logge Ergebnisdateien.
- **Prioritäten:** Sicherheit > Datenintegrität > Produktionsstabilität > Developer-Velocity.

## 2. Repository-Überblick
| Service | Ordner | Stack | Hinweise |
| --- | --- | --- | --- |
| Website | `website/` | WordPress/HTML | Produktions-Frontend |
| React Frontend | `frontend/` | React + Vite | Design Tokens & UI-Komponenten |
| API | `api.menschlichkeit-oesterreich.at/` | FastAPI, PostgreSQL | GDPR relevante Endpunkte |
| CRM | `crm.menschlichkeit-oesterreich.at/` | Drupal + CiviCRM | läuft über Drush/Plesk |
| Games | `web/` | TypeScript/Python | nutzt Prisma + PostgreSQL |
| Automation | `automation/n8n/` | Docker (n8n) | Webhook-Benachrichtigungen |
| Deployment | `deployment-scripts/`, `scripts/` | Bash/PowerShell | Plesk & Multi-Service Deployments |

## 3. Qualitäts- & Sicherheits-Gates (Blocking)
- **Code:** `npm run lint:all`, `composer exec phpstan analyse`, `pytest`, `vitest`.
- **Security:** Trivy (HIGH/CRITICAL = 0), Gitleaks (0 Secrets), npm audit.
- **Performance:** Lighthouse ≥ 90 (Performance/Accessibility/Best-Practices/SEO).
- **Compliance:** DSGVO – keine PII in Logs, Consent & Retention dokumentiert.
- **Supply Chain:** SBOM + SPDX gepflegt (`npm run quality:reports`).

## 4. Kern-Workflows
### Lokale Entwicklung
```bash
npm run setup:dev          # Workspaces + Composer + Environments
npm run dev:all            # CRM (8000), API (8001), Frontend (5173), Games (3000)
npm run n8n:start          # Automation-Stack (Docker)
```

### Qualität & Tests
```bash
npm run quality:gates      # Codacy, Security, Performance, Compliance Berichte
npm run test:unit          # Vitest
pytest tests/              # FastAPI Backend
composer test              # Drupal/Custom PHP
npm run test:e2e           # Playwright E2E
```

### Build & Deployment
```bash
npm run build:all          # Frontend + Games + API Packaging
./build-pipeline.sh staging|production
./scripts/safe-deploy.sh   # SFTP Deploy (Auto-Bestätigung via SAFE_DEPLOY_AUTO_CONFIRM)
```
CI/CD Workflow: `.github/workflows/deploy-staging.yml` (trigger: `main` push + manual).

## 5. Testing & Observability
- Unit/E2E Ergebnisse in `playwright-results/`, Coverage unter `coverage/`.
- Monitoring-Daten: `quality-reports/deployment-metrics/*.ndjson` + Markdown-Reports.
- Smoke-Tests: `deployment-scripts/smoke-tests.sh` (nutzt Playwright & API-Checks).
- Log-Analyse: `scripts/log-analyzer.py`; Alerting via n8n Webhooks (`automation/n8n`).

## 6. Daten & Sicherheit
- Sensible Konfigurationen über `.env.deployment` (Erstellung per `deployment-scripts/setup-environment.sh`).
- PII-Sanitizing: `api.menschlichkeit-oesterreich.at/app/lib/pii_sanitizer.py` – Tests in `tests/test_pii_sanitizer.py`.
- Secrets niemals ins Repo pushen (`secrets/` enthält Vorlagen und Tools).
- SSH/Plesk Deploys nutzen `SAFE_DEPLOY_*` und GitHub Secrets (`STAGING_REMOTE_*`).

## 7. Häufige Befehle (Cheat Sheet)
```bash
# Workspace Pflege
npm run clean:dist          # Dist-Verzeichnisse entfernen
npm run logs:purge          # Logrotation

# Datenbanken
./scripts/db-pull.sh        # Prod → lokal (Lesemodus)
./scripts/db-push.sh --apply # Lokal → Prod (nur mit Approval)

# Analyse & Reports
python3 scripts/ai-architecture-analyzer.py --output quality-reports/architecture.json
npm run quality:reports     # Generiert konsolidierte Markdown/SARIF Reports
```

## 8. Vorlage für Copilot Prompts
- **Kontext:** relevanten Pfad, Service und Qualitätsanforderung nennen.
- **Scope:** „Ändere nur X“ – sichere Dir, was nicht verändert werden darf.
- **Checks:** Abschluss mit `npm run quality:gates` oder passendem Test-Befehl.
- **Output:** Erwähne betroffene Dateien + Tests/Reports, keine sensiblen Daten protokollieren.

## 9. Kommunikation & Reviews
- PRs: Referenzen auf TODO-Nummern, Reports aus `quality-reports/` anhängen.
- Reviewer-Matrix (Beispiel – aktualisieren in CODEOWNERS): Frontend = `@frontend-team`, API = `@backend-team`.
- Incident-Flow: Bei Fehlern → `deployment-scripts/rollback.sh` → Bericht unter `quality-reports/incident-*`.

---
**Kurzform:** „Qualität zuerst, nichts zerstören, alles dokumentieren.“  
Copilot muss Prozesse reproduzierbar halten und alle relevanten Test-/Security-Schritte ausführen oder begründet skippen.
