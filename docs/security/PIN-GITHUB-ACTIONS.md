# GitHub Actions pinnen (Security)

Warum: Dritthersteller-Actions sollten auf vollständige Commit-SHAs gepinnt werden, um Supply-Chain-Risiken durch mutable Tags wie `@v4`, `@master` oder `@latest` zu vermeiden.

Dieses Repo enthält ein Hilfsskript, das alle Actions in `.github/workflows/` auf den passenden Commit-SHA umstellt.

## Nutzung

- Dry-Run (ändert nichts, erzeugt Report):
  - npm run security:pin-actions
- Write (schreibt Änderungen in die Workflow-Dateien):
  - npm run security:pin-actions:write

Optional: Setze `GITHUB_TOKEN` in der Umgebung, um API-Rate-Limits zu vermeiden.

Bericht wird unter `security/reports/pin-actions-report.json` abgelegt.

## Hinweise
- Bereits gepinnte Einträge (40-stellige SHAs) werden übersprungen.
- Bei nicht auflösbaren Refs (z. B. private Repos/Tags) wird der Eintrag belassen und im Report als `failed` vermerkt.
- Das Skript hängt einen Kommentar `# ref: <original>` an, damit die ursprüngliche Version/Tag ersichtlich bleibt.
