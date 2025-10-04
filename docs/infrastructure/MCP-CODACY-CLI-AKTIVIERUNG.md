# Codacy MCP-CLI Aktivierung (VS Code Copilot)

Ziel: Nach jedem Datei-Edit die Codacy-Analyse via MCP-Server automatisch ausführen können.

## 1) MCP-Server in GitHub Copilot aktivieren

- Öffne GitHub Einstellungen:
  - Privat: https://github.com/settings/copilot/features
  - Organisation: https://github.com/organizations/<org>/settings/copilot/features
- Aktiviere „Enable MCP servers in Copilot“.
- Stelle sicher, dass der Codacy MCP Server erlaubt ist.

## 2) VS Code: MCP neu initialisieren

- In VS Code: Copilot → MCP-Einstellungen öffnen → Reset/Neu laden.
- Workspace neu öffnen, damit die Datei `mcp.json` erkannt wird.

## 3) mcp.json prüfen (bereits vorhanden)

Die Datei `mcp.json` im Repo definiert u. a. den Codacy-CLI-Server:

- Key: `codacy-cli` → command: `codacy-analysis-cli`
- Output: `quality-reports/codacy-analysis.sarif`

## 4) Verifikation

- In Copilot (oder der Problems-Ansicht) eine Analyse für eine Datei auslösen.
- Erwartung: Der MCP-Server führt `codacy_cli_analyze` aus und liefert Befunde in der IDE.

## 5) Troubleshooting

- Wenn die CLI fehlt oder ein Plattformfehler erscheint:
  1. MCP in der Copilot-Erweiterung resetten.
  2. Obige Copilot-Einstellungen nochmals prüfen (Enable MCP Servers).
  3. Netzwerk/Proxy prüfen.
  4. Wenn weiterhin kein Zugriff: Codacy Support kontaktieren.

## 6) Alternativer Fallback (CI)

- Optional zusätzlich eine GitHub Action einrichten, die `codacy-analysis-cli` im Container auf jedem Push/PR ausführt (SARIF-Export). Dazu wird ein `CODACY_PROJECT_TOKEN` Secret benötigt.

_Status: Diese Anleitung ermöglicht die Aktivierung ohne lokale manuelle Installationstools. Nach erfolgreicher Aktivierung werden Analysen nach jedem Edit automatisch via MCP durchgeführt._
