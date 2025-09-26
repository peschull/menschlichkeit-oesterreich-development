# 🚀 Democracy Metaverse - Prototyp-Phase
## MVP-Entwicklung in 4-6 Wochen

**Status**: 🏗️ In Entwicklung  
**Ziel**: Proof of Concept + User Testing Ready  
**Umfang**: Kapitel 1-3 (30 Level) + Core-Systeme  
**Timeline**: 4-6 Wochen Sprint

---

## 🎯 **Prototyp-Scope (MVP)**

### ✅ **Was wird entwickelt:**

#### **Kern-Features (Must-Have):**
- **30 Level** (Kapitel 1-3: Nachbarschaft, Schule/Arbeit, Digital)
- **3 Boss-Kämpfe** mit adaptiver KI
- **3 Mini-Games** (Fact-Check, Bridge-Puzzle, Debate-Duel)
- **Interaktive Weltkarte** mit 3 Regionen
- **4-Achsen-Werte-System** (E/R/P/Z)
- **Skill-Tree** (Grundstufe mit 6 Skills)
- **PWA-Funktionalität** (Offline-Modus)

#### **Demo-Features (Nice-to-Have):**
- **Multiplayer-Grundlagen** (2-4 Spieler)
- **Learning Analytics** (Basic Tracking)
- **Export-Funktion** (JSON/PDF)
- **Accessibility AAA** (Screen Reader Ready)

#### **Nicht im Prototyp:**
- ❌ Kapitel 4-10 (folgt in Phase 2)
- ❌ Endgame-Arc (Level 101-110)
- ❌ Advanced Multiplayer (>4 Spieler)
- ❌ Lokalisierung (nur Deutsch)

---

## 📋 **Sprint-Planung (4-6 Wochen)**

### **Woche 1-2: Foundation**
- Core Game Engine (Level-System, State Management)
- Basic UI/UX (Glassmorphism Design System)
- Kapitel 1 komplett (10 Level + Boss)

### **Woche 3-4: Mechanics**
- 3 Mini-Games vollständig funktional
- World Map mit Bridge-Visualisierung
- Kapitel 2-3 implementiert

### **Woche 5-6: Polish & Testing**
- Boss-AI verfeinert
- User Testing & Feedback-Integration
- PWA-Optimierung & Deployment

---

## 🛠️ **Technische Architektur (Prototyp)**

### **Vereinfachte Struktur:**
```
web/games/prototype/
├── 📄 index.html                 # PWA Shell
├── 📱 manifest.json              # Prototyp-Manifest
├── 🎨 css/
│   ├── prototype-tokens.css      # Design-System
│   ├── components.css            # UI-Komponenten  
│   └── animations.css            # Micro-Interactions
├── 🧠 js/
│   ├── prototype-core.js         # Game Engine (30 Level)
│   ├── minigames-basic.js        # 3 Mini-Games
│   ├── world-map.js              # Interaktive Karte
│   ├── boss-ai.js                # 3 Boss-Systeme
│   └── multiplayer-basic.js      # WebRTC Grundlagen
└── 📊 content/
    ├── levels-prototype.yml      # 30 Level-Definitionen
    └── characters.json           # Figuren-Pool
```

### **Performance-Ziele:**
- **< 2s** Initial Load Time
- **< 500ms** Level-Transition
- **60 FPS** Animations
- **< 50MB** Total App Size

---

## 🎮 **Level-Auswahl für Prototyp**

### **Kapitel 1: Nachbarschaft (Level 1-10)**
1. **Lärm im Hof** - Tutorial + Empathie-Grundlagen
2. **Essensgerüche** - Kulturelle Vielfalt
3. **Müll oder Kultur?** - Ästhetik-Konflikte
4. **Nachbarschaftshilfe** - Solidarität lernen  
5. **Hundekonflikt** - Regelkonflikte lösen
6. **Kinder vs. Ruhe** - Kompromisse finden
7. **Straßenfest** - Organisation & Partizipation
8. **Erste Mediation** - Konfliktvermittlung
9. **Special: Nachbarschaftskarte** - Mapping Mini-Game
10. **Boss: Sturkopf-Nachbar** - Erste Boss-Mechanik

### **Kapitel 2: Schule & Arbeit (Level 11-20)**
11. **Mobbing stoppen** - Zivilcourage-Tutorial
12. **Gender Pay Gap** - Gerechtigkeit am Arbeitsplatz
13. **Diskriminierung erkennen** - Bias-Awareness
14. **Klassensprecherwahl** - Demokratie-Mechaniken
15. **Unfaire Bewertung** - Systemische Probleme
16. **Streik im Betrieb** - Solidarität vs. Existenzangst  
17. **Ethik im Unterricht** - Kontroverse Themen
18. **Kollegin verteidigen** - Workplace-Zivilcourage
19. **Special: Schüler*innen-Rat** - Simulation Mini-Game
20. **Boss: Ungerechter Chef** - Authority-Challenge

### **Kapitel 3: Digitale Demokratie (Level 21-30)**
21. **Like vs. Hass** - Social Media Dynamics
22. **WhatsApp-Gerüchte** - Fact-Checking-Tutorial
23. **Trolljäger** - Online-Moderation  
24. **Cybermobbing** - Digitale Zivilcourage
25. **Influencer-Druck** - Media Literacy
26. **Fact-Check Speedrun** - Core Mini-Game
27. **Filterblase** - Algorithm-Awareness
28. **Datenschutz-Entscheidung** - Privacy vs. Convenience
29. **Special: Netzwerk-Analyse** - Bot-Detection Mini-Game
30. **Boss: Fake News Mastermind** - Information-War

