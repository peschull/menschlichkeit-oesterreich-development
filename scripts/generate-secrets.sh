#!/bin/bash

# Generate Secrets Script
# Generates all required security keys for the application

set -e

echo "🔐 Menschlichkeit Österreich - Secret Generator"
echo "================================================"
echo ""

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo "❌ Error: openssl is not installed"
    echo "   Please install openssl first"
    exit 1
fi

# Create secrets directory if not exists
SECRETS_DIR="$(dirname "$0")/../secrets"
mkdir -p "$SECRETS_DIR"

OUTPUT_FILE="$SECRETS_DIR/generated-secrets.env"

echo "📝 Generating secrets..."
echo ""

# Generate JWT Secret
JWT_SECRET=$(openssl rand -base64 32)
echo "✅ JWT Secret generated"

# Generate n8n Encryption Key
N8N_ENCRYPTION_KEY=$(openssl rand -base64 32)
echo "✅ n8n Encryption Key generated"

# Generate App Key for Laravel
APP_KEY=$(openssl rand -base64 32)
echo "✅ Laravel App Key generated"

# Generate random passwords
N8N_ADMIN_PASSWORD=$(openssl rand -base64 16 | tr -d "=+/" | cut -c1-16)
echo "✅ n8n Admin Password generated"

# Write to file
cat > "$OUTPUT_FILE" << EOF
# Generated Secrets - $(date)
# WICHTIG: Diese Datei NICHT in Git committen!

# API Authentication
JWT_SECRET=$JWT_SECRET

# n8n Workflow Automation
N8N_ENCRYPTION_KEY=$N8N_ENCRYPTION_KEY
N8N_BASIC_AUTH_USER=moe_admin
N8N_BASIC_AUTH_PASSWORD=$N8N_ADMIN_PASSWORD

# Laravel API
APP_KEY=base64:$APP_KEY

# Nächste Schritte:
# 1. Kopiere diese Werte in die entsprechenden .env Dateien
# 2. Füge Database Credentials manuell hinzu (von Plesk)
# 3. Füge CiviCRM Keys hinzu (nach Installation)
EOF

echo ""
echo "✅ Secrets generated successfully!"
echo ""
echo "📄 Secrets saved to: $OUTPUT_FILE"
echo ""
echo "🔒 Security Notice:"
echo "   - Diese Datei ist bereits in .gitignore"
echo "   - NIEMALS in Git committen"
echo "   - Sichere Aufbewahrung (Password Manager)"
echo ""
echo "📋 Nächste Schritte:"
echo "   1. cat $OUTPUT_FILE"
echo "   2. Kopiere Secrets in .env Dateien"
echo "   3. Füge Database Credentials hinzu"
echo "   4. Teste mit: npm run dev:all"
echo ""
