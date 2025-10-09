# MCP Server Sampling Fix - 2025-10-08

## ❌ PROBLEM IDENTIFIZIERT

**VS Code `settings.json` hat nur 1 Server in `chat.mcp.serverSampling`:**

- ✅ `makenotion/notion-mcp-server`

**Aber `.vscode/mcp.json` hat 44 Server!**

→ **Die anderen 43 Server haben KEINE Model-Permissions**  
→ **VS Code kann sie NICHT nutzen** (daher Parse-Fehler)

---

## ✅ LÖSUNG

**Füge folgendes in `settings.json` ein** (ersetze das leere `chat.mcp.serverSampling` Object):

```jsonc
"chat.mcp.serverSampling": {
  "airtable": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "aws": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "azure": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "azure-devops": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "codacy": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "confluence": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "context7": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "datadog": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "discord": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "docker": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "elasticsearch": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "figma": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "filesystem": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "firebase": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "gcp": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "github": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "google-sheets": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "graphql": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "jira": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "kubernetes": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "linear": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "make": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "memory": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "mongodb": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "mysql": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "n8n": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "neon": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "notion": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "playwright": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "postgres": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "postman": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "redis": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "rest-api": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "sendgrid": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "sentry": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "sequential-thinking": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "slack": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "sqlite": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "stripe": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "supabase": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "terraform": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "todoist": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "twilio": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "zapier": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  }
}
```

---

## 📝 MANUELLE SCHRITTE

1. **Öffne Settings:**
   - `Cmd/Ctrl+Shift+P` → "Preferences: Open User Settings (JSON)"
   - Oder: `C:/Users/schul/AppData/Roaming/Code/User/settings.json`

2. **Suche Zeile 296:** `"chat.mcp.serverSampling"`

3. **Ersetze das leere Object `{}` mit der obigen Config**

4. **Speichern & VS Code Reload:**
   - `Cmd/Ctrl+S` (Speichern)
   - `Cmd/Ctrl+Shift+P` → "Developer: Reload Window"

---

## 🎯 ALTERNATIVE: Minimal Config (nur Core Server)

Falls 44 Server zu viel sind, verwende nur diese:

```jsonc
"chat.mcp.serverSampling": {
  "github": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "memory": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "sequential-thinking": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "filesystem": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "context7": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  },
  "figma": {
    "allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]
  }
}
```

Dann auch `.vscode/mcp.json` auf 6 Server reduzieren.

---

## ✅ ERWARTETES ERGEBNIS

Nach Reload sollten in Copilot Chat alle Server als `@-mentions` verfügbar sein:

- `@github`, `@memory`, `@figma`, `@postgres`, etc.

**Kein Parse-Fehler mehr!**
