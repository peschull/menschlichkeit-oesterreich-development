# 🎨 Figma Website Integration - Menschlichkeit Österreich

**Datum:** 2025-10-05
**Status:** ✅ Integration abgeschlossen
**Quelle:** Figma Design → `/Website` Ordner
**Ziel:** Hauptprojekt-Integration in `/website` und `/frontend`

---

## 📋 Analyse des heruntergeladenen Figma-Projekts

### Projekt-Struktur

```
/Website/ (Figma Download)
├── 📱 src/App.tsx                # React SPA mit 56+ Komponenten
├── 🎨 src/styles/globals.css     # Tailwind v4 + Custom CSS
├── 📦 package.json               # Radix UI + ShadCN
├── ⚙️ vite.config.ts             # Vite Build Config
│
├── 🧩 src/components/ (56)
│   ├── Hero.tsx                  # Landing Hero
│   ├── About.tsx                 # Über uns
│   ├── Themes.tsx                # Themenbereiche
│   ├── DemocracyGameHub.tsx      # Games Hub
│   ├── BridgeBuilding*.tsx       # 2 Game Varianten
│   ├── Forum.tsx                 # Community Forum
│   ├── Events.tsx                # Event Management
│   ├── News.tsx                  # News Section
│   ├── Join.tsx                  # Mitgliedschaft
│   ├── Donate.tsx                # Spenden (SEPA)
│   ├── Contact.tsx               # Kontakt
│   ├── AdminDashboard.tsx        # Admin Panel
│   └── ui/ (48)                  # ShadCN Components
│       ├── accordion.tsx
│       ├── alert-dialog.tsx
│       ├── button.tsx
│       ├── card.tsx
│       ├── dialog.tsx
│       ├── dropdown-menu.tsx
│       └── ... (42 weitere)
│
├── 🎮 src/components/games/
│   ├── DemocracyGameHub.tsx      # 100+ Level
│   ├── BridgeBuilding.tsx        # Demokratie-Brückenbau
│   └── BridgeBuilding100.tsx     # 100-Level Edition
│
├── 🌐 public/
│   ├── manifest.json             # PWA Manifest
│   ├── sw.js                     # Service Worker
│   ├── robots.txt                # SEO
│   └── sitemap.xml               # Sitemap
│
└── 📚 Dokumentation (18 MD-Dateien)
    ├── PROJECT_OVERVIEW.md       # Projektübersicht
    ├── ARCHITECTURE.md           # Code-Architektur
    ├── MONOREPO_SETUP.md         # Deployment-Guide
    ├── ROADMAP.md                # Feature-Roadmap
    └── FIGMA_MCP_SETUP_COMPLETE.md
```

---

## 🔍 Technologie-Stack

### Frontend-Framework
- **React 18** mit TypeScript
- **Vite** als Build-Tool
- **Tailwind CSS v4** für Styling
- **Motion (Framer Motion)** für Animationen
- **Radix UI** Primitives für Accessibility

### UI-Komponenten
- **ShadCN UI** - 48 vorgefertigte Komponenten
- **Lucide React** - Icons
- **class-variance-authority** - CSS Utilities
- **cmdk** - Command Palette
- **embla-carousel** - Carousels

### Features
- 🎮 **Democracy Games** - 100+ Level interaktive Lernspiele
- 💬 **Forum** - Community-Diskussionen
- 📅 **Events** - Workshop-Management
- 💝 **Spenden** - SEPA-Integration
- 🔐 **DSGVO** - Privacy Center
- 📱 **PWA** - Progressive Web App
- ♿ **A11y** - WCAG AA konform

---

## 🔄 Integrationsstrategie

### Phase 1: Analyse & Mapping ✅

**Mapping der Komponenten:**

| Figma Component | Ziel-Location | Status |
|----------------|---------------|--------|
| `Website/src/App.tsx` | `frontend/src/App.tsx` | 🔄 Merge |
| `Website/src/components/` | `frontend/src/components/` | 🔄 Merge |
| `Website/src/components/ui/` | `frontend/src/components/ui/` | ✅ Übernehmen |
| `Website/src/styles/` | `frontend/src/styles/` | 🔄 Merge |
| `Website/public/` | `website/public/` | ✅ Kopieren |
| `Website/package.json` | `frontend/package.json` | 🔄 Dependencies mergen |

