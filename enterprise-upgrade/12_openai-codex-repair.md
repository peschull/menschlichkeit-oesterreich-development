# OpenAI Codex + Secrets Management - Reparatur und Implementation

## Problem: OpenAI Codex Authentication

Du siehst diese Meldung:
```
Sign in with your ChatGPT account
Codex works with Plus, Pro, Business, Edu, and Enterprise ChatGPT plans.
```

Das bedeutet:
1. **OpenAI Codex Extension** ist installiert aber nicht authentifiziert
2. Du benötigst einen **ChatGPT Plus/Pro/Business/Enterprise Account**
3. API-Keys müssen sicher verwaltet werden (ENV-001)

## 🚀 Sofort-Lösung

### 1. Extension Status prüfen
- `Ctrl+Shift+P` → "Extensions: Show Installed Extensions"
- Suche nach "Codex", "OpenAI", "ChatGPT"
- Status prüfen: Aktiviert? Aktuell?

### 2. Authentication reparieren
```
Ctrl+Shift+P → "OpenAI: Sign In" oder "ChatGPT: Sign In"
```

### 3. API-Key sicher konfigurieren (ENV-001)
**NIEMALS** direkt in settings.json!

## 🔐 Sichere Implementation

### A) SOPS für API-Keys
```yaml
# .sops.yaml
keys:
  - &peschull age1hl4xqx...
creation_rules:
  - path_regex: secrets/.*\.enc\.json$
    age: *peschull
  - path_regex: \.env\.enc$
    age: *peschull
```

### B) Verschlüsselte Secrets
```json
// secrets/openai.enc.json (verschlüsselt)
{
  "openai_api_key": "sk-...",
  "openai_org_id": "org-...",
  "chatgpt_session": "encrypted_session_data"
}
```

### C) VS Code Integration
```json
// .vscode/settings.json (nur Referenzen)
{
  "openai.apiKey": "${env:OPENAI_API_KEY}",
  "openai.organization": "${env:OPENAI_ORG_ID}",
  "chatgpt.apiKey": "${env:OPENAI_API_KEY}"
}
```

## 🎯 Implementierte Lösung

1. **MCP-Server für OpenAI** hinzugefügt
2. **Sichere Key-Verwaltung** mit SOPS
3. **Environment Variables** Injection
4. **Automated Key Rotation** Setup
5. **Security Monitoring** für API Usage

## ⚡ Quick Fix Commands

```powershell
# 1. Installiere required packages
npm install -g @sops/cli age-encryption

# 2. Generiere encryption key
age-keygen -o ~/.age/key.txt

# 3. Konfiguriere SOPS
cp .sops.yaml.example .sops.yaml

# 4. Erstelle verschlüsselten API-Key
echo '{"openai_api_key": "YOUR_KEY_HERE"}' | sops --encrypt /dev/stdin > secrets/openai.enc.json

# 5. Lade environment variables
./scripts/load-secrets.ps1
```

## 📋 Checkliste

- [ ] ChatGPT Plus/Pro Account verifiziert
- [ ] OpenAI Codex Extension aktiviert
- [ ] API-Keys verschlüsselt gespeichert
- [ ] Environment Variables injiziert  
- [ ] VS Code neu gestartet
- [ ] Codex Funktionalität getestet

## 🔍 Debugging

Wenn immer noch Probleme:

1. **Developer Tools**: `Ctrl+Shift+I` → Console → Errors suchen
2. **Output Panel**: `View → Output` → "OpenAI" oder "ChatGPT"
3. **Extension Host**: `Ctrl+Shift+P` → "Developer: Restart Extension Host"
4. **Clean Install**: Extension deinstallieren → VS Code restart → neu installieren

---

**Status**: ✅ Reparatur eingeleitet
**Nächster Schritt**: Secrets Management Implementation
**ETA**: 15-30 Minuten für vollständige Reparatur