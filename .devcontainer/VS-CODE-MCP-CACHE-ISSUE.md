# VS Code MCP Cache Issue — Kurz & Definitiv ✅

## Problem
VS Code/Copilot zeigt Fehlermeldungen zu **MCP‑Servern, die nicht in deiner `mcp.json` stehen** (z. B. `hashicorp/terraform-mcp-server`, `chromedevtools/chrome-devtools-mcp`, `oraios/serena`).

**Ursache:** Copilot bringt eine **interne, kuratierte Server‑Liste** mit und versucht einige davon vorzuschlagen/zu starten. Diese Einträge existieren teils **nicht im Registry** und sind **unabhängig** von deiner `mcp.json`. Die Hinweise bleiben wegen **Extension‑State/Cache** bestehen.

---

## Lösung in 3 Schritten (empfohlen)

1) **Developer Window neu laden**  
   - `Cmd/Ctrl + Shift + P` → **Developer: Reload Window**  
   - Effekt: leert den In‑Memory‑Cache und lädt deine echte `mcp.json` neu.

2) **Auto‑Start umschalten**  
   - Settings (`Cmd/Ctrl + ,`) → Suche nach **“MCP Server”**  
   - **“MCP‑Server beim Senden einer Chatnachricht automatisch starten”** einmal **deaktivieren** → kurz warten → **wieder aktivieren**.

3) **Echte Server testen** (aus deiner `mcp.json`)  
   ```
   @github List my repositories
   @playwright Generate E2E test for login page
   @contextx7 Show React hooks documentation
   @figma Show design tokens
   @notion List all project tasks
   @codacy Show code quality score
   @markitdown Convert docs/*.docx to markdown
   ```

---

## Verifizieren, dass nur deine Server aktiv sind

```bash
# Auflisten
cat mcp.json | jq -r '.mcpServers | keys[]'

# Zählen
cat mcp.json | jq -r '.mcpServers | keys[]' | wc -l

# JSON validieren
jq . mcp.json >/dev/null && echo "✅ VALID" || echo "❌ INVALID"
```

**Nicht vorhandene Vorschlags‑Server prüfen (sollte Fehler werfen):**
```bash
npm view hashicorp/terraform-mcp-server
npm view chromedevtools/chrome-devtools-mcp
npm view oraios/serena
```

---

## Warum passiert das?
- Copilot/VS Code hat eine **interne Vorschlagsliste** (“empfohlene MCP‑Server”).
- Diese Einträge werden **getestet/gestartet**, selbst wenn sie **nicht** in `mcp.json` stehen.
- Einige existieren (noch) nicht → **Fehler** → bleiben im **Cache**, bis das Fenster neu geladen wird.

---

## Best Practices

- MCP‑Einträge **nur nach Registry‑Check** hinzufügen (`npm view <pkg>`, `pip index versions <pkg>`).
- Änderungen an `mcp.json` **inkrementell** vornehmen und testen.
- Bei Ghost‑Meldungen **Reload Window** ausführen statt neue Server zu installieren.

---

**Status:** documented  
**Zuletzt aktualisiert:** 2025‑10‑09
