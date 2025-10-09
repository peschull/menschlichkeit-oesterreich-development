# MCP 44-Server Aktivierung - 2025-10-08

## ✅ STATUS: AKTIVIERT

**44 MCP Server** sind jetzt in `.vscode/mcp.json` aktiv.

## Aktive Server (Auszug)

```
airtable, aws, azure, azure-devops, codacy, confluence, context7,
datadog, discord, docker, elasticsearch, figma, firebase, gcp,
github, google-sheets, graphql, jira, kubernetes, linear, make,
mongodb, mysql, n8n, neon, notion, postgres, redis, sentry,
sendgrid, slack, sqlite, stripe, supabase, terraform, todoist,
twilio, zapier, ... (44 total)
```

## NÄCHSTER SCHRITT

**VS Code MUSS neu geladen werden:**

```
Cmd/Ctrl+Shift+P → "Developer: Reload Window"
```

**Danach testen in Copilot Chat:**

```
@github list repositories
@memory store test
@figma get design tokens
```

## Falls Parse-Fehler erneut auftritt

Das bedeutet VS Code hat Problem mit der Anzahl oder spezifischen Servern.

**Debugging-Strategie:**

1. Check VS Code Extension Logs
2. Teste Server einzeln (Environment-Variablen)
3. Reduziere auf Core-Server (6-10)

**Core Server Empfehlung (falls 44 zu viel):**

- github, memory, sequential-thinking, filesystem, context7, figma

Siehe: `quality-reports/MCP-DEBUG-REPORT-2025-10-08.md`
