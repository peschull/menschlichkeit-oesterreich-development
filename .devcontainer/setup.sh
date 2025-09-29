#!/bin/bash

# GitHub Codespace Setup Script - Menschlichkeit Österreich
# Läuft beim ersten Start des Codespace

echo "🚀 Menschlichkeit Österreich - Codespace Setup"
echo "============================================="

# System Updates
echo "📦 System Updates..."
sudo apt-get update -y
sudo apt-get upgrade -y

# PHP Extensions für CiviCRM
echo "🔧 PHP Extensions für CiviCRM..."
sudo apt-get install -y php8.1-mysql php8.1-xml php8.1-mbstring php8.1-curl php8.1-zip php8.1-intl php8.1-gd

# MariaDB für lokale Development
echo "🗄️ MariaDB Setup..."
sudo apt-get install -y mariadb-server mariadb-client
sudo systemctl start mariadb
sudo mysql_secure_installation --use-default

# Create development databases
echo "📊 Creating development databases..."
sudo mysql -e "CREATE DATABASE IF NOT EXISTS mo_laravel_api_dev;"
sudo mysql -e "CREATE DATABASE IF NOT EXISTS mo_civicrm_dev;"
sudo mysql -e "CREATE USER IF NOT EXISTS 'laravel_dev'@'localhost' IDENTIFIED BY 'dev_password';"
sudo mysql -e "CREATE USER IF NOT EXISTS 'civicrm_dev'@'localhost' IDENTIFIED BY 'dev_password';"
sudo mysql -e "GRANT ALL PRIVILEGES ON mo_laravel_api_dev.* TO 'laravel_dev'@'localhost';"
sudo mysql -e "GRANT ALL PRIVILEGES ON mo_civicrm_dev.* TO 'civicrm_dev'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

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
