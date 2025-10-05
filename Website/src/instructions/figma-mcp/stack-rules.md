# Figma MCP Stack Rules - Menschlichkeit Österreich

## 🎨 Code-Generierung Regeln

Diese Regeln definieren, wie Code aus Figma-Designs generiert werden soll.

---

## 📋 **Framework & Stack**

### **Primary Stack:**
- **Framework:** React 18.3+
- **Language:** TypeScript 5.0+
- **Styling:** Tailwind CSS v4.0
- **Build:** Vite 5.0+

### **Imports:**
```typescript
// React
import { useState, useEffect, useCallback } from 'react';

// UI Components (ShadCN)
import { Button } from './components/ui/button';
import { Card } from './components/ui/card';

// Icons
import { IconName } from 'lucide-react';

// Animations
import { motion } from 'motion/react';

// Types
import { TypeName } from './types';
```

---

## 🎨 **Design Tokens**

### **WICHTIG: Nur CSS-Variablen verwenden!**

```css
/* ✅ CORRECT - Use CSS Variables */
.element {
  color: var(--primary);
  background: var(--card);
  border-radius: var(--radius-lg);
}

/* ❌ WRONG - No Hardcoded Values */
.element {
  color: #0d6efd;
  background: #ffffff;
  border-radius: 16px;
}
```

### **Token-Referenz:**

```typescript
// Farben - Brand
--brand-orange: #ff6b35
--brand-red: #e63946
--brand-gradient: linear-gradient(135deg, #ff6b35 0%, #e63946 100%)
--brand-blue: #0d6efd (Bootstrap Blue - Primary)
--brand-austria-red: #c8102e

// Farben - Semantic
--primary: Bootstrap Blue
--secondary: Orange-Red Gradient
--success, --warning, --destructive

// Spacing
--radius: 0.75rem (default)
--radius-sm: 0.5rem
--radius-lg: 1rem
--radius-xl: 1.5rem

// Shadows
--card-shadow
--card-shadow-lg
```

**Token-Drift:** MUSS immer 0 sein! Keine Hardcodes!

---

## 📐 **Component-Struktur**

### **File Template:**

```typescript
import React, { useState } from 'react';
import { motion } from 'motion/react';
import { IconName } from 'lucide-react';
import { Button } from './ui/button';

/**
 * ComponentName - Kurzbeschreibung
 * @description Ausführliche Beschreibung
 */

interface ComponentNameProps {
  title?: string;
  description?: string;
  onAction?: () => void;
  className?: string;
  children?: React.ReactNode;
}

export function ComponentName({
  title = 'Default Title',
  description,
  onAction,
  className = '',
  children
}: ComponentNameProps) {
  const [isActive, setIsActive] = useState(false);

  return (
    <motion.div
      className={`component-base ${className}`}
      initial={{ opacity: 0 }}
      animate={{ opacity: 1 }}
    >
      {/* Component Content */}
      <h2>{title}</h2>
      {description && <p>{description}</p>}
      {children}
    </motion.div>
  );
}

export default ComponentName;
```

---

## 🎯 **Tailwind CSS Guidelines**

### **WICHTIG: Typography-Klassen VERBIETEN!**

```tsx
/* ❌ VERBOTEN - Keine text-*, font-* Klassen */
<h1 className="text-4xl font-bold">Title</h1>

/* ✅ KORREKT - Nur semantisches HTML */
<h1>Title</h1>  /* Typography kommt aus globals.css */
```

**Grund:** Wir haben ein automatisches Typography-System in `globals.css`!

### **Erlaubte Tailwind-Klassen:**

```tsx
/* ✅ Layout & Spacing */
className="flex flex-col gap-4 p-6 mt-4"

/* ✅ Colors (mit CSS-Variablen) */
className="bg-card text-foreground border-border"

/* ✅ Brand-Klassen */
className="bg-brand-gradient text-brand-blue"

/* ✅ Responsive */
className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3"

/* ✅ States */
className="hover:bg-accent focus:ring-2 active:scale-95"

/* ✅ Utility-Klassen (aus globals.css) */
className="card-modern glass btn-primary-gradient"
```

---

## ♿ **Accessibility (WCAG 2.1 AA)**

### **Obligatorisch:**

