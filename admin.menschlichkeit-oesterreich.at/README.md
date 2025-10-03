# Admin Portal - Menschlichkeit Österreich

> Next.js 14 Admin-Backend mit Figma Design System Integration

## 🚀 Schnellstart

```bash
# Dependencies installieren
npm install

# Development Server starten (Port 3001)
npm run dev

# Production Build
npm run build

# Production Server starten
npm start
```

## 📋 Features

### ✅ Implementiert

- **Design System Integration**
  - Figma Design Tokens über CSS Custom Properties
  - Tailwind CSS mit Admin-spezifischen Tokens
  - Österreichische Branding-Farben (Rot-Weiß-Rot)
  - WCAG AA konforme Farbkontraste

- **Layout System**
  - Responsive Sidebar (collapsible)
  - Top Navigation mit Suche
  - Organization Switcher
  - User Menu & Notifications

- **Dashboard Widgets**
  - GitHub CI Status Widget
  - Mitglieder-Übersicht
  - Forum Aktivität
  - Letzte Aktivitäten Feed

- **Accessibility**
  - Keyboard Navigation
  - ARIA Labels
  - Focus States (2px Ring)
  - Reduced Motion Support

### 🔜 Geplant (Phase 3 W2-W4)

- **Keycloak OIDC Integration**
  - JWT Middleware
  - Role-Based Access Control (RBAC)
  - Multi-Org Scoping

- **Daten-Integrationen**
  - Directus SDK (Mitglieder, Beiträge)
  - GitHub GraphQL API
  - Discourse REST API
  - n8n Webhook Triggers
  - Matomo Analytics

- **Weitere Komponenten**
  - Data Tables (Pagination, Sorting, RLS)
  - Form System (8 Input Types)
  - Modal & Toast System
  - Badge-Komponenten

## 🎨 Design Tokens

Die Admin-Portal-Tokens befinden sich in:
- **JSON**: `../figma-design-system/admin-portal-tokens.json`
- **CSS**: `../figma-design-system/styles/admin-portal.css`
- **Tailwind**: `tailwind.config.ts`

### Token-Update Workflow

```bash
# 1. Figma Design Tokens synchronisieren
npm run figma:sync

# 2. Admin Portal CSS generieren
npm run admin:tokens

# 3. Build testen
npm run build
```

## 📁 Projektstruktur

```
admin.menschlichkeit-oesterreich.at/
├── app/
│   ├── layout.tsx          # Root Layout (Sidebar + Topbar)
│   └── page.tsx            # Dashboard Page
├── components/
│   ├── Sidebar.tsx         # Navigation Sidebar
│   ├── Topbar.tsx          # Top Navigation
│   └── widgets/
│       ├── CIStatusWidget.tsx
│       └── MembersWidget.tsx
├── lib/                    # Utilities & Services
├── styles/
│   └── globals.css         # Global Styles + Design Tokens Import
├── next.config.js          # Next.js Config
├── tailwind.config.ts      # Tailwind + Design Tokens
└── tsconfig.json           # TypeScript Config
```

## 🔧 Konfiguration

### Environment Variables

Erstelle `.env.local`:

```env
# Keycloak OIDC (TODO)
NEXTAUTH_URL=http://localhost:3001
NEXTAUTH_SECRET=your-secret-here
KEYCLOAK_ID=admin-portal
KEYCLOAK_SECRET=your-keycloak-secret
KEYCLOAK_ISSUER=https://auth.menschlichkeit-oesterreich.at/realms/main

# Directus API (TODO)
NEXT_PUBLIC_DIRECTUS_URL=https://control.menschlichkeit-oesterreich.at
DIRECTUS_TOKEN=your-directus-token

# n8n Webhooks (TODO)
N8N_WEBHOOK_BASE_URL=https://automation.menschlichkeit-oesterreich.at
```

## 🧪 Testing

```bash
# Linting
npm run lint

# Type Check
npm run type-check

# E2E Tests (TODO)
npm run test:e2e

# Accessibility Tests (TODO)
npm run test:a11y
```

## 📚 Dokumentation

- **Architektur**: `../docs/ADMIN-FIGMA-INTEGRATION.md`
- **Design System**: `../figma-design-system/DESIGN-SYSTEM.md`
- **Roadmap**: `../docs/FOCUS.md` (Phase 3)

## 🚢 Deployment

### Plesk Deployment

```bash
# Production Build
npm run build

# Deploy to Plesk (TODO)
npm run deploy:admin
```

### Docker (TODO)

```bash
# Build Image
docker build -t admin-portal .

# Run Container
docker run -p 3001:3001 admin-portal
```

## 📊 Quality Gates

| Metrik                     | Ziel   | Status |
| -------------------------- | ------ | ------ |
| **WCAG AA Compliance**     | 100%   | ✅     |
| **Design Token Drift**     | 0%     | ✅     |
| **Lighthouse Performance** | ≥90    | 🔄     |
| **Bundle Size**            | <200KB | 🔄     |
| **TypeScript Errors**      | 0      | ✅     |

## 🤝 Contributing

Siehe [`../CONTRIBUTING.md`](../CONTRIBUTING.md) für Guidelines.

## 📝 License

MIT © Menschlichkeit Österreich
