# 🧠 AI-KONTEXT: Menschlichkeit Österreich
## Vollständige Projektdokumentation für GitHub Copilot & Figma AI

> **Version**: 2.0.0 | **Letzte Aktualisierung**: Oktober 2025 | **Status**: 🚀 Produktionsbereit

---

## 🇦🇹 PROJEKT-ÜBERSICHT

**Menschlichkeit Österreich** ist eine Enterprise-NGO-Plattform für soziale Gerechtigkeit in Österreich mit Multi-Service-Architektur.

### Mission & Ziele
- **Soziale Gerechtigkeit**: Förderung von Menschenrechten & Demokratie in Österreich
- **Demokratische Bildung**: Interaktive Lernspiele ("Brücken Bauen" mit 100+ Leveln)
- **Community-Engagement**: Forum, Events, Diskussionen
- **Transparente Verwaltung**: Admin-Dashboard, CRM-Integration (CiviCRM)
- **DSGVO-Compliance**: Vollständige Datenschutz-Konformität

### Zielgruppen
- **Primär**: Gemeinnützige Organisationen, NGOs, Bildungseinrichtungen
- **Sekundär**: Bürger*innen, Aktivist*innen, Demokratie-Interessierte
- **Bildung**: Schulklassen (ab 14 Jahren), Erwachsenenbildung

---

## 🏗️ SYSTEM-ARCHITEKTUR

### Service-Boundaries (Microservices-orientiert)

```
┌──────────────────────────────────────────────────────────────┐
│              MENSCHLICHKEIT ÖSTERREICH PLATFORM              │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 1. PUBLIC WEBSITE (WordPress/Static)               │    │
│  │    • Domain: menschlichkeit-oesterreich.at         │    │
│  │    • Öffentliche Inhalte, SEO, Marketing           │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 2. FRONTEND (React 18 + TypeScript + Vite)        │    │
│  │    • Member Area, Spenden, Forum                   │    │
│  │    • Design Token System (Tailwind v4.0 Sync)     │    │
│  │    • Democracy Games (100+ Level)                  │    │
│  │    • PWA-Features (Offline-fähig)                 │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 3. API SERVICE (FastAPI + Python)                 │    │
│  │    • REST API mit JWT Authentication               │    │
│  │    • CRM Bridge (CiviCRM Integration)             │    │
│  │    • HMAC-Webhook-Validierung                     │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 4. CRM SYSTEM (Drupal 10 + CiviCRM + MariaDB)    │    │
│  │    • Mitgliederverwaltung (DSGVO-konform)         │    │
│  │    • SEPA-Lastschrift-Verwaltung                  │    │
│  │    • Newsletter-Automation                         │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 5. GAMING PLATFORM (Prisma + PostgreSQL)          │    │
│  │    • Lernspiele-Backend (Fortschritt, Scores)     │    │
│  │    • Multiplayer-Koordination                      │    │
│  │    • Skill-System, Achievements                    │    │
│  └────────────────────────────────────────────────────┘    │
│                          ↓                                   │
│  ┌────────────────────────────────────────────────────┐    │
│  │ 6. AUTOMATION (n8n + Docker)                      │    │
│  │    • CRM ↔ API ↔ Frontend Workflows              │    │
│  │    • Automatische Sync-Prozesse                   │    │
│  │    • Event-Driven Architecture                     │    │
│  └────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Datenfluss

```
User → Frontend (React) → API (FastAPI) → Database (PostgreSQL)
                    ↓                           ↓
                  CRM (CiviCRM) ←─ n8n ←─ Webhooks (HMAC)
```

---

## 🛠️ TECH-STACK (Detailliert)

### Frontend Technologies
```typescript
{
  "framework": "React 18+",
  "build": "Vite",
  "language": "TypeScript (implicit .tsx)",
  "styling": "Tailwind CSS v4.0",
  "animations": "Motion/React (ehemals Framer Motion)",
  "ui-library": "shadcn/ui",
  "icons": "lucide-react",
  "charts": "recharts",
  "forms": "react-hook-form@7.55.0",
  "notifications": "sonner@2.0.3",
  "carousel": "react-slick",
  "state": "React Context (AppStateManager)"
}
```

### Backend & Infrastructure
```python
{
  "api": "FastAPI (Python)",
  "database": "PostgreSQL (Prisma ORM)",
  "crm": "Drupal 10 + CiviCRM + MariaDB",
  "automation": "n8n (Docker)",
  "deployment": "Plesk",
  "quality": "ESLint + Prettier + Lighthouse CI"
}
```

### KRITISCHE Import-Regeln

```typescript
// ✅ KORREKT - Motion Import
import { motion, AnimatePresence } from 'motion/react';

// ✅ KORREKT - React Hook Form mit VERSION
import { useForm } from 'react-hook-form@7.55.0';

// ✅ KORREKT - Toast mit VERSION
import { toast } from 'sonner@2.0.3';

// ✅ KORREKT - shadcn/ui
import { Button } from './components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './components/ui/card';

// ✅ KORREKT - Lucide Icons
import { Heart, Users, Trophy, Star } from 'lucide-react';

// ❌ FALSCH - Alte Framer Motion (NICHT VERWENDEN!)
import { motion } from 'framer-motion';