```tsx
/* ✅ Semantic HTML */
<button type="button">Click Me</button>  // nicht <div onClick>
<nav aria-label="Main Navigation">...</nav>
<main id="main-content">...</main>

/* ✅ ARIA Labels */
<button aria-label="Close Modal">
  <X className="w-4 h-4" />
</button>

/* ✅ Keyboard Navigation */
onKeyDown={(e) => e.key === 'Enter' && handleAction()}

/* ✅ Focus States */
className="focus:ring-2 focus:ring-primary focus:outline-none"

/* ✅ Color Contrast */
// Minimum 4.5:1 für normalen Text
// Minimum 3:1 für großen Text

/* ✅ Touch Targets */
// Minimum 44x44px
className="min-h-[44px] min-w-[44px] touch-spacing"

/* ✅ Screen Reader */
<span className="sr-only">Beschreibung für Screen Reader</span>
```

---

## 📱 **Mobile-First Responsive**

### **Breakpoint-Strategie:**

```tsx
/* Mobile First (Default: < 640px) */
<div className="flex flex-col gap-4">

/* Tablet (≥ 640px) */
<div className="sm:flex-row sm:gap-6">

/* Desktop (≥ 1024px) */
<div className="lg:grid lg:grid-cols-3 lg:gap-8">
```

### **Touch-Optimierung:**

```tsx
/* ✅ Touch-freundliche Buttons */
<Button className="btn-touch">  // min 44x44px
  Click Me
</Button>

/* ✅ Swipe-Support */
<div className="swipeable scroll-mobile">
  {/* Horizontales Scrollen */}
</div>

/* ✅ Bottom-Sheet (Mobile) */
<div className="bottom-sheet">
  {/* Modal-Content für Mobile */}
</div>
```

---

## 🎭 **Animations (Motion/React)**

### **Standard-Animationen:**

```tsx
/* ✅ Fade In */
<motion.div
  initial={{ opacity: 0 }}
  animate={{ opacity: 1 }}
  transition={{ duration: 0.3 }}
>

/* ✅ Slide Up */
<motion.div
  initial={{ opacity: 0, y: 20 }}
  animate={{ opacity: 1, y: 0 }}
  transition={{ duration: 0.4 }}
>

/* ✅ Scale In */
<motion.div
  initial={{ scale: 0.95, opacity: 0 }}
  animate={{ scale: 1, opacity: 1 }}
  transition={{ duration: 0.3 }}
>

/* ✅ Stagger Children */
<motion.div
  initial="hidden"
  animate="visible"
  variants={{
    hidden: { opacity: 0 },
    visible: {
      opacity: 1,
      transition: { staggerChildren: 0.1 }
    }
  }}
>
```

### **Performance:**

```tsx
/* ✅ Will-Change für Performance */
<div className="will-change-transform">

/* ✅ Reduced Motion Support */
@media (prefers-reduced-motion: reduce) {
  /* Animationen deaktivieren */
}
```

---

## 📦 **File Placement**

### **Design-System Components:**
```
figma-design-system/components/ui/<ComponentName>.tsx
```

### **App-Specific Components:**
```
frontend/src/components/<Feature>/<ComponentName>.tsx
```

### **Barrel Exports:**
```typescript
// figma-design-system/index.ts
export { ComponentName } from './components/ui/ComponentName';
```

### **Website (HTML/CSS):**
```
website/
├── index.html
└── assets/css/design-tokens.css  // CSS-Variablen importieren
```

---

## 🧪 **Quality Checklist**

Jede generierte Komponente MUSS:

- [ ] **TypeScript:** Vollständige Type-Definitionen
- [ ] **Props Interface:** Mit JSDoc-Kommentaren
- [ ] **Default Props:** Sinnvolle Defaults
- [ ] **CSS-Variablen:** Keine Hardcodes
- [ ] **Accessibility:** WCAG 2.1 AA konform
- [ ] **Semantic HTML:** Korrekte Tags
- [ ] **ARIA:** Labels wo nötig
- [ ] **Keyboard:** Vollständig navigierbar
- [ ] **Touch:** Min 44x44px Targets
- [ ] **Responsive:** Mobile-First
- [ ] **Animations:** Smooth & performant
- [ ] **Error Handling:** Graceful Degradation
- [ ] **Loading States:** Skeleton/Spinner
- [ ] **Dark Mode:** Automatisch via CSS-Variablen
- [ ] **Default Export:** Vorhanden

