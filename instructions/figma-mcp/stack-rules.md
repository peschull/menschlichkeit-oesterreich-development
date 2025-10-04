# Stack- und Design-System-Regeln (Figma MCP)

Geltungsbereich: `frontend/**`, `figma-design-system/**`, `website/**`

## Tech-Stack
- Framework: React + TypeScript
- Styling: Tailwind CSS (konfiguriert via Design Tokens)
- Tokens: `figma-design-system/00_design-tokens.json` → CSS Variablen in `figma-design-system/styles/design-tokens.css`
- Komponenten-Ort: `frontend/src/components/ui/`

## Code-Richtlinien
- Semantisches HTML, ARIA-Attribute wo nötig
- Fokus-States sichtbar, Kontrastverhältnis ≥ 4.5:1 (WCAG AA)
- Keine Inline-Styles für Farben/Spacing, stattdessen Tokens/CSS-Variablen
- Props klar typisieren, sinnvolle Defaults, keine versteckte Magie
- Barrierefreiheit: Tastaturbedienung, Rollen/Labelling, Live-Regionen wenn nötig

## Generierungsvorgaben (für get_code)
- Nutze Tailwind-Klassen, die auf die vorhandenen Tokens mappen
- Verwende vorhandene Bausteine, wenn gewünscht: `frontend/src/components/ui/*`
- Exporte: Named Exports, Story/Beispiel in eigener Datei `*.example.tsx`

## Tests & Qualität
- Token-Drift: `npm run figma:validate` muss grün sein
- Lint: `npm run lint:all` ohne Fehler
- Accessibility: Schneller Check (role, aria-*, focusable)
