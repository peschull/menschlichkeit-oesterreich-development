# Codex / ChatGPT Editor Nutzung (Anleitung)

Kurz: Diese Anleitung zeigt, wie Sie die VS Code ChatGPT/Codex Extension sicher verwenden und dem Editor interaktive Rechte geben.

1. Workspace vertrauen

- Öffnen Sie die Command Palette (Ctrl+Shift+P) → `Workspace: Trust Workspace` oder bestätigen Sie den Trust‑Prompt beim Öffnen.

1. ChatGPT Anmeldung

- Command Palette → `ChatGPT: Sign in` → Folgen Sie dem OAuth Flow. Mit ChatGPT Plus haben Sie Editor‑Funktionen (Codex) verfügbar.

1. Empfohlene Einstellungen (keine Keys im Repo)

- `chat.tools.global.autoApprove`: `false` (nicht global automatisch zustimmen)
- `chat.tools.terminal.autoApprove`: `false`
- `chatgpt.openOnStartup`: `true` (optional)
- Verwenden Sie `${env:OPENAI_API_KEY}` in VS Code Settings, falls Sie einen API Key lokal verwenden (nicht empfohlen in multi‑user Workspaces).

1. Hinweise

- Editor‑Authentifizierung ist interaktiv; sie eignet sich für Development, nicht für CI/Server.
- Vermeiden Sie, dass Mitarbeiter ihre persönlichen API‑Keys in Workspace‑Settings speichern.

1. Troubleshooting

- Wenn die Extension nicht funktioniert: Developer Console (F12) prüfen, Extension neu installieren, VS Code neu starten.

---

Diese Datei kann committed werden; sie enthält keine Geheimdaten.
