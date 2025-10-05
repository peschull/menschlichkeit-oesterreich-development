# Build-Graph & Quality Gates – Turborepo Integration

**Datum:** 2025-10-05

## Zusammenfassung

Ab Oktober 2025 orchestriert Turborepo alle Quality Gates (lint, test, build) und parallele Builds für alle Workspaces im Monorepo. Fehlerhafte Workspaces blockieren den gesamten Build. Affected Detection sorgt für gezielte Builds bei Änderungen.

## Quality Gates
- Lint, Test und Build laufen für alle Services/Packages parallel.
- Fehler in einem Workspace blockieren den gesamten Build.
- Skripte:
  - `npm run turbo:lint` – Lint für alle Workspaces
  - `npm run turbo:test` – Tests für alle Workspaces
  - `npm run turbo:build` – Build für alle Workspaces
  - `npm run turbo:affected:lint` – Lint nur für geänderte Workspaces
  - `npm run turbo:affected:test` – Tests nur für geänderte Workspaces
  - `npm run turbo:affected:build` – Build nur für geänderte Workspaces

## Best Practices
- Jeder Workspace benötigt ein eigenes `lint`-, `test`- und `build`-Skript in der package.json.
- Quality Gates werden zentral über Turborepo gesteuert.
- Fehlerhafte Workspaces müssen vor Merge/Deploy behoben werden.

## Referenzen
- turbo.json
- package.json (root)
- README.md
- Quality-Reports
