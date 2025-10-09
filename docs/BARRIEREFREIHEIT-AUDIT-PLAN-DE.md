# Barrierefreiheits- und Accessibility-Audit Plan

## Menschlichkeit Österreich Development Platform

---

## Ziele des Audits

### Primäre Ziele

- **WCAG 2.1 Level AA Compliance**: Vollständige Einhaltung der Web Content Accessibility Guidelines 2.1 auf Level AA
- **Austrian Accessibility Standards**: Konformität mit österreichischen Barrierefreiheitsgesetzen (BGStG §6-8)
- **NGO Best Practices**: Implementierung von Accessibility-Standards für gemeinnützige Organisationen
- **User Experience Excellence**: Gewährleistung einer inklusiven und benutzerfreundlichen Erfahrung für alle Nutzer

### Sekundäre Ziele

- **Legal Compliance**: Erfüllung rechtlicher Anforderungen für öffentliche Webauftritte in Österreich
- **SEO Enhancement**: Verbesserung der Suchmaschinenoptimierung durch semantische Struktur
- **Performance Impact**: Minimierung des Performance-Impacts von Accessibility-Features
- **Maintenance Strategy**: Etablierung nachhaltiger Accessibility-Wartungsprozesse

### Success Metrics

- **Lighthouse Accessibility Score**: ≥ 95/100
- **axe-core Violations**: 0 Critical/Serious Issues
- **Manual Testing**: 100% Pass Rate für kritische User Flows
- **Screen Reader Support**: Vollständige Navigation mit NVDA, JAWS und VoiceOver

## Prüfkriterien

### 1. Wahrnehmbarkeit (Perceivable)

#### 1.1 Textalternativen

- **Alt-Attribute**: Alle informativen Bilder haben aussagekräftige Alt-Texte
- **Dekorative Bilder**: `alt=""` für rein dekorative Elemente
- **Complex Images**: Längere Beschreibungen für Diagramme/Charts
- **Logo Accessibility**: Korrekte Alt-Texte für Branding-Elemente

**Referenz**: #file:figma-design-system/BRAND-GUIDELINES.md (Line 486-500)

#### 1.2 Zeitbasierte Medien

- **Video Captions**: Untertitel für alle Video-Inhalte
- **Audio Descriptions**: Audiodeskriptionen für komplexe Videos
- **Auto-Play Control**: Nutzersteuerung für automatische Medien

#### 1.3 Anpassbarkeit

- **Responsive Design**: Vollständige Funktionalität bei 320px-1920px Breite
- **Text Scaling**: Lesbarkeit bei 200% Zoom ohne horizontales Scrollen
- **Content Reflow**: Inhalte passen sich verschiedenen Viewport-Größen an
- **Orientation Support**: Portrait/Landscape Unterstützung

#### 1.4 Unterscheidbarkeit

- **Farbkontrast**: Mind. 4.5:1 für normalen Text, 3:1 für großen Text
- **Enhanced Contrast**: 7:1 für AAA-Level (optional)
- **Color Independence**: Information nicht nur durch Farbe vermittelt
- **Audio Control**: Hintergrundaudio kann gesteuert werden

**Referenz**: #file:figma-design-system/00_design-tokens.json (Farbdefinitionen)

### 2. Bedienbarkeit (Operable)

#### 2.1 Tastaturzugänglichkeit

- **Keyboard Navigation**: Alle interaktiven Elemente per Tastatur erreichbar
- **Focus Management**: Sichtbare und logische Focus-Indikatoren
- **Tab Order**: Logische Tab-Reihenfolge entsprechend visueller Anordnung
- **Skip Links**: Navigation zu Hauptinhalt für Screen Reader

**Test-Komponenten**:

