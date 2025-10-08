#!/bin/bash

echo "🔧 Git Token & Push Fix Script"
echo "=============================="

# Prüfe GitHub Token
if [ -n "$GITHUB_TOKEN" ]; then
    echo "✅ GitHub Token verfügbar: ${GITHUB_TOKEN:0:20}..."
    
    # API Test
    USER=$(curl -s -H "Authorization: Bearer ${GITHUB_TOKEN}" https://api.github.com/user | jq -r '.login' 2>/dev/null)
    if [ "$USER" = "peschull" ]; then
        echo "✅ GitHub API funktioniert (User: $USER)"
    else
        echo "❌ GitHub API Test fehlgeschlagen"
        exit 1
    fi
else
    echo "❌ GITHUB_TOKEN nicht gefunden"
    echo "💡 Lösung: source ~/.bashrc && source .env"
    exit 1
fi

# Prüfe GPG Key ID
if [ -n "$GPG_KEY_ID" ]; then
    echo "✅ GPG Key ID verfügbar: ${GPG_KEY_ID}"
    
    # Prüfe ob GPG-Schlüssel in Git konfiguriert ist
    CURRENT_KEY=$(git config --global user.signingkey 2>/dev/null)
    if [ "$CURRENT_KEY" = "$GPG_KEY_ID" ]; then
        echo "✅ GPG bereits in Git konfiguriert"
    else
        echo "⚠️ GPG nicht in Git konfiguriert - wird automatisch gesetzt"
        git config --global user.signingkey "${GPG_KEY_ID}"
        git config --global commit.gpgsign true
        echo "✅ GPG für Git konfiguriert"
    fi
else
    echo "⚠️ GPG_KEY_ID nicht gefunden (optional)"
    echo "💡 Für signierte Commits: GPG_KEY_ID in Secrets setzen"
fi

# Git Konfiguration prüfen
echo -e "\n🔍 Git Konfiguration:"
echo "User: $(git config user.name)"
echo "Email: $(git config user.email)"
echo "GPG Signing: $(git config commit.gpgsign)"

# Push-Optionen
echo -e "\n🚀 Push-Optionen:"
echo "1. Standard Push (kann durch Branch Protection blockiert werden)"
echo "2. GPG Signierung mit Secrets aktivieren + Push"
echo "3. GPG Signierung deaktivieren + Push"
echo "4. Neuen Branch erstellen (ohne Protection)"

read -p "Wähle Option (1-4): " option

case $option in
    1)
        echo "Versuche Standard Push..."
        git push origin chore/figma-mcp-make
        ;;
    2)
        if [ -n "$GPG_KEY_ID" ]; then
            echo "Aktiviere GPG Signierung mit Secrets..."
            git config --global user.signingkey "${GPG_KEY_ID}"
            git config --global commit.gpgsign true
            git commit --amend --no-edit -S
            git push origin chore/figma-mcp-make
        else
            echo "❌ GPG_KEY_ID nicht verfügbar"
            exit 1
        fi
        ;;
    3)
        echo "Deaktiviere GPG Signierung temporär..."
        git config --global commit.gpgsign false
        git push origin chore/figma-mcp-make
        ;;
    4)
        echo "Erstelle neuen Branch..."
        BRANCH_NAME="fix/mcp-server-$(date +%Y%m%d-%H%M)"
        git checkout -b "$BRANCH_NAME"
        git push origin "$BRANCH_NAME"
        echo "✅ Branch erstellt: $BRANCH_NAME"
        echo "💡 Erstelle jetzt einen Pull Request:"
        echo "gh pr create --title 'Fix: MCP Server Configuration' --body 'Reparierte MCP Server Konfiguration'"
        ;;
    *)
        echo "Ungültige Option"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo "✅ Git Push erfolgreich!"
else
    echo "❌ Git Push fehlgeschlagen"
    echo "💡 Nächste Schritte:"
    echo "   - Branch Protection Settings prüfen"
    echo "   - GPG-Schlüssel einrichten"  
    echo "   - Oder neuen Branch verwenden (Option 3)"
fi