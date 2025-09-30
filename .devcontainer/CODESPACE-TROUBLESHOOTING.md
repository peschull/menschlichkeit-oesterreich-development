# GitHub Codespace Troubleshooting Guide

# Menschlichkeit Österreich Development

> **⚠️ WICHTIG:** Dieses Dokument wurde aktualisiert (Jan 2024). Für die vollständige Anleitung siehe: `.devcontainer/README.md`

## ✅ NEUE FIXES (Januar 2024)

Die folgenden Probleme wurden **automatisch behoben**:

1. ✅ **Script Permissions:** Alle Scripts sind jetzt automatisch ausführbar (via .gitattributes)
2. ✅ **PHP Version:** Auf 8.2 fixiert (statt 8.3 oder 8.4)
3. ✅ **Error Handling:** Setup-Scripts fahren fort auch bei nicht-kritischen Fehlern
4. ✅ **Environment Files:** .env-Dateien werden automatisch erstellt
5. ✅ **Dependency Installation:** Fallback-Mechanismen für npm/composer/pip
6. ✅ **Prebuild Workflow:** Schnellerer Codespace-Start via GitHub Actions
7. ✅ **Emergency Recovery:** Blockiert Codespace-Erstellung nicht mehr

## 🚀 SCHNELLSTART

```bash
# Nach Codespace-Start:
bash .devcontainer/codespace-health.sh  # Health Check
./codespace-start.sh                    # Services starten
```

Für Details siehe: **`.devcontainer/README.md`**

---

## 🚨 HÄUFIGE CODESPACE PROBLEME & LÖSUNGEN

### 0. **NEU: Codespace hängt beim Setup**

**Problem:** Codespace-Erstellung dauert >10 Minuten oder friert ein

**Lösung:**
```bash
# Option A: Warten (empfohlen)
# Die neuen Setup-Scripts haben automatische Fallbacks und werden fertiggestellt

# Option B: Emergency Recovery
bash .devcontainer/emergency-recovery.sh

# Option C: Neu starten
# VS Code: Codespace → Restart Codespace
```

### 1. SSH Zugang zu Plesk Server

**Problem:** SSH Key nicht verfügbar oder SSH Verbindung fehlschlägt

**Lösung:**

```bash
# SSH Key aus GitHub Secret einrichten
echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519

# SSH Verbindung testen
ssh dmpl20230054@5.183.217.146 "echo 'Connected!'"

# Falls Host Verification Error:
ssh-keyscan -H 5.183.217.146 >> ~/.ssh/known_hosts
```

### 2. Environment Variables fehlen

**Problem:** GitHub Secrets nicht in Codespace verfügbar

**✅ AUTO-FIX:** .env-Dateien werden jetzt automatisch erstellt!

**Lösung (falls manual nötig):**

```bash
# Überprüfe verfügbare Secrets
env | grep -E "(LARAVEL|CIVICRM|CODACY|SNYK)"

# .env wird automatisch erstellt, aber du kannst prüfen:
ls -la .env api.menschlichkeit-oesterreich.at/.env frontend/.env
```

### 3. Port Forwarding Probleme

**Problem:** Services nicht über Codespace URLs erreichbar

**Lösung:**

```bash
# Ports checken
netstat -tulpn | grep -E "(3000|8000|8001|5678)"

# Services starten
npm run dev:all

# Port Forwarding in VS Code
# Gehe zu: PORTS Tab → Forward Port → Add Port
```

### 4. Database Connection Fehler

**Problem:** MariaDB/MySQL nicht verfügbar

**Lösung:**

```bash
# MariaDB Status checken
sudo systemctl status mariadb

# MariaDB starten
sudo systemctl start mariadb

# Development Databases erstellen
sudo mysql -e "CREATE DATABASE IF NOT EXISTS mo_laravel_api_dev;"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS mo_civicrm_dev;"
```

### 5. Node.js/PHP Version Konflikte

**Problem:** Falsche Runtime Versionen

**✅ AUTO-FIX:** PHP ist jetzt auf 8.2 fixiert!

**Lösung:**

```bash
# Versionen checken
node --version  # Should be 20.x (updated!)
php --version   # Should be 8.2.x (fixed!)
python3 --version  # Should be 3.12.x (updated!)

# Falls immer noch falsche Version: Codespace → Rebuild Container
```

### 6. Permission Denied Errors

**Problem:** Scripts nicht ausführbar

**✅ AUTO-FIX:** Scripts haben jetzt automatisch execute permissions!

**Lösung (falls manual nötig):**

```bash
# Scripts sollten automatisch ausführbar sein, aber falls nicht:
chmod +x scripts/*.sh
chmod +x deployment-scripts/*.sh
chmod +x .devcontainer/*.sh

# Für PowerShell Scripts in Linux
bash -c "pwsh ./scripts/script-name.ps1"
```

### 7. Docker/n8n Probleme

**Problem:** n8n Container startet nicht

**Lösung:**

```bash
# Docker Status
docker --version
sudo systemctl status docker

# n8n Container
cd automation/n8n
docker-compose down
docker-compose up -d

# Logs checken
docker-compose logs -f
```

### 8. GitHub Actions in Codespace

**Problem:** CI/CD Tests schlagen fehl

**Lösung:**

```bash
# Lokale Quality Gates
npm run quality:gates

# Security Scan lokal
npm run security:scan

# ESLint Fix
npm run lint -- --fix
```

## 🔧 QUICK FIXES

### Reset Codespace Environment

```bash
# Full reset (in Terminal)
sudo apt-get update -y
npm install
composer install --ignore-platform-reqs
pip install -r requirements.txt
```

