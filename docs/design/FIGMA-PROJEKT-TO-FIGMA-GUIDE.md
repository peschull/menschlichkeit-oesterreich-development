# Projekt → Figma: Drei praxistaugliche Wege

Zielabhängig stehen dir drei robuste Routen zur Verfügung, sauber in unseren Workspace integriert.

- 1) HTML/CSS eines Web-Projekts als editierbare Frames in Figma rekonstruieren
- 2) Deinen Code (React/Vue/etc.) mit Figma verknüpfen, statt zu importieren (Figma Dev Mode + Code Connect)
- 3) Design‑Tokens/Assets aus dem Repo nach Figma holen (Tokens Studio + unsere Sync-Skripte)

Hinweis: Diese Anleitung ist auf dieses Repo abgestimmt (Ordner `figma-design-system/`, `frontend/`, `website/`). Für Figma‑MCP siehe `.github/instructions/figma-mcp.instructions.md`.

---

## 1) HTML/CSS → Figma (Rückwärts‑Engineering)

Wann? Wenn du eine existierende Website/HTML‑Vorlage in Figma weiterdesignen willst.

- Tool: Figma‑Plugin „HTML to Design / HTML.to.design“ (Builder.io)
- Ergebnis: Frames/Auto‑Layouts, Texte, Vektoren; Interaktionen/JS werden nicht übernommen.

Schritte
1) In Figma: Plugins → Browse → „HTML to design“ installieren.
2) Plugin starten → Reiter HTML öffnen.
3) Entweder
   - URL deiner Seite einfügen (z. B. lokal gestartet), oder
   - HTML & CSS aus VS Code einfügen (aus `website/` oder einem Build).
4) Auf Import klicken → es entstehen bearbeitbare Frames/Layers.
5) Nacharbeiten: Auto‑Layouts prüfen, fehlende Fonts ersetzen, Komponenten strukturieren.

Tipps für dieses Repo
- Lokale Seite bereitstellen (z. B. `website/` oder `web/`):
  - Dev‑Stack starten: `npm run dev:all`
  - Oder statisch: `cd web && python -m http.server 3000`
- Interne/dev‑Seiten: Baue HTML/CSS lokal und füge im Plugin als Code ein.

Links
- HTML to Design: https://www.builder.io/blog/html-to-design
- Import Code in Figma: https://html.to.design/blog/new-feature-import-code-in-figma/

---

## 2) Code ↔︎ Figma verknüpfen (statt importieren)

Wann? Wenn ihr eine Component‑Library habt und in Figma echte Code‑Snippets sehen wollt (Handover, Konsistenz, Versionierung).

- Figma Dev Mode + Code Connect verbindet Design‑Komponenten mit Codebeispielen/Storybook
- Kein Voll‑Import der App, sondern präzise, versionierte Code‑Anbindung

Kurz‑Setup
1) In Figma: Dev Mode aktivieren (oben rechts in der Datei).
2) Code Connect gemäß Doku einrichten (Mapping der Figma‑Komponenten zu Codebeispielen/Stories).
3) Optional: Figma for VS Code Extension, um Designs/Kommentare/Snippets im Editor zu sehen.

Repo‑Kontext
- Komponenten: `frontend/` (React) und `figma-design-system/components/`
- Storybook (optional): über `design:docs` Script anbindbar (`storybook build`)
- Pfade: Nutze klare Exporte (`index.ts`) pro Komponente und dokumentiere Props/Varianten.

Links
- Figma Code Connect: https://developers.figma.com/docs/code-connect/
- Figma for VS Code: https://help.figma.com/hc/en-us/articles/15023121296151-Figma-for-VS-Code

Weitere Details und Schritt‑für‑Schritt siehe `docs/design/CODE-CONNECT-SETUP.md`.

---

## 3) Design‑Tokens & Assets übertragen

Wann? Wenn du Farben, Typografie, Spacing, etc. aus dem Repo nach Figma holen willst.

Option A: Tokens Studio (Figma Plugin)
- Tokens als JSON im Repo pflegen: `figma-design-system/00_design-tokens.json`
- In Figma: Tokens Studio → JSON View → Token‑Sets importieren/mappen (Variablen/Styles)
- Optional: Rückexport in Code (Style Dictionary/Build‑Pipelines)

Option B: Unsere Scripts (MCP‑freundlich)
- Sync‑Befehl: `npm run figma:sync`
  - Liest `FIGMA_FILE_KEY` + `FIGMA_ACCESS_TOKEN` (siehe Secrets/CI) und aktualisiert:
    - `figma-design-system/00_design-tokens.json`
    - `figma-design-system/styles/design-tokens.css`
    - `tailwind.config.js`
    - `figma-design-system/TOKEN-REFERENCE.md`
- Validierung: `npm run figma:validate` (prüft Struktur, Drift, CSS/TS‑Abgleich)
 - Export für Tokens Studio: `npm run design:export:tokensstudio` (erzeugt `figma-design-system/exports/tokens-studio.json` für direkten Import im Tokens‑Studio‑Plugin)

Links
- Tokens Studio JSON View: https://docs.tokens.studio/manage-tokens/token-sets/json-view
- MCP‑Regeln: `.github/instructions/figma-mcp.instructions.md`

---

## Entscheidungshilfe
- Pixelgenaue Ausgangsbasis eines bestehenden Frontends in Figma? → 1) HTML/CSS → Figma
- Design‑System & Entwickler‑Handover optimieren? → 2) Dev Mode + Code Connect
- Marken/Design‑Konsistenz über Code & Figma? → 3) Tokens

## Schnellstart‑Checkliste
- [ ] Ziel festlegen: rekonstruieren vs. verknüpfen vs. Tokens
- [ ] Falls 1): HTML to Design installieren, Seite/HTML importieren
- [ ] Falls 2): Dev Mode aktivieren, Code Connect einrichten, VS Code Extension installieren
- [ ] Falls 3): Tokens Studio importieren oder `npm run figma:sync && npm run figma:validate`

---

## Troubleshooting
- 401 Unauthorized bei Figma‑Sync: `FIGMA_ACCESS_TOKEN` fehlt (Secret setzen)
- 404 bei Node/File: `fileKey`/`nodeId` prüfen (URL in Figma: node‑id nutzt Doppelpunkt 1:2)
- Große Dateien: `get_metadata` statt `get_code` verwenden (siehe MCP‑Anleitung)
