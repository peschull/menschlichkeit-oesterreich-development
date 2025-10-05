# 🏗️ Architektur-Dokumentation - Menschlichkeit Österreich v4.2.0

## 📋 Übersicht

Dieses Dokument beschreibt die **verbesserte Architektur** und **Code-Organisation** des Projekts.

---

## 🎯 **Architektur-Prinzipien**

### **1. Separation of Concerns**
- Komponenten, Logik, Styles und Daten sind klar getrennt
- Jede Datei hat eine spezifische Verantwortung
- Business Logic ist von UI-Komponenten entkoppelt

### **2. DRY (Don't Repeat Yourself)**
- Wiederverwendbare Hooks, Utils und Komponenten
- Zentralisierte Konfiguration und Constants
- Typ-sichere Helper-Funktionen

### **3. SOLID-Prinzipien**
- Single Responsibility: Jede Komponente/Hook hat einen Zweck
- Open/Closed: Erweiterbar ohne Modifikation
- Dependency Inversion: Abhängigkeiten durch Interfaces

### **4. Type-Safety First**
- TypeScript für alle Dateien
- Zentralisierte Type-Definitionen
- Strikte Type-Checking

---

## 📁 **Neue Ordnerstruktur**

```
/src
├── /hooks              # Custom React Hooks
│   ├── usePerformanceMonitoring.ts
│   ├── useOnlineStatus.ts
│   ├── usePrefetch.ts
│   └── ...
├── /types              # TypeScript Type Definitions
│   └── index.ts        # Zentrale Types
├── /config             # Configuration & Constants
│   └── constants.ts    # App-weite Constants
├── /utils              # Utility Functions
│   ├── storage.ts      # LocalStorage Wrapper
│   ├── format.ts       # Formatting Utilities
│   ├── validation.ts   # Validation Helpers
│   └── ...
├── /services           # API & External Services
│   ├── api.ts          # API Client
│   ├── auth.ts         # Authentication Service
│   └── ...
├── /contexts           # React Context Providers
│   ├── AppContext.tsx  # Global App State
│   └── ...
├── /components         # React Components (unverändert)
│   ├── ...
│   └── ui/             # ShadCN UI Components
├── /styles             # Global Styles
│   └── globals.css     # Tailwind + Custom Styles
├── App.tsx             # Main App Component (verbessert)
└── main.tsx            # Entry Point
```

---

## 🎣 **Custom Hooks**

### **1. usePerformanceMonitoring**

**Purpose:** Trackt Web Vitals (LCP, FID, CLS) automatisch

**Usage:**
```tsx
import { usePerformanceMonitoring } from './hooks/usePerformanceMonitoring';

function App() {
  usePerformanceMonitoring(); // Aktiviert Monitoring
}
```

**Features:**
- ✅ Trackt LCP (Largest Contentful Paint)
- ✅ Trackt FID (First Input Delay)
- ✅ Trackt CLS (Cumulative Layout Shift)
- ✅ Optional: Google Analytics Integration
- ✅ Fail-safe (läuft auch ohne PerformanceObserver)

---

### **2. useOnlineStatus**

**Purpose:** Erkennt Online/Offline-Status automatisch

**Usage:**
```tsx
import { useOnlineStatus } from './hooks/useOnlineStatus';

function App() {
  const isOnline = useOnlineStatus();

  if (!isOnline) {
    return <OfflineMessage />;
  }
}
```

**Features:**
- ✅ Real-time Online/Offline Detection
- ✅ Event-basiert (window.online/offline)
- ✅ SSR-safe (prüft navigator.onLine)

---

### **3. usePrefetch**

**Purpose:** Prefetcht Components im Idle-Time

**Usage:**
```tsx
import { usePrefetch, prefetchCriticalComponents } from './hooks/usePrefetch';

function App() {
  // Prefetch häufig besuchte Components
  usePrefetch(prefetchCriticalComponents());
}
```

