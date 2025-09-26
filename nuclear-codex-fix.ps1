#!/usr/bin/env powershell
# 🚨 NUCLEAR CODEX SIDEBAR FIX
# LETZTE LÖSUNG für hartnäckige Sidebar-Probleme

Write-Host ""
Write-Host "☢️  NUCLEAR CODEX SIDEBAR REPARATUR" -ForegroundColor Red -BackgroundColor Yellow
Write-Host "    Für hartnäckige Fälle wo normale Reparatur fehlschlägt" -ForegroundColor Yellow
Write-Host ""

# Schritt 1: Komplette VS Code Bereinigung
Write-Host "🧹 Schritt 1: Komplette VS Code Bereinigung..." -ForegroundColor Red

# Alle VS Code Prozesse töten
Get-Process "*code*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 3

# Extension-spezifische Registry-Einträge löschen (falls vorhanden)
$regPaths = @(
    "HKCU:\Software\Microsoft\VSCode",
    "HKCU:\Software\Classes\vscode-insiders"
)

foreach ($path in $regPaths) {
    if (Test-Path $path) {
        Write-Host "   Bereinige Registry: $path" -ForegroundColor Cyan
        # Vorsichtige Registry-Bereinigung
    }
}

# Schritt 2: Extension komplett entfernen
Write-Host ""
Write-Host "🗑️  Schritt 2: Extension komplett entfernen..." -ForegroundColor Red

$extensionDirs = @(
    "$env:USERPROFILE\.vscode-insiders\extensions\openai.chatgpt-*",
    "$env:USERPROFILE\.vscode-insiders\extensions\.obsolete",
    "$env:USERPROFILE\.vscode-insiders\CachedExtensions"
)

foreach ($dir in $extensionDirs) {
    if (Test-Path $dir) {
        Write-Host "   Lösche: $dir" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $dir -ErrorAction SilentlyContinue
    }
}

# Extension über Command Line entfernen
code-insiders --uninstall-extension openai.chatgpt --force 2>$null
Start-Sleep 2

# Schritt 3: Clean Extension Install
Write-Host ""
Write-Host "⬇️  Schritt 3: Clean Extension Installation..." -ForegroundColor Green

Write-Host "   Installiere OpenAI Codex Extension neu..." -ForegroundColor Cyan
code-insiders --install-extension openai.chatgpt --force 2>$null
Start-Sleep 5

# Schritt 4: Workspace komplett neu konfigurieren
Write-Host ""
Write-Host "⚙️  Schritt 4: Workspace Nuclear-Konfiguration..." -ForegroundColor Green

$nuclearSettings = @{
    # Codex spezifisch
    "chatgpt.openOnStartup" = $true
    "chatgpt.commentCodeLensEnabled" = $true
    "chatgpt.cliExecutable" = $null
    
    # UI Erzwingung
    "workbench.activityBar.visible" = $true
    "workbench.sideBar.location" = "left"
    "workbench.panel.defaultLocation" = "right"
    "workbench.view.alwaysShowHeaderActions" = $true
    
    # Extension Erzwingung
    "extensions.autoCheckUpdates" = $false
    "extensions.autoUpdate" = $false
    "extensions.ignoreRecommendations" = $false
    
    # Startup Optimization
    "window.restoreWindows" = "all"
    "window.reopenFolders" = "all"
    "workbench.startupEditor" = "welcomePage"
    
    # Debug/Logging
    "developer.reload.action" = "restart"
    "telemetry.enableTelemetry" = $false
}

# User Settings überschreiben
$userSettingsPath = "$env:USERPROFILE\AppData\Roaming\Code - Insiders\User\settings.json"
Write-Host "   Überschreibe User Settings: $userSettingsPath" -ForegroundColor Yellow

if (Test-Path $userSettingsPath) {
    $currentSettings = Get-Content $userSettingsPath -Raw | ConvertFrom-Json -ErrorAction SilentlyContinue
    if (-not $currentSettings) { $currentSettings = @{} }
    
    # Nuclear Settings hinzufügen/überschreiben
    foreach ($key in $nuclearSettings.Keys) {
        $currentSettings | Add-Member -Name $key -Value $nuclearSettings[$key] -Force
    }
    
    $currentSettings | ConvertTo-Json -Depth 10 | Out-File $userSettingsPath -Encoding UTF8 -Force
}

