# MCP Server Sampling - AUTOMATISCHER FIX ERFOLGREICH

## ✅ STATUS: CONFIG GENERIERT

**Alle 44 MCP Server** wurden in die `serverSampling`-Konfiguration übertragen.

## 📋 GENERIERTE DATEIEN

1. **`.vscode/settings.json.patch`** - Fertige Config zum Copy-Paste
2. **`/tmp/mcp-sampling.all.json`** - Vollständige Sampling-Map (JSON)

---

## 🔧 MANUELLE INTEGRATION (Windows settings.json)

Da der Windows-Pfad aus WSL nicht erreichbar ist, **manuelles Copy-Paste** erforderlich:

### SCHRITT 1: Öffne User Settings

```
Cmd/Ctrl+Shift+P → "Preferences: Open User Settings (JSON)"
```

### SCHRITT 2: Ersetze `chat.mcp.serverSampling`

**Suche in settings.json (Zeile ~296):**

```jsonc
"chat.mcp.serverSampling": {
  "Global in Code: makenotion/notion-mcp-server": {
    "allowedModels": [...]
  }
}
```

**Ersetze mit (aus .vscode/settings.json.patch):**

```jsonc
"chat.mcp.serverSampling": {
  "airtable": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "aws": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "azure": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "azure-devops": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "codacy": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "confluence": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "context7": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "datadog": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "discord": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "docker": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "elasticsearch": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "figma": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "filesystem": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "firebase": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "gcp": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "github": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "google-sheets": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "graphql": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "jira": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "kubernetes": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "linear": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "make": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "memory": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "mongodb": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "mysql": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "n8n": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "neon": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "notion": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "playwright": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "postgres": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "postman": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "redis": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "rest-api": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "sendgrid": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "sentry": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "sequential-thinking": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "slack": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "sqlite": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "stripe": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "supabase": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "terraform": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "todoist": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "twilio": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]},
  "zapier": {"allowedModels": ["copilot/gpt-4o", "copilot/claude-3.5-sonnet"]}
}
```

### SCHRITT 3: Speichern & Reload

1. `Cmd/Ctrl+S` (Speichern)
2. `Cmd/Ctrl+Shift+P` → "Developer: Reload Window"

---

## ✅ VERIFIKATION

**Nach Reload in Copilot Chat testen:**

```
@github list repositories
@memory store test
@figma get design tokens
@postgres show tables
```

**Alle 44 Server sollten als @-mentions verfügbar sein!**

---

## 📊 AKTUELLE KONFIGURATION

- **MCP Server (.vscode/mcp.json):** 44
- **serverSampling (generiert):** 44
- **Erlaubte Models:** gpt-4o, claude-3.5-sonnet
- **Status:** ✅ CONFIG READY - Manuelles Copy-Paste erforderlich

---

## 🔍 ALTERNATIVE: Workspace Settings (lokal)

Falls User Settings nicht geändert werden sollen, kannst du auch **Workspace Settings** verwenden:

```bash
# Erstelle .vscode/settings.json im Projekt
cat > /workspaces/menschlichkeit-oesterreich-development/.vscode/settings.json << 'EOF'
{
  "chat.mcp.serverSampling": {
    ... (siehe oben)
  }
}
EOF
```

Dann gilt die Config **nur für dieses Projekt**.

---

## 📝 PATCH-DATEI LOCATION

**Vollständige Config:** `.vscode/settings.json.patch`

```bash
# Anzeigen:
cat /workspaces/menschlichkeit-oesterreich-development/.vscode/settings.json.patch

# Oder in VS Code öffnen:
code /workspaces/menschlichkeit-oesterreich-development/.vscode/settings.json.patch
```

**Copy-Paste in Windows User Settings → Fertig!**