// ❌ FALSCH - Ohne Version bei required packages
import { useForm } from 'react-hook-form';
import { toast } from 'sonner';
```

---

## 🎨 DESIGN-SYSTEM

### Design Tokens (Quelle: Figma → Tailwind v4 Sync)

**Sync-Status**: ✅ Synchronisiert (Stand: 2025-09-26)
**Quelle**: `figma-design-system/00_design-tokens.json`
**Ziel**: `/styles/globals.css` (Tailwind v4.0 Custom Properties)

### Farbpalette

#### Brand Colors (Primary Identity)
```css
/* Hauptfarben - Menschlichkeit Österreich */
--brand-bootstrap-blue: #0d6efd;     /* Primär - Vertrauen, Aktion */
--brand-orange: #ff6b35;              /* Sekundär - Energie, Warmth */
--brand-red: #e63946;                 /* Highlight - Leidenschaft */
--brand-gradient: linear-gradient(135deg, #ff6b35 0%, #e63946 100%);

/* Österreich-Identität */
--brand-austria-red: #c8102e;         /* Österreich-Rot */
--brand-austria-white: #ffffff;       /* Österreich-Weiß */
```

#### Functional Colors
```css
/* Primary (Blau) - Vertrauen, Identität */
--primary: #0d6efd;                   /* Bootstrap Blue */
--primary-500: #0ea5e9;               /* Alternative (helleres Blau) */
--primary-foreground: #ffffff;
--primary-hover: #0056d6;
--primary-active: #004bb8;

/* Secondary (Orange-Red Gradient) */
--secondary: #ff6b35;
--secondary-500: #64748b;             /* Grau-Alternative */
--secondary-foreground: #ffffff;

/* Accent (Magenta) - Highlights, Calls-to-Action */
--accent: #f1f5f9;
--accent-500: #f472b6;
--accent-foreground: #334155;

/* States */
--success: #22c55e;                   /* Grün - Bestätigung */
--warning: #f59e0b;                   /* Orange - Vorsicht */
--error: #ef4444;                     /* Rot - Fehler */
--destructive: #dc2626;
```

### Typografie

**Fonts**:
- **Primary**: Inter (Sans-serif) → Standard-Text, UI-Elemente
- **Secondary**: Merriweather (Serif) → Überschriften, Editorial
- **Mono**: JetBrains Mono → Code-Snippets

**Font-Sizes** (4px Grid):
```css
--font-size: 16px;                    /* Base */
/* Heading Sizes */
h1: 3rem (48px)                       /* Hero, Hauptüberschriften */
h2: 2.25rem (36px)                    /* Section Headers */
h3: 1.875rem (30px)                   /* Subsections */
h4: 1.5rem (24px)                     /* Card Titles */
h5: 1.25rem (20px)
h6: 1.125rem (18px)

/* Body Sizes */
.lead: 1.25rem (20px)                 /* Intro-Text */
p: 1rem (16px)                        /* Standard Body */
.small: 0.875rem (14px)               /* Captions, Meta */
```

**Font-Weights**:
```css
--font-weight-light: 300;
--font-weight-normal: 400;
--font-weight-medium: 500;
--font-weight-semibold: 600;
--font-weight-bold: 700;
```

**Line-Heights**:
```css
h1-h3: 1.2-1.4                        /* Tight for headlines */
body: 1.7                             /* Optimal readability */
small: 1.5
```

**Letter-Spacing**:
```css
h1: -0.02em
h2: -0.015em
h3: -0.01em
button: 0.025em
```

### Spacing System (4px Grid)

```css
/* Standard Increments */
0: 0px
1: 4px
2: 8px
3: 12px
4: 16px                               /* Standard */
5: 20px
6: 24px
8: 32px                               /* Groß */
10: 40px
12: 48px
16: 64px                              /* Sehr groß */

/* Section Padding */
--section-padding: 5rem (80px)        /* Desktop */
--section-padding-lg: 7rem (112px)
--section-padding-sm: 3rem (48px)     /* Mobile */
```

### Border Radius

```css
--radius-sm: 0.5rem (8px)
--radius-md: 0.75rem (12px)           /* Standard */
--radius-lg: 1rem (16px)
--radius-xl: 1.5rem (24px)
--radius-full: 9999px                 /* Pills, Avatare */
```

### Shadows

```css
/* Card Shadows */
--card-shadow: 0 1px 3px 0 rgba(0,0,0,0.1), 0 1px 2px 0 rgba(0,0,0,0.06);
--card-shadow-lg: 0 10px 15px -3px rgba(0,0,0,0.1), 0 4px 6px -2px rgba(0,0,0,0.05);

/* Popover/Modal Shadows */
--popover-shadow: 0 20px 25px -5px rgba(0,0,0,0.1), 0 10px 10px -5px rgba(0,0,0,0.04);
```

### Animation Timings

```css
/* Durations */
--duration-fast: 150ms
--duration-normal: 300ms
--duration-slow: 500ms

/* Easing */
--easing: cubic-bezier(0.4, 0, 0.2, 1)  /* ease-out */
```

### Z-Index Stack

```css
--z-dropdown: 1000;
--z-sticky: 1020;
--z-fixed: 1030;
--z-modal-backdrop: 1040;
--z-modal: 1050;
--z-popover: 1060;
--z-tooltip: 1070;
```

### Breakpoints (Responsive)

```css
xs: 0px                               /* Mobile */
sm: 640px                             /* Large Mobile */
md: 768px                             /* Tablet */
lg: 1024px                            /* Desktop */
xl: 1280px                            /* Large Desktop */
2xl: 1536px                           /* Extra Large */
```

---

## 🧩 UI-KOMPONENTEN (shadcn/ui Library)

### Verfügbare Komponenten (`/components/ui/`)

**Layout & Navigation**:
- `card.tsx` - Karten-Container
- `navigation-menu.tsx` - Hauptnavigation
- `sidebar.tsx` - Seitenleiste
- `tabs.tsx` - Tab-Navigation
- `breadcrumb.tsx` - Breadcrumb-Navigation
- `pagination.tsx` - Seitennavigation
- `separator.tsx` - Trennlinien
- `accordion.tsx` - Ausklappbare Inhalte
- `collapsible.tsx` - Zusammenklappbare Bereiche

**Forms & Input**:
- `button.tsx` - Buttons
- `input.tsx` - Text-Eingabefelder
- `textarea.tsx` - Mehrzeilige Eingabe
- `select.tsx` - Dropdown-Auswahl
- `checkbox.tsx` - Checkboxen
- `radio-group.tsx` - Radio-Buttons
- `switch.tsx` - Toggle-Schalter
- `slider.tsx` - Schieberegler
- `form.tsx` - Formular-Wrapper
- `label.tsx` - Formular-Labels
- `calendar.tsx` - Datumsauswahl
- `input-otp.tsx` - OTP-Eingabe

**Feedback & Overlays**:
- `alert.tsx` - Benachrichtigungen
- `alert-dialog.tsx` - Bestätigungs-Dialog
- `dialog.tsx` - Modale Dialoge
- `sheet.tsx` - Slide-in Panel
- `drawer.tsx` - Drawer-Navigation
- `popover.tsx` - Popover-Overlay
- `tooltip.tsx` - Tooltips
- `hover-card.tsx` - Hover-Informationen
- `sonner.tsx` - Toast-Notifications
- `progress.tsx` - Fortschrittsbalken
- `skeleton.tsx` - Loading-Platzhalter

**Data Display**:
- `table.tsx` - Tabellen
- `chart.tsx` - Charts (Recharts-Integration)
- `badge.tsx` - Status-Badges
- `avatar.tsx` - Benutzer-Avatare
- `aspect-ratio.tsx` - Seitenverhältnis-Container

**Interactive**:
- `command.tsx` - Command-Palette
- `context-menu.tsx` - Rechtsklick-Menü
- `dropdown-menu.tsx` - Dropdown-Menü
- `menubar.tsx` - Menüleiste
- `toggle.tsx` - Toggle-Button
- `toggle-group.tsx` - Toggle-Gruppe
- `carousel.tsx` - Karussell
- `scroll-area.tsx` - Scroll-Container
- `resizable.tsx` - Größenveränderbarer Container

### WICHTIG: shadcn/ui-Regeln

```typescript
// ✅ KORREKT - Komponenten nutzen, NICHT modifizieren
import { Button } from './components/ui/button';

<Button variant="default">Aktion</Button>
<Button variant="destructive">Löschen</Button>
<Button variant="outline">Sekundär</Button>
<Button variant="ghost">Tertiär</Button>

// ❌ FALSCH - shadcn/ui Dateien NICHT ändern!
// Dateien in /components/ui/* sind GESCHÜTZT
```

### Custom Utility-Klassen (für shadcn/ui-Extensions)

```tsx
// Brand-Buttons (Custom Gradients)
<Button className="btn-primary-gradient">
  Mitglied werden
</Button>

<Button className="btn-secondary-gradient">
  Jetzt spenden
</Button>

// Enhanced Cards
<Card className="card-modern">
  <CardContent>Moderner Stil mit Hover</CardContent>
</Card>

<Card className="card-elevated">
  <CardContent>Erhöhte Karte mit starkem Shadow</CardContent>
</Card>

// Glassmorphismus
<div className="glass">
  Glassmorphismus Light
</div>

<div className="glass-dark">
  Glassmorphismus Dark
</div>
```

---

## 🎯 TYPOGRAFIE-REGELN (KRITISCH!)

### ⚠️ WICHTIGSTE REGEL: Keine Tailwind-Typografie-Klassen!

**NIEMALS** Tailwind-Klassen für Font-Size, Font-Weight oder Line-Height verwenden – **außer explizit vom Benutzer gefordert!**

```tsx
// ❌ ABSOLUT FALSCH
<h2 className="text-3xl font-bold leading-tight">Titel</h2>

// ✅ KORREKT - CSS-Defaults arbeiten lassen
<h2>Titel</h2>

// ✅ NUR bei expliziter Anforderung
<h2 className="text-4xl font-extrabold">
  Titel
</h2>
// ^ Nur wenn User sagt: "Mach die Überschrift größer/fetter"
```

### Begründung

Das Projekt hat ein vollständiges Typografie-System in `/styles/globals.css` definiert, das:
- Optimale Font-Sizes für alle HTML-Elemente
- Semantisch korrekte Font-Weights
- Perfekte Line-Heights für Lesbarkeit

Tailwind-Klassen würden diese sorgfältig abgestimmten Werte überschreiben!

### Typografie-Hierarchie (aus globals.css)

```css
h1: 3rem (48px) • bold • line-height: 1.2 • letter-spacing: -0.02em
h2: 2.25rem (36px) • semibold • line-height: 1.3 • letter-spacing: -0.015em
h3: 1.875rem (30px) • semibold • line-height: 1.4 • letter-spacing: -0.01em
h4: 1.5rem (24px) • medium • line-height: 1.4
h5: 1.25rem (20px) • medium • line-height: 1.5
h6: 1.125rem (18px) • medium • line-height: 1.5

p: 1rem (16px) • normal • line-height: 1.7
.lead: 1.25rem (20px) • normal • line-height: 1.6
.small: 0.875rem (14px) • normal • line-height: 1.5
```

---

## 📁 PROJEKT-STRUKTUR & KOMPONENTEN-ARCHITEKTUR

### Komponenten-Organisation

```
/components
├── ui/                          # shadcn/ui (PROTECTED - nicht ändern!)
│   ├── button.tsx
│   ├── card.tsx
│   ├── ... (60+ Components)
│
├── figma/                       # Figma-spezifische Komponenten
│   └── ImageWithFallback.tsx   # (PROTECTED)
│
├── [Feature].tsx                # Haupt-Feature-Komponenten
│   ├── About.tsx
│   ├── Hero.tsx
│   ├── Navigation.tsx
│   └── ...
│
└── [Subsystem]/                 # Komplexe Features mit Sub-Komponenten
    └── ... (bei Bedarf)
```

### Haupt-Komponenten (Aktueller Stand)

#### Public Pages
```typescript
Hero.tsx                  // Landing-Hero
About.tsx                 // Über uns
Themes.tsx                // Themenbereiche (Demokratie, Menschenrechte, etc.)
Forum.tsx                 // Community-Forum
Join.tsx                  // Mitgliedschafts-Formular
Donate.tsx                // Spenden-Seite
Events.tsx                // Event-Kalender
News.tsx                  // News/Blog
Contact.tsx               // Kontakt-Formular
Footer.tsx                // Footer
Navigation.tsx            // Hauptnavigation
```

#### Democracy Games System
```typescript
DemocracyGameHub.tsx              // Hub-Übersicht (2 Spielvarianten)
BridgeBuilding.tsx                // Klassisches 8-Level Game
BridgeBuilding100.tsx             // Vollversion: 100+ Level, 10 Kapitel
SkillTreeInterface.tsx            // Skill-System (12 Skills, 4 Kategorien)
AchievementGallery.tsx            // Achievement-Tracking (20+ Achievements)
MultiplayerLobby.tsx              // Multiplayer (3 Modi: Coop, Competitive, Classroom)

// Support-Komponenten
GameDataGenerator.tsx             // Level-Daten-Generator
Enhanced3DGameGraphics.tsx        // AAA-Level Graphics (Particles, 3D-Cards, etc.)
ImmersiveGameInterface.tsx        // Immersive UI (Fullscreen-Szenarien)
MinigameComponents.tsx            // Minigames (Fact-Check Arena, etc.)
AdvancedLevelVisualization.tsx    // WorldMap, Progress-Übersicht
GameGraphics.tsx                  // SVG-basierte Grafiken
LevelEditor.tsx                   // Level-Editor (Admin)
```

#### Admin & Management
```typescript
AdminDashboard.tsx        // Haupt-Admin-Dashboard
MemberManagement.tsx      // Mitgliederverwaltung
DonationManagement.tsx    // Spendenverwaltung
EventManagement.tsx       // Event-Verwaltung
NewsManagement.tsx        // News-Verwaltung
SepaManagement.tsx        // SEPA-Lastschrift
Moderation.tsx            // Forum-Moderation
AdminSettings.tsx         // Admin-Einstellungen
```

#### User Management & Security
```typescript
AppStateManager.tsx       // Globaler State (Context API)
AuthSystem.tsx            // Login/Register
UserProfile.tsx           // Benutzerprofil
PrivacyCenter.tsx         // DSGVO-Datenschutz-Center
SecurityDashboard.tsx     // Sicherheits-Dashboard
ModalManager.tsx          // Modal-Verwaltung
```

#### Integration & Utilities
```typescript
CivicrmIntegration.tsx    // CiviCRM-Integration
CommunityDashboard.tsx    // Community-Übersicht
PWAInstaller.tsx          // PWA-Installations-Prompt
```

### State Management (AppStateManager)

```typescript
import { useAppState } from './components/AppStateManager';

function MyComponent() {
  const {
    state,           // Global State
    updateUser,      // User updaten
    openModal,       // Modal öffnen
    logout,          // Logout
    // ... weitere Actions
  } = useAppState();

  // Verwendung
  if (state.isAuthenticated && state.user?.role === 'admin') {
    // Admin-Funktionen
  }
}
```

**State-Struktur**:
```typescript
interface AppState {
  isAuthenticated: boolean;
  user: User | null;
  modals: {
    auth: { isOpen: boolean; mode: 'login' | 'register' };
    profile: { isOpen: boolean };
    security: { isOpen: boolean };
    privacy: { isOpen: boolean };
  };
  preferences: {
    theme: 'light' | 'dark' | 'system';
    language: 'de-AT';
    notifications: boolean;
  };
}
```

---

## 🎮 DEMOCRACY GAMES SYSTEM (Detailliert)

### Übersicht

Das "Brücken Bauen" Democracy Game ist das Herzstück der Plattform mit:
- **2 Spielvarianten**: Klassisch (8 Level) + Vollversion (100+ Level)
- **AAA-Level Graphics**: 3D-Effekte, Particles, Holographische Badges
- **4 Demokratie-Kompetenzen**: Empathie, Menschenrechte, Partizipation, Zivilcourage
- **Multiplayer**: 3 Modi (Kooperativ, Kompetitiv, Klassenraum)
- **Skill-System**: 12 freischaltbare Skills mit 5 Upgrade-Leveln
- **Achievements**: 20+ Achievements in 5 Kategorien

### Komponenten-Hierarchie

```
DemocracyGameHub
├── BridgeBuilding (Klassisch)
│   └── 8 Szenarien
│
└── BridgeBuilding100 (Vollversion)
    ├── 10 Kapitel
    ├── 100+ Level
    ├── SkillTreeInterface
    ├── AchievementGallery
    ├── MultiplayerLobby
    ├── ImmersiveGameInterface
    └── Enhanced3DGameGraphics
```

### Enhanced 3D Graphics System

Alle Game-Komponenten nutzen das `Enhanced3DGameGraphics.tsx`-System:

```typescript
import {
  ParticleSystem,           // Partikel-Effekte (Konfetti, etc.)
  Advanced3DCard,           // 3D-Tilt Karten mit Glow
  DynamicBackground,        // Animierte Hintergründe
  AnimatedCounter,          // Smooth Zahlen-Animation
  HolographicBadge,         // Holographische Badges (Rarity-System)
  DemocracyWheel            // 360° Kompetenz-Rad
} from './components/Enhanced3DGameGraphics';

// Beispiel-Nutzung
<Advanced3DCard
  glowColor="#3b82f6"       // Hex-Farbe für Glow-Effekt
  tiltIntensity={8}         // Tilt-Stärke (1-10)
  depth={3}                 // 3D-Tiefe
  interactive={true}        // Interaktiv
>
  <CardContent>...</CardContent>
</Advanced3DCard>

<ParticleSystem
  count={30}                // Anzahl Partikel
  color="#3b82f6"          // Hex-Farbe
  size={4}                 // Pixel-Größe
  shape="star"             // circle | star | diamond | heart
  direction="radial"       // up | down | left | right | radial
  trigger={true}           // Boolean zum Auslösen
/>

<HolographicBadge
  icon={<Trophy />}
  title="Achievement Name"
  description="Beschreibung"
  rarity="legendary"       // common | rare | epic | legendary
  size="large"             // small | medium | large
/>
```

### Skill-System (12 Skills, 4 Kategorien)

**Kategorien**:
1. **Empathie** (3 Skills): Aktives Zuhören, Perspektiven-Karten, Kulturelle Brücke
2. **Menschenrechte** (3 Skills): Schnell-Fact-Check, Rechtshilfe-Kit, Verfassungsexperte
3. **Partizipation** (3 Skills): Bürgerforum, Koalitionsbau, Kampagnen-Meister
4. **Zivilcourage** (3 Skills): Whistleblower-Schutz, Gegenrede-Boost, Ziviler Ungehorsam

**Features**:
- Prerequisite-System (manche Skills erfordern andere)
- 5 Upgrade-Level pro Skill
- Skill-Punkte-Verwaltung pro Kategorie
- Detaillierte Skill-Beschreibungen + Vorteile

### Achievement-System (20+ Achievements, 5 Kategorien)

**Kategorien**:
1. **Story**: Erste Schritte, Kapitel-Abschlüsse, Halbzeit-Held*in, Democracy-Meister*in
2. **Skills**: Empathie-Expert*in, Rechte-Verteidiger*in, etc. (je 100 Punkte)
3. **Social**: Brückenbauer*in, Koalitionsbauer*in, Multiplayer-Meister*in
4. **Special**: Perfekte Wertung, Speed-Runner, Minigame-Meister*in, Boss-Bezwinger*in
5. **Mastery**: Skill-Tree komplett, Demokratie-Gelehrte*r, Demokratie-Visionär*in

**Rarity-System**:
- **Common** (Grau): Einfach zu erreichen
- **Rare** (Blau): Mittelschwer
- **Epic** (Lila): Schwer
- **Legendary** (Gold): Sehr selten, höchste Herausforderung

### Multiplayer-System (3 Modi)

**Modi**:
1. **Kooperativ**: Gemeinsame Entscheidungsfindung (max. 4 Spieler)
2. **Kompetitiv**: Wettbewerb um beste Scores (max. 6 Spieler)
3. **Klassenraum**: Bildungs-Modus für Schulklassen (max. 30 Spieler)

**Features**:
- Raum erstellen/beitreten mit Raum-Codes
- Eingebetteter Chat
- Ready-System
- Host-Controls (Kapitel, Schwierigkeit, Spielerzahl)
- Echtzeit-Status-Anzeige

### Datenstrukturen (Game-System)

```typescript
// Szenario
interface Scenario {
  id: number;
  title: string;
  description: string;
  situation: string;
  context: string;
  stakeholders: Stakeholder[];
  choices: Choice[];
  reflection: ReflectionData;
  realWorldConnection: string;
}

// Stakeholder
interface Stakeholder {
  id: string;
  name: string;
  role: string;
  motivation: string;
  concerns: string[];
  power: number;           // 1-10
  influence: number;       // 1-10
}

// Choice
interface Choice {
  id: number;
  text: string;
  shortTermConsequence: string;
  longTermConsequence: string;
  stakeholderReactions: StakeholderReaction[];
  scores: Scores;
  difficulty: number;
  ethicalDilemma?: string;
}

// 4 Demokratie-Kompetenzen
interface Scores {
  empathy: number;           // Empathie
  humanRights: number;       // Menschenrechte
  participation: number;     // Partizipation
  civilCourage: number;      // Zivilcourage
}
```

---

## ♿ ACCESSIBILITY (WCAG 2.1 Level AA - PFLICHT!)

### KRITISCHE Anforderungen

Alle Komponenten **MÜSSEN** folgende Accessibility-Standards erfüllen:

#### 1. Semantic HTML

```tsx
// ✅ KORREKT - Semantische Tags
<nav aria-label="Hauptnavigation">
  <ul role="list">
    <li><a href="#section">Link</a></li>
  </ul>
</nav>

<main id="main-content">
  <article>
    <header>
      <h1>Titel</h1>
    </header>
    <section>
      <h2>Untertitel</h2>
      <p>Inhalt</p>
    </section>
  </article>
</main>

// ❌ FALSCH - Nur divs
<div class="nav">
  <div class="list">
    <div class="item">Link</div>
  </div>
</div>
```

#### 2. ARIA-Labels & Roles

```tsx
// Icons IMMER mit aria-hidden + Text
<Heart className="w-5 h-5" aria-hidden="true" />
<span className="sr-only">Empathie-Punkte</span>

// Interaktive Elemente mit aria-label
<button
  onClick={handleClick}
  aria-label="Profil öffnen"
  aria-expanded={isOpen}
>
  <UserIcon />
</button>

// Live-Regions für dynamische Inhalte
<div
  role="status"
  aria-live="polite"
  aria-atomic="true"
>
  {statusMessage}
</div>
```

#### 3. Keyboard-Navigation

```tsx
<button
  onClick={handleClick}
  onKeyDown={(e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      handleClick();
    }
  }}
  aria-label="Beschreibender Text"
