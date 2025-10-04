# Figma Code Connect – Setup für dieses Repo

Diese Anleitung verbindet Figma‑Komponenten mit deinem Code, ohne die App zu importieren. Ideal für konsistente Handover‑Snippets im Dev Mode.

## Voraussetzungen
- Figma Datei mit Komponenten (Dev Mode aktiv)
- Zugriff auf Code‑Repo (dieses Monorepo)
- Optional: Storybook Build für Komponenten (`design:docs`)

## Struktur in diesem Repo
- Komponenten: `frontend/src/components/`, `figma-design-system/components/`
- Tokens: `figma-design-system/00_design-tokens.json` → `tailwind.config.js`, `styles/design-tokens.css`

## Schritte
1) Dev Mode aktivieren (Figma UI, oben rechts).
2) Komponenten in Figma benennen und Varianten definieren (Props/States klar halten).
3) Code Connect einrichten (siehe Doku):
   - Mapping einer Figma‑Komponente zu einem Codebeispiel:
     - Quelle: Storybook URL oder Repo‑Datei (z. B. `frontend/src/components/ui/button.tsx`)
     - Snippet: Minimal‑Beispiel mit Import und JSX, inkl. Props
4) Optional: Storybook veröffentlichen und in Figma referenzieren.
5) Im Repo sicherstellen:
   - Jede Komponente hat einen klaren Default‑Export und dokumentierte Props
   - Usage‑Beispiel in `COMPONENT-USAGE.md` oder Story (`.stories.tsx`)

## Minimal‑Beispiel (Button)
- Datei: `frontend/src/components/ui/button.tsx`
- Story: `frontend/src/components/ui/Button.stories.tsx`
- In Figma Code Connect: Verknüpfe die Button‑Komponente mit der Story/Datei und lege die Props‑Varianten an.

## Nützliche Skripte
- Tokens Sync: `npm run figma:sync`
- Tokens Validierung: `npm run figma:validate`
- Design Docs Build (optional): `npm run design:docs`

## Best Practices
- WCAG AA: Kontraste/Focus sichtbar halten
- Design Token Drift = 0: Nach Änderungen `npm run figma:validate`
- Einheitliche Benennung: lowercase‑kebab für Tokens, PascalCase für Komponenten

## Links
- Code Connect Doku: https://developers.figma.com/docs/code-connect/
- Figma VS Code: https://help.figma.com/hc/en-us/articles/15023121296151-Figma-for-VS-Code
