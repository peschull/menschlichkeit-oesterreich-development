#!/bin/bash

# GitHub Codespace Quick Fix Script
# Menschlichkeit Österreich

echo "🔧 CODESPACE QUICK FIX"
echo "====================="

# Detect current problems
echo "🔍 Diagnosing issues..."

# Check services
echo "📊 Service Status:"
if pgrep -f "npm.*dev" > /dev/null; then
    echo "✅ Development services running"
else
    echo "❌ Development services NOT running"
    START_SERVICES=true
fi

# Check database
if sudo systemctl is-active --quiet mariadb; then
    echo "✅ MariaDB is running"
else
    echo "❌ MariaDB is NOT running"
    sudo systemctl start mariadb
fi

# Check SSH key
if [ -f ~/.ssh/id_ed25519 ]; then
    echo "✅ SSH Key found"
else
    echo "❌ SSH Key missing"
    if [ ! -z "$SSH_PRIVATE_KEY" ]; then
        echo "🔧 Setting up SSH key from secret..."
        mkdir -p ~/.ssh
        chmod 700 ~/.ssh
        echo "$SSH_PRIVATE_KEY" > ~/.ssh/id_ed25519
        chmod 600 ~/.ssh/id_ed25519
        echo "✅ SSH Key configured"
    else
        echo "⚠️ SSH_PRIVATE_KEY secret not available"
    fi
fi

# Check .env
if [ -f .env ]; then
    echo "✅ .env file exists"
else
    echo "❌ .env file missing"
    echo "🔧 Creating .env from template..."
    cp .env.example .env

    # Replace with codespace-specific values
    if [ ! -z "$CODESPACE_NAME" ]; then
        sed -i "s|http://localhost:8001|https://$CODESPACE_NAME-8001.preview.app.github.dev|g" .env
        sed -i "s|http://localhost:8000|https://$CODESPACE_NAME-8000.preview.app.github.dev|g" .env
        sed -i "s|http://localhost:3000|https://$CODESPACE_NAME-3000.preview.app.github.dev|g" .env
    fi
    echo "✅ .env configured for Codespace"
fi

# Install missing dependencies
echo "📦 Checking dependencies..."
if [ ! -d node_modules ]; then
    echo "🔧 Installing npm dependencies..."
    npm install
fi

if [ ! -d vendor ]; then
    echo "🔧 Installing composer dependencies..."
    composer install --ignore-platform-reqs --no-interaction
fi

# Start services if needed
if [ "$START_SERVICES" = true ]; then
    echo "🚀 Starting development services..."
    npm run dev:all &
    echo "✅ Services starting..."
fi

# Show status
echo ""
echo "🌐 CODESPACE URLS:"
if [ ! -z "$CODESPACE_NAME" ]; then
    echo "   Frontend: https://$CODESPACE_NAME-3000.preview.app.github.dev"
    echo "   API:      https://$CODESPACE_NAME-8001.preview.app.github.dev"
    echo "   CRM:      https://$CODESPACE_NAME-8000.preview.app.github.dev"
    echo "   n8n:      https://$CODESPACE_NAME-5678.preview.app.github.dev"
else
    echo "   Not in Codespace environment"
fi

echo ""
echo "✅ Quick fix complete!"
echo "🎯 Next: Wait 30 seconds, then access the URLs above"
