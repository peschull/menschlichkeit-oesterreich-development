# Task 7: Frontend React/Tailwind Upgrade – Design‑Tokens integrieren & Performance optimieren

Dieser Leitfaden setzt die Frontend‑Modernisierung fort. Ziel ist eine produktionsreife React + Tailwind‑Basis, die direkt unsere Figma‑Design‑Tokens nutzt und klare Performance‑Standards ab Tag 1 einhält.

## Ziele
- Einheitliche UI durch zentrale Design‑Tokens aus `figma-design-system/00_design-tokens.json`.
- Moderne Frontend‑Toolchain (Vite + React + TypeScript + Tailwind).
- Strikte Performance‑Vorgaben (Purge, Code‑Splitting, Caching, Budgets).
- Sanfter Migrationspfad von `website/` (statisches HTML/CSS/JS) hin zu React‑Views.

## Voraussetzungen
- Node.js ≥ 18 (Repository‑weit bereits vorgesehen)
- NPM ≥ 8
- Tokens-Datei: `figma-design-system/00_design-tokens.json`

---

## 1) Projektstruktur (neues Frontend)

Wir legen ein neues Projekt unter `frontend/` an (Vite + React + TS + Tailwind). Die bestehende `website/` bleibt unverändert; Migration erfolgt schrittweise.

Struktur (Ziel):

```
frontend/
  package.json
  tsconfig.json
  index.html
  postcss.config.cjs
  tailwind.config.cjs
  vite.config.ts
  lighthouse.config.cjs
  src/
    main.tsx
    App.tsx
    index.css
    styles/tokens.css        # generiert aus Tokens (Version im Repo enthalten)
  scripts/
    generate-design-tokens.mjs  # Generator (JSON -> CSS Variablen)
    run-lighthouse.mjs          # Build + Preview + Lighthouse Report
```

Starten (nach `npm install` im Ordner `frontend/`):

- Entwicklung: `npm run dev`
- Produktion: `npm run build` (Artefakte: `frontend/dist/`)
- Lighthouse Report: `npm run lh:ci`

---

## 2) Design‑Tokens in Tailwind integrieren

Es gibt zwei Wege, die kombiniert werden können:

- CSS‑Variablen: Aus den Tokens wird eine `:root`‑Definition generiert (`src/styles/tokens.css`). Vorteil: Runtime‑Theming ist möglich (z. B. Dark Mode via Attributwechsel).
- Tailwind Theme‑Erweiterung: Tokens werden in `tailwind.config.cjs` ins Theme gemappt (Farben, Spacing, Radius, Schatten, Breakpoints, Typografie). Vorteil: Autocomplete/Utility‑Klassen in Tailwind.

Beispielnutzung in Komponenten:

- Farbe: `class="text-primary-600 bg-secondary-50"`
- Abstände: `class="px-4 py-2 md:px-6"`
- Radius: `class="rounded-lg"`

---

## 3) Token‑Sync (Generator)

Der Generator `scripts/generate-design-tokens.mjs` liest `figma-design-system/00_design-tokens.json` und schreibt `src/styles/tokens.css`. Er wird via NPM‑Script aufgerufen:

- `npm run tokens:build` – Einmalig/neue Versionen erzeugen.
- `npm run tokens:watch` – Optional für lokale Entwicklung.

Die initiale `tokens.css` ist bereits eingecheckt, damit das Frontend ohne Pre‑Step startfähig ist. Der Generator dient für Updates aus Figma.

---

## 4) Performance‑Optimierungen

- Purge/Content: Tailwind entfernt unbenutzte Klassen anhand der `content`‑Globs.
- Code‑Splitting: Vite/React dynamic imports (`React.lazy`, `import()`), vendor‑Chunks.
- Caching: Hashed Dateinamen im Build, `immutable` static assets (über Reverse‑Proxy/Hosting konfigurierbar).
- CSS‑Optimierung: Tailwind JIT, Minimierung, `@tailwindcss/typography` optional.
- Fonts: `font-display: swap`, Vorab‑Laden kritischer Schnitte, self‑hosted bevorzugt.
- Bilder: moderne Formate (WebP/AVIF), responsive Größen, Lazy‑Loading.
- Budgets: Lighthouse‑ und Bundle‑Budgets dokumentiert (s. Abschnitt 6).

---

## 5) Migration von `website/` nach React

Empfohlene Reihenfolge:

1. UI‑Basiskomponenten (Buttons, Inputs, Navigation) in React/Tailwind nachbauen; Klassen gemäß Tokens.
2. Seitenweise Migration der Templates (zuerst häufig frequentierte). Bestehendes HTML als Referenz behalten.
3. Funktionale JS‑Teile (z. B. Formularlogik, Auth‑Flows) in React Hooks/Services überführen.
4. Parallele Bereitstellung: `website/` bleibt produktiv; `frontend/` läuft zunächst unter Subpfad/Subdomain.
5. Nach Stabilisierung: Umschwenken der Hauptnavigation auf React‑Version.

---

## 6) Qualitätsziele & Budgets

- Lighthouse: ≥ 95 Performance, ≥ 95 Accessibility, ≥ 95 Best Practices, ≥ 90 SEO.
- First Contentful Paint < 1.5s (4G), LCP < 2.5s, TTI < 3.0s.
- JS Bundle initial < 180KB gzip (ohne polyfills), CSS < 60KB gzip.
- Bildgrößen strikt optimieren (kritische Hero‑Assets < 200KB, rest lazy‑load).

---

## 7) Nächste Schritte (konkret)

1. `frontend/` installieren: `cd frontend && npm install && npm run dev`.
2. Tokens‑Sync testen: `npm run tokens:build` – Änderungen in `tokens.css` prüfen.
3. UI‑Atoms (Button, Input) bauen und in einer Beispielseite einsetzen.
4. Performance‑Audit lokal (Lighthouse) und Budgets im README dokumentieren.
5. Migrationsplan mit Seitenprioritäten und Milestones fixieren.

---

## Anhang: Hinweise zur Dark‑Mode‑Strategie

- Empfohlen: Attribut‑gesteuert (`data-theme="dark"`) und CSS‑Variablen pro Theme‑Scope überschreiben.
- Tailwind: `darkMode: ["class", ["[data-theme=dark]"]]` – ermöglicht Dark‑Mode auf Root‑Container.

---

## Anhang: Lighthouse‑Vorlage

- Konfiguration: `frontend/lighthouse.config.cjs`
- Ausführen: `npm run lh:ci -w frontend` – erstellt Report in `frontend/.lighthouse/`
- Abbruchkriterien: P≥0.90, A11y≥0.95, Best‑Practices≥0.95, SEO≥0.90

---

## Anhang: Bereits implementierte UI‑Bausteine

- Atoms: Button (Varianten: primary, secondary, ghost, outline, success, warning, danger, accent), Input (States: default/success/warning/error)
- Molecules: Navigation (Desktop/Mobile, Sticky, Skip‑Link, Dark‑Mode‑Toggle), Alert, Card, Breadcrumb

