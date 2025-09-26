# 🎮 Democracy Metaverse - VS Code Debug Setup

## 🚀 Debug-Konfiguration für Mixed-Stack

Unser Projekt nutzt einen **Mixed-Stack** optimiert für verschiedene Development-Szenarien:

### **Stack-Übersicht:**
- **🏛️ CMS:** Drupal 10 + PHP (Xdebug Port 9003)  
- **🎮 Games:** Vanilla JS + PWA (Browser + Node Port 9229)
- **⚛️ Frontend:** React/Next.js + TypeScript (Port 3000)
- **🔧 API:** FastAPI Python (Port 8001)

---

## 🛠️ Schnellstart Debug-Modi

### **1. 🎮 Game Development**
```
Debug Panel → "🎮 Game Development: Browser + Node"
```
**Startet:**
- Chrome mit Democracy Games @ localhost:3000
- Node.js Attach für Game-Engine Debugging
- Source Maps für TypeScript/JavaScript

### **2. 🏛️ CMS Development** 
```
Debug Panel → "🏛️ CMS Development: Drupal + Browser"
```
**Startet:**
- PHP Xdebug für Drupal-Backend
- Chrome mit CRM @ localhost:8000
- Drupal-spezifische Breakpoints

### **3. 🚀 Full-Stack Development**
```
Debug Panel → "🚀 Full-Stack: Drupal + Games + API" 
```
**Startet:**
- Alle drei Stacks parallel
- PHP, Node, und Browser Debug gleichzeitig
- Perfekt für Integration-Testing

---

## 🎯 Debug-Features pro Stack

### **🎮 Game Engine (JavaScript/TypeScript)**
- **Breakpoints in:** `web/games/js/*.js`
- **Source Maps:** Automatisch für moderne JS-Features
- **Console:** Browser DevTools + VS Code Debug Console
- **Performance:** JS Profiler für Game-Loops verfügbar

### **🏛️ Drupal Backend (PHP)**
- **Xdebug:** Voll konfiguriert für Drupal 10
- **Breakpoints in:** `crm.menschlichkeit-oesterreich.at/httpdocs/**/*.php`
- **Path Mappings:** Docker → Local automatisch gemappt
- **Performance:** Xdebug mit optimierten Settings

### **⚛️ React Frontend (TypeScript)**  
- **Next.js:** Server-Side + Client-Side Debugging
- **Hot Reload:** Breakpoints bleiben bei Code-Changes
- **TypeScript:** Vollständige Type-Awareness im Debugger

---

## 📋 Tasks & Workflows

### **Automatische Server-Starts:**
- `PHP: Start Server (Debug Mode)` → Xdebug aktiv
- `Games: Serve Local (Port 3000)` → Game-Development-Server  
- `Next.js: Dev (Debug Mode)` → React mit Debug-Support
- `API: Start FastAPI (Debug)` → Python Backend mit Auto-Reload

### **Quality & Testing:**
- `Vitest: Unit Tests (Debug)` → Interaktives Test-Debugging
- `Playwright: E2E Tests (Debug)` → Visuelles Browser-Testing
- `Lint: ESLint` → Code-Quality mit SARIF-Output

---

## 🔧 Erweiterte Debug-Features

### **Conditional Breakpoints:**
```javascript
// Beispiel: Nur bei bestimmten Leveln stoppen
level.id === 5 && gameState.values.empathy > 10
```

### **Logpoints (ohne Stoppen):**
```javascript
// Automatisches Logging ohne Breakpoint
Player progress: {gameState.currentLevel}, Values: {gameState.values}
```

### **Hit Count Breakpoints:**
```javascript
// Stoppe erst beim 10. Durchlauf
>= 10
```

---

## 🐳 Docker Debug Support

### **Node.js in Container:**
```bash
# Container mit Debug-Port starten
docker run -p 3000:3000 -p 9229:9229 democracy-games
```
**Debug Config:** "Docker: Node Attach" verwenden

### **PHP/Drupal in Container:**
```bash
# Xdebug Environment
XDEBUG_MODE=debug XDEBUG_CONFIG="client_host=host.docker.internal"
```
**Debug Config:** "PHP: Xdebug Listen (9003)" funktioniert automatisch

---

## 🎲 Game-Specific Debug Tipps

### **Level-Progression Debugging:**
```javascript
// Breakpoint in prototype-core.js
async completeLevel(levelId) {
  // Debug hier für Level-Transitions
  debugger; // Stoppt bei jedem Level-Abschluss
}
```

### **Character-Development Debugging:**
```javascript
// In character-development.js
processInteraction(characterId, interactionType, playerChoice) {
  // Conditional Breakpoint: characterId === "herr_grimmig"
  // Verfolge Boss-Entwicklung gezielt
}
```

### **Mini-Game Performance:**
```javascript
// In enhanced-minigames.js  
updateNetworkMapping(deltaTime) {
  // Performance Profiler hier aktiv
  // Measure game loop performance
}
```

---

## 📊 Monitoring & Analytics

### **Debug-Performance-Tracking:**
- **JavaScript Profiler:** Automatisch für Game-Loops
- **PHP Profiler:** Xdebug Performance-Mode verfügbar
- **Memory Usage:** Live-Tracking in Debug-Console

### **Error-Tracking:**
- **Browser Errors:** Automatic capture in Debug Console
- **PHP Errors:** Xdebug mit Stack-Traces  
- **TypeScript Errors:** Inline in Editor

---

## 🚨 Troubleshooting

### **Port-Konflikte:**
- **9003 belegt:** PHP Xdebug → Alternative Port in launch.json ändern
- **9229 belegt:** Node Inspector → `NODE_OPTIONS='--inspect=9230'` 
- **3000 belegt:** Games Server → `python -m http.server 3001`

### **Source Maps funktionieren nicht:**
- **Check:** `webRoot` in Browser-Config
- **Check:** `sourceMap: true` in Build-Config  
- **Check:** Files accessible via http://localhost

### **Xdebug verbindet nicht:**
- **Check:** `xdebug.client_host` = VS Code Host IP
- **Check:** Port 9003 nicht geblockt (Firewall)
- **Check:** `xdebug.start_with_request=yes`

---

## 🎯 Fazit

Die Debug-Konfiguration unterstützt **alle drei Haupt-Stacks** des Democracy Metaverse:

✅ **Drupal/PHP** mit Xdebug  
✅ **Games/JS** mit Browser + Node Debugging  
✅ **React/TS** mit Next.js Full-Stack Support  
✅ **API/Python** mit FastAPI Debug-Mode  

**Compound-Konfigurationen** ermöglichen **paralleles Multi-Stack-Debugging** für komplexe Integration-Szenarien.

**Ready für Production-Level Development! 🚀**