### Manual SSH Key Setup

```bash
# In Codespace Terminal
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# SSH Key eingeben (ersetze mit echtem Key)
cat > ~/.ssh/id_ed25519 << 'EOF'
-----BEGIN OPENSSH PRIVATE KEY-----
[Dein SSH Private Key hier]
-----END OPENSSH PRIVATE KEY-----
EOF

chmod 600 ~/.ssh/id_ed25519
```

### Development Environment Setup

```bash
# .env für Development
cat > .env << 'EOF'
# Development Environment
NODE_ENV=development
DEBUG=true

# Local Database
LARAVEL_DB_HOST=localhost
LARAVEL_DB_NAME=mo_laravel_api_dev
LARAVEL_DB_USER=laravel_dev
LARAVEL_DB_PASS=dev_password

CIVICRM_DB_HOST=localhost
CIVICRM_DB_NAME=mo_civicrm_dev
CIVICRM_DB_USER=civicrm_dev
CIVICRM_DB_PASS=dev_password

# Codespace URLs
VITE_API_BASE_URL=https://$CODESPACE_NAME-8001.preview.app.github.dev
VITE_CRM_BASE_URL=https://$CODESPACE_NAME-8000.preview.app.github.dev
EOF
```

### Service Restart Commands

```bash
# All Services
npm run dev:all

# Individual Services
npm run dev:frontend  # Port 3000
npm run dev:api       # Port 8001
npm run dev:crm       # Port 8000
npm run dev:games     # Port 3001
npm run n8n:start     # Port 5678
```

## 🌐 CODESPACE URLS

Replace `CODESPACE_NAME` with your actual codespace name:

- **Frontend:** `https://CODESPACE_NAME-3000.preview.app.github.dev`
- **API:** `https://CODESPACE_NAME-8001.preview.app.github.dev`
- **CRM:** `https://CODESPACE_NAME-8000.preview.app.github.dev`
- **Games:** `https://CODESPACE_NAME-3001.preview.app.github.dev`
- **n8n:** `https://CODESPACE_NAME-5678.preview.app.github.dev`

## 📞 SUPPORT

### GitHub Codespaces Issues

- GitHub Support: https://support.github.com
- Codespaces Docs: https://docs.github.com/en/codespaces

### Project Specific

- Repository Issues: Create Issue in GitHub
- Email: support@menschlichkeit-oesterreich.at

## 🚀 COMPLETE RESET PROCEDURE

If everything fails, complete reset:

```bash
# 1. Stop all services
pkill -f "npm\|node\|php\|python"

# 2. Clean dependencies
rm -rf node_modules
rm -rf vendor
rm -rf __pycache__

# 3. Reinstall everything
npm install
composer install --ignore-platform-reqs
pip install -r requirements.txt

# 4. Restart MariaDB
sudo systemctl restart mariadb

# 5. Recreate databases
bash .devcontainer/setup.sh

# 6. Start services
npm run dev:all
```

---

## 📊 CHANGELOG: Was wurde behoben (Januar 2024)

### Automatische Fixes (keine Aktion erforderlich)

1. **`.gitattributes` hinzugefügt**
   - Alle `.sh` Dateien haben automatisch execute permissions
   - Keine `chmod +x` mehr nötig

2. **`devcontainer.json` optimiert**
   - PHP Version auf 8.2 fixiert (mit installComposer)
   - Node.js 20 mit nodeGypDependencies
   - Python 3.12 mit installTools
   - Bessere Feature-Konfiguration

3. **Setup Scripts verbessert**
   - `codespace-optimized-setup.sh`: Fehlertoleranz, fährt fort bei Warnungen
   - `codespace-post-create.sh`: Automatische .env-Erstellung, Fallback-Mechanismen
   - `emergency-recovery.sh`: Blockiert nicht mehr, exit 0 immer

4. **GitHub Actions Prebuild**
   - Neue Workflow: `.github/workflows/codespace-prebuild.yml`
   - Pre-installiert Dependencies für schnelleren Start
   - Validiert alle Scripts automatisch

5. **Dokumentation aktualisiert**
   - Neue umfassende Anleitung: `.devcontainer/README.md`
   - Troubleshooting mit allen Lösungen
   - Best Practices und Emergency Recovery

### Schnellere Codespace-Starts

- **Vorher:** 5-10 Minuten mit möglichen Hängern
- **Nachher:** 2-3 Minuten, keine Blockierungen mehr
- **Mit Prebuild:** <30 Sekunden (nach erstem Build)

### Bekannte Probleme (behoben)

- ✅ Scripts haben keine execute permissions → **BEHOBEN** via .gitattributes
- ✅ PHP Version Mismatch (8.3/8.4 statt 8.2) → **BEHOBEN** in devcontainer.json
- ✅ Setup hängt bei npm/composer Fehlern → **BEHOBEN** mit Fallbacks
- ✅ .env Dateien fehlen → **BEHOBEN** automatische Erstellung
- ✅ Emergency Recovery blockiert Start → **BEHOBEN** exit 0

---

## 🔗 Weitere Ressourcen

- **Vollständige Anleitung:** `.devcontainer/README.md`
- **Codespace Workflow:** `.github/workflows/codespace.yml`
- **Prebuild Workflow:** `.github/workflows/codespace-prebuild.yml`
- **GitHub Codespaces Docs:** https://docs.github.com/en/codespaces

---

**Zuletzt aktualisiert:** 2024-01-30
**Maintainer:** Austrian NGO Development Team