>
  Aktion
</button>

// Skip-Links
<a
  href="#main-content"
  className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 bg-primary text-primary-foreground px-4 py-2 rounded-md z-50"
>
  Zum Hauptinhalt springen
</a>
```

#### 4. Focus Management

```tsx
// Sichtbarer Focus-Ring (automatisch via globals.css)
<div
  tabIndex={0}
  className="focus:ring-2 focus:ring-primary focus:outline-none"
>
  Fokussierbares Element
</div>

// Focus-Trap in Modals
<Dialog>
  <DialogContent>
    {/* Focus bleibt im Modal */}
  </DialogContent>
</Dialog>
```

#### 5. Color Contrast (≥4.5:1)

```css
/* Alle Text-Farben im Design-System erfüllen WCAG AA */
--foreground: #1a202c;                /* auf weiß: 16.75:1 ✅ */
--foreground-muted: #4a5568;          /* auf weiß: 7.48:1 ✅ */
--primary: #0d6efd;                   /* auf weiß: 4.57:1 ✅ */
```

#### 6. Motion & Animation Accessibility

```tsx
// Motion wird automatisch reduziert bei prefers-reduced-motion
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.6 }}
  // CSS @media (prefers-reduced-motion: reduce) überschreibt
/>
```

**CSS in globals.css**:
```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

