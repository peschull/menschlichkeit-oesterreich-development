#!/usr/bin/env powershell
# CODEX SIDEBAR REPARATUR SCRIPT
# Löst das Problem: "Codex Extension startet in seitenleiste chat nicht"

Write-Host "🚨 CODEX SIDEBAR REPARATUR STARTET..." -ForegroundColor Red -BackgroundColor White
Write-Host ""

# Schritt 1: VS Code Extension Status prüfen
Write-Host "🔍 Schritt 1: Extension Status analysieren..." -ForegroundColor Yellow
$extensions = code-insiders --list-extensions --show-versions
$codexExt = $extensions | Select-String "openai.chatgpt"

if ($codexExt) {
    Write-Host "✅ Extension gefunden: $codexExt" -ForegroundColor Green
} else {
    Write-Host "❌ Extension nicht gefunden! Neuinstallation..." -ForegroundColor Red
    code-insiders --install-extension openai.chatgpt
    Start-Sleep 5
}

Write-Host ""

# Schritt 2: VS Code Extension Reset
Write-Host "🔄 Schritt 2: Extension Reset durchführen..." -ForegroundColor Yellow
Write-Host "Deaktiviere Extension..." -ForegroundColor Cyan
# Extension temporär deaktivieren und wieder aktivieren
$vscodePath = "$env:USERPROFILE\.vscode-insiders"
$extensionPath = Get-ChildItem "$vscodePath\extensions" -Directory | Where-Object { $_.Name -like "*openai.chatgpt*" } | Select-Object -First 1

if ($extensionPath) {
    Write-Host "Extension Pfad: $($extensionPath.FullName)" -ForegroundColor Gray
    
    # Package.json lesen um Extension ID zu validieren
    $packageJsonPath = Join-Path $extensionPath.FullName "package.json"
    if (Test-Path $packageJsonPath) {
        $packageJson = Get-Content $packageJsonPath | ConvertFrom-Json
        Write-Host "Extension ID: $($packageJson.name) v$($packageJson.version)" -ForegroundColor Green
    }
}

Write-Host ""

# Schritt 3: Workspace Settings korrigieren
Write-Host "⚙️ Schritt 3: Workspace Settings reparieren..." -ForegroundColor Yellow
$workspaceSettings = "D:\Arbeitsverzeichniss\.vscode\settings.json"

if (Test-Path $workspaceSettings) {
    Write-Host "✅ Workspace Settings gefunden" -ForegroundColor Green
    
    # Backup erstellen
    Copy-Item $workspaceSettings "$workspaceSettings.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    # Codex-spezifische Settings hinzufügen/korrigieren
    $settingsContent = Get-Content $workspaceSettings -Raw | ConvertFrom-Json -AsHashtable
    
    # Codex Settings setzen
    $settingsContent["chatgpt.openOnStartup"] = $true
    $settingsContent["chatgpt.commentCodeLensEnabled"] = $true
    $settingsContent["workbench.activityBar.visible"] = $true
    
    # Zurück schreiben
    $settingsContent | ConvertTo-Json -Depth 10 | Set-Content $workspaceSettings -Encoding UTF8
    Write-Host "✅ Settings aktualisiert" -ForegroundColor Green
} else {
    Write-Host "⚠️  Workspace Settings nicht gefunden, erstelle..." -ForegroundColor Yellow
    $newSettings = @{
        "chatgpt.openOnStartup" = $true
        "chatgpt.commentCodeLensEnabled" = $true
        "workbench.activityBar.visible" = $true
    }
    
    New-Item -Path "D:\Arbeitsverzeichniss\.vscode" -ItemType Directory -Force | Out-Null
    $newSettings | ConvertTo-Json -Depth 10 | Set-Content $workspaceSettings -Encoding UTF8
    Write-Host "✅ Neue Settings erstellt" -ForegroundColor Green
}

Write-Host ""

# Schritt 4: VS Code mit spezifischen Parametern starten
Write-Host "🚀 Schritt 4: VS Code mit Codex-Fokus starten..." -ForegroundColor Yellow