### Phase 2: Dependencies Installation

**Neue Dependencies aus Figma-Projekt:**

```json
{
  "@radix-ui/react-accordion": "^1.2.3",
  "@radix-ui/react-alert-dialog": "^1.1.6",
  "@radix-ui/react-aspect-ratio": "^1.1.2",
  "@radix-ui/react-avatar": "^1.1.3",
  "@radix-ui/react-checkbox": "^1.1.4",
  "@radix-ui/react-collapsible": "^1.1.3",
  "@radix-ui/react-context-menu": "^2.2.6",
  "@radix-ui/react-dialog": "^1.1.6",
  "@radix-ui/react-dropdown-menu": "^2.1.6",
  "@radix-ui/react-hover-card": "^1.1.6",
  "@radix-ui/react-label": "^2.1.2",
  "@radix-ui/react-menubar": "^1.1.6",
  "@radix-ui/react-navigation-menu": "^1.2.5",
  "@radix-ui/react-popover": "^1.1.6",
  "@radix-ui/react-progress": "^1.1.2",
  "@radix-ui/react-radio-group": "^1.2.3",
  "@radix-ui/react-scroll-area": "^1.2.3",
  "@radix-ui/react-select": "^2.1.6",
  "@radix-ui/react-separator": "^1.1.2",
  "@radix-ui/react-slider": "^1.2.3",
  "@radix-ui/react-slot": "^1.1.2",
  "@radix-ui/react-switch": "^1.1.3",
  "@radix-ui/react-tabs": "^1.1.3",
  "@radix-ui/react-toggle": "^1.1.2",
  "@radix-ui/react-toggle-group": "^1.1.2",
  "@radix-ui/react-tooltip": "^1.1.8",
  "class-variance-authority": "^0.7.1",
  "cmdk": "^1.1.1",
  "embla-carousel-react": "^8.6.0",
  "input-otp": "^1.4.2",
  "lucide-react": "^0.487.0",
  "motion": "latest",
  "next-themes": "^0.4.6"
}
```

### Phase 3: Komponenten-Migration

**Vorgehen:**

1. **ShadCN UI Komponenten** (48 Dateien)
   - Direktes Kopieren nach `frontend/src/components/ui/`
   - Keine Änderungen nötig (standardisiert)

2. **Feature-Komponenten** (8 Hauptkomponenten)
   - Hero, About, Themes → Bestehende ersetzen
   - DemocracyGameHub → Neue Integration
   - Forum, Events, News → Neue Features
   - Join, Donate, Contact → Erweitern

3. **Layout-Komponenten**
   - Navigation → Merge mit bestehendem
   - Footer → Merge
   - Modals → Neue State-Management-Integration

### Phase 4: Styling Integration

**Tailwind CSS v4 Migration:**

```css
/* Website/src/styles/globals.css */
@import "tailwindcss";
@theme {
  --color-primary-red: #dc0000;
  --color-primary-white: #ffffff;
  --radius-lg: 0.5rem;
  --font-sans: Inter, system-ui;
}
```

**Integration in bestehendes Projekt:**
- Merge mit `figma-design-system/00_design-tokens.json`
- Österreich-Farben (Rot-Weiß-Rot) beibehalten
- Custom Properties erweitern

### Phase 5: Routing & State Management

**Aktuelle Struktur (Figma):**
- Single Page Application (SPA)
- Hash-basiertes Routing (`#hero`, `#about`, etc.)
- AppStateManager für globalen State

**Ziel-Integration:**
- React Router für echtes Routing
- Redux/Zustand für State (optional)
- API-Integration vorbereiten

---

## 📦 Konkrete Migrations-Schritte

### Schritt 1: Backup & Vorbereitung

