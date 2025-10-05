# 🇦🇹 Menschlichkeit Österreich

> **Gemeinnütziger Verein für soziale Gerechtigkeit, Menschenrechte und demokratische Bildung**

[![Version](https://img.shields.io/badge/version-4.0.0-blue.svg)](https://github.com/menschlichkeit-oesterreich/website)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![PWA](https://img.shields.io/badge/PWA-enabled-orange.svg)](https://menschlichkeit-oesterreich.at)
[![Accessibility](https://img.shields.io/badge/WCAG-2.1%20AA-brightgreen.svg)](https://www.w3.org/WAI/WCAG21/quickref/)

---

## 📋 Inhaltsverzeichnis

- [Über das Projekt](#-über-das-projekt)
- [Features](#-features)
- [Technologie-Stack](#-technologie-stack)
- [Quick Start](#-quick-start)
- [Entwicklung](#️-entwicklung)
- [Deployment](#-deployment)
- [Projektstruktur](#-projektstruktur)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🎯 Über das Projekt

**Menschlichkeit Österreich** ist eine moderne, barrierefreie Web-Plattform für einen gemeinnützigen Verein, der sich für soziale Gerechtigkeit und demokratische Bildung in Österreich einsetzt.

### 🌟 Highlights

- **🎮 Democracy Games**: Interaktive Lernspiele mit 100+ Leveln
- **💬 Community Forum**: Aktive Community mit Moderation
- **📅 Event-Management**: Workshops, Demos und Aktionen
- **💝 Spenden-System**: SEPA-Integration für Österreich
- **🔐 DSGVO-konform**: Privacy-Center und Cookie-Consent
- **📱 Mobile-First**: Touch-optimiert und PWA-fähig
- **🌓 Dark Mode**: Vollständig implementiert

---

## ✨ Features

### 🎨 Design & UX

- ✅ **Modern Glassmorphismus-Design** mit Brand-Gradient
- ✅ **Responsive**: Mobile-First für alle Devices
- ✅ **Accessibility**: WCAG 2.1 AA konform
- ✅ **Dark Mode**: Light/Dark/System
- ✅ **Smooth Animations**: Motion/React Animationen
- ✅ **Touch-Optimierung**: Min. 44px Touch-Targets

### 🎮 Democracy Games

- ✅ **Brücken Bauen Classic**: 8 Szenarien (20-30 Min)
- ✅ **Democracy Metaverse**: 100+ Level, 10 Kapitel
- ✅ **Skill-System**: 12 demokratische Kompetenzen
- ✅ **Achievements**: 20+ freischaltbare Erfolge
- ✅ **Multiplayer**: 3 Modi (Coop, Competitive, Classroom)
- ✅ **Enhanced 3D Graphics**: Particles, 3D-Cards, Holographic
- ✅ **Immersive Interface**: Fullscreen-Modus
- ✅ **Level-Editor**: Admin-Tool für Custom-Levels

### 💬 Community

- ✅ **Forum-System**: Boards, Threads, Posts
- ✅ **Moderation**: Report-System, Admin-Dashboard
- ✅ **Events**: Kalender mit RSVP
- ✅ **News**: CMS für Artikel
- ✅ **User-Profile**: Avatare, Badges, Stats

### 🔐 Security & Privacy

- ✅ **Auth-System**: Login, Register, 2FA
- ✅ **DSGVO**: Cookie-Consent, Privacy-Center
- ✅ **Security-Dashboard**: Session-Management, Audit-Log
- ✅ **SEPA-Compliance**: Österreichische Standards
- ✅ **Data-Minimierung**: Privacy by Design

### ⚡ Performance

- ✅ **Lazy Loading**: Code-Splitting für große Komponenten
- ✅ **PWA**: Service Worker + Offline-Support
- ✅ **SEO**: Meta-Tags, Structured Data, Sitemap
- ✅ **Lighthouse Score**: ≥90 in allen Kategorien
- ✅ **Bundle-Optimierung**: Gzip + Brotli Compression

### 🛠️ Developer Experience

- ✅ **TypeScript**: Type-Safe
- ✅ **Tailwind CSS v4**: Utility-First
- ✅ **shadcn/ui**: 48 UI-Komponenten
- ✅ **Vite**: Lightning-Fast HMR
- ✅ **ESLint**: Code-Quality
- ✅ **Playwright**: A11y-Tests

---

## 🚀 Technologie-Stack

### Frontend

| Technologie | Version | Verwendung |
|-------------|---------|------------|
| **React** | 18.3+ | UI-Framework |
| **TypeScript** | 5.0+ | Type-Safety |
| **Tailwind CSS** | 4.0 | Styling |
| **Motion/React** | Latest | Animationen |
| **Vite** | 5.0+ | Build-Tool |
| **shadcn/ui** | Latest | UI-Komponenten |
| **Lucide-React** | Latest | Icons |
| **Recharts** | Latest | Charts |

### Libraries

| Library | Verwendung |
|---------|------------|
| `sonner` | Toast-Notifications |
| `react-hook-form` | Formulare |
| `react-slick` | Carousels |
| `react-responsive-masonry` | Masonry-Grids |
| `react-dnd` | Drag & Drop |

### Development

| Tool | Verwendung |
|------|------------|
| **ESLint** | Code-Linting |
| **Playwright** | A11y-Testing |
| **Lighthouse** | Performance-Audit |

---

## 🚀 Quick Start

### Voraussetzungen

- Node.js ≥18.0.0
- npm ≥9.0.0

### Installation

```bash
# Repository klonen
git clone https://github.com/menschlichkeit-oesterreich/website.git
cd website

# Dependencies installieren
npm install

# Development-Server starten
npm run dev
```

Die Anwendung läuft jetzt auf [http://localhost:3000](http://localhost:3000)

---

## 🛠️ Entwicklung

### Available Scripts

```bash
# Development-Server (mit HMR)
npm run dev

# Type-Check (ohne Build)
npm run type-check

# Linting
npm run lint

# Production-Build
npm run build

# Build-Preview
npm run preview

# Lighthouse-Audit
npm run lighthouse

# A11y-Tests
npm run test:a11y
```

### Wichtige Dateien

- `.github/copilot-instructions.md` - Vollständiger AI-Kontext (60+ KB)
- `guidelines/Guidelines.md` - Coding-Guidelines
- `INTEGRATION_GUIDE.md` - Integration-Anleitungen
- `DEBUG_REPORT.md` - Debug-Informationen
- `PROJECT_STATUS.md` - Projekt-Status

### Coding-Standards

- ✅ **TypeScript-First**: Alle Komponenten in `.tsx`
- ✅ **Mobile-First**: Responsive Design
- ✅ **Accessibility-First**: WCAG 2.1 AA
- ✅ **Component-Based**: Kleine, wiederverwendbare Komponenten
- ✅ **No inline-styles**: Tailwind-Utility-Classes

### Component-Struktur

```
/components
├── /ui              # shadcn/ui Komponenten (48)
├── /figma           # Figma-Import-Utils
├── Hero.tsx         # Landing-Section
├── About.tsx        # Über uns
├── Themes.tsx       # Schwerpunkte
├── DemocracyGameHub.tsx  # Game-Hub
├── BridgeBuilding.tsx    # 8-Level Game
├── BridgeBuilding100.tsx # 100-Level Game
├── Forum.tsx        # Community-Forum
├── Events.tsx       # Event-Kalender
├── AdminDashboard.tsx    # Admin-Panel
└── ...              # Weitere Komponenten
```

---

## 📦 Deployment

### Build erstellen

```bash
npm run build
```

Der Build wird im `dist/` Ordner erstellt.

### Plesk-Deployment

1. **Build hochladen**:
   ```bash
   # Upload dist/ Inhalt zu Plesk
   ```

2. **Server-Konfiguration**:
   - HTTPS erzwingen
   - Service Worker aktivieren (`/sw.js`)
   - Headers setzen (CSP, HSTS)
   - Gzip/Brotli Compression aktivieren

3. **Post-Deployment**:
   - Lighthouse-Check
   - Cross-Browser-Testing
   - Mobile-Device-Testing

### Environment-Variablen

```env
# .env.production
VITE_API_URL=https://api.menschlichkeit-oesterreich.at
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## 📂 Projektstruktur

```
menschlichkeit-oesterreich/
├── public/
│   ├── manifest.json         # PWA Manifest
│   ├── sw.js                 # Service Worker
│   ├── robots.txt            # SEO
│   ├── sitemap.xml           # SEO
│   └── ...                   # Assets
├── components/
│   ├── ui/                   # shadcn/ui (48)
│   ├── figma/                # Figma-Utils
│   ├── Navigation.tsx        # Sticky-Nav
│   ├── Hero.tsx              # Landing
│   ├── DemocracyGameHub.tsx  # Games
│   ├── Forum.tsx             # Community
│   ├── AdminDashboard.tsx    # Admin
│   └── ...                   # 56 Komponenten
├── styles/
│   └── globals.css           # Global Styles (2500+ Zeilen)
├── guidelines/
│   └── Guidelines.md         # Coding-Guidelines
├── .github/
│   ├── copilot-instructions.md  # AI-Kontext
│   └── workflows/            # CI/CD
├── App.tsx                   # Root-Komponente
├── vite.config.ts            # Vite-Config
├── tsconfig.json             # TypeScript-Config
├── tailwind.config.js        # Tailwind v4
├── package.json              # Dependencies
└── README.md                 # Diese Datei
```

---

## 🎨 Design-System

### Farben

```css
/* Brand Colors */
--brand-gradient: linear-gradient(135deg, #ff6b35 0%, #f7931e 50%, #ffc947 100%);
--brand-bootstrap-blue: #0d6efd;

/* Primary (Bootstrap Blue) */
--primary: hsl(217, 91%, 60%);
--primary-foreground: hsl(0, 0%, 100%);

/* Dark Mode */
.dark {
  --background: hsl(222, 47%, 11%);
  --foreground: hsl(210, 40%, 98%);
  /* ... */
}
```

### Typography

```css
/* Fonts */
--font-sans: 'Inter', system-ui, sans-serif;
--font-serif: 'Merriweather', Georgia, serif;
--font-mono: 'JetBrains Mono', monospace;

/* Sizes (responsive) */
h1: 2rem → 3rem (mobile → desktop)
h2: 1.75rem → 2.25rem
```

### Spacing

```css
/* 4px Grid-System */
--spacing-xs: 0.25rem;  /* 4px */
--spacing-sm: 0.5rem;   /* 8px */
--spacing-md: 1rem;     /* 16px */
--spacing-lg: 1.5rem;   /* 24px */
--spacing-xl: 2rem;     /* 32px */
```

---

## 🧪 Testing

### Accessibility-Tests

```bash
npm run test:a11y
```

Tests prüfen:
- ✅ Keyboard-Navigation
- ✅ Screen-Reader-Support
- ✅ Color-Contrast (≥4.5:1)
- ✅ Touch-Targets (≥44px)
- ✅ ARIA-Labels
- ✅ Focus-Management

### Performance-Tests

```bash
npm run lighthouse
```

Lighthouse prüft:
- ✅ Performance (≥90)
- ✅ Accessibility (≥90)
- ✅ Best Practices (≥95)
- ✅ SEO (≥90)
- ✅ PWA (Installable)

---

## 📈 SEO-Optimierung

### Meta-Tags

```tsx
<SEOHead
  title="Menschlichkeit Österreich"
  description="Gemeinnütziger Verein für soziale Gerechtigkeit..."
  keywords="Menschenrechte, Demokratie, Österreich, NGO"
  image="https://menschlichkeit-oesterreich.at/og-image.jpg"
/>
```

### Structured Data

```json
{
  "@context": "https://schema.org",
  "@type": "NGO",
  "name": "Menschlichkeit Österreich",
  "url": "https://menschlichkeit-oesterreich.at",
  "logo": "...",
  "address": { ... },
  "contactPoint": { ... }
}
```

### Sitemap

- ✅ `/sitemap.xml` - Alle wichtigen Seiten
- ✅ `/robots.txt` - Crawler-Regeln
- ✅ Canonical-URLs

---

## 🔐 Security

### DSGVO-Compliance

- ✅ **Cookie-Consent**: 4 Kategorien (Necessary, Functional, Analytics, Marketing)
- ✅ **Privacy-Center**: User-Daten-Export, Löschen
- ✅ **Transparent**: Klare Datenschutzerklärung
- ✅ **Opt-In**: Explizite Zustimmung

### Security-Features

- ✅ **HTTPS**: SSL/TLS erzwungen
- ✅ **CSP**: Content-Security-Policy Headers
- ✅ **HSTS**: Strict-Transport-Security
- ✅ **No Secrets im Code**: Environment-Variablen
- ✅ **XSS-Prevention**: React-Standard
- ✅ **CSRF**: Token-basiert (API)

---

## 🤝 Contributing

Wir freuen uns über Contributions! Bitte beachte:

1. Fork das Repository
2. Erstelle einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Committe deine Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Pushe zum Branch (`git push origin feature/AmazingFeature`)
5. Öffne einen Pull Request

### Contribution-Guidelines

- ✅ Folge den Coding-Standards in `guidelines/Guidelines.md`
- ✅ Schreibe Tests für neue Features
- ✅ Dokumentiere neue Komponenten
- ✅ Accessibility immer beachten (WCAG 2.1 AA)
- ✅ Mobile-First entwickeln

---

## 📄 License

Dieses Projekt ist lizenziert unter der MIT License - siehe die [LICENSE](LICENSE) Datei für Details.

---

## 👥 Team

**Menschlichkeit Österreich** - Gemeinnütziger Verein

- Website: [https://menschlichkeit-oesterreich.at](https://menschlichkeit-oesterreich.at)
- Email: kontakt@menschlichkeit-oesterreich.at
- GitHub: [@menschlichkeit-oesterreich](https://github.com/menschlichkeit-oesterreich)

---

## 🙏 Danksagungen

- [React](https://react.dev) - UI-Framework
- [Tailwind CSS](https://tailwindcss.com) - Styling
- [shadcn/ui](https://ui.shadcn.com) - UI-Komponenten
- [Motion](https://motion.dev) - Animationen
- [Vite](https://vitejs.dev) - Build-Tool
- [Unsplash](https://unsplash.com) - Stock-Images

---

## 📞 Support

Bei Fragen oder Problemen:

- 📧 Email: kontakt@menschlichkeit-oesterreich.at
- 💬 GitHub Issues: [Issues](https://github.com/menschlichkeit-oesterreich/website/issues)
- 📖 Dokumentation: `/guidelines` Ordner

---

<div align="center">

**Gemacht mit ❤️ für eine menschlichere Gesellschaft in Österreich** 🇦🇹

[Website](https://menschlichkeit-oesterreich.at) • [GitHub](https://github.com/menschlichkeit-oesterreich) • [Kontakt](mailto:kontakt@menschlichkeit-oesterreich.at)

</div>