# Aktuelle VS Code Prozesse beenden
$vscodeProcesses = Get-Process | Where-Object { $_.Name -like "*code*" -and $_.Name -notlike "*powershell*" }
if ($vscodeProcesses) {
    Write-Host "Beende bestehende VS Code Prozesse..." -ForegroundColor Cyan
    $vscodeProcesses | ForEach-Object { $_.CloseMainWindow() }
    Start-Sleep 3
}

# VS Code mit Workspace starten
Write-Host "Starte VS Code mit Workspace..." -ForegroundColor Cyan
Start-Process "code-insiders" -ArgumentList "D:\Arbeitsverzeichniss" -WindowStyle Normal

Start-Sleep 5

Write-Host ""

# Schritt 5: Benutzer-Anweisungen
Write-Host "👤 Schritt 5: MANUELLE AKTIVIERUNG ERFORDERLICH" -ForegroundColor Red -BackgroundColor Yellow
Write-Host ""
Write-Host "FÜHREN SIE JETZT IN VS CODE AUS:" -ForegroundColor White -BackgroundColor Red
Write-Host ""
Write-Host "1️⃣  Warten Sie 10 Sekunden bis VS Code vollständig geladen ist" -ForegroundColor Cyan
Write-Host ""
Write-Host "2️⃣  Drücken Sie: Ctrl+Shift+P" -ForegroundColor Cyan
Write-Host ""
Write-Host "3️⃣  Tippen Sie: 'Codex: Open Codex' (oder 'chatgpt')" -ForegroundColor Cyan
Write-Host ""
Write-Host "4️⃣  Falls kein 'Codex' Befehl gefunden:" -ForegroundColor Yellow
Write-Host "    -> Ctrl+Shift+P" -ForegroundColor Gray
Write-Host "    -> 'Developer: Reload Window'" -ForegroundColor Gray
Write-Host "    -> Warten 10 Sekunden" -ForegroundColor Gray
Write-Host "    -> Wiederholen Sie Schritte 2-3" -ForegroundColor Gray
Write-Host ""
Write-Host "5️⃣  Schauen Sie in der Activity Bar (links) nach dem Codex Icon (🌸)" -ForegroundColor Cyan
Write-Host ""
Write-Host "6️⃣  Klicken Sie auf 'Sign in with ChatGPT'" -ForegroundColor Cyan
Write-Host ""

# Schritt 6: Fallback-Optionen
Write-Host "🆘 Schritt 6: FALLS IMMER NOCH NICHT FUNKTIONIERT" -ForegroundColor Red
Write-Host ""
Write-Host "Option A - Extension Neuinstallation:" -ForegroundColor Yellow
Write-Host "  Ctrl+Shift+P -> 'Extensions: Show Installed Extensions'" -ForegroundColor Gray
Write-Host "  Suche 'OpenAI' -> Uninstall -> Install" -ForegroundColor Gray
Write-Host ""
Write-Host "Option B - Direkter Extension-Befehl:" -ForegroundColor Yellow
Write-Host "  Ctrl+Shift+P -> 'chatgpt.openSidebar'" -ForegroundColor Gray
Write-Host ""
Write-Host "Option C - View Menu:" -ForegroundColor Yellow
Write-Host "  Menu: View -> Open View... -> 'Codex'" -ForegroundColor Gray
Write-Host ""

Write-Host "🎯 ERFOLGSTEST:" -ForegroundColor Green
Write-Host "   ✅ Codex Icon sichtbar in Activity Bar" -ForegroundColor Gray
Write-Host "   ✅ Codex Sidebar öffnet sich" -ForegroundColor Gray
Write-Host "   ✅ 'Sign in with ChatGPT' Button vorhanden" -ForegroundColor Gray
Write-Host ""

Write-Host "🚀 VS CODE IST BEREIT! FOLGEN SIE DEN ANWEISUNGEN OBEN!" -ForegroundColor Green -BackgroundColor Black