#### 7. Screen Reader Support

```tsx
// Visually hidden but available to screen readers
<span className="sr-only">
  Nur für Screen Reader sichtbar
</span>

// Skip repetitive content
<nav>
  <a href="#main-content" className="sr-only focus:not-sr-only">
    Skip to main content
  </a>
</nav>
```

#### 8. Touch Targets (≥44px)

```css
/* Alle interaktiven Elemente ≥44x44px */
.btn {
  min-height: 44px;
  min-width: 44px;
  padding: 0.5rem 1rem;
}
```

---

## 🚀 PERFORMANCE & OPTIMIZATION

### Code-Splitting & Lazy Loading

```typescript
import { lazy, Suspense } from 'react';

// Große Komponenten lazy laden
const AdminDashboard = lazy(() => import('./components/AdminDashboard'));
const BridgeBuilding100 = lazy(() => import('./components/BridgeBuilding100'));

// In Komponente
<Suspense fallback={<LoadingSkeleton />}>
  {isAdmin && <AdminDashboard />}
</Suspense>
```

### Motion Performance

```typescript
// ✅ KORREKT - Nur transform/opacity animieren
<motion.div
  animate={{
    x: 100,           // ✅ transform
    y: 50,            // ✅ transform
    scale: 1.2,       // ✅ transform
    rotate: 45,       // ✅ transform
    opacity: 0.5      // ✅ opacity
  }}
/>

// ❌ FALSCH - Layout-triggernde Animationen
<motion.div
  animate={{
    width: '100%',    // ❌ Layout reflow
    height: '100%',   // ❌ Layout reflow
    top: 100,         // ❌ Layout reflow
    left: 50          // ❌ Layout reflow
  }}
/>
```

