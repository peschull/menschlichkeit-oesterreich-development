# OpenAI Codex VS Code Integration Guide

## 🎯 Problem: Codex Extension lädt nicht trotz ChatGPT Plus Plan

### ✅ Was Sie haben:

- **ChatGPT Plus Plan** (berechtigt für Codex)
- **Extension installiert** (`openai.chatgpt`)
- **Korrekte VS Code Settings**

### ❌ Was fehlt: **AUTHENTIFIZIERUNG**

## 🔧 Lösung: Schritt-für-Schritt Anmeldung

### **Schritt 1: Extension aktivieren**

1. Öffnen Sie VS Code
2. Drücken Sie `Ctrl+Shift+P`
3. Tippen Sie: "**Codex: Open Codex**"
4. Wählen Sie den Befehl aus

### **Schritt 2: Anmeldung durchführen**

1. **Codex Sidebar** öffnet sich (linke Seite)
2. Klicken Sie auf "**Sign in with ChatGPT**"
3. **Browser öffnet sich** → Anmelden mit ChatGPT Plus Account
4. **Berechtigung erteilen** für VS Code Extension
5. **Zurück zu VS Code** → "Sign in successful"

### **Schritt 3: Codex testen**

1. Öffnen Sie `ai-test.ts` oder `codex-diagnose.ts`
2. **TODO-Kommentar** sollte **CodeLens** "Implement with Codex" zeigen
3. **Klick auf CodeLens** → Codex generiert Code
4. **Inline Completion** beim Tippen aktiv

## 🎛️ VS Code Kommandos nach Anmeldung:

### **Chat-Funktionen:**

- `Ctrl+Shift+P` → "**Codex: New Chat**"
- `Ctrl+Shift+P` → "**Codex: Add to Chat**"

### **Code-Funktionen:**

- **TODO-Kommentare** → Automatische "Implement with Codex" CodeLens
- **Inline Completion** → Beim Tippen automatische Vorschläge
- **Code Review** → Markieren + "Add to Codex chat"

## 🔍 Fehlerbehebung:

### **Problem: "Sign in" Button nicht sichtbar**

```bash
# Extension neu starten
Ctrl+Shift+P → "Developer: Reload Window"
```

### **Problem: Anmeldung schlägt fehl**

1. Prüfen Sie Ihren **ChatGPT Plus Plan Status**
2. **Browser-Cookies** für openai.com aktiviert
3. **Firewall/Proxy** Einstellungen prüfen

### **Problem: CodeLens erscheint nicht**

```json
// settings.json prüfen:
"chatgpt.commentCodeLensEnabled": true
```

## 🚀 Sofortige Aktion:

**Führen Sie JETZT aus:**

1. `Ctrl+Shift+P`
2. Tippen: "**Codex: Open Codex**"
3. **Anmelden mit ChatGPT Plus Account**

## 📝 Test nach Anmeldung:

```typescript
// In ai-test.ts oder codex-diagnose.ts
function validateAustrianIban(iban: string): boolean {
  // TODO: Implement IBAN validation for Austria
  // ↑ Sollte "Implement with Codex" CodeLens zeigen

  return false;
}
```

**Nach erfolgreicher Anmeldung funktioniert Codex in VS Code! 🎉**
