#!/usr/bin/env powershell
# 🗑️ CODEX KOMPLETT ENTFERNEN
# Bereinigt alle Spuren der OpenAI Codex Extension für saubere Neuinstallation

Write-Host ""
Write-Host "🗑️  CODEX EXTENSION KOMPLETT ENTFERNEN" -ForegroundColor Red -BackgroundColor White
Write-Host "   Bereitet saubere Neuinstallation vor..." -ForegroundColor Yellow
Write-Host ""

# Schritt 1: Alle VS Code Prozesse beenden
Write-Host "🔄 Schritt 1: Alle VS Code Prozesse beenden..." -ForegroundColor Yellow

$vscodeProcesses = Get-Process "*Code*" -ErrorAction SilentlyContinue
if ($vscodeProcesses) {
    Write-Host "   Beende $($vscodeProcesses.Count) VS Code Prozesse..." -ForegroundColor Cyan
    $vscodeProcesses | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 3
    Write-Host "✅ VS Code Prozesse beendet" -ForegroundColor Green
} else {
    Write-Host "✅ Keine aktiven VS Code Prozesse" -ForegroundColor Green
}

# Schritt 2: Extension über Command Line deinstallieren
Write-Host ""
Write-Host "❌ Schritt 2: Extension deinstallieren..." -ForegroundColor Red

Write-Host "   Deinstalliere openai.chatgpt..." -ForegroundColor Cyan
$uninstallResult = code-insiders --uninstall-extension openai.chatgpt 2>&1
Write-Host "   Result: $uninstallResult" -ForegroundColor Gray

# Auch andere mögliche OpenAI Extensions entfernen
$possibleExtensions = @(
    "openai.chatgpt",
    "openai.codex", 
    "genieai.chatgpt-vscode",
    "danielsanmedium.dscodegpt"
)

foreach ($ext in $possibleExtensions) {
    Write-Host "   Entferne $ext..." -ForegroundColor Cyan
    code-insiders --uninstall-extension $ext 2>$null
}

Write-Host "✅ Extensions deinstalliert" -ForegroundColor Green

# Schritt 3: Extension-Verzeichnisse löschen
Write-Host ""
Write-Host "🗂️  Schritt 3: Extension-Verzeichnisse bereinigen..." -ForegroundColor Red

$extensionPaths = @(
    "$env:USERPROFILE\.vscode-insiders\extensions\openai.chatgpt-*",
    "$env:USERPROFILE\.vscode-insiders\extensions\openai.codex-*", 
    "$env:USERPROFILE\.vscode-insiders\extensions\genieai.chatgpt-vscode-*",
    "$env:USERPROFILE\.vscode-insiders\extensions\danielsanmedium.dscodegpt-*"
)

foreach ($path in $extensionPaths) {
    $dirs = Get-ChildItem -Path (Split-Path $path) -Filter (Split-Path $path -Leaf) -Directory -ErrorAction SilentlyContinue
    foreach ($dir in $dirs) {
        Write-Host "   Lösche: $($dir.FullName)" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $dir.FullName -ErrorAction SilentlyContinue
    }
}

Write-Host "✅ Extension-Verzeichnisse bereinigt" -ForegroundColor Green

# Schritt 4: Cache und temporäre Dateien löschen
Write-Host ""
Write-Host "🧹 Schritt 4: Cache bereinigen..." -ForegroundColor Red

$cachePaths = @(
    "$env:USERPROFILE\.vscode-insiders\CachedExtensions",
    "$env:USERPROFILE\.vscode-insiders\logs",
    "$env:USERPROFILE\.vscode-insiders\extensionHostLogsCache", 
    "$env:USERPROFILE\.vscode-insiders\User\workspaceStorage"
)

foreach ($cache in $cachePaths) {
    if (Test-Path $cache) {
        Write-Host "   Bereinige Cache: $cache" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $cache -ErrorAction SilentlyContinue
        Start-Sleep 1
    }
}

Write-Host "✅ Cache bereinigt" -ForegroundColor Green

# Schritt 5: Settings bereinigen
Write-Host ""
Write-Host "⚙️  Schritt 5: Codex-spezifische Settings entfernen..." -ForegroundColor Red

# User Settings bereinigen
$userSettingsPath = "$env:USERPROFILE\AppData\Roaming\Code - Insiders\User\settings.json"
if (Test-Path $userSettingsPath) {
    Write-Host "   Bereinige User Settings: $userSettingsPath" -ForegroundColor Cyan
    
    $content = Get-Content $userSettingsPath -Raw -ErrorAction SilentlyContinue
    if ($content) {
        # Entferne alle Codex/ChatGPT/OpenAI Settings
        $codexSettings = @(
            "chatgpt\.",
            "openai-chatgpt\.", 
            "genieai\.",
            "codegpt\.",
            "openai\.codex\."
        )
        
        $lines = $content -split "`n"
        $cleanedLines = @()
        
        foreach ($line in $lines) {
            $shouldKeep = $true
            foreach ($setting in $codexSettings) {
                if ($line -match $setting) {
                    $shouldKeep = $false
                    Write-Host "     Entfernt: $($line.Trim())" -ForegroundColor Gray
                    break
                }
            }
            if ($shouldKeep) {
                $cleanedLines += $line
            }
        }
        
        $cleanedContent = $cleanedLines -join "`n"
        $cleanedContent | Out-File $userSettingsPath -Encoding UTF8 -Force
    }
}