**Features:**
- ✅ Nutzt requestIdleCallback (optimal)
- ✅ Fallback zu setTimeout
- ✅ Silent fail (Prefetch ist optional)
- ✅ Helper-Funktionen für kritische Components

---

## 🔧 **Utils**

### **1. Storage Utils** (`/src/utils/storage.ts`)

**Purpose:** Type-safe LocalStorage Wrapper

**Usage:**
```tsx
import { storage } from './utils/storage';

// Get
const user = storage.get<User>('USER_DATA');

// Set
storage.set('USER_DATA', userData);

// Remove
storage.remove('USER_DATA');

// Clear all
storage.clear();

// Check existence
if (storage.has('AUTH_TOKEN')) {
  // ...
}
```

**Features:**
- ✅ Type-safe mit generics
- ✅ JSON serialization automatisch
- ✅ Error handling built-in
- ✅ Key-basiert auf STORAGE_KEYS enum

---

### **2. Format Utils** (`/src/utils/format.ts`)

**Purpose:** Formatting-Helper für Daten, Zahlen, Strings

**Usage:**
```tsx
import { formatDate, formatNumber, formatString } from './utils/format';

// Dates
formatDate.short(new Date());          // "03.10.2025"
formatDate.long(new Date());           // "3. Oktober 2025"
formatDate.relative(new Date());       // "heute um 14:30"
formatDate.distance(new Date());       // "vor 2 Stunden"

// Numbers
formatNumber.default(1234567);         // "1.234.567"
formatNumber.currency(99.99);          // "99,99 €"
formatNumber.percentage(0.75);         // "75 %"
formatNumber.compact(1500000);         // "1,5 Mio."
formatNumber.fileSize(1024 * 1024);    // "1 MB"

// Strings
formatString.truncate("Long text...", 20);
formatString.capitalize("hello");      // "Hello"
formatString.titleCase("hello world"); // "Hello World"
formatString.slug("Hello World!");     // "hello-world"
formatString.initials("Max Mustermann"); // "MM"
```

**Features:**
- ✅ Lokalisierung (de-AT)
- ✅ date-fns Integration
- ✅ Intl API für Zahlen/Currency
- ✅ String-Manipulationen

---

## 📦 **Types** (`/src/types/index.ts`)

### **Zentrale Type-Definitionen:**

```tsx
// User & Authentication
export interface User {
  id: string;
  email: string;
  name: string;
  role: 'user' | 'moderator' | 'admin';
}

// App State
export interface AppState {
  isAuthenticated: boolean;
  user: User | null;
  modal: ModalState;
  notifications: Notification[];
  theme: 'light' | 'dark' | 'system';
}

// Game Types
export interface Scenario { ... }
export interface Choice { ... }
export interface Stakeholder { ... }
export interface Skill { ... }
export interface Achievement { ... }

// Forum Types
export interface ForumBoard { ... }
export interface ForumThread { ... }
export interface ForumPost { ... }

// API Types
export interface ApiResponse<T> { ... }
export interface PaginationParams { ... }

// ... und viele mehr
```

**Features:**
- ✅ Vollständige Type-Coverage
- ✅ Generics für wiederverwendbare Types
- ✅ Utility Types (Nullable, Optional, DeepPartial)
- ✅ Enum-ähnliche Konstanten

---

## ⚙️ **Config** (`/src/config/constants.ts`)

### **Zentralisierte Konfiguration:**

