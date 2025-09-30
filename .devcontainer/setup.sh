#!/bin/bash

# GitHub Codespace Setup Script - Menschlichkeit Österreich
# Läuft beim ersten Start des Codespace

echo "🚀 Menschlichkeit Österreich - Codespace Setup"
echo "============================================="

# Set robust error handling
set +e  # Don't exit on errors during setup
export DEBIAN_FRONTEND=noninteractive

# Emergency recovery fallback
if [ "$1" = "--emergency" ]; then
    echo "🚨 Running emergency recovery mode"
    bash .devcontainer/emergency-recovery.sh
    exit $?
fi

# System Updates with timeout protection
echo "📦 System Updates..."
timeout 300 sudo apt-get update -y || echo "⚠️ Update timeout, continuing..."
sudo apt-get install -y curl wget git build-essential || echo "⚠️ Some packages failed to install"

# PHP Extensions für CiviCRM
echo "🔧 PHP Extensions für CiviCRM..."
sudo apt-get install -y php8.2-mysql php8.2-xml php8.2-mbstring php8.2-curl php8.2-zip php8.2-intl php8.2-gd php8.2-cli php8.2-common || echo "⚠️ Some PHP extensions failed to install"

# MariaDB für lokale Development (with fallback to SQLite)
echo "🗄️ Database Setup..."
if sudo apt-get install -y mariadb-server mariadb-client; then
    sudo systemctl start mariadb 2>/dev/null || echo "⚠️ MariaDB start failed, will use fallback"
    sudo systemctl enable mariadb 2>/dev/null || true
    echo "✅ MariaDB installiert"
else
    echo "⚠️ MariaDB installation failed, using SQLite fallback"
    sudo apt-get install -y sqlite3 || echo "⚠️ SQLite installation also failed"
fi

# Create development databases (with error handling)
echo "📊 Creating development databases..."
if command -v mysql >/dev/null 2>&1 && sudo systemctl is-active --quiet mariadb; then
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS mo_laravel_api_dev;" 2>/dev/null || echo "⚠️ Laravel DB creation failed"
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS mo_civicrm_dev;" 2>/dev/null || echo "⚠️ CiviCRM DB creation failed"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'laravel_dev'@'localhost' IDENTIFIED BY 'dev_password';" 2>/dev/null || echo "⚠️ Laravel user creation failed"
    sudo mysql -e "CREATE USER IF NOT EXISTS 'civicrm_dev'@'localhost' IDENTIFIED BY 'dev_password';" 2>/dev/null || echo "⚠️ CiviCRM user creation failed"
    sudo mysql -e "GRANT ALL PRIVILEGES ON mo_laravel_api_dev.* TO 'laravel_dev'@'localhost';" 2>/dev/null || true
    sudo mysql -e "GRANT ALL PRIVILEGES ON mo_civicrm_dev.* TO 'civicrm_dev'@'localhost';" 2>/dev/null || true
    sudo mysql -e "FLUSH PRIVILEGES;" 2>/dev/null || true
    echo "✅ Development databases setup completed"
else
    echo "⚠️ MariaDB not available, using environment-based database URLs"
    export DATABASE_URL="sqlite:///tmp/development.db"
    echo "DATABASE_URL=sqlite:///tmp/development.db" >> .env
fi

# SSH Key Setup für Plesk Access
echo "🔐 SSH Key Setup..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Wenn SSH_PRIVATE_KEY Secret verfügbar ist, setup
if [ ! -z "$SSH_PRIVATE_KEY" ]; then
    echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_ed25519
    chmod 600 ~/.ssh/id_ed25519
    echo "✅ SSH Key für Plesk Server konfiguriert"
else
    echo "⚠️ SSH_PRIVATE_KEY Secret nicht verfügbar - manual setup erforderlich"
fi

# n8n Docker Setup
echo "🤖 n8n Docker Setup..."
cd automation/n8n
if [ -f docker-compose.yml ]; then
    docker-compose pull
    echo "✅ n8n Docker Images bereit"
fi
cd ../..

# Composer Dependencies (ignore platform requirements for Codespace)
echo "📦 Composer Dependencies..."
if [ -f composer.json ]; then
    composer install --ignore-platform-reqs --no-interaction
fi

# Frontend Dependencies
echo "⚡ Frontend Dependencies..."
if [ -d frontend ] && [ -f frontend/package.json ]; then
    cd frontend
    npm install
    cd ..
fi

# Python Dependencies
echo "🐍 Python Dependencies..."
if [ -f requirements.txt ]; then
    pip install -r requirements.txt
fi

# Set up git configuration
echo "📝 Git Configuration..."
git config --global user.name "Codespace User"
git config --global user.email "codespace@menschlichkeit-oesterreich.at"

# Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x scripts/*.sh
chmod +x scripts/*.ps1
chmod +x deployment-scripts/*.sh

# Create development .env if not exists
echo "⚙️ Development Environment Setup..."
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Development .env created from template"
fi

# Development ports info
echo ""
echo "🌐 DEVELOPMENT PORTS:"
echo "   Frontend (React):     http://localhost:3000"
echo "   Games Platform:       http://localhost:3001"
echo "   API (FastAPI):        http://localhost:8001"
echo "   CRM (CiviCRM):        http://localhost:8000"
echo "   Website:              http://localhost:8080"
echo "   n8n Automation:       http://localhost:5678"
echo ""

echo "✅ Codespace Setup Complete!"
echo "🎯 Next: Run 'npm run dev:all' to start all services"
