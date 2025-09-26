# Brücken Bauen - Interactive Democracy Game 🌉

Ein interaktives Political Education Game über **Empathie**, **Menschenrechte** und **demokratischen Zusammenhalt**.

## 🎯 Spielkonzept

**"Brücken Bauen"** ist ein browserbasiertes Educational Game, das Spieler*innen durch verschiedene gesellschaftliche Szenarien führt und dabei demokratische Werte, Empathie und Menschenrechte vermittelt.

### 🎮 Gameplay-Mechaniken

1. **Szenario-basiert**: 8 realistische gesellschaftliche Situationen
2. **Entscheidungs-Spiel**: Multiple-Choice mit Konsequenzen
3. **Empathie-System**: Verschiedene Perspektiven verstehen
4. **Progress-Tracking**: Demokratie-Score und Lernfortschritt
5. **Reflexions-Phasen**: Nachdenkliche Momente zwischen Szenarien

### 📚 Lernziele

- **Empathie entwickeln** für verschiedene gesellschaftliche Gruppen
- **Demokratische Prozesse** verstehen und wertschätzen
- **Menschenrechte** als Grundlage des Zusammenlebens erkennen
- **Zivilcourage** fördern und Handlungsoptionen aufzeigen
- **Kritisches Denken** über gesellschaftliche Herausforderungen

## 🏗️ Technische Implementierung

### Technologie-Stack
- **Frontend**: Vanilla JavaScript (ES6+), CSS3, HTML5
- **PWA**: Service Worker, Web App Manifest, Offline-Support
- **Accessibility**: WCAG 2.2 AA Compliance, Screen Reader Support
- **Performance**: Optimiert für Mobile & Desktop
- **Integration**: Drupal Custom Block für CMS-Einbindung

### Ordner-Struktur
```
web/games/
├── index.html          # Haupt-HTML-Datei
├── manifest.json       # PWA-Manifest
├── sw.js              # Service Worker
├── assets/
│   ├── icons/         # Game Icons & Illustrationen
│   ├── audio/         # Sound-Effekte (optional)
│   └── images/        # Background-Images
├── css/
│   ├── main.css       # Haupt-Stylesheet
│   ├── components.css # UI-Komponenten
│   └── animations.css # Micro-Animations
└── js/
    ├── game.js        # Haupt-Game-Logic
    ├── scenarios.js   # Szenario-Daten
    ├── ui.js          # UI-Interaktionen
    └── pwa.js         # PWA-Funktionalität
```

## 🎨 Design-Philosophie

### Visual Identity
- **Konsistent** mit Menschlichkeit Österreich Branding
- **Warm & Einladend**: Pastellfarben, abgerundete Ecken
- **Glassmorphism**: Moderne, transparente UI-Elemente
- **Responsive Design**: Mobile-First Approach
- **Micro-Animations**: Subtile Übergänge für bessere UX

### Accessibility
- **Keyboard Navigation**: Vollständig tastaturzugänglich
- **Screen Reader**: Semantisches HTML mit ARIA-Labels
- **High Contrast**: Farbkontrast nach WCAG-Standards
- **Reduced Motion**: Respekt vor Bewegungseinstellungen
- **Multiple Languages**: Deutsch mit Erweiterbarkeit

## 🎲 Game-Szenarien

### 1. **Nachbarschaftskonflikt**
*Lärmbeschwerden vs. kulturelle Vielfalt*
- Empathie für verschiedene Lebenssituationen
- Mediation und Kompromissfindung

### 2. **Arbeitsplatz-Diskriminierung**
*Ungleichbehandlung erkennen und handeln*
- Zivilcourage am Arbeitsplatz
- Rechtliche vs. moralische Verpflichtungen

### 3. **Flüchtlingshilfe**
*Solidarität in der Gemeinde*
- Vorurteile abbauen
- Aktive Hilfe vs. passive Toleranz

### 4. **Digitale Demokratie**
*Fake News und Meinungsbildung*
- Medienkompetenz entwickeln
- Demokratische Meinungsbildung

### 5. **Generationenkonflikt**
*Klimaschutz vs. Wirtschaftsinteressen*
- Intergenerationale Gerechtigkeit
- Langfristige vs. kurzfristige Entscheidungen

### 6. **Inklusion im Sport**
*Behinderung und gesellschaftliche Teilhabe*
- Barrierefreie Gestaltung
- Inklusion als Bereicherung

### 7. **LGBTQ+ Akzeptanz**
*Vielfalt in der Schule*
- Respekt für sexuelle Identität
- Aufklärung vs. Tradition

### 8. **Bürgerbeteiligung**
*Stadtplanung und Partizipation*
- Demokratische Teilhabe
- Gemeinwohl vs. Eigeninteressen

## 📊 Scoring & Feedback

### Demokratie-Score
- **Empathie-Punkte**: Für das Verstehen anderer Perspektiven
- **Menschenrechts-Punkte**: Für das Eintreten für Grundrechte
- **Partizipations-Punkte**: Für aktive demokratische Teilnahme
- **Zivilcourage-Punkte**: Für mutiges Handeln in schwierigen Situationen

### Reflexions-System
- Nach jedem Szenario: **"Was hast du gelernt?"**
- Am Ende: **Persönlichkeitsprofil** als "Demokratie-Champion"
- **Handlungsempfehlungen** für den Alltag
- **Weiterführende Ressourcen** von Menschlichkeit Österreich

## 🚀 Deployment & Integration

### Standalone-Nutzung
- **GitHub Pages**: Direkter Link für Schulen/Bildungseinrichtungen
- **PWA-Installation**: Installierbar als App auf Mobile/Desktop
- **Offline-Modus**: Funktioniert ohne Internetverbindung

### CMS-Integration
- **Drupal Custom Block**: Einbettung in NGO-Website
- **Progress-Tracking**: Integration mit CiviCRM möglich
- **Multiplayer-Modus**: Zukünftige Erweiterung für Schulklassen

---

**Entwickelt von**: Menschlichkeit Österreich  
**Lizenz**: Creative Commons (Educational Use)  
**Zielgruppe**: Jugendliche ab 14 Jahren, Erwachsenenbildung  
**Spieldauer**: 20-30 Minuten