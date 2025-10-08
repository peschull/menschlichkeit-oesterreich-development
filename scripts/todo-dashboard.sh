#!/bin/bash

echo "📋 === TODO STATUS DASHBOARD ==="
echo "Datum: $(date '+%Y-%m-%d %H:%M')"
echo

# Kategorien extrahieren
echo "🔴 HOHE PRIORITÄT (Diese Woche - Fällig: 2025-10-12):"
echo "======================================================"
grep -A 3 "CiviCRM‑Datenbank initialisieren" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
grep -A 3 "API‑Authentication" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1  
grep -A 3 "Frontend‑Router erweitern" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
grep -A 3 "n8n‑Workflows konfigurieren" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
echo

echo "🔒 SICHERHEIT & COMPLIANCE (Fällig: 2025-10-19):"
echo "================================================"
grep -A 3 "Keycloak SSO Setup" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
grep -A 3 "DSGVO‑Compliance" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
grep -A 3 "Security Hardening" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
echo

echo "🧾 CRM AUTOMATISIERUNG (Fällig: 2025-11-09):"
echo "============================================"
grep -A 3 "CiviSEPA Setup" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
grep -A 3 "Bankabgleich automatisieren" /workspaces/menschlichkeit-oesterreich-development/TODO.md | head -1
echo

echo "📊 STATISTIKEN:"
echo "==============="
total_items=$(grep -c '^\- \[' /workspaces/menschlichkeit-oesterreich-development/TODO.md)
completed_items=$(grep -c '^\- \[x\]' /workspaces/menschlichkeit-oesterreich-development/TODO.md) 
pending_items=$(grep -c '^\- \[ \]' /workspaces/menschlichkeit-oesterreich-development/TODO.md)

echo "- Gesamt TODO Items: $total_items"
echo "- Abgeschlossene Items: $completed_items"  
echo "- Offene Items: $pending_items"
echo "- Prozent abgeschlossen: $(( completed_items * 100 / total_items ))%"
echo

echo "🎯 NÄCHSTE KRITISCHE AKTIONEN:"
echo "=============================="
echo "1. Branch Protection & Required Checks (0.5h)"
echo "2. CiviCRM Database Setup (3h)" 
echo "3. JWT Authentication API (4h)"
echo "4. GitHub Actions CI/CD Pipeline (2h)"
echo

echo "🚨 ÜBERFÄLLIGE ITEMS (Fällig: 2025-10-05):"
echo "=========================================="
echo "✅ Codacy-Analyse für Contact.tsx (erledigt)"
echo "✅ ESLint-Probleme beheben (erledigt)"  
echo "✅ Staging-Deployment (erledigt)"
echo

echo "⚡ MCP SERVER STATUS (heute repariert):"
echo "====================================="
echo "✅ 6 stabile MCP Server aktiv"
echo "✅ Problematische Server entfernt"
echo "✅ Security-Fix: Token → Environment Variable"
echo "❌ Git Push blockiert (Branch Protection)"
echo

echo "🔄 NÄCHSTER SCHRITT:"
echo "==================="
echo "VS Code neu laden → MCP Server testen → Branch Protection konfigurieren"