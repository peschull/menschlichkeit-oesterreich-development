# GitHub Codespace Troubleshooting Guide

# Menschlichkeit Österreich Development

## 🚨 HÄUFIGE CODESPACE PROBLEME & LÖSUNGEN

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

**Lösung:**

```bash
# Überprüfe verfügbare Secrets
env | grep -E "(LARAVEL|CIVICRM|CODACY|SNYK)"

# Manual setup für Development
cp .env.example .env
# Dann .env mit Development-Werten editieren
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

**Lösung:**

```bash
# Versionen checken
node --version  # Should be 18.x
php --version   # Should be 8.4.x
python3 --version  # Should be 3.11.x

# Falls falsche Version, devcontainer.json prüfen
```

### 6. Permission Denied Errors

**Problem:** Scripts nicht ausführbar

**Lösung:**

```bash
# Scripts ausführbar machen
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
