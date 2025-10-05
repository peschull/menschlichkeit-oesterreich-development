# 🔧 Integration Guide - Letzte Schritte

## 🎨 Dark Mode Toggle in Navigation integrieren

### Schritt 1: Import hinzufügen

Öffne `/components/Navigation.tsx` und füge den Import hinzu:

```tsx
// Zeile 2 (nach anderen Imports):
import { DarkModeToggle } from './DarkModeToggle';
```

### Schritt 2: Desktop-Navigation aktualisieren

Suche Zeile ~100 (Desktop Navigation) und füge hinzu:

```tsx
{/* Enhanced Desktop Navigation */}
<div className="hidden md:flex items-center gap-6">
  {navItems.map((item) => (
    // ... existing code
  ))}
  <div className="flex items-center gap-3 ml-6">
    {/* ✅ NEU: Dark Mode Toggle */}
    <DarkModeToggle />

    {!isAuthenticated ? (
      // ... existing code
    )}
  </div>
</div>
```

### Schritt 3: Mobile-Navigation aktualisieren

Suche Zeile ~236 (Mobile Navigation) und füge hinzu:

```tsx
<div className="flex flex-col gap-3 pt-4 border-t border-border">
  {/* ✅ NEU: Dark Mode Toggle für Mobile */}
  <div className="flex items-center justify-between px-2 py-2">
    <span className="text-sm font-medium">Theme</span>
    <DarkModeToggle />
  </div>

  {!isAuthenticated ? (
    // ... existing code
  )}
</div>
```

---

## ✅ **Vollständige Checkliste nach Integration:**

### Funktionale Tests:

- [ ] **PWA**: Service Worker registriert (`npm run dev` → Console prüfen)
- [ ] **Dark Mode**: Toggle funktioniert (Light/Dark/System)
- [ ] **Cookie-Banner**: Erscheint beim ersten Besuch
- [ ] **Back-to-Top**: Button erscheint nach Scrollen
- [ ] **Scroll-Progress**: Balken bewegt sich beim Scrollen
- [ ] **Toast**: Test mit `showToast.success('Test')`
- [ ] **Loading**: Spinner zeigt sich bei Ladeoperationen
- [ ] **Error-Boundary**: Fängt React-Fehler ab

### Mobile Tests (Chrome DevTools → Device-Modus):

- [ ] **Cookie-Banner**: Responsive auf iPhone/Android
- [ ] **Dark Mode**: Toggle sichtbar in Mobile-Navigation
- [ ] **Back-to-Top**: Safe-Area-Aware (bei Notch-Geräten)
- [ ] **Touch-Targets**: Min. 44x44px (alle Buttons)
- [ ] **Scroll-Progress**: Sichtbar auf Mobile
- [ ] **Toast**: Lesbar auf kleinen Bildschirmen

### Accessibility Tests:

- [ ] **Keyboard-Navigation**: Tab durch alle Elemente
- [ ] **Screen-Reader**: NVDA/JAWS Tests
- [ ] **Kontrast**: WCAG AA erfüllt (4.5:1)
- [ ] **Focus-Visible**: Sichtbare Fokus-Ringe
- [ ] **ARIA-Labels**: Alle interaktiven Elemente

---

## 🚀 Build & Deploy Checkliste:

### Vor dem Build:

```bash
# 1. Dependencies installieren
npm install

# 2. Type-Check
npm run type-check

# 3. Lint
npm run lint

# 4. Lighthouse (lokal)
npm run lighthouse

# 5. A11y-Tests (Playwright)
npm run test:a11y
```

### Build:

```bash
# Production Build
npm run build

# Preview
npm run preview
```

### Deployment (Plesk):

1. **Upload `dist/` Ordner** nach Plesk
2. **Service Worker prüfen**: `/sw.js` muss erreichbar sein
3. **Manifest prüfen**: `/manifest.json` muss erreichbar sein
4. **HTTPS erzwingen**: Plesk SSL-Einstellungen
5. **Headers setzen** (optional):
   ```
   Content-Security-Policy: ...
   X-Frame-Options: SAMEORIGIN
   X-Content-Type-Options: nosniff
   ```

---

## 📊 Performance-Check nach Deployment:

### Lighthouse (Production):

```bash
# Lighthouse CLI (gegen Live-URL)
lighthouse https://menschlichkeit-oesterreich.at \
  --view \
  --chrome-flags="--headless"
```

**Erwartete Werte:**
- ✅ Performance: ≥90
- ✅ Accessibility: ≥90
- ✅ Best Practices: ≥95
- ✅ SEO: ≥90
- ✅ PWA: ✓ Installierbar

### PageSpeed Insights:

1. Öffne: https://pagespeed.web.dev/
2. URL eingeben: `https://menschlichkeit-oesterreich.at`
3. Prüfen für Mobile + Desktop
4. Core Web Vitals checken:
   - LCP (Largest Contentful Paint): <2.5s
   - FID (First Input Delay): <100ms
   - CLS (Cumulative Layout Shift): <0.1

---