```tsx
// App Info
export const APP_NAME = 'Verein Menschlichkeit Österreich';
export const APP_VERSION = '4.1.0';

// URLs
export const SITE_URL = 'https://menschlichkeit-oesterreich.at';
export const API_URL = process.env.VITE_API_URL || '/api';

// Contact
export const CONTACT_EMAIL = 'kontakt@menschlichkeit-oesterreich.at';
export const SOCIAL_LINKS = { ... };

// Theme
export const BRAND_COLORS = { ... };
export const THEME_OPTIONS = ['light', 'dark', 'system'] as const;

// Storage Keys
export const STORAGE_KEYS = {
  AUTH_TOKEN: 'menschlichkeit_auth_token',
  USER_DATA: 'menschlichkeit_user_data',
  // ...
} as const;

// Validation
export const VALIDATION_RULES = { ... };

// Game Config
export const GAME_CONFIG = { ... };

// Feature Flags
export const FEATURES = {
  ENABLE_ANALYTICS: true,
  ENABLE_MULTIPLAYER: true,
  // ...
} as const;

// Error/Success Messages
export const ERROR_MESSAGES = { ... };
export const SUCCESS_MESSAGES = { ... };
```

**Features:**
- ✅ Zentrale Config für gesamte App
- ✅ Environment-Variable-Support
- ✅ Type-safe Constants
- ✅ Feature Flags
- ✅ Keine Magic Strings im Code

---

## 🏗️ **Verbessertes App.tsx**

### **Neue Struktur:**

```tsx
// 1. Imports organisiert
import { /* React */ } from 'react';
import { /* Components */ } from './components/...';
import { /* Hooks */ } from './hooks/...';
import { /* Config */ } from './config/...';

// 2. Lazy Loading
const Component = lazy(() => import('./Component'));

// 3. Sub-Components (besser strukturiert)
const LoadingFallback = ({ text }) => <motion.div>...</motion.div>;
const OfflineIndicator = ({ isOnline }) => <AnimatePresence>...</AnimatePresence>;
const SkipNavigation = () => <a href="#main-content">...</a>;
const PerformanceHints = () => <link rel="dns-prefetch" ... />;

// 4. App Content (mit Hooks)
function AppContent() {
  const { state } = useAppState();
  const isOnline = useOnlineStatus();

  usePerformanceMonitoring();
  usePrefetch(prefetchCriticalComponents());

  return <div>...</div>;
}

// 5. Error Recovery Wrapper
function AppWithRecovery() {
  return (
    <ErrorBoundary fallback={...}>
      <AppStateProvider>
        <AppContent />
      </AppStateProvider>
    </ErrorBoundary>
  );
}

// 6. Main Export
export default function App() {
  useEffect(() => {
    console.log(`${APP_NAME} v${APP_VERSION}`);
  }, []);

  return <AppWithRecovery />;
}
```

**Verbesserungen:**
- ✅ Besser organisierte Imports
- ✅ Sub-Components für Übersichtlichkeit
- ✅ Custom Hooks extrahiert
- ✅ Klare Komponenten-Hierarchie
- ✅ Config aus constants.ts

---

## 🎯 **Best Practices**

### **1. Component-Struktur:**

```tsx
// ✅ Good
function Component() {
  // 1. Hooks
  const [state, setState] = useState();
  const { data } = useQuery();

  // 2. Effects
  useEffect(() => { ... }, []);

  // 3. Handlers
  const handleClick = () => { ... };

  // 4. Render
  return <div>...</div>;
}

// ❌ Bad
function Component() {
  // Mixed hooks, effects, and logic
}
```

### **2. Custom Hook-Struktur:**

```tsx
// ✅ Good
export function useCustomHook(param: string) {
  const [state, setState] = useState();

  useEffect(() => {
    // Logic here
  }, [param]);

  return { state, setState };
}

// Export interface
export interface UseCustomHookReturn {
  state: any;
  setState: (state: any) => void;
}
```

### **3. Type-Definitionen:**

```tsx
// ✅ Good - Zentrale Types
import { User, AppState } from './types';

// ❌ Bad - Inline types
function Component({ user }: { user: { id: string; name: string } }) { ... }
```

### **4. Constants:**