# Workspace Settings bereinigen
$workspaceSettingsPath = "D:\Arbeitsverzeichniss\.vscode\settings.json"
if (Test-Path $workspaceSettingsPath) {
    Write-Host "   Bereinige Workspace Settings: $workspaceSettingsPath" -ForegroundColor Cyan
    
    # Backup erstellen
    Copy-Item $workspaceSettingsPath "$workspaceSettingsPath.backup" -Force
    
    $content = Get-Content $workspaceSettingsPath -Raw -ErrorAction SilentlyContinue
    if ($content) {
        $json = $content | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($json) {
            # Entferne alle Codex-related Properties
            $codexProps = $json.PSObject.Properties | Where-Object { 
                $_.Name -match "chatgpt|openai|genieai|codegpt|codex" 
            }
            
            foreach ($prop in $codexProps) {
                Write-Host "     Entfernt: $($prop.Name)" -ForegroundColor Gray
                $json.PSObject.Properties.Remove($prop.Name)
            }
            
            $json | ConvertTo-Json -Depth 10 | Out-File $workspaceSettingsPath -Encoding UTF8 -Force
        }
    }
}

Write-Host "✅ Settings bereinigt" -ForegroundColor Green

# Schritt 6: Registry bereinigen (vorsichtig)
Write-Host ""
Write-Host "🗃️  Schritt 6: Registry bereinigen..." -ForegroundColor Red

$regKeys = @(
    "HKCU:\Software\Microsoft\VSCode\Extensions\openai.chatgpt",
    "HKCU:\Software\Classes\vscode-insiders\Extensions\openai.chatgpt"
)

foreach ($key in $regKeys) {
    if (Test-Path $key) {
        Write-Host "   Entferne Registry Key: $key" -ForegroundColor Yellow
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "✅ Registry bereinigt" -ForegroundColor Green

# Schritt 7: Neustart-Vorbereitung
Write-Host ""
Write-Host "🔄 Schritt 7: System für Neuinstallation vorbereiten..." -ForegroundColor Green

# Extension Liste aktualisieren
Write-Host "   Aktualisiere Extension-Liste..." -ForegroundColor Cyan
code-insiders --list-extensions --show-versions > "$env:TEMP\vscode_extensions_after_cleanup.txt" 2>$null

Write-Host "✅ System vorbereitet" -ForegroundColor Green

# Schritt 8: Verifikation
Write-Host ""
Write-Host "🔍 Schritt 8: Bereinigung verifizieren..." -ForegroundColor Green

$remainingExtensions = code-insiders --list-extensions 2>$null | Select-String -Pattern "openai|chatgpt|codex|genieai"

if ($remainingExtensions) {
    Write-Host "⚠️  Noch gefunden: $remainingExtensions" -ForegroundColor Yellow
} else {
    Write-Host "✅ Keine Codex/OpenAI Extensions mehr vorhanden" -ForegroundColor Green
}

# Abschließende Information
Write-Host ""
Write-Host "🎯 BEREINIGUNG ABGESCHLOSSEN!" -ForegroundColor Green -BackgroundColor Black
Write-Host ""
Write-Host "📋 NÄCHSTE SCHRITTE FÜR NEUINSTALLATION:" -ForegroundColor White -BackgroundColor Blue
Write-Host ""
Write-Host "1️⃣  VS Code neustarten:" -ForegroundColor Cyan
Write-Host "      code-insiders D:\Arbeitsverzeichniss" -ForegroundColor White
Write-Host ""
Write-Host "2️⃣  Extension neu installieren:" -ForegroundColor Cyan  
Write-Host "      Ctrl+Shift+P → 'Extensions: Install Extensions'" -ForegroundColor White
Write-Host "      Suche: 'OpenAI ChatGPT'" -ForegroundColor White
Write-Host "      Publisher: OpenAI (offizielle Extension)" -ForegroundColor White
Write-Host ""
Write-Host "3️⃣  Oder via Command Line:" -ForegroundColor Cyan
Write-Host "      code-insiders --install-extension openai.chatgpt" -ForegroundColor White
Write-Host ""
Write-Host "4️⃣  Nach Installation aktivieren:" -ForegroundColor Cyan
Write-Host "      Ctrl+Shift+P → 'Codex: Open Codex'" -ForegroundColor White
Write-Host "      Sign in with ChatGPT Plus Account" -ForegroundColor White
Write-Host ""
Write-Host "🧹 SYSTEM IST JETZT SAUBER FÜR NEUINSTALLATION!" -ForegroundColor Green
Write-Host ""

# Optional: VS Code direkt starten
$startNow = Read-Host "Möchten Sie VS Code jetzt neu starten? (y/n)"
if ($startNow -eq "y" -or $startNow -eq "Y") {
    Write-Host "🚀 Starte VS Code..." -ForegroundColor Green
    Start-Sleep 2
    Start-Process "code-insiders" -ArgumentList "D:\Arbeitsverzeichniss"
}