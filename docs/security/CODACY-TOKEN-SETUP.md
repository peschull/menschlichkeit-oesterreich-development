# Codacy Projekt-Token einrichten

Für token-basierte Analysen via CLI (lokal/CI) wird ein Codacy Projekt-Token benötigt.

## 1) Token erzeugen
- Gehe in Codacy zum entsprechenden Projekt
- Settings → Integrations → Project API Token → Generate
- Kopiere den Token-Wert sicher (nicht im Klartext committen)

## 2) GitHub Secret anlegen
- Repository → Settings → Secrets and variables → Actions → New repository secret
- Name: `CODACY_PROJECT_TOKEN`
- Value: <Token aus Codacy>

## 3) CI-Workflow
- Der Workflow `.github/workflows/codacy-analysis.yml` nutzt den Secret und erzeugt `quality-reports/codacy-analysis.sarif`.
- SARIF wird zudem an GitHub Code Scanning hochgeladen.

## 4) Lokal mit Docker
- Token exportieren und Skript aufrufen:

```bash
export CODACY_PROJECT_TOKEN=... # niemals committen
bash scripts/codacy-cli-docker.sh
```

- Ergebnis unter `quality-reports/codacy-analysis.sarif` (falls Analyse durchgeführt wurde)

## 5) Compliance
- Token nur als Secret speichern, nicht im Code/Logs ausgeben.
- Regelmäßig rotieren.
- Zugriff minimal halten (projekt-spezifisch, nicht global).