### Image Optimization

```typescript
// IMMER ImageWithFallback für neue Bilder
import { ImageWithFallback } from './components/figma/ImageWithFallback';

<ImageWithFallback
  src="/path/to/image.jpg"
  alt="Beschreibung"
  className="w-full h-auto"
  loading="lazy"
/>

// Stock-Images via Unsplash-Tool
// (wird automatisch vom System verwendet)
```

### Performance-Ziele (Lighthouse)

```
Performance:       ≥90
Accessibility:     ≥90
Best Practices:    ≥95
SEO:               ≥90
```

---

## 🎯 CODING-STANDARDS

### TypeScript Conventions

```typescript
// Interfaces für Props
interface MyComponentProps {
  title: string;
  count?: number;            // Optional mit ?
  onAction: () => void;      // Callbacks mit "on" prefix
  children?: React.ReactNode;
}

// Function Components (bevorzugt)
export function MyComponent({
  title,
  count = 0,              // Default-Werte
  onAction,
  children
}: MyComponentProps) {
  // Component logic
}

// Export am Ende
export default MyComponent;
```

### Naming Conventions

```typescript
// PascalCase für Komponenten
export function UserProfile() {}
export function DemocracyGameHub() {}

// camelCase für Funktionen & Variablen
const handleSubmit = () => {};
const isAuthenticated = true;
const currentUser = null;

// UPPER_SNAKE_CASE für Konstanten
const MAX_RETRY_COUNT = 3;
const API_BASE_URL = 'https://api.example.com';
const DEFAULT_TIMEOUT = 5000;

// Prefixes für Event-Handlers
onClick={handleClick}
onChange={handleChange}
onSubmit={handleSubmit}
onSuccess={handleSuccess}
onError={handleError}
```