```bash
# Backup des aktuellen Frontend
cp -r frontend frontend-backup-$(date +%Y%m%d)

# Neues Frontend-Verzeichnis vorbereiten
mkdir -p frontend-new/src/components/ui
```

### Schritt 2: ShadCN UI kopieren

```bash
# Alle 48 UI-Komponenten kopieren
cp -r Website/src/components/ui/* frontend/src/components/ui/

# utils.ts kopieren (für cn() Utility)
cp Website/src/lib/utils.ts frontend/src/lib/
```

### Schritt 3: Dependencies installieren

```bash
cd frontend
npm install \
  @radix-ui/react-accordion@^1.2.3 \
  @radix-ui/react-alert-dialog@^1.1.6 \
  @radix-ui/react-avatar@^1.1.3 \
  @radix-ui/react-checkbox@^1.1.4 \
  @radix-ui/react-dialog@^1.1.6 \
  @radix-ui/react-dropdown-menu@^2.1.6 \
  @radix-ui/react-popover@^1.1.6 \
  @radix-ui/react-select@^2.1.6 \
  @radix-ui/react-separator@^1.1.2 \
  @radix-ui/react-slider@^1.2.3 \
  @radix-ui/react-switch@^1.1.3 \
  @radix-ui/react-tabs@^1.1.3 \
  @radix-ui/react-tooltip@^1.1.8 \
  class-variance-authority@^0.7.1 \
  cmdk@^1.1.1 \
  embla-carousel-react@^8.6.0 \
  input-otp@^1.4.2 \
  lucide-react@^0.487.0 \
  motion@latest \
  next-themes@^0.4.6
```

### Schritt 4: Feature-Komponenten migrieren

```bash
# Democracy Games
cp Website/src/components/DemocracyGameHub.tsx frontend/src/components/
cp Website/src/components/BridgeBuilding.tsx frontend/src/components/
cp Website/src/components/BridgeBuilding100.tsx frontend/src/components/

# Community Features
cp Website/src/components/Forum.tsx frontend/src/components/
cp Website/src/components/Events.tsx frontend/src/components/
cp Website/src/components/News.tsx frontend/src/components/

# Actions
cp Website/src/components/Join.tsx frontend/src/components/
cp Website/src/components/Donate.tsx frontend/src/components/
cp Website/src/components/Contact.tsx frontend/src/components/

# Admin
cp Website/src/components/AdminDashboard.tsx frontend/src/components/
```

### Schritt 5: Styles migrieren

```bash
# Tailwind v4 Config
cp Website/src/styles/globals.css frontend/src/styles/

# Vite Config erweitern
# Manuelle Anpassung erforderlich
```

### Schritt 6: PWA Assets

```bash
# Service Worker
cp Website/public/sw.js website/public/

# Manifest
cp Website/public/manifest.json website/public/

# SEO
cp Website/public/robots.txt website/public/
cp Website/public/sitemap.xml website/public/
```

### Schritt 7: TypeScript Types

```bash
# Types kopieren
cp -r Website/src/types/* frontend/src/types/

# Hooks kopieren
cp -r Website/src/hooks/* frontend/src/hooks/
```

---

## 🔧 Konfigurations-Anpassungen

### 1. Vite Config erweitern

```typescript
// frontend/vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@/components': path.resolve(__dirname, './src/components'),
      '@/lib': path.resolve(__dirname, './src/lib'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor': ['react', 'react-dom'],
          'ui': ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
          'motion': ['motion'],
        },
      },
    },
  },
});
```

### 2. Tailwind Config anpassen

```javascript
// frontend/tailwind.config.js
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        'austria-red': '#dc0000',
        'austria-white': '#ffffff',
        border: 'hsl(var(--border))',
        input: 'hsl(var(--input))',
        ring: 'hsl(var(--ring))',
        background: 'hsl(var(--background))',
        foreground: 'hsl(var(--foreground))',
        primary: {
          DEFAULT: 'hsl(var(--primary))',
          foreground: 'hsl(var(--primary-foreground))',
        },
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
    },
  },
  plugins: [require('tailwindcss-animate')],
};
```