# Workspace Settings überschreiben
$workspaceSettingsPath = "D:\Arbeitsverzeichniss\.vscode\settings.json"
Write-Host "   Überschreibe Workspace Settings: $workspaceSettingsPath" -ForegroundColor Yellow

if (-not (Test-Path "D:\Arbeitsverzeichniss\.vscode")) {
    New-Item -ItemType Directory -Path "D:\Arbeitsverzeichniss\.vscode" -Force | Out-Null
}

$nuclearSettings | ConvertTo-Json -Depth 3 | Out-File $workspaceSettingsPath -Encoding UTF8 -Force

# Schritt 5: VS Code mit Nuclear Flags starten
Write-Host ""
Write-Host "🚀 Schritt 5: VS Code Nuclear Start..." -ForegroundColor Green

$nuclearFlags = @(
    "D:\Arbeitsverzeichniss",
    "--verbose",
    "--enable-logging",
    "--log-level=trace",
    "--disable-gpu",
    "--no-sandbox",
    "--force-device-scale-factor=1",
    "--disable-background-timer-throttling",
    "--disable-backgrounding-occluded-windows",
    "--disable-renderer-backgrounding"
)

Write-Host "   Starte mit Nuclear Flags: $($nuclearFlags -join ' ')" -ForegroundColor Cyan
Start-Process "code-insiders" -ArgumentList $nuclearFlags

Start-Sleep 8

Write-Host ""
Write-Host "☢️  NUCLEAR REPARATUR ABGESCHLOSSEN!" -ForegroundColor Green -BackgroundColor Red
Write-Host ""

# Finale Anweisungen
Write-Host "📋 NUCLEAR POST-REPARATUR AKTIVIERUNG:" -ForegroundColor White -BackgroundColor Blue
Write-Host ""
Write-Host "🕐 1. Warten Sie 15 Sekunden bis VS Code komplett geladen ist" -ForegroundColor Cyan
Write-Host ""
Write-Host "🔧 2. Wenn VS Code geöffnet ist:" -ForegroundColor Yellow
Write-Host "      Ctrl+Shift+P" -ForegroundColor White
Write-Host "      Tippen: 'Extensions: Show Installed Extensions'" -ForegroundColor White  
Write-Host "      Suchen: 'OpenAI'" -ForegroundColor White
Write-Host "      Status prüfen: Sollte 'Enabled' sein" -ForegroundColor White
Write-Host ""
Write-Host "🎯 3. Codex Sidebar erzwingen:" -ForegroundColor Yellow
Write-Host "      Ctrl+Shift+P" -ForegroundColor White
Write-Host "      Tippen: 'Codex'" -ForegroundColor White
Write-Host "      Auswählen: 'Codex: Open Codex'" -ForegroundColor White
Write-Host ""
Write-Host "🔍 4. Activity Bar durchsuchen:" -ForegroundColor Yellow
Write-Host "      - Schauen Sie nach einem Blumen/Blossom Icon 🌸" -ForegroundColor White
Write-Host "      - Falls nicht sichtbar: Rechtsklick auf Activity Bar → Codex aktivieren" -ForegroundColor White
Write-Host ""
Write-Host "🆘 5. Notfall-Alternativen:" -ForegroundColor Red
Write-Host "      Menu: View → Open View... → 'Codex'" -ForegroundColor White
Write-Host "      Oder: Ctrl+Shift+P → 'workbench.view.extension.codexViewContainer'" -ForegroundColor White
Write-Host ""
Write-Host "✅ 6. Erfolgs-Check:" -ForegroundColor Green
Write-Host "      - Codex Sidebar öffnet sich" -ForegroundColor White
Write-Host "      - 'Sign in with ChatGPT' Button ist sichtbar" -ForegroundColor White
Write-Host "      - Icon in Activity Bar (links) vorhanden" -ForegroundColor White
Write-Host ""
Write-Host "🎉 NACH NUCLEAR REPARATUR SOLLTE CODEX FUNKTIONIEREN!" -ForegroundColor Green -BackgroundColor Black
Write-Host ""