### Component Structure Template

```typescript
import React, { useState, useEffect, useCallback, useMemo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { Button } from './components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from './components/ui/card';
import { Heart, Users, Trophy } from 'lucide-react';

// 1. Types/Interfaces
interface MyComponentProps {
  title: string;
  onAction?: () => void;
}

// 2. Component
export function MyComponent({
  title,
  onAction
}: MyComponentProps) {
  // 3. State Hooks
  const [count, setCount] = useState(0);
  const [isLoading, setIsLoading] = useState(false);

  // 4. Effect Hooks
  useEffect(() => {
    // Side effects
  }, []);

  // 5. Event Handlers
  const handleClick = useCallback(() => {
    setCount(prev => prev + 1);
    onAction?.();
  }, [onAction]);

  // 6. Computed Values
  const computedValue = useMemo(() => {
    return count * 2;
  }, [count]);

  // 7. Render
  return (
    <div className="container mx-auto px-4">
      <Card className="card-modern">
        <CardHeader>
          <CardTitle>{title}</CardTitle>
        </CardHeader>
        <CardContent>
          <Button onClick={handleClick}>
            Count: {count}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}

// 8. Export
export default MyComponent;
```

---

## 🌍 INTERNATIONALIZATION (i18n)

### Sprache: Deutsch (Österreich)

```typescript
// IMMER deutsche Texte (österreichische Variante)
<h2>Willkommen bei Menschlichkeit Österreich</h2>

// Österreichische Ausdrücke bevorzugen
"Jänner" statt "Januar"
"heuer" statt "dieses Jahr"
"Matura" statt "Abitur"
"Topfen" statt "Quark"

// Formelle Ansprache (Sie/Ihnen)
"Melden Sie sich an"
"Ihre Daten sind sicher"

// Ausnahme: Game-Kontext (Du/Dir)
"Du hast 100 Punkte erreicht!"
"Deine Entscheidung hat Konsequenzen"
```

### Datum & Währung

```typescript
// Datum formatieren (de-AT)
const date = new Date().toLocaleDateString('de-AT', {
  day: '2-digit',
  month: '2-digit',
  year: 'numeric'
});
// Output: "01.10.2025"

// Zeit formatieren
const time = new Date().toLocaleTimeString('de-AT', {
  hour: '2-digit',
  minute: '2-digit'
});
// Output: "14:30"

// Währung formatieren (EUR)
const price = (100).toLocaleString('de-AT', {
  style: 'currency',
  currency: 'EUR'
});
// Output: "€ 100,00"
```

---

## 🛡️ COMPLIANCE & SECURITY

### DSGVO-Compliance

```typescript
// Consent-Management
<PrivacyCenter />           // DSGVO-Datenschutz-Center
<SecurityDashboard />       // Sicherheits-Dashboard

// Daten-Minimierung
// Nur notwendige Daten sammeln
interface UserProfile {
  id: string;
  email: string;
  name: string;
  // KEINE sensitiven Daten ohne Consent!
}

// Recht auf Vergessen
const handleDeleteAccount = async () => {
  // Alle User-Daten löschen
  await api.deleteUser(userId);
  // Audit-Log erstellen
  await api.logDeletion(userId, reason);
};

// Audit-Logging
// Alle wichtigen Aktionen loggen
await auditLog.create({
  action: 'USER_DATA_ACCESS',
  userId,
  timestamp: new Date(),
  ipAddress: request.ip
});
```

### Security Best Practices

