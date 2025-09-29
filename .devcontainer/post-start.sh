#!/bin/bash

# Post-Start Script für GitHub Codespace
# Läuft bei jedem Start des Codespace

echo "🔄 Codespace Post-Start Setup"
echo "============================="

# MariaDB starten
echo "🗄️ Starting MariaDB..."
sudo systemctl start mariadb

# Check if SSH key is configured
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "✅ SSH Key gefunden - Plesk Zugang verfügbar"

    # Test SSH connection (non-blocking)
    if [ ! -z "$PLESK_HOST" ]; then
        echo "🔍 Testing Plesk SSH connection..."
        timeout 5 ssh -o ConnectTimeout=3 -o StrictHostKeyChecking=no "$PLESK_HOST" "echo 'SSH OK'" 2>/dev/null && echo "✅ Plesk SSH funktioniert" || echo "⚠️ Plesk SSH Test fehlgeschlagen"
    fi
else
    echo "⚠️ SSH Key nicht konfiguriert"
    echo "   Setup: echo \$SSH_PRIVATE_KEY > ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519"
fi

# Environment Variables Check
echo "🔍 Environment Check..."
[ ! -z "$CODACY_API_TOKEN" ] && echo "✅ Codacy Token verfügbar" || echo "❌ Codacy Token fehlt"
[ ! -z "$SNYK_TOKEN" ] && echo "✅ Snyk Token verfügbar" || echo "❌ Snyk Token fehlt"
[ ! -z "$LARAVEL_DB_PASS" ] && echo "✅ Laravel DB Password verfügbar" || echo "❌ Laravel DB Password fehlt"

# Port Status
echo ""
echo "🌐 Port Forwarding Status:"
echo "   Codespace URL: $CODESPACE_NAME-3000.preview.app.github.dev"
echo "   Frontend: https://$CODESPACE_NAME-3000.preview.app.github.dev"
echo "   API: https://$CODESPACE_NAME-8001.preview.app.github.dev"
echo "   CRM: https://$CODESPACE_NAME-8000.preview.app.github.dev"
echo "   n8n: https://$CODESPACE_NAME-5678.preview.app.github.dev"

# Quick Health Check
echo ""
echo "🏥 System Health Check:"
node --version && echo "✅ Node.js OK" || echo "❌ Node.js Problem"
php --version | head -1 && echo "✅ PHP OK" || echo "❌ PHP Problem"
python3 --version && echo "✅ Python OK" || echo "❌ Python Problem"
docker --version && echo "✅ Docker OK" || echo "❌ Docker Problem"

echo ""
echo "🚀 Ready to start development!"
echo "   Run: npm run dev:all"
