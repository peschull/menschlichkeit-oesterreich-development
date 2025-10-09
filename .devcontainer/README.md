# Codespace & Devcontainer Setup — Menschlichkeit Österreich 🇦🇹

> **Kurzüberblick:** Dieser Leitfaden ist auf den gehärteten Devcontainer mit Node 22, uv, Playwright‑Cache und zusätzlichen Ports (inkl. 5678 für n8n) abgestimmt.

## 1) Schnellstart

```bash
# Container neu bauen (VS Code Command Palette)
Dev Containers: Rebuild Container

# Alternativ im Terminal (nach Rebuild):
npm run dev:all
```

**Nach dem Start erreichbare Services**

| Dienst      | Port  | URL                         | Hinweis                         |
|-------------|-------|-----------------------------|---------------------------------|
| Frontend    | 5173  | http://localhost:5173       | Vite; Browser wird automatisch geöffnet |
| API (FastAPI)| 8001 | http://localhost:8001       | Uvicorn                         |
| CRM (Drupal)| 8000  | http://localhost:8000       | Composer-Install im Setup       |
| Games       | 3000  | http://localhost:3000       | Python/Prisma                   |
| n8n         | 5678  | http://localhost:5678       | Docker-/Automation-Workflows    |

---

## 2) Was der Devcontainer automatisch macht

- **uv** installieren und aktivieren (Python Package Manager)
- **Caches** mounten (npm/pnpm, uv/pip, Composer, Playwright)
- **Playwright-Browser** installieren, wenn `@playwright/test` im `package.json` vorhanden ist
- **Corepack** aktivieren (pnpm optional)
- **.env** Dateien aus `*.env.example` kopieren (falls vorhanden)
- **Composer install** für `crm.menschlichkeit-oesterreich.at`
- **Python-Dependencies** für `api.menschlichkeit-oesterreich.at`
- **Prisma Client** generieren, wenn `schema.prisma` existiert

> Die Logik steckt in `.devcontainer/setup.sh` und `.devcontainer/setup-codespace.sh` und ist idempotent.

---

## 3) Entwicklung

### Empfohlene Skripte (Monorepo)

```bash
npm run dev:all        # alle Services starten
npm run dev:frontend   # Frontend (Vite)
npm run dev:api        # FastAPI
npm run dev:crm        # Drupal/CiviCRM
npm run dev:games      # Games
npm run n8n:start      # n8n Automations
```

> Falls einzelne Skripte im Projekt noch fehlen, im jeweiligen Service-Ordner starten (z. B. `cd frontend && npm run dev`).

### Datenbank & Migrations

**PostgreSQL** via `DATABASE_URL` (shared).

```bash
# Alembic (API)
cd api.menschlichkeit-oesterreich.at
alembic upgrade head

# Prisma (Games)
cd -
npx prisma migrate dev
npx prisma studio   # GUI
```

---

## 4) Qualität, Sicherheit & Compliance

```bash
npm run quality:gates   # Security (Trivy, Gitleaks), Linting, Lighthouse, DSGVO-Checks
npm run lint:all        # ESLint + Ruff
npm run test:unit       # Vitest
npm run test:e2e        # Playwright
pytest tests/           # Python API
composer test           # PHP/Drupal
```

- **DSGVO**: PII-Sanitizer in API/CRM/n8n
- **Secrets**: Gitleaks (Policy 0-Secrets)
- **SBOM**: CycloneDX + Cosign
- **Vulnerabilities**: Trivy (HIGH/CRITICAL = 0)

---

## 5) Troubleshooting (kurz)

**uv fehlt oder bricht ab**
```bash
pip install --upgrade pip
pip install uv
uv --version
```

**Playwright hängt**
```bash
npx playwright install --with-deps
```

**Prisma Fehler**
```bash
npx prisma generate
npx prisma migrate dev
```

**Git Safe Directory**
```bash
git config --global --add safe.directory "$(pwd)"
```

**MCP Warnungen in VS Code**
Siehe `VS-CODE-MCP-CACHE-ISSUE.md` für die definitive Lösung.

---

## 6) Projektstruktur (ausgewählt)

- `api.menschlichkeit-oesterreich.at/` — FastAPI + Alembic
- `crm.menschlichkeit-oesterreich.at/` — Drupal 10 + CiviCRM
- `frontend/` — React 18 + TypeScript + Vite + Tailwind
- `web/` — Games (Prisma + Python HTTP)
- `automation/n8n/` — Workflows (Docker)
- `mcp-servers/` — Model Context Protocol Integrationen

---

## 7) System-Check

Nach dem Setup gibt das Bootstrap-Skript Versionen aus:
- Node.js, npm, Python, uv, PHP, Composer

Manuell prüfen:
```bash
node -v && npm -v && python3 --version && uv --version
```

---

**Maintainer:** Menschlichkeit Österreich Development Team  
**Letztes Update:** 2025‑10‑09