---

## 🚫 **Verboten**

### **NIE verwenden:**

```tsx
/* ❌ Hardcoded Colors */
color: "#0d6efd"
background: "rgb(13, 110, 253)"

/* ❌ Typography-Klassen */
className="text-4xl font-bold leading-tight"

/* ❌ Inline Styles (außer absolut nötig) */
style={{ color: 'red' }}

/* ❌ any Types */
const data: any = ...

/* ❌ Non-Semantic HTML */
<div onClick={handleClick}>Button</div>

/* ❌ console.log in Production */
console.log('Debug')

/* ❌ Magic Numbers */
width: 250  // Was bedeutet 250?

/* ❌ Non-Accessible */
<div className="hover:underline">Link</div>  // Sollte <a> sein
```

---

## 📝 **Code-Generierung Workflow**

### **1. Metadata abrufen:**
```
get_metadata für fileKey + nodeId
→ Struktur analysieren
```

### **2. Code generieren:**
```
get_code für fileKey + nodeId
→ React + TypeScript + Tailwind
→ Design-Tokens verwenden
```

### **3. Screenshot vergleichen:**
```
get_screenshot
→ Visueller Vergleich
→ Layout-Treue prüfen
```

### **4. Code ablegen:**
```
→ figma-design-system/components/ui/
→ Barrel-Export aktualisieren
→ Types dokumentieren
```

### **5. Qualität prüfen:**
```
✅ Token-Drift = 0
✅ WCAG 2.1 AA
✅ TypeScript: 0 Errors
✅ Build erfolgreich
```

---

## 🎨 **Brand-Specific Rules**

### **Menschlichkeit Österreich:**

```tsx
/* ✅ Primärfarbe: Bootstrap Blue */
className="bg-primary text-primary-foreground"

/* ✅ Sekundärfarbe: Orange-Red Gradient */
className="bg-brand-gradient"

/* ✅ Österreich-Bezug */
<Badge className="bg-brand-austria-red">🇦🇹</Badge>

/* ✅ Card-Styles */
className="card-modern hover-lift"

/* ✅ Glassmorphismus */
className="glass backdrop-blur-lg"

/* ✅ Buttons */
className="btn-primary-gradient"

/* ✅ Democracy-Game-Specific */
className="choice-card stakeholder-badge game-progress"
```

---

## 🔄 **Sync-Workflow**

### **Token-Sync (Täglich):**

```bash
# Manuell
npm run sync-figma-tokens

# Automatisch (CI)
.github/workflows/sync-figma-tokens.yml
→ Erstellt PR bei Änderungen
→ Zeigt Diff in Review
```

### **Environment:**

```env
FIGMA_ACCESS_TOKEN=your_token
FIGMA_FILE_ID=from_url
```

---

## 📚 **Beispiel-Prompt für Figma MCP**

```
Generiere React + TypeScript + Tailwind Code aus Figma:

FileKey: <FILE_KEY>
NodeID: <NODE_ID>

Anforderungen:
- Nutze Design-Tokens aus figma-design-system/00_design-tokens.json
- Nur CSS-Variablen, keine Hardcodes
- WCAG 2.1 AA konform
- Semantic HTML mit ARIA
- Mobile-First responsive
- TypeScript mit vollständigen Types
- Motion/React Animationen
- Ablage: figma-design-system/components/ui/<Name>.tsx
- Barrel-Export in figma-design-system/index.ts aktualisieren
- Default Export vorhanden

Spezifisch:
[Beschreibe spezifische Anforderungen]
```

---

## 🎯 **Erfolgs-Kriterien**

Eine erfolgreiche Code-Generierung:

✅ **Token-Drift:** 0 (keine Hardcodes)
✅ **TypeScript:** 0 Errors
✅ **Accessibility:** WCAG 2.1 AA
✅ **Build:** Erfolgreich
✅ **Visual:** Pixel-perfect zu Figma
✅ **Performance:** Lighthouse ≥90
✅ **Mobile:** Touch-optimiert
✅ **Dark Mode:** Automatisch funktionierend

---

**Version:** 1.0
**Erstellt:** 2025-10-02
**Status:** 🟢 **AKTIV**

---

<div align="center">

**Figma → Code = Perfection** 🎨✨

</div>
