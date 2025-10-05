# 🤝 Contributing to Menschlichkeit Österreich

Vielen Dank für dein Interesse, zu **Menschlichkeit Österreich** beizutragen! 

Wir freuen uns über jeden Beitrag – ob Code, Dokumentation, Bug-Reports oder Feature-Vorschläge.

---

## 📋 **Code of Conduct**

Bitte sei respektvoll und konstruktiv in deiner Kommunikation. Wir wollen eine offene und einladende Community schaffen.

---

## 🚀 **Wie kann ich beitragen?**

### **1. Bug-Reports** 🐛

Wenn du einen Fehler gefunden hast:

1. Prüfe, ob der Bug bereits als [Issue](https://github.com/menschlichkeit-oesterreich/website/issues) gemeldet wurde
2. Wenn nicht, erstelle ein neues Issue mit:
   - **Titel**: Kurze Beschreibung des Problems
   - **Beschreibung**: Detaillierte Beschreibung
   - **Schritte zur Reproduktion**: 1. Gehe zu... 2. Klicke auf... 3. Siehe Fehler
   - **Erwartetes Verhalten**: Was sollte passieren?
   - **Screenshots**: Wenn möglich
   - **Browser/OS**: Welcher Browser, welches Betriebssystem?

### **2. Feature-Requests** ✨

Hast du eine Idee für ein neues Feature?

1. Prüfe, ob das Feature bereits vorgeschlagen wurde
2. Erstelle ein Issue mit:
   - **Titel**: Feature-Name
   - **Problem**: Welches Problem löst das Feature?
   - **Lösung**: Wie sollte das Feature funktionieren?
   - **Alternativen**: Gibt es andere Lösungen?

### **3. Code-Beiträge** 💻

#### **Setup:**

```bash
# Repository forken und klonen
git clone https://github.com/DEIN-USERNAME/website.git
cd website

# Dependencies installieren
npm install

# Development-Server starten
npm run dev
```

#### **Workflow:**

1. **Branch erstellen:**
   ```bash
   git checkout -b feature/dein-feature-name
   # oder
   git checkout -b fix/bug-beschreibung
   ```

2. **Änderungen machen:**
   - Folge den [Coding-Guidelines](#-coding-guidelines)
   - Schreibe Tests für neue Features
   - Aktualisiere Dokumentation

3. **Commit:**
   ```bash
   git add .
   git commit -m "feat: Beschreibung deines Features"
   # oder
   git commit -m "fix: Beschreibung des Bugfixes"
   ```

4. **Push:**
   ```bash
   git push origin feature/dein-feature-name
   ```

5. **Pull Request erstellen:**
   - Gehe zu GitHub
   - Klicke auf "New Pull Request"
   - Fülle die PR-Template aus
   - Warte auf Review

---

## 📐 **Coding Guidelines**

### **TypeScript:**
- ✅ Immer Types verwenden (kein `any`)
- ✅ Interfaces für Props definieren
- ✅ Enums/Const für feste Werte

### **React Components:**
- ✅ Functional Components (keine Class Components)
- ✅ Custom Hooks für wiederverwendbare Logik
- ✅ Props mit TypeScript Interfaces
- ✅ Memoization bei Performance-kritischen Components

### **Styling:**
- ✅ Tailwind CSS Utility-Classes verwenden
- ✅ **KEINE** inline `text-*` oder `font-*` Klassen (wegen Typography-System)
- ✅ Custom-Utilities aus `globals.css` nutzen
- ✅ Responsive Mobile-First

### **Naming Conventions:**
- **Components**: `PascalCase` (z.B. `UserProfile.tsx`)
- **Hooks**: `camelCase` mit `use` Prefix (z.B. `useOnlineStatus.ts`)
- **Utils**: `camelCase` (z.B. `format.ts`)
- **Constants**: `UPPER_SNAKE_CASE` (z.B. `API_URL`)

### **File Structure:**
```
/components       # React Components
/src/hooks        # Custom Hooks
/src/types        # TypeScript Types
/src/utils        # Utility Functions
/src/config       # Configuration
/styles           # Global Styles
```

### **Commit Messages:**

Verwende [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: Neue Feature hinzugefügt
fix: Bug behoben
docs: Dokumentation aktualisiert
style: Code-Formatierung
refactor: Code umstrukturiert
test: Tests hinzugefügt
chore: Build-Prozess/Dependencies
```

**Beispiele:**
```bash
feat: Add notification center component
fix: Resolve navigation z-index issue
docs: Update architecture documentation
refactor: Extract auth logic to custom hook
test: Add unit tests for format utils
```

---

## ✅ **Pull Request Checklist**

Bevor du einen PR erstellst, stelle sicher:

- [ ] Code läuft ohne Errors (`npm run type-check`)
- [ ] Keine ESLint-Warnings (`npm run lint`)
- [ ] Tests geschrieben und bestehen
- [ ] Dokumentation aktualisiert
- [ ] Responsive Design getestet (Mobile/Tablet/Desktop)
- [ ] Accessibility getestet (Keyboard-Navigation, Screen-Reader)
- [ ] Browser-Testing (Chrome, Firefox, Safari)
- [ ] PR-Beschreibung ist vollständig

---

## 🧪 **Testing**

### **Unit Tests:**
```bash
npm run test
```

### **E2E Tests:**
```bash
npm run test:e2e
```

### **Accessibility Tests:**
```bash
npm run test:a11y
```

---

## 📚 **Dokumentation**

Bei größeren Features:

1. Aktualisiere `README.md`
2. Erweitere `ARCHITECTURE.md` (wenn Architektur betroffen)
3. Füge Beispiele in Component-Dateien hinzu (JSDoc)
4. Erstelle Screenshots/GIFs für visuelle Änderungen

---

## 🎨 **Design-Guidelines**

### **Brand Colors:**
- Primary: `#0d6efd` (Bootstrap Blue)
- Secondary: `#ff6b35` → `#e63946` (Orange-Red Gradient)
- Austria: `#c8102e` (Austria Red)

### **Spacing:**
- Mobile: `1rem` (16px)
- Tablet: `1.5rem` (24px)
- Desktop: `2rem` (32px)

### **Typography:**
- Headings: Automatisch via globals.css
- Body: 1rem (16px), line-height 1.7
- Small: 0.875rem (14px)

---

## 🚫 **Was NICHT zu tun ist**

- ❌ Direkt in `main` pushen
- ❌ Große PRs ohne Diskussion
- ❌ Breaking Changes ohne Absprache
- ❌ Code ohne Tests
- ❌ Hardcoded Secrets/API-Keys
- ❌ `console.log` in Production-Code
- ❌ `any` Types verwenden

---

## 💬 **Fragen?**

Bei Fragen:

- **GitHub Issues**: Für technische Fragen
- **Email**: kontakt@menschlichkeit-oesterreich.at
- **Documentation**: Siehe [README.md](README.md) und [ARCHITECTURE.md](ARCHITECTURE.md)

---

## 🎉 **Danke!**

Jeder Beitrag zählt! Vielen Dank, dass du **Menschlichkeit Österreich** unterstützt.

Gemeinsam schaffen wir eine bessere, gerechtere Gesellschaft! 🇦🇹✨

---

**Letzte Aktualisierung:** 2025-10-02
