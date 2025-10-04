# Figma MCP Server – Tools Kurzreferenz

Diese Referenz bündelt die wichtigsten Tools des Figma MCP Servers für dieses Monorepo.

## Übersicht

| Tool | Zweck | Lokal/Remote | Typische Prompts/Parameter | Hinweise |
|---|---|---|---|---|
| get_code | Generiert UI‑Code zur aktuellen Auswahl bzw. zu referenzierten Nodes | Lokal: Auswahl-basiert; Remote: Link/Node-ID erforderlich | „in Vue“, „Plain HTML + CSS“, „iOS SwiftUI“, „nutze Komponenten aus src/components/ui“, „Tailwind verwenden“ | Remote benötigt `fileKey` + `nodeId` (siehe unten) |
| get_variable_defs | Listet Variablen/Styles (Farben, Spacing, Typo) der Auswahl | Nur lokal | „alle Tokens auflisten“, „nur Farben und Spacing“, „Namen und Werte als JSON“ | Token-Audits/Drift-Checks |
| get_code_connect_map | Mapping Figma-Node → Code-Komponente (codeConnectSrc, codeConnectName) | Nur lokal | „Mapping für aktuelle Seite“, „nur verbundene Komponenten“ | Design ↔ Implementierung abgleichen |
| get_screenshot | Screenshot der Auswahl (verbessert Code-Qualität/Layout-Treue) | Lokal & Remote | „format: png/jpg“, „scale: 2x“, „transparent: true“ | Für Code-Gen meist eingeschaltet lassen |
| create_design_system_rules | Erstellt/validiert Regeln für DS-/Stack-konforme Outputs | Lokal & Remote | „React + TS + Tailwind, WCAG AA, Tokens aus figma-design-system/00_design-tokens.json“ | Datei unter `instructions/figma-mcp/stack-rules.md` |
| get_metadata | Schlanke XML-Outline (IDs, Namen, Typen, Pos/Größe) | Lokal & Remote | „nur Frames“, „ganze Seite“, „IDs und Typen“ | Bei großen Seiten zuerst nutzen |

## Remote‑Kontext: fileKey und nodeId

- `fileKey` ist in `.vscode/mcp.json` hinterlegt (`metadata.fileKey`).
- `nodeId` aus der Figma‑URL extrahieren (Parameter `node-id=`). Dabei Bindestrich zu Doppelpunkt normalisieren: `1-2` → `1:2`.
- Hilfsskript: `npm run figma:nodeid -- <figma-url>` gibt eine normalisierte Node‑ID aus.

Beispiele für Figma‑URLs:

- https://www.figma.com/make/<fileKey>/<Datei>?node-id=1-2
- https://www.figma.com/file/<fileKey>/<Datei>?type=design&node-id=1%3A2

## Best Practices in diesem Repo

- Stack: React + TypeScript + Tailwind, Tokens aus `figma-design-system/00_design-tokens.json`.
- Accessibility: WCAG AA, ARIA‑Attribute, fokussierbare Interaktionen, Kontrast ≥ 4.5:1.
- Code Connect: Dev Resources in Figma → auf kleine Beispieldateien verlinken (z. B. `frontend/src/components/ui/Button.example.tsx`).
- Token‑Drift: `npm run figma:validate` vor PRs; CSS‑Variablen aus `figma-design-system/styles/design-tokens.css` verwenden.