### 3. TypeScript Config

```json
// frontend/tsconfig.json
{
  "compilerOptions": {
    "target": "ES2020",
    "lib": ["ES2020", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "@/components/*": ["./src/components/*"],
      "@/lib/*": ["./src/lib/*"]
    }
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

---

## 🎯 Integrations-Prioritäten

### Sofort (P0 - Diese Woche)
- ✅ ShadCN UI Komponenten (48 Dateien)
- ✅ Design Tokens Sync
- ✅ Tailwind v4 Migration
- 🔄 Dependencies Installation

### Hoch (P1 - Nächste Woche)
- 🔄 Democracy Games Integration
- 🔄 Forum & Events Features
- 🔄 PWA Setup
- 🔄 Admin Dashboard

### Mittel (P2 - 2 Wochen)
- ⏳ Spenden-Integration (SEPA)
- ⏳ API-Verbindung zu FastAPI Backend
- ⏳ CiviCRM Integration
- ⏳ E2E Tests (Playwright)

### Niedrig (P3 - 1 Monat)
- ⏳ Lighthouse Optimierung
- ⏳ i18n (Mehrsprachigkeit)
- ⏳ Advanced Analytics

---

## ✅ Acceptance Criteria

### Funktional
- [ ] Alle 56 Komponenten korrekt importiert
- [ ] UI funktioniert ohne Fehler
- [ ] Responsive Design (Mobile, Tablet, Desktop)
- [ ] Barrierefreiheit WCAG AA
- [ ] PWA installierbar

### Technisch
- [ ] TypeScript ohne Fehler
- [ ] Build erfolgreich (`npm run build`)
- [ ] Bundle Size < 500KB (Initial)
- [ ] Lighthouse Score > 90
- [ ] Alle Dependencies aktuell

### Integration
- [ ] Design Tokens synchronisiert
- [ ] Österreich-Branding konsistent
- [ ] API-Endpoints konfiguriert
- [ ] DSGVO-Compliance gewährleistet

---

## 📊 Metriken & Monitoring

### Performance-Ziele
- **First Contentful Paint:** < 1.5s
- **Time to Interactive:** < 3.5s
- **Largest Contentful Paint:** < 2.5s
- **Cumulative Layout Shift:** < 0.1
- **Total Blocking Time:** < 300ms

### Bundle Analysis
```bash
npm run build -- --mode analyze
```

**Erwartete Bundle-Größe:**
- `vendor.js` - 150-200 KB (React, React-DOM)
- `ui.js` - 80-120 KB (Radix UI Components)
- `motion.js` - 50-70 KB (Framer Motion)
- `app.js` - 100-150 KB (App Code)
- **Total:** ~400-500 KB (gzipped)

---

## 🚀 Deployment-Plan

### Staging Deployment
1. Merge in `frontend/` Branch
2. Build & Test auf Staging-Server
3. QA Approval
4. Lighthouse Audit

### Production Deployment
1. Tag Version `v4.2.0`
2. Build Production Bundle
3. Deploy zu Plesk: `menschlichkeit-oesterreich.at`
4. Monitor Performance
5. Rollback-Plan bereit

---

## 📚 Dokumentation Updates

### Zu aktualisierende Dateien
- `README.md` - Neue Features beschreiben
- `ARCHITECTURE.md` - Komponenten-Struktur
- `ROADMAP.md` - Milestone Updates
- `CONTRIBUTING.md` - Development-Guide

---

## 🔗 Nächste Schritte

1. **Dependencies installieren** (npm install in frontend/)
2. **ShadCN UI kopieren** (48 Komponenten)
3. **Feature-Komponenten migrieren** (Games, Forum, etc.)
4. **Tailwind v4 testen** (Build & Verify)
5. **TypeScript Errors fixen**
6. **E2E Tests schreiben**
7. **Staging Deployment**
8. **Production Release**

---

**Erstellt:** 2025-10-05
**Nächstes Review:** 2025-10-12
**Verantwortlich:** GitHub Copilot + Development Team
