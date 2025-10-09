# Git Push Problem - Diagnose & Lösung

## 🚨 Problem identifiziert

**Error:** "Commits must have verified signatures" - Branch Protection verlangt signierte Commits

## ✅ GitHub Token & GPG Status

- ✅ **GitHub Token verfügbar:** `${GITHUB_TOKEN:0:20}...`
- ✅ **API Access:** Funktioniert (User: peschull)
- ✅ **Git Credentials:** Konfiguriert in `~/.git-credentials`
- ✅ **Environment:** `GITHUB_TOKEN` in `~/.bashrc` und `.env`
- ✅ **GPG Key ID:** Verfügbar in GitHub Secrets (`${GPG_KEY_ID}`)
- ⚠️ **GPG Config:** Noch nicht in Git konfiguriert

## 🔧 Lösungsoptionen

### Option 1: GPG-Signierung aktivieren (Dauerhaft)

```bash
# 1. GPG Key ID aus Secrets verwenden (bereits verfügbar)
export GPG_KEY_ID="${GPG_KEY_ID}"  # Aus GitHub Secrets

# 2. Git für Signierung konfigurieren
git config --global user.signingkey "${GPG_KEY_ID}"
git config --global commit.gpgsign true

# 3. Commits signieren und pushen
git commit --amend --no-edit -S
git push origin chore/figma-mcp-make

# 4. Falls GPG-Schlüssel noch nicht vorhanden:
gpg --list-secret-keys --keyid-format=long
# Dann GPG-Schlüssel aus Backup importieren oder neu generieren
```

### Option 2: Branch Protection anpassen (Empfohlen)

**GitHub Repository Settings:**

1. Gehe zu: `https://github.com/peschull/menschlichkeit-oesterreich-development/settings/branches`
2. Editiere Branch Protection Rule für `chore/figma-mcp-make`
3. Deaktiviere: "Require signed commits"
4. Speichere Änderungen

**Danach:**

```bash
git push origin chore/figma-mcp-make
```

### Option 3: Neuen Branch erstellen (Workaround)

```bash
# 1. Neuen Branch ohne Protection erstellen
git checkout -b fix/mcp-server-final

# 2. Änderungen pushen
git push origin fix/mcp-server-final

# 3. Pull Request erstellen
gh pr create --title "🔧 Fix MCP Server Configuration" --body "MCP Server Reparatur mit 6 stabilen Servern"
```

## 📋 Was funktioniert

- ✅ **Lokale Änderungen:** MCP Server erfolgreich repariert
- ✅ **Konfiguration:** 6 stabile Server (100% Erfolgsrate)  
- ✅ **Security Fix:** Tokens → Environment Variables
- ✅ **Dokumentation:** Umfassende Berichte erstellt
- ✅ **Git Authentication:** GitHub Token funktioniert

## ❌ Was blockiert

- ❌ **Branch Protection:** Verlangt signierte Commits
- ❌ **Git Push:** Wird remote abgelehnt
- ❌ **GPG Setup:** Nicht für alle Commits konfiguriert

## 🎯 Empfohlene Aktion

**Kurzfristig:** Option 2 (Branch Protection anpassen)
**Langfristig:** Option 1 (GPG-Signierung einrichten)

## 💾 Backups verfügbar

- `.vscode/mcp-backup-*.json` - Originale MCP-Konfiguration
- `quality-reports/MCP-*REPORT*.md` - Detaillierte Reparatur-Dokumentation
- `fix-mcp-servers.js` - Automatisiertes Cleanup-Tool

---

**Status:** Lokal vollständig repariert, Push durch Branch Protection blockiert  
**Nächster Schritt:** Branch Protection Settings anpassen oder GPG einrichten
