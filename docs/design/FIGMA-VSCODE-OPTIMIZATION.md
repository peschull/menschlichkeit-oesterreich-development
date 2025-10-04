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