- Navigation (#file:figma-design-system/components/ui/breadcrumb.tsx)
- Formulare (#file:figma-design-system/components/ui/form.tsx)
- Buttons (#file:figma-design-system/components/ui/button.tsx)
- Dropdown Menus (#file:figma-design-system/components/ui/dropdown-menu.tsx)

#### 2.2 Ausreichend Zeit

- **Session Timeouts**: Warnung vor automatischen Logouts
- **Content Updates**: Steuerung für sich selbst aktualisierende Inhalte
- **Animation Control**: Pause/Stop für bewegte Inhalte

#### 2.3 Anfälle und physische Reaktionen

- **Flashing Content**: Keine Inhalte, die mehr als 3x pro Sekunde blinken
- **Motion Sensitivity**: Respektierung von `prefers-reduced-motion`

#### 2.4 Navigierbarkeit

- **Page Titles**: Eindeutige und beschreibende Seitentitel
- **Heading Structure**: Logische H1-H6 Hierarchie ohne Sprünge
- **Link Purpose**: Aussagekräftige Link-Texte
- **Multiple Ways**: Mehrere Navigationsmöglichkeiten (Menü, Breadcrumbs, Sitemap)

### 3. Verständlichkeit (Understandable)

#### 3.1 Lesbarkeit

- **Language Attributes**: `lang="de"` für deutsche Inhalte
- **Content Language**: Sprachwechsel markiert mit `lang`-Attributen
- **Unusual Words**: Erklärungen für Fachbegriffe
- **Reading Level**: Angemessenes Sprachniveau für Zielgruppe

#### 3.2 Vorhersagbarkeit

- **Consistent Navigation**: Einheitliche Navigation auf allen Seiten
- **Consistent Identification**: Gleiche Elemente haben gleiche Bezeichnungen
- **Context Changes**: Keine unerwarteten Kontextwechsel bei Focus/Input

#### 3.3 Eingabehilfen

- **Error Identification**: Fehler werden identifiziert und beschrieben
- **Labels/Instructions**: Eingabefelder haben aussagekräftige Labels
- **Error Prevention**: Validierung und Bestätigung für kritische Aktionen

**Referenz**: #file:frontend/src/components/privacy/PrivacyCenter.tsx (DSGVO-Formulare)

### 4. Robustheit (Robust)

#### 4.1 Kompatibilität

- **Valid HTML**: W3C-konforme Markup-Struktur
- **ARIA Usage**: Korrekte Verwendung von ARIA-Attributen
- **Assistive Technology**: Kompatibilität mit Screen Readern

## Methodik

### 1. Automatisierte Tests

#### Axe-Core Integration

```bash
# Installation in Projekt
npm install --save-dev @axe-core/playwright

# Test-Integration
npx playwright test --project=accessibility
```

**Konfiguration**: Erweiterte Playwright-Konfiguration für Accessibility-Tests  
**Referenz**: #file:playwright.config.js

#### Lighthouse CI

```bash
npm run performance:lighthouse
# Accessibility Score Target: ≥ 95/100
```

#### ESLint Accessibility Rules

```json
{
  "extends": ["plugin:jsx-a11y/recommended"],
  "rules": {
    "jsx-a11y/alt-text": "error",
    "jsx-a11y/anchor-has-content": "error",
    "jsx-a11y/aria-role": "error"
  }
}
```

### 2. Manuelle Tests

#### Screen Reader Testing

- **NVDA** (Windows): Primärer Test-Screen Reader
- **JAWS** (Windows): Sekundärer Test für Enterprise-Kompatibilität
- **VoiceOver** (macOS): Safari-Kompatibilität
- **Orca** (Linux): Open-Source Screen Reader Tests

#### Keyboard Navigation Testing

```markdown
Test-Szenarien:
1. Tab-Navigation durch gesamte Seite
2. Shift+Tab Rückwärts-Navigation
3. Enter/Space auf interaktiven Elementen
4. Arrow Keys für komplexe Komponenten
5. Escape für Modal/Dropdown-Schließung
```

#### Mobile Accessibility Testing

- **iOS VoiceOver**: Touch-Exploration und Gesture-Navigation
- **Android TalkBack**: Accessibility-Gesten und Voice-Commands
- **Switch Navigation**: Externe Switch-Control Unterstützung

### 3. User Testing

#### Zielgruppen

- **Sehbehinderte Nutzer**: Screen Reader und Vergrößerung
- **Motorisch eingeschränkte Nutzer**: Tastatur-only Navigation
- **Kognitive Beeinträchtigungen**: Verständlichkeit und Navigation
- **Ältere Nutzer**: Font-Größe und Kontrast-Präferenzen

## Testumfang

### 1. Frontend-Komponenten (React/TypeScript)

#### Priorität 1: Critical Components

- **Navigation** (#file:frontend/src/components/NavBar.tsx)
- **Authentication** (#file:frontend/src/pages/Login.tsx)
- **Main Content** (#file:frontend/src/pages/Home.tsx)
- **Privacy Center** (#file:frontend/src/components/privacy/PrivacyCenter.tsx)

#### Priorität 2: Design System Components

- **Button Variants** (#file:figma-design-system/components/ui/button.tsx)
- **Form Elements** (#file:figma-design-system/components/ui/form.tsx)
- **Card Layouts** (#file:figma-design-system/components/ui/card.tsx)
- **Alert Messages** (#file:frontend/src/components/ui/Alert.tsx)

#### Priorität 3: Interactive Features

- **Dropdown Menus** (#file:figma-design-system/components/ui/dropdown-menu.tsx)
- **Modal Dialogs** (#file:figma-design-system/components/ui/dialog.tsx)
- **Accordions** (#file:figma-design-system/components/ui/accordion.tsx)
- **Data Tables** (wenn vorhanden)

### 2. Gaming Platform (`web/`)

#### Educational Games

- **Democracy Simulations**: Accessibility für komplexe Interaktionen
- **Achievement System**: Screen Reader Kompatibilität für XP/Badges
- **Multiplayer Features**: Barrier-free Communication Tools

#### Data Visualization

- **Progress Charts**: Alternative Datenrepräsentation
- **Leaderboards**: Tabellarische Alternativen zu visuellen Rankings

### 3. CRM Interface (`crm.menschlichkeit-oesterreich.at/`)

#### Drupal/CiviCRM Accessibility

- **Admin Interface**: Tastatur-Navigation für Verwaltungsaufgaben
- **Member Forms**: Barrierefreie Registrierung und Mitgliedschaftsverwaltung
- **Donation Process**: Accessible SEPA-Mandate und Payment-Flows

### 4. API Endpoints (`api.menschlichkeit-oesterreich.at/`)

#### API Response Accessibility

- **Error Messages**: Screen Reader-freundliche Fehlermeldungen
- **Success Notifications**: Accessible Feedback für API-Calls
- **Progress Indicators**: Alternative Repräsentation für Loading States

### 5. Dokumentation und Legal Pages

#### DSGVO Compliance Content

- **Privacy Policy**: Strukturierte, verständliche Datenschutzerklärung
- **Cookie Consent**: Barrier-free Cookie-Management
- **Terms of Service**: Accessible AGB und rechtliche Inhalte

## Berichterstattung

### Audit-Report Format

#### Executive Summary

```markdown
# Accessibility Audit Report - Menschlichkeit Österreich Platform
**Audit Datum**: [Datum]
**WCAG Level**: AA
**Overall Score**: [X]/100

## Key Findings
- Critical Issues: [X]
- Serious Issues: [X]  
- Moderate Issues: [X]
- Minor Issues: [X]

## Compliance Status
- ✅ WCAG 2.1 AA: [Percentage]%
- ✅ Austrian BGStG: [Status]
- ✅ Section 508: [Status]
```

#### Detaillierte Findings

**Issue-Template**:

```markdown
### Issue #[ID]: [Beschreibung]
**Severity**: Critical/Serious/Moderate/Minor
**WCAG Criterion**: [X.X.X]
**Component**: [File/Component-Name]
**User Impact**: [Beschreibung der Auswirkung]

**Problem**:
[Detaillierte Problembeschreibung]

**Solution**:
[Konkrete Lösungsschritte]

**Code Example**:
```

// ❌ Problematisch
<button onClick={handleClick}>
  <Icon />
</button>

// ✅ Lösung
<button onClick={handleClick} aria-label="Aktion ausführen">
  <Icon aria-hidden="true" />
</button>

```text

**Testing**: [Wie zu testen]
**Priority**: High/Medium/Low

```

#### Priority Matrix

| Severity | User Impact | Implementation Effort | Priority |
|----------|-------------|----------------------|----------|
| Critical | High | Low | P0 (Immediate) |
| Critical | High | High | P1 (Sprint 1) |
| Serious | Medium | Low | P1 (Sprint 1) |
| Serious | Medium | High | P2 (Sprint 2) |
| Moderate | Low | Low | P3 (Backlog) |

### Umsetzungsvorschläge

#### Phase 1: Critical Issues (Woche 1-2)

- **Keyboard Navigation**: Focus-Management und Tab-Order
- **Alt-Texte**: Alle informativen Bilder
- **Form Labels**: Korrekte Label-Zuordnung
- **Color Contrast**: Kontrast-Fixes für Text

#### Phase 2: Serious Issues (Woche 3-4)

- **ARIA Implementation**: Roles, States, Properties
- **Heading Structure**: Logische H1-H6 Hierarchie
- **Error Handling**: Accessible Error Messages
- **Screen Reader Testing**: NVDA/JAWS Kompatibilität

#### Phase 3: Moderate Issues (Woche 5-6)

- **Enhanced Navigation**: Skip Links, Landmarks
- **Content Structure**: Semantic HTML Improvements
- **Mobile Accessibility**: Touch-Target Optimization
- **Performance**: Accessibility Performance Impact

#### Phase 4: Continuous Improvement (Ongoing)

- **User Testing**: Regelmäßige Tests mit echten Nutzern
- **Training**: Team-Schulungen zu Accessibility
- **Monitoring**: Automatisierte Accessibility-Überwachung
- **Documentation**: Accessibility-Guidelines für Entwickler

## Zeitplan und Ressourcen

### Projekt Timeline

#### Audit Phase (2 Wochen)

**Woche 1**: Automatisierte Tests und Setup

- Axe-core Integration in Playwright
- Lighthouse CI Konfiguration
- ESLint Accessibility Rules Setup
- Initial Automated Scan

**Woche 2**: Manuelle Tests und User Testing

- Screen Reader Testing (NVDA, JAWS, VoiceOver)
- Keyboard Navigation Tests
- Mobile Accessibility Testing
- Expert Review und Report-Erstellung

#### Implementation Phase (6 Wochen)

**Sprint 1** (Woche 3-4): Critical Issues

- Keyboard Navigation Fixes
- Color Contrast Adjustments
- Alt-Text Implementation
- Form Label Corrections

**Sprint 2** (Woche 5-6): Serious Issues

- ARIA Implementation
- Heading Structure Optimization
- Error Message Enhancement
- Screen Reader Compatibility

**Sprint 3** (Woche 7-8): Moderate Issues

- Navigation Improvements
- Content Structure Refinement
- Mobile Touch Targets
- Performance Optimization

### Benötigte Expertise

#### Team-Rollen

- **Accessibility Expert** (Vollzeit, 2 Wochen): Audit-Leitung und Review
- **Frontend Developer** (80%, 6 Wochen): Implementation der Fixes
- **UX Designer** (40%, 4 Wochen): Design-Adjustments für Accessibility
- **QA Tester** (50%, 4 Wochen): Acceptance Testing und Regression Tests

#### Externe Expertise

- **Screen Reader Consultant**: User Testing mit echten Screen Reader-Nutzern
- **Legal Advisor**: Österreichische Accessibility-Gesetze (BGStG)
- **WCAG Auditor**: Unabhängige Validierung der Compliance

### Benötigte Tools

#### Software-Tools

```json
{
  "accessibility": {
    "axe-core": "^4.8.0",
    "lighthouse": "^11.0.0", 
    "pa11y": "^6.2.0",
    "jest-axe": "^8.0.0"
  },
  "screen_readers": {
    "nvda": "2023.3",
    "jaws": "2024",
    "voiceover": "macOS Sonoma"
  },
  "browsers": {
    "chrome": "latest",
    "firefox": "latest", 
    "safari": "latest",
    "edge": "latest"
  }
}
```

#### Hardware-Anforderungen

- **Windows PC**: NVDA und JAWS Testing
- **macOS Device**: VoiceOver und Safari Testing
- **iOS Device**: Mobile VoiceOver Testing
- **Android Device**: TalkBack Testing
- **External Switches**: Switch-Control Testing (optional)

### Budget-Schätzung

#### Personalkosten (8 Wochen)

- Accessibility Expert: €12.000 (2 Wochen × €6.000)
- Frontend Developer: €19.200 (6 Wochen × 80% × €4.000)
- UX Designer: €6.400 (4 Wochen × 40% × €4.000)
- QA Tester: €6.000 (4 Wochen × 50% × €3.000)

**Subtotal Personal**: €43.600

#### Tool- und Software-Lizenzen

- JAWS License: €1.200/Jahr
- Axe DevTools Pro: €600/Jahr
- Testing Devices: €2.000 (einmalig)

**Subtotal Tools**: €3.800

#### Externe Beratung

- Screen Reader Consultant: €3.000
- Legal Advisor (BGStG): €1.500
- WCAG Auditor: €2.500

**Subtotal Extern**: €7.000

**Gesamtbudget**: €54.400

### Success Monitoring

#### Acceptance Criteria

- **Lighthouse Score**: ≥ 95/100 Accessibility
- **axe-core**: 0 Critical/Serious Violations
- **Manual Testing**: 100% Pass Rate für Core User Flows
- **User Testing**: Positive Feedback von ≥5 Screen Reader-Nutzern

#### Continuous Monitoring

```bash
# Tägliche Accessibility-Checks
npm run test:accessibility

# Wöchentliche Lighthouse Audits
npm run performance:lighthouse

# Monatliche manuelle Reviews
npm run audit:accessibility:full
```

#### Quality Gates Integration

**Referenz**: #file:.github/instructions/quality-gates.instructions.md

- Gate 6: Accessibility (WCAG AA) ist bereits als PR-Blocker konfiguriert
- Lighthouse Accessibility Score ≥ 90 ist mandatory
- axe-core Violations führen zu Build-Failures

---

**Audit-Plan Version**: 1.0.0  
**Erstellt am**: 7. Oktober 2025  
**Nächste Review**: 7. Januar 2026  
**Maintainer**: Menschlichkeit Österreich Development Team

**Referenzen**:

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Austrian BGStG](https://www.ris.bka.gv.at/GeltendeFassung.wxe?Abfrage=Bundesnormen&Gesetzesnummer=20003236)
- [axe-core Documentation](https://github.com/dequelabs/axe-core)
- [Lighthouse Accessibility Audit](https://web.dev/accessibility-scoring/)