```typescript
// JWT mit Auto-Refresh
const token = localStorage.getItem('jwt_token');
// Token-Rotation bei jeder Request
if (isTokenExpiringSoon(token)) {
  const newToken = await refreshToken();
  localStorage.setItem('jwt_token', newToken);
}

// XSS-Prevention
// React escaped automatisch, aber:
// ❌ NIEMALS dangerouslySetInnerHTML ohne Sanitization!
<div dangerouslySetInnerHTML={{ __html: userInput }} />  // ❌

// ✅ Nutze Library wie DOMPurify
import DOMPurify from 'dompurify';
<div dangerouslySetInnerHTML={{
  __html: DOMPurify.sanitize(userInput)
}} />

// CSRF-Protection
// API verwendet CSRF-Tokens
headers: {
  'X-CSRF-Token': csrfToken
}

// Content Security Policy (CSP)
// Headers vom Server gesetzt
```

---

## 📦 UTILITY-KLASSEN (Custom)

### Layout Utilities

```css
.section-padding          /* 5rem padding (3rem mobile) */
.section-padding-lg       /* 7rem padding (4rem mobile) */
.section-padding-sm       /* 3rem padding (2rem mobile) */
```

### Button Styles

```css
.btn-primary-gradient     /* Bootstrap Blue Gradient */
.btn-secondary-gradient   /* Orange-Red Gradient */
```

### Card Styles

```css
.card-modern              /* Modern card with hover */
.card-elevated            /* Elevated card with shadow-lg */
```

### Austria Branding

```css
.austria-border           /* Rot-Weiß-Rot Border */
```

### Glassmorphismus

```css
.glass                    /* Light glassmorphism */
.glass-dark               /* Dark glassmorphism */
```

### Text Utilities

```css
.text-gradient            /* Brand gradient text */
.text-balance             /* Balanced text wrapping */
.text-glow                /* Glowing text effect */
```

### Animation Utilities

```css
.animate-fade-in          /* Fade-in animation */
.animate-slide-up         /* Slide-up animation */
.animate-scale-in         /* Scale-in animation */
.floating-element         /* Floating animation */
```

### Game-Specific

```css
.democracy-pulse          /* Pulse for game elements */
.stakeholder-hover        /* Hover for stakeholder cards */
.level-card-hover         /* Hover for level cards */
.enhanced-3d-card         /* 3D-tilt effect */
.holographic-border       /* Holographic border effect */
.energy-pulse             /* Energy pulse animation */
.morphing-shape           /* Morphing shape animation */
.advanced-glow            /* Advanced glow effect */
```

---

## 🚨 HÄUFIGE FEHLER VERMEIDEN

### ❌ NICHT TUN:

```typescript
// 1. Falsche Motion-Imports
import { motion } from 'framer-motion';  // ❌ ALT!

// 2. Tailwind für Typography
<h2 className="text-3xl font-bold">   // ❌

// 3. Libraries ohne Version (wenn required)
import { useForm } from 'react-hook-form';  // ❌
import { toast } from 'sonner';             // ❌

// 4. shadcn/ui Komponenten modifizieren
// Dateien in /components/ui/* NICHT ändern!  // ❌

// 5. Accessibility ignorieren
<div onClick={handleClick}>Click me</div>   // ❌

// 6. Inline-Styles statt Tailwind
<div style={{ color: 'blue' }}>            // ❌

// 7. Performance-Killer (Layout-Animationen)
<motion.div animate={{ width: '100%' }}>   // ❌

// 8. Protected Files ändern
// /components/figma/ImageWithFallback.tsx   // ❌
// /components/ui/*                          // ❌
```

### ✅ STATTDESSEN:

```typescript
// 1. Korrekte Motion-Imports
import { motion, AnimatePresence } from 'motion/react';  // ✅

// 2. CSS-Defaults für Typography
<h2>Titel</h2>  // ✅

// 3. Libraries mit Version
import { useForm } from 'react-hook-form@7.55.0';  // ✅
import { toast } from 'sonner@2.0.3';              // ✅

// 4. shadcn/ui Komponenten nur nutzen
import { Button } from './components/ui/button';   // ✅

// 5. Accessibility first
<button
  onClick={handleClick}
  aria-label="Aktion"
  onKeyDown={handleKeyDown}
>
  Click me
</button>  // ✅

// 6. Tailwind-Klassen
<div className="text-blue-600">  // ✅

// 7. Performance-optimiert (nur transform/opacity)
<motion.div animate={{ x: 100, opacity: 1 }}>  // ✅

// 8. Protected Files NICHT ändern
// Nur konsumieren, nicht modifizieren  // ✅
```

---

## 🎨 FIGMA-SPEZIFISCHE ANWEISUNGEN

### Design-Token-Synchronisation

**Quelle**: Figma Design System
**Ziel**: `/styles/globals.css` (Tailwind v4.0)
**Frequenz**: Bei Design-Updates
**Status**: ✅ Synchronisiert (2025-09-26)

### Figma → Code Workflow

1. **Design Tokens exportieren** aus Figma
2. **Konvertieren** zu Tailwind v4 Custom Properties
3. **Sync** in `globals.css`
4. **Validieren** via Storybook/Lighthouse

### Figma Component Library

**Nutze vorhandene Komponenten**:
- Alle shadcn/ui-Komponenten sind in Figma verfügbar
- Nutze Figma-Varianten → mappt zu shadcn/ui-Varianten
- Neue Komponenten: erst in Figma designen, dann in React umsetzen

### Responsive Breakpoints (in Figma setzen)

```
Mobile:      375px  (xs)
Mobile-L:    640px  (sm)
Tablet:      768px  (md)
Desktop:     1024px (lg)
Desktop-L:   1280px (xl)
Desktop-XL:  1536px (2xl)
```

### 4px-Grid System

**ALLE Spacing-Werte MÜSSEN durch 4 teilbar sein**:
```
Spacing: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64, ...
```

### Touch-Targets (Figma Frames)

**Minimale Größe**: 44x44px (WCAG-konform)

### Accessibility in Figma

- **Kontrast-Checker** Plugin nutzen (≥4.5:1)
- **Semantic Naming** von Layers (Button, Input, Card, etc.)
- **Focus States** immer designen
- **Keyboard-Navigation** berücksichtigen

### Design-to-Code Handoff

**Layer-Naming Convention**:
```
ComponentName/Variant/State
Button/Primary/Default
Button/Primary/Hover
Button/Primary/Disabled
```

