# 🚀 GitHub Codespace - Schnellstart-Anleitung

## ✅ Codespace erfolgreich starten

### 1️⃣ Codespace erstellen

1. Gehe zum Repository: `peschull/menschlichkeit-oesterreich-development`
2. Klicke auf **Code** → **Codespaces** → **Create codespace on main**
3. Warte 3-5 Minuten während das Setup läuft

### 2️⃣ Nach dem Start

Der Codespace führt automatisch folgende Schritte aus:

1. **onCreate**: Systemsetup und Tools installieren
2. **postCreate**: Dependencies installieren (npm, composer, pip)
3. **postStart**: Services bereitstellen

Du erkennst, dass alles fertig ist, wenn im Terminal steht:
```
🎉 Austrian NGO Codespace is ready! Run: ./codespace-start.sh to begin development
```

### 3️⃣ Services starten

Im Terminal ausführen:
```bash
# Alle Services auf einmal starten
npm run dev:all

# Oder einzeln starten:
npm run dev:frontend  # React Frontend (Port 3000)
npm run dev:api       # FastAPI Backend (Port 8001)
npm run dev:crm       # CRM Development (Port 8000)
npm run dev:games     # Educational Games (Port 3000)
```

### 4️⃣ URLs aufrufen

Services sind über VS Code Port Forwarding erreichbar:

- **Frontend**: Klick auf "Ports" Tab → Port 3000 → Globe-Icon
- **API**: Port 8001 → Globe-Icon
- **CRM**: Port 8000 → Globe-Icon

Oder direkt über URLs (ersetze `{CODESPACE_NAME}` mit deinem Namen):
```
https://{CODESPACE_NAME}-3000.preview.app.github.dev  # Frontend
https://{CODESPACE_NAME}-8001.preview.app.github.dev  # API
https://{CODESPACE_NAME}-8000.preview.app.github.dev  # CRM
```

---

## 🔧 Probleme beheben

### Problem: "Codespace startet nicht"

**Lösung 1: Warte länger**
- Erster Start dauert 5-10 Minuten
- Schau in den Terminal-Output

**Lösung 2: Rebuild Container**
- `Ctrl+Shift+P` → "Codespaces: Rebuild Container"
- Warte bis Rebuild fertig ist

**Lösung 3: Neu erstellen**
```bash
# Alten Codespace löschen und neu erstellen
# GitHub → Codespaces → ... → Delete
```

### Problem: "Services starten nicht"

```bash
# Quick-Fix ausführen
npm run codespace:fix

# Oder manuell diagnostizieren
npm run codespace:health
```

### Problem: "Port nicht erreichbar"

1. **Ports Tab öffnen**: Klick auf "PORTS" in VS Code
2. **Port forwarding prüfen**: Ports 3000, 8000, 8001 sollten sichtbar sein
3. **Manuell forwarden**: Rechtsklick in Ports Tab → "Forward a Port"

### Problem: "Dependencies fehlen"

```bash
# Alle Dependencies neu installieren
npm run codespace:setup
npm run codespace:post-start

# Oder einzeln
npm ci                    # Node.js dependencies
composer install          # PHP dependencies
pip install -r requirements.txt  # Python dependencies
```

### Problem: "Git/SSH funktioniert nicht"

```bash
# SSH Key von GitHub Secret laden (falls konfiguriert)
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Manuell SSH Key einfügen
nano ~/.ssh/id_ed25519
# Key einfügen, speichern
chmod 600 ~/.ssh/id_ed25519

# Testen
ssh -T git@github.com
```

### Problem: "MariaDB läuft nicht"

```bash
# MariaDB starten
sudo systemctl start mariadb

# Status prüfen
sudo systemctl status mariadb

# Falls DB nicht nötig: SQLite als Fallback verwenden
```

---

## 📋 Nützliche Befehle

### System Status

```bash
# Gesamtstatus prüfen
npm run codespace:health

# Services prüfen
ps aux | grep -E "(node|python|php)"

# Ports prüfen
netstat -tlnp | grep -E ":(3000|8000|8001|5678)"
```

### Logs anschauen

```bash
# Service logs (wenn mit codespace-start.sh gestartet)
tail -f logs/frontend.log
tail -f logs/api.log
tail -f logs/crm.log

# Oder direkt beim Start beobachten
npm run dev:frontend  # Im Terminal sichtbar
```

### Cleanup

```bash
# Processes stoppen
pkill -f "node.*dev"
pkill -f "uvicorn"
pkill -f "php.*server"

# Cache leeren
npm cache clean --force
composer clear-cache

# Node modules neu installieren
rm -rf node_modules
npm ci
```

---

## 🔐 GitHub Secrets (Optional)

Für erweiterte Features (Plesk-Zugang, externe APIs) konfiguriere GitHub Secrets:

1. **Repository Settings** → **Secrets and variables** → **Codespaces**
2. Füge hinzu:
   - `SSH_PRIVATE_KEY`: SSH Key für Plesk Server
   - `PLESK_HOST`: Server-Adresse (z.B. `user@server-ip`)
   - `CODACY_API_TOKEN`: Code Quality Analysis
   - `SNYK_TOKEN`: Security Scanning

Diese Secrets werden automatisch als Umgebungsvariablen geladen.

---

## 🎯 Best Practices

### Während der Entwicklung

1. **Services einzeln starten**: Starte nur was du brauchst
   ```bash
   npm run dev:frontend  # Nur Frontend
   ```

2. **Regelmäßig speichern**: Commits häufig pushen
   ```bash
   git add .
   git commit -m "Feature X implementiert"
   git push
   ```

3. **Health Checks**: Bei Problemen sofort diagnostizieren
   ```bash
   npm run codespace:health
   ```

### Nach der Arbeit

1. **Services stoppen**: Spart Ressourcen
   ```bash
   pkill -f "node\|python\|php"
   ```

2. **Codespace stoppen**: GitHub → Codespaces → Stop
3. **Oder automatisch**: Codespaces stoppen nach 30min Inaktivität

---

## 📞 Support

Bei anhaltenden Problemen:

1. **Quick-Fix ausführen**: `npm run codespace:fix`
2. **Health Report erstellen**: `npm run codespace:health > health.txt`
3. **Issue erstellen**: Mit `health.txt` als Attachment
4. **Dokumentation**: Siehe `.devcontainer/CODESPACE-TROUBLESHOOTING.md`

---

**Version**: 2.0
**Zuletzt aktualisiert**: 2025-01-03
**Status**: ✅ Production Ready
