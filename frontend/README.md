# Frontend (React + Tailwind)

Dieses Paket stellt das neue React‑Frontend mit TailwindCSS und Design‑Token‑Integration bereit.

## Schnellstart

- Abhängigkeiten installieren: `npm install` (im Ordner `frontend/`)
- Entwicklung starten: `npm run dev`
- Produktion bauen: `npm run build`

Optional: `.env.local` aus `.env.example` kopieren und API‑URL anpassen.

## Design‑Tokens

- Quelle: `figma-design-system/00_design-tokens.json`
- Generator: `npm run tokens:build` schreibt `src/styles/tokens.css`
- Tailwind nutzt die Tokens direkt über `tailwind.config.cjs` (Farben, Typography, Spacing …)

## API‑Wiring

- Konfiguration: `src/services/config.ts` (liest `VITE_API_BASE_URL`)
- HTTP‑Wrapper: `src/services/http.ts`
- Beispiel‑Endpoints: `src/services/api.ts` (`/health`, `/auth/login`)

## Performance

- Tailwind JIT + Purge über `content`‑Globs
- Vite Code‑Splitting (separate `react`‑Vendor‑Chunk)
- Hashed Assets im Prod‑Build
- Budgets: initial JS < 180KB gzip, CSS < 60KB gzip

## A11y

- Baseline: Tailwind + semantische HTML‑Strukturen
- Empfohlen: `@tailwindcss/forms` und `@tailwindcss/typography` (optional hinzufügen)

## Lighthouse

- Config: `lighthouse.config.cjs` (Mobile‑Emulation + Budgets)
- Report erzeugen: `npm run lh:ci`
  - baut das Projekt, startet `vite preview` und generiert Report unter `.lighthouse/`
  - bricht mit Exit‑Code 1 ab, wenn Scores unter Grenzwerten liegen (P≥0.90, A11y≥0.95, BP≥0.95, SEO≥0.90)