**Component Props in Figma** → React Props:
```
Figma:  variant="primary", size="large"
React:  <Button variant="primary" size="lg">
```

---

## 📋 WICHTIGE DATEIEN & KONFIGURATION

### Konfigurationsdateien

```
/styles/globals.css          # Tailwind v4 + Custom Properties
/App.tsx                     # Main Entry Point
/components/AppStateManager.tsx  # Global State
/guidelines/Guidelines.md    # Projekt-Guidelines
/.github/copilot-instructions.md  # Diese Datei
/package.json                # Dependencies
/eslint.config.js            # ESLint Config
/playwright-a11y.config.ts   # A11y Tests
/lighthouserc.json           # Lighthouse CI
```

### Protected Files (NICHT modifizieren!)

```
❌ /components/figma/ImageWithFallback.tsx
❌ /components/ui/*  (alle shadcn/ui Komponenten)
```

### Environment Variables (nicht im Repo!)

```bash
# API
VITE_API_URL=https://api.menschlichkeit-oesterreich.at
VITE_API_KEY=your_api_key_here

# CRM
VITE_CIVICRM_URL=https://crm.menschlichkeit-oesterreich.at
VITE_CIVICRM_KEY=your_civicrm_key

# Gaming
VITE_GAME_DB_URL=postgresql://...
```

---

## 📚 RESSOURCEN & DOKUMENTATION

### Externe Dokumentation

- **Motion**: https://motion.dev/
- **shadcn/ui**: https://ui.shadcn.com/
- **Tailwind v4**: https://tailwindcss.com/
- **Lucide Icons**: https://lucide.dev/
- **WCAG Guidelines**: https://www.w3.org/WAI/WCAG21/quickref/
- **React Hook Form**: https://react-hook-form.com/

### Interne Dokumentation

- **Guidelines**: `/guidelines/Guidelines.md`
- **Component Library**: Storybook (bei Bedarf)
- **API Docs**: API-Repository

---

## ✅ QUALITY ASSURANCE CHECKLISTE

### Vor jedem Commit:

- [ ] **TypeScript**: Keine Errors (`npm run type-check`)
- [ ] **ESLint**: Keine Errors (`npm run lint`)
- [ ] **Prettier**: Code formatiert
- [ ] **A11y**: WCAG 2.1 AA erfüllt
- [ ] **Responsive**: Mobile → Desktop getestet
- [ ] **Design Tokens**: Konsequent angewendet
- [ ] **Typography**: KEINE Tailwind-Klassen (außer explizit)
- [ ] **Motion**: Nur transform/opacity animiert
- [ ] **Performance**: Lighthouse ≥90 in allen Kategorien
- [ ] **Imports**: Versionen korrekt (react-hook-form@7.55.0, etc.)
- [ ] **Protected Files**: NICHT modifiziert

### Vor jedem Release:

- [ ] **Lighthouse CI**: Alle Tests bestanden
- [ ] **Playwright A11y**: Alle Tests bestanden
- [ ] **Security Audit**: `npm audit` ohne Critical Issues
- [ ] **DSGVO-Check**: Datenschutz-Compliance geprüft
- [ ] **Browser-Tests**: Chrome, Firefox, Safari, Edge
- [ ] **Mobile-Tests**: iOS Safari, Android Chrome
- [ ] **Performance**: Lighthouse ≥90
- [ ] **Accessibility**: Lighthouse ≥90
- [ ] **Best Practices**: Lighthouse ≥95
- [ ] **SEO**: Lighthouse ≥90

---

## 🚀 DEPLOYMENT-HINWEISE

### Build-Prozess

```bash
# Development
npm run dev

# Type-Check
npm run type-check

# Lint
npm run lint

# Build (Production)
npm run build

# Preview (nach Build)
npm run preview
```

### Deployment-Ziele

- **Plesk**: Hauptdeployment
- **CDN**: Static Assets (optional)
- **PWA**: Service Worker aktiviert

---

## 🎯 PROJEKT-PHILOSOPHIE

### Kernwerte

1. **Menschlichkeit**: User-zentriertes Design, Empathie, Inklusion
2. **Zugänglichkeit**: WCAG 2.1 AA Compliance, niemand wird ausgeschlossen
3. **Transparenz**: Open-Source-Ansatz, klare Kommunikation
4. **Bildung**: Demokratische Kompetenzen fördern
5. **Gemeinschaft**: Community-orientierte Features, Zusammenhalt

### Design-Prinzipien

1. **Mobile First**: Responsive Design von Anfang an
2. **Performance**: Schnelle Ladezeiten, optimierte Animationen
3. **Accessibility First**: Niemand wird ausgeschlossen
4. **Glassmorphismus**: Moderne, klare Ästhetik
5. **Österreich-Bezug**: Lokale Identität bewahren (Rot-Weiß-Rot)
6. **NGO-Professionalität**: Vertrauenswürdig, seriös, modern

---

## 💡 COPILOT-TIPPS

### Best Practices für AI-Assistenten

1. **Kontext nutzen**: Diese Datei als Referenz
2. **Design-System respektieren**: Tokens konsequent nutzen
3. **Accessibility prüfen**: WCAG 2.1 AA immer erfüllen
4. **Performance beachten**: Lighthouse-Metriken im Blick
5. **Code-Qualität**: TypeScript, ESLint, Prettier
6. **Dokumentation**: Code kommentieren (EN oder DE)
7. **Testing**: A11y-Tests schreiben

### Wenn Unsicherheit besteht:

- **Frage nach**: Lieber nachfragen als raten
- **Dokumentation lesen**: Links oben nutzen
- **Konsistenz prüfen**: Bestehenden Code als Vorbild
- **Accessibility prüfen**: axe DevTools nutzen
- **Performance messen**: Lighthouse lokal laufen lassen

---

**Viel Erfolg beim Coding! 🚀🇦🇹**

---

**Version**: 2.0.0
**Letzte Aktualisierung**: Oktober 2025
**Projekt**: Menschlichkeit Österreich
**Maintainer**: Development Team
**Lizenz**: [Projektspezifisch]
**Repository**: [GitHub-Link]

---

_Diese Datei wird automatisch von GitHub Copilot und Figma AI-Tools gelesen._
