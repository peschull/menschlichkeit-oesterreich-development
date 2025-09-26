#!/usr/bin/env powershell
# Codex VS Code Extension Aktivierungs-Script
# Für ChatGPT Plus Benutzer

Write-Host "🚀 Codex VS Code Extension Aktivierung startet..." -ForegroundColor Green
Write-Host ""

# Schritt 1: Extension Status prüfen
Write-Host "📋 Schritt 1: Extension Status prüfen" -ForegroundColor Yellow
$codexExtension = code-insiders --list-extensions | Select-String "openai.chatgpt"
if ($codexExtension) {
    Write-Host "✅ OpenAI Codex Extension ist installiert: $codexExtension" -ForegroundColor Green
} else {
    Write-Host "❌ OpenAI Codex Extension nicht gefunden! Installiere..." -ForegroundColor Red
    code-insiders --install-extension openai.chatgpt
    Start-Sleep 3
}

Write-Host ""

# Schritt 2: VS Code öffnen mit Test-Datei
Write-Host "📋 Schritt 2: VS Code mit Codex Test-Datei öffnen" -ForegroundColor Yellow
Write-Host "Öffne vscode-codex-test.ts..." -ForegroundColor Cyan

# Test-Datei in VS Code öffnen
code-insiders "D:\Arbeitsverzeichniss\openai-python\examples\vscode-codex-test.ts"

Start-Sleep 2

Write-Host ""

# Schritt 3: Anweisungen für Benutzer
Write-Host "📋 Schritt 3: Manuelle Codex Aktivierung" -ForegroundColor Yellow
Write-Host ""
Write-Host "JETZT IN VS CODE AUSFÜHREN:" -ForegroundColor Red -BackgroundColor White
Write-Host ""
Write-Host "1️⃣  Drücken Sie: Ctrl+Shift+P" -ForegroundColor Cyan
Write-Host "2️⃣  Tippen Sie: 'Codex: Open Codex'" -ForegroundColor Cyan
Write-Host "3️⃣  Drücken Sie: Enter" -ForegroundColor Cyan
Write-Host "4️⃣  Klicken Sie: 'Sign in with ChatGPT'" -ForegroundColor Cyan
Write-Host "5️⃣  Melden Sie sich mit Ihrem ChatGPT Plus Account an" -ForegroundColor Cyan
Write-Host ""

# Schritt 4: Test-Anweisungen
Write-Host "📋 Schritt 4: Codex testen (nach erfolgreicher Anmeldung)" -ForegroundColor Yellow
Write-Host ""
Write-Host "TESTS IN DER GEÖFFNETEN DATEI:" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Test 1: TODO-CodeLens" -ForegroundColor White
Write-Host "   - Schauen Sie auf Zeile 8-9 (TODO-Kommentar)" -ForegroundColor Gray
Write-Host "   - Sollte 'Implement with Codex' CodeLens zeigen" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Test 2: Inline Completion" -ForegroundColor White  
Write-Host "   - Gehen Sie zu Zeile 18-20 (SepaMandate constructor)" -ForegroundColor Gray
Write-Host "   - Beginnen Sie zu tippen -> automatische Vorschläge" -ForegroundColor Gray
Write-Host ""
Write-Host "🎯 Test 3: Chat Integration" -ForegroundColor White
Write-Host "   - Markieren Sie Zeilen 38-41 (validateAustrianAddress)" -ForegroundColor Gray
Write-Host "   - Rechtsklick -> 'Add to Codex chat'" -ForegroundColor Gray
Write-Host ""

# Schritt 5: Erfolgs-Indikatoren
Write-Host "📋 Schritt 5: Erfolgs-Indikatoren" -ForegroundColor Yellow
Write-Host ""
Write-Host "✅ Codex funktioniert wenn:" -ForegroundColor Green
Write-Host "   - Codex Sidebar ist sichtbar (linke Seite)" -ForegroundColor Gray
Write-Host "   - TODO-Kommentare zeigen CodeLens" -ForegroundColor Gray
Write-Host "   - Beim Tippen erscheinen AI-Vorschläge" -ForegroundColor Gray
Write-Host "   - 'Codex: New Chat' funktioniert" -ForegroundColor Gray
Write-Host ""

# Schritt 6: Fehlerbehebung
Write-Host "📋 Schritt 6: Fehlerbehebung" -ForegroundColor Yellow
Write-Host ""
Write-Host "❌ Falls Codex nicht funktioniert:" -ForegroundColor Red
Write-Host "   1. Prüfen Sie Ihren ChatGPT Plus Plan Status" -ForegroundColor Gray
Write-Host "   2. Ctrl+Shift+P -> 'Developer: Reload Window'" -ForegroundColor Gray  
Write-Host "   3. Browser-Cookies für openai.com aktivieren" -ForegroundColor Gray
Write-Host "   4. Firewall/Proxy Einstellungen prüfen" -ForegroundColor Gray
Write-Host ""

Write-Host "🎉 VS Code ist bereit für Codex! Folgen Sie den Anweisungen oben." -ForegroundColor Green -BackgroundColor Black
Write-Host ""

# VS Code Fokus setzen
Write-Host "Fokussiere VS Code Fenster..." -ForegroundColor Cyan
Start-Sleep 1

# Versuche VS Code in Vordergrund zu bringen
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Window {
    [DllImport("user32.dll")]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

$vscodeWindow = [Window]::FindWindow($null, "*Visual Studio Code*")
if ($vscodeWindow -ne [IntPtr]::Zero) {
    [Window]::SetForegroundWindow($vscodeWindow)
    Write-Host "✅ VS Code Fenster fokussiert!" -ForegroundColor Green
} else {
    Write-Host "⚠️  VS Code Fenster nicht gefunden. Wechseln Sie manuell zu VS Code." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🚀 STARTEN SIE JETZT: Ctrl+Shift+P -> 'Codex: Open Codex'" -ForegroundColor White -BackgroundColor Red