---

## 🎲 **Mini-Games für Prototyp**

### **1. Fact-Check Speedrun**
- **Mechanik**: Quellen-Verifikation unter Zeitdruck
- **Lernziel**: Media Literacy, Source Credibility
- **Implementation**: 90s Timer, 8-12 Claims, Accuracy Scoring

### **2. Bridge Puzzle**  
- **Mechanik**: Werte-Verbindungen mit Physics-Engine
- **Lernziel**: Democratic Values Integration
- **Implementation**: 8x8 Grid, Drag & Drop, Stability-Testing

### **3. Debate Duel**
- **Mechanik**: Real-time Argumentation vs. AI
- **Lernziel**: Rhetorik, Fallacy-Detection
- **Implementation**: Turn-based, 5 Rounds, Audience-Meter

---

## 🤖 **Boss-AI System (Prototyp)**

### **Boss 1: Sturkopf-Nachbar**
```javascript
{
  name: "Herr Grimmig",
  type: "emotional_resistance", 
  health: 100,
  patterns: ["denial", "escalation", "guilt_tripping"],
  weaknesses: ["empathy", "common_ground", "respect"],
  victory: "50+ Persuasion Points without aggression"
}
```

### **Boss 2: Ungerechter Chef**  
```javascript
{
  name: "Direktor Macht",
  type: "institutional_authority",
  health: 150, 
  patterns: ["hierarchy_assertion", "deflection", "intimidation"],
  weaknesses: ["evidence", "coalition", "transparency"],
  victory: "System reform + student rights secured"
}
```

### **Boss 3: Fake News Mastermind**
```javascript
{
  name: "Dr. Desinformation", 
  type: "information_warfare",
  health: 200,
  patterns: ["deepfake_spam", "source_flooding", "emotion_manipulation"],
  weaknesses: ["fact_checking", "source_triangulation", "calm_logic"],
  victory: "Truth restored + misinformation network exposed"
}
```

---

## 📊 **Success Metrics (Prototyp)**

### **Technical KPIs:**
- ✅ Load Time < 2s
- ✅ 30 Level completable 
- ✅ 3 Mini-Games functional
- ✅ PWA installable
- ✅ Accessibility AA compliance

### **Educational KPIs:**
- 🎯 **Engagement**: Ø ≥12 min/Session
- 🎯 **Completion**: ≥70% finish Kapitel 1
- 🎯 **Learning**: ≥80% correct on reflection questions
- 🎯 **Satisfaction**: ≥4/5 Stars User Rating

### **User Testing Goals:**
- **5 Schulklassen** (14-18 Jahre) testen Prototyp
- **3 NGO-Workshops** mit Erwachsenen
- **2 Accessibility-Audits** mit Expert*innen
- **Feedback-Integration** in finaler Version

---

## 🎨 **Design-System (Prototyp)**

### **Glassmorphism UI:**
```css
:root {
  /* Prototyp-Tokens */
  --glass-primary: rgba(184, 0, 0, 0.1);
  --glass-secondary: rgba(255, 255, 255, 0.25);
  --glass-border: rgba(255, 255, 255, 0.18);
  --glass-blur: blur(20px);
  
  /* Democratic Values Colors */
  --empathy: #e879f9;      /* Purple-400 */
  --rights: #06b6d4;       /* Cyan-500 */  
  --participation: #10b981; /* Emerald-500 */
  --courage: #f59e0b;      /* Amber-500 */
}
```

### **Component Library:**
- **Glass Cards** für Level-Container
- **Bridge Animations** für Progress-Visualization
- **Value Meters** für Live-Stats
- **Boss Health Bars** für Kampf-UI
- **Notification Toasts** für Feedback

---

## 🔄 **Development Workflow**

### **Daily Standups:**
- **Was**: Täglicher 15min Check-in
- **Wann**: 9:00 Uhr
- **Fokus**: Blocker, Progress, Next Steps

### **Weekly Reviews:**
- **Sprint-Review**: Freitag 15:00 (Demo neuer Features)
- **Sprint-Planning**: Montag 10:00 (Nächste Woche planen)
- **User Testing**: Jeden Donnerstag mit echten Nutzer*innen

### **Git-Workflow:**
```
main (production-ready)
├── develop (integration)
├── feature/level-system
├── feature/minigames
├── feature/world-map
└── hotfix/accessibility
```

---

## 🚀 **Deployment-Strategie**

### **Prototyp-Hosting:**
- **GitHub Pages** für Demo-Version
- **Netlify** für Stakeholder-Previews  
- **Local PWA** für Offline-Testing
- **School Servers** für Pilotprojekte

### **Feedback-Kanäle:**
- **In-App Feedback** (Quick Surveys nach Leveln)
- **Video-Interviews** mit Lehrer*innen
- **Analytics Dashboard** für Behavior-Tracking
- **GitHub Issues** für Bug-Reports

---

## 🎯 **Next Steps (Week 1)**

### **Sofort starten:**
1. **Core Engine** entwickeln (prototype-core.js)
2. **Level 1.1** vollständig implementieren  
3. **Basic UI** mit Glassmorphism-Design
4. **PWA-Setup** mit Offline-Caching

### **Ende Woche 1 Ziel:**
- ✅ **Level 1-5** spielbar
- ✅ **Werte-System** funktional  
- ✅ **Save/Load** implementiert
- ✅ **Erste User-Tests** möglich

**Bereit für den Sprint-Start?** 🏃‍♀️💨

Die **Democracy Metaverse Prototyp-Phase** kann sofort beginnen! 🌉🚀