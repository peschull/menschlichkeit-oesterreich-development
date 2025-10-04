# Figma VS Code – Optimierung für dieses Repo

Diese Kurz-Anleitung optimiert die Zusammenarbeit von Figma (Dev Mode) und VS Code in diesem Monorepo.

## 1) VS Code Extension

- Empfohlen: `Figma for VS Code` (`figma.figma-vscode-extension`).
- In VS Code: Sidebar → Figma → Anmelden, dann Dateien/Frames öffnen.
- Dev Resources in Figma: Verlinke Code-Dateien (z. B. `frontend/src/components/ui/Button.tsx`).

## 2) Code Connect – kompakte Snippets

- Nutze kleine Beispieldateien pro Komponente, z. B. `frontend/src/components/ui/Button.example.tsx` mit minimalen Varianten.
- In Figma Dev Mode → Komponente wählen → Dev resources → Link zu `Button.example.tsx`.
- Vorteil: Saubere, kopierbare Snippets für Entwickler; prop‑Varianten klar dokumentiert.

## 3) Design Tokens Sync

- Code→Figma: `npm run design:export:tokensstudio` erzeugt `figma-design-system/exports/tokens-studio.json` (Import in Tokens Studio).
- Figma→Code (optional): Figma API Keys setzen und `npm run figma:sync` erweitert Fallback um echte Pulls.
- Tailwind & CSS‑Vars werden aus Tokens generiert (kein Drift): `figma-design-system/styles/design-tokens.css`.

## 4) Best Practices

- Eine Komponente = eine Beispieldatei mit 2–3 häufigen Varianten.
- Props in Docs erwähnen (`docs/design/CODE-CONNECT-SETUP.md`) und auf Dev Resources verlinken.
- Review‑Check: Token‑Drift prüfen: `npm run figma:validate`.

## 5) Troubleshooting

- Extension zeigt nichts? In VS Code in der Figma‑Ansicht anmelden.
- Komponente nicht verlinkt? Dev resources in Figma prüfen, Pfad muss im Repo existieren.
- Tokens fehlen in Figma? `figma-design-system/exports/tokens-studio.json` erneut importieren.

## 6) MCP Server: Figma Datei hinterlegen

- File Key aus Figma‑URL extrahieren, z. B. aus:
	- https://www.figma.com/make/mTlUSy9BQk4326cvwNa8zQ/Website?node-id=0-1
	- ergibt `mTlUSy9BQk4326cvwNa8zQ`
- In `.vscode/mcp.json` ist `metadata.fileKey` bereits eingetragen.
- Optional: `.env.local` (auf Basis von `config-templates/figma.env`) mit:
	- `FIGMA_FILE_KEY=mTlUSy9BQk4326cvwNa8zQ`
	- `FIGMA_ACCESS_TOKEN=figd_...` (Personal Access Token)

Hilfsmittel:
```bash
# File Key schnell aus URL extrahieren
npm run figma:filekey -- https://www.figma.com/make/mTlUSy9BQk4326cvwNa8zQ/Website?node-id=0-1

# Node-ID aus URL extrahieren (normalisiert 1-2 → 1:2)
npm run figma:nodeid -- "https://www.figma.com/make/mTlUSy9BQk4326cvwNa8zQ/Website?node-id=1-2"
```

Weitere Referenz:

- `docs/design/FIGMA-MCP-TOOLS.md` – Kurzreferenz der Figma MCP Tools (Zweck, Lokal/Remote, Prompts, Hinweise)
- Regeln für generierten Code: `instructions/figma-mcp/stack-rules.md`

Remote-Hinweis:

- Für `get_code`, `get_metadata`, `get_screenshot` im Remote-Server Kontext immer `fileKey` und `nodeId` mitgeben.
