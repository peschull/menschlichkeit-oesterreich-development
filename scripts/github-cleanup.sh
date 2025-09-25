#!/usr/bin/env bash

# GitHub Repository Cleanup Script
# Hilft beim Identifizieren und Entfernen alter Repositories

echo "🔍 GitHub Repository Cleanup Helper"
echo "=================================="
echo

# GitHub CLI prüfen
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) ist nicht installiert."
    echo "   Installation: https://cli.github.com/"
    echo "   Oder verwenden Sie die manuelle Methode aus GITHUB-REPOSITORY-CLEANUP-GUIDE.md"
    exit 1
fi

# GitHub Authentication prüfen
if ! gh auth status &> /dev/null; then
    echo "❌ GitHub CLI nicht authentifiziert."
    echo "   Führen Sie aus: gh auth login"
    exit 1
fi

echo "✅ GitHub CLI ist bereit"
echo

# Alle Repositories des Users anzeigen
echo "📋 Ihre GitHub Repositories:"
echo "----------------------------"
gh repo list --limit 50 | grep -E "(menschlichkeit|crm|api|frontend|design|drupal)" || echo "Keine relevanten Repositories gefunden"

echo
echo "🎯 Empfohlene Aktionen:"
echo "======================"
echo
echo "1. Überprüfen Sie die obige Liste auf alte Repositories"
echo "2. Für jedes Repository, das jetzt konsolidiert ist:"
echo "   gh repo delete OWNER/REPOSITORY --yes"
echo
echo "⚠️  WARNUNG: Repository-Löschung ist UNWIDERRUFLICH!"
echo
echo "Beispiel-Befehle (falls Repositories existieren):"
echo "gh repo delete peschull/menschlichkeit-frontend --yes"
echo "gh repo delete peschull/menschlichkeit-api --yes" 
echo "gh repo delete peschull/crm-system --yes"
echo
echo "✅ Behalten Sie nur: menschlichkeit-oesterreich-development"