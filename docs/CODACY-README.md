# Codacy CLI – CI Setup (Kurz)

## Secret setzen

1. GitHub → Repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**
2. **Name:** `CODACY_TOKEN`
3. **Wert:** Personal/Project Token aus Codacy (Account → Access tokens). Verwende ein Token mit minimalen Rechten.

## Lokaler Schnelltest (optional)

- Prüfen, ob CLI im Runner gefunden wird:
  - Der Workflow enthält einen Step `Locate codacy-cli`, der `which codacy-cli` und `ls -la $HOME/.local/bin` ausgibt.
- Falls PATH-Probleme: Der Workflow verwendet die automatisch gefundene BIN via `${{ steps.codacy.outputs.bin }}`.

## Troubleshooting

- **Exit 1 in "Verify CODACY_TOKEN is set":** Secret fehlt → anlegen (siehe oben).
- **Exit 127 / not found:** CLI nicht im PATH → Logs des Steps "Locate codacy-cli" ansehen.
- **Weiteres Debugging:** Kopiere die relevanten Actions-Logs (Install, Locate, Analyze) und sende sie hier; ich analysiere sie sofort.