## 🔧 Troubleshooting:

### Problem: Service Worker registriert nicht

**Lösung:**
```bash
# 1. sw.js existiert in /public/?
ls public/sw.js

# 2. Console-Errors prüfen
# → Chrome DevTools → Console → Filter: "service worker"

# 3. HTTPS erzwingen (Service Worker funktioniert nur über HTTPS!)
```

### Problem: Dark Mode funktioniert nicht

**Lösung:**
```tsx
// In DarkModeToggle.tsx prüfen:
// - LocalStorage wird gespeichert?
localStorage.getItem('theme')

// - HTML-Klasse wird gesetzt?
document.documentElement.classList.contains('dark')

// - CSS-Variablen sind definiert?
// → globals.css → .dark { ... }
```

### Problem: Cookie-Banner erscheint immer wieder

**Lösung:**
```tsx
// LocalStorage löschen:
localStorage.removeItem('menschlichkeit-cookie-consent');
localStorage.removeItem('menschlichkeit-cookie-preferences');

// Oder in CookieConsent.tsx:
// COOKIE_CONSENT_KEY prüfen
```

### Problem: Toast-Notifications erscheinen nicht

**Lösung:**
```tsx
// 1. ToastProvider ist in App.tsx?
// <ToastProvider />

// 2. Sonner-Import korrekt?
import { toast } from 'sonner@2.0.3';

// 3. Test:
import { showToast } from './components/ToastProvider';
showToast.success('Test');
```

---

## 🎓 Verwendungs-Beispiele:

### 1. Loading-State mit Toast:

```tsx
import { showToast } from './components/ToastProvider';
import { LoadingSpinner } from './components/LoadingSpinner';

async function handleSave() {
  // Loading-Toast
  const toastId = showToast.loading('Speichere...');

  try {
    await saveData();
    toast.dismiss(toastId);
    showToast.success('Gespeichert!');
  } catch (error) {
    toast.dismiss(toastId);
    showToast.error('Fehler beim Speichern');
  }
}
```

### 2. Cookie-Preferences nutzen:

```tsx
import { useCookiePreferences } from './components/CookieConsent';

function AnalyticsWrapper() {
  const preferences = useCookiePreferences();

  useEffect(() => {
    if (preferences.analytics) {
      // Google Analytics initialisieren
      initGA();
    }
  }, [preferences.analytics]);
}
```

### 3. Error-Boundary für Abschnitte:

```tsx
import { ErrorBoundary } from './components/ErrorBoundary';

<ErrorBoundary fallback={<div>Dieser Abschnitt konnte nicht geladen werden.</div>}>
  <DemocracyGameHub />
</ErrorBoundary>
```

---

## 📱 PWA-Installation testen:

### Desktop (Chrome):

1. Öffne die Website
2. Adressleiste → ⊕ Icon (Installieren)
3. "Installieren" klicken
4. App öffnet sich in eigenem Fenster

### Mobile (Chrome Android):

1. Website öffnen
2. Menü → "Zum Startbildschirm hinzufügen"
3. Name bestätigen
4. App-Icon erscheint auf Homescreen

### iOS (Safari):

1. Website öffnen
2. Teilen-Button → "Zum Home-Bildschirm"
3. Name bestätigen
4. App-Icon erscheint

---

## 🎯 Final Check vor Go-Live:

### Content:

- [ ] Alle Platzhalter-Texte ersetzt
- [ ] Bilder optimiert (WebP, Kompression)
- [ ] Links funktionieren
- [ ] Kontakt-Formular tested
- [ ] Admin-Login funktioniert

### Legal:

- [ ] Impressum vorhanden
- [ ] Datenschutzerklärung aktuell
- [ ] Cookie-Policy aktualisiert
- [ ] AGB (falls Spenden/Mitgliedschaft)

### SEO:

- [ ] Meta-Tags gesetzt
- [ ] Open-Graph-Tags
- [ ] Sitemap.xml
- [ ] Robots.txt
- [ ] Google Search Console eingerichtet

### Security:

- [ ] HTTPS aktiv
- [ ] CSP-Header gesetzt
- [ ] No Mixed Content
- [ ] Secrets nicht im Code
- [ ] ENV-Variablen auf Server

### Performance:

- [ ] Lighthouse Score ≥90
- [ ] Images lazy-loaded
- [ ] Code-Splitting aktiv
- [ ] Service Worker cacht Assets

---

## 🎉 Success!

Nach Abschluss aller Schritte ist **Menschlichkeit Österreich** **100% produktionsbereit**! 🚀🇦🇹

### Features komplett:
✅ PWA (Offline-fähig)
✅ DSGVO-konform
✅ Accessibility (WCAG 2.1 AA)
✅ Mobile-optimiert
✅ Dark Mode
✅ Democracy Games (100+ Level)
✅ Admin-System
✅ Community-Features

---

**Support**: Für Fragen oder Probleme → #contact oder direkt im Code Issues erstellen.

**Version**: 3.0.0 Final
**Status**: 🟢 Ready for Production
