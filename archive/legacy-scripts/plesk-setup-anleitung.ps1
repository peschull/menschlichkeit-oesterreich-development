# Automatisierte Database Setup Anleitung für Plesk Server
# Nach erfolgreichem Upload der Setup-Dateien

Write-Host "🎯 Plesk Database Setup - Finale Schritte" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "`n✅ Upload erfolgreich abgeschlossen!" -ForegroundColor Green
Write-Host "Alle Setup-Dateien sind auf dem Server verfügbar." -ForegroundColor Green

Write-Host "`n🔧 Database Setup ausführen:" -ForegroundColor Yellow
Write-Host "1. Öffne im Browser: https://menschlichkeit-oesterreich.at/plesk-db-setup.php?key=MO_SETUP_2025_SECURE_KEY" -ForegroundColor White
Write-Host "2. Gib das Database Root-Passwort ein" -ForegroundColor White
Write-Host "3. Führe das Setup aus (erstellt 3 Datenbanken + User)" -ForegroundColor White

Write-Host "`n📝 .env-Dateien erstellen:" -ForegroundColor Yellow
Write-Host "Nach erfolgreichem Database Setup:" -ForegroundColor Gray
Write-Host "• httpdocs/.env.template → httpdocs/.env (WordPress)" -ForegroundColor White
Write-Host "• api.menschlichkeit-oesterreich.at/.env.template → api.menschlichkeit-oesterreich.at/.env (Laravel)" -ForegroundColor White
Write-Host "• crm.menschlichkeit-oesterreich.at/.env.template → crm.menschlichkeit-oesterreich.at/.env (CiviCRM)" -ForegroundColor White

Write-Host "`n🔐 Sicherheits-Keys generieren:" -ForegroundColor Yellow
Write-Host "WordPress Salts: https://api.wordpress.org/secret-key/1.1/salt/" -ForegroundColor White
Write-Host "Laravel App Key: `php artisan key:generate` (im API-Verzeichnis)" -ForegroundColor White
Write-Host "CiviCRM Keys: Werden automatisch bei Installation generiert" -ForegroundColor White

Write-Host "`n🗂️ Hochgeladene Dateien:" -ForegroundColor Cyan
Write-Host "✓ plesk-db-setup.php (Database Setup Script)" -ForegroundColor Green
Write-Host "✓ httpdocs/.env.template (WordPress Konfiguration)" -ForegroundColor Green
Write-Host "✓ api.menschlichkeit-oesterreich.at/.env.template (Laravel API)" -ForegroundColor Green
Write-Host "✓ crm.menschlichkeit-oesterreich.at/.env.template (CiviCRM)" -ForegroundColor Green

Write-Host "`n⚠️  Wichtige Sicherheitshinweise:" -ForegroundColor Red
Write-Host "1. Setup-Script nach erfolgreicher Ausführung SOFORT löschen!" -ForegroundColor Red
Write-Host "2. Sichere Passwörter für alle Database-User verwenden" -ForegroundColor Red
Write-Host "3. .env-Dateien niemals in Version Control einchecken" -ForegroundColor Red
Write-Host "4. Regelmäßige Backups der Datenbanken erstellen" -ForegroundColor Red

Write-Host "`n🚀 Nach Database Setup verfügbar:" -ForegroundColor Green
Write-Host "• WordPress: https://menschlichkeit-oesterreich.at" -ForegroundColor White
Write-Host "• Laravel API: https://api.menschlichkeit-oesterreich.at" -ForegroundColor White
Write-Host "• CiviCRM: https://crm.menschlichkeit-oesterreich.at" -ForegroundColor White

Write-Host "`n💡 Bei Problemen:" -ForegroundColor Yellow
Write-Host "• Plesk Database Manager überprüfen" -ForegroundColor White
Write-Host "• PHP Error Logs in Plesk ansehen" -ForegroundColor White
Write-Host "• .env-Dateien auf korrekte Syntax prüfen" -ForegroundColor White

Write-Host "`n🎉 Viel Erfolg mit dem Multi-Domain Setup!" -ForegroundColor Green