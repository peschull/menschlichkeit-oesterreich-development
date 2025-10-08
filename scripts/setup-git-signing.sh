#!/bin/bash

echo "🔧 Git Configuration & Push Setup"
echo "================================="

# Check if GPG key exists
if ! gpg --list-secret-keys --keyid-format=long | grep -q "sec"; then
    echo "📄 Erstelle GPG Schlüssel für Git-Signierung..."
    
    # Generate GPG key non-interactively
    cat > gpg-key-config << EOF
%echo Generating GPG key for Menschlichkeit Österreich
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: Menschlichkeit Österreich Development
Name-Email: dev@menschlichkeit-oesterreich.at
Expire-Date: 2y
%no-protection
%commit
%echo GPG key generation complete
EOF

    # Generate key
    gpg --batch --generate-key gpg-key-config
    rm gpg-key-config
    
    echo "✅ GPG Schlüssel erstellt"
else
    echo "✅ GPG Schlüssel bereits vorhanden"
fi

# Get GPG key ID
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep "sec" | awk '{print $2}' | cut -d'/' -f2 | head -1)

if [ -z "$GPG_KEY_ID" ]; then
    echo "❌ Fehler: GPG Schlüssel konnte nicht gefunden werden"
    exit 1
fi

echo "🔑 GPG Key ID: $GPG_KEY_ID"

# Configure Git
echo "⚙️ Konfiguriere Git für Signierung..."
git config user.name "Peter Schuller"
git config user.email "schuller.peter@outlook.at"
git config user.signingkey "$GPG_KEY_ID"
git config commit.gpgsign true
git config tag.gpgsign true

# Export public key to add to GitHub
echo "📤 Exportiere öffentlichen Schlüssel für GitHub..."
gpg --armor --export "$GPG_KEY_ID" > github-gpg-public-key.asc

echo
echo "🎯 NÄCHSTE SCHRITTE:"
echo "==================="
echo "1. Öffentlichen GPG-Schlüssel zu GitHub hinzufügen:"
echo "   - Datei: github-gpg-public-key.asc"  
echo "   - GitHub: Settings → SSH and GPG keys → New GPG key"
echo "   - URL: https://github.com/settings/gpg/new"
echo
echo "2. Commit signieren und pushen:"
echo "   git commit --amend --no-edit -S"
echo "   git push origin chore/figma-mcp-make"
echo
echo "3. Oder Branch Protection deaktivieren:"
echo "   - GitHub Repository → Settings → Branches"
echo "   - 'Require signed commits' deaktivieren"
echo
echo "📋 GPG Key für GitHub (Kopieren und in GitHub einfügen):"
echo "========================================================="
cat github-gpg-public-key.asc