```tsx
// ✅ Good - Aus config importieren
import { APP_NAME, CONTACT_EMAIL } from './config/constants';

// ❌ Bad - Magic strings
const appName = 'Verein Menschlichkeit Österreich';
```

---

## 📊 **Performance-Optimierungen**

### **1. Code-Splitting:**
- ✅ Lazy Loading für große Komponenten
- ✅ Suspense-Boundaries für besseres UX
- ✅ Route-basiertes Splitting (zukünftig)

### **2. Prefetching:**
- ✅ Idle-time Component-Prefetching
- ✅ DNS-Prefetch für externe Ressourcen
- ✅ Kritische Komponenten priorisieren

### **3. Memoization:**
- ✅ useMemo für teure Berechnungen
- ✅ useCallback für Event-Handler
- ✅ React.memo für Pure Components

### **4. Bundle-Optimierung:**
- ✅ Tree-shaking durch ES Modules
- ✅ Vendor-Chunk-Splitting
- ✅ Gzip/Brotli Compression

---

## 🧪 **Testing-Strategie**

### **Unit Tests:**
```tsx
// Custom Hooks testen
import { renderHook } from '@testing-library/react-hooks';
import { useOnlineStatus } from './useOnlineStatus';

test('should detect online status', () => {
  const { result } = renderHook(() => useOnlineStatus());
  expect(result.current).toBe(true);
});
```

### **Integration Tests:**
```tsx
// Components mit Hooks testen
import { render, screen } from '@testing-library/react';
import App from './App';

test('renders app with performance monitoring', () => {
  render(<App />);
  expect(screen.getByText(/Menschlichkeit/)).toBeInTheDocument();
});
```

---

## 🔮 **Zukünftige Erweiterungen**

### **Phase 1 (v4.3.0):**
- [ ] React Router für echtes Client-Side-Routing
- [ ] Zustand/Redux für komplexeren Global State
- [ ] API Service Layer mit Axios/Fetch
- [ ] React Query für Server State Management

### **Phase 2 (v4.4.0):**
- [ ] Feature-basierte Ordnerstruktur
- [ ] Micro-Frontends für große Features
- [ ] Shared Component Library
- [ ] Storybook für Component-Dokumentation

### **Phase 3 (v5.0.0):**
- [ ] Full-Stack mit Supabase/Node.js Backend
- [ ] GraphQL API Layer
- [ ] WebSocket für Real-time Features
- [ ] Server-Side Rendering (SSR) mit Vite SSR

---

## 📚 **Migration-Guide (v4.1.0 → v4.2.0)**

### **Schritte:**

1. **Neue Ordner erstellen:**
   ```bash
   mkdir src/hooks src/types src/config src/utils
   ```

2. **Alte App.tsx durch neue ersetzen:**
   ```bash
   mv App.tsx App.old.tsx
   cp src/App.tsx App.tsx
   ```

3. **Imports aktualisieren:**
   ```tsx
   // Old
   import { APP_NAME } from './constants';

   // New
   import { APP_NAME } from './config/constants';
   ```

4. **Types migrieren:**
   ```tsx
   // Old
   interface User { ... }

   // New
   import { User } from './types';
   ```

5. **Custom Hooks nutzen:**
   ```tsx
   // Old
   useEffect(() => {
     // Performance monitoring code
   }, []);

   // New
   usePerformanceMonitoring();
   ```

---

## 📞 **Support**

Bei Fragen zur neuen Architektur:

- 📖 **Diese Datei**: `ARCHITECTURE.md`
- 📧 **Email**: kontakt@menschlichkeit-oesterreich.at
- 💬 **GitHub**: [Issues](https://github.com/menschlichkeit-oesterreich/website/issues)

---

**Version**: 4.2.0
**Datum**: 2025-10-02
**Status**: 🟢 **IMPLEMENTIERT**

---

<div align="center">

## 🎉 **Verbesserte Architektur!**

_Professionell | Skalierbar | Wartbar_ ✨

</div>
