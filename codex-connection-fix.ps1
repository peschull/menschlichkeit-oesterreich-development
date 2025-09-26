#!/usr/bin/env powershell
# 🚨 CODEX VERBINDUNGSPROBLEM DIAGNOSE & REPARATUR
# Für "lädt ewig, findet keine Verbindung"

Write-Host "🚨 CODEX VERBINDUNGSPROBLEM - DIAGNOSE STARTET" -ForegroundColor Red -BackgroundColor White
Write-Host ""

# Schritt 1: Netzwerk-Diagnose
Write-Host "🌐 Schritt 1: Netzwerk-Verbindung zu OpenAI testen..." -ForegroundColor Yellow
Write-Host ""

$endpoints = @(
    "api.openai.com",
    "chat.openai.com", 
    "platform.openai.com"
)

foreach ($endpoint in $endpoints) {
    Write-Host "   Testing $endpoint..." -ForegroundColor Cyan
    $result = Test-NetConnection -ComputerName $endpoint -Port 443 -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) {
        Write-Host "   ✅ $endpoint - Verbindung OK" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $endpoint - Verbindung FEHLGESCHLAGEN" -ForegroundColor Red
    }
}

Write-Host ""

# Schritt 2: Browser-Cookies prüfen
Write-Host "🍪 Schritt 2: Browser-Cookies für OpenAI prüfen..." -ForegroundColor Yellow

$cookiePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cookies",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cookies",
    "$env:APPDATA\Mozilla\Firefox\Profiles\*\cookies.sqlite"
)

$cookiesFound = $false
foreach ($path in $cookiePaths) {
    if (Test-Path $path) {
        Write-Host "   ✅ Browser-Cookies gefunden: $path" -ForegroundColor Green
        $cookiesFound = $true
    }
}

if (-not $cookiesFound) {
    Write-Host "   ⚠️  Keine Browser-Cookies gefunden - möglicherweise Anmeldeproblem" -ForegroundColor Yellow
}

Write-Host ""

# Schritt 3: VS Code Extension Logs prüfen
Write-Host "📋 Schritt 3: VS Code Extension Logs analysieren..." -ForegroundColor Yellow

$logPath = "$env:USERPROFILE\.vscode-insiders\logs"
if (Test-Path $logPath) {
    $latestLog = Get-ChildItem $logPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestLog) {
        Write-Host "   📁 Neueste Logs: $($latestLog.FullName)" -ForegroundColor Cyan
        
        # Suche nach OpenAI/Codex Fehlern
        $extLogPath = "$($latestLog.FullName)\exthost1\openai.chatgpt"
        if (Test-Path $extLogPath) {
            Write-Host "   🔍 OpenAI Extension Logs gefunden" -ForegroundColor Green
            $errorLogs = Get-ChildItem "$extLogPath\*.log" -ErrorAction SilentlyContinue | 
                        Get-Content -ErrorAction SilentlyContinue | 
                        Select-String -Pattern "error|failed|timeout|connection" -CaseSensitive:$false
            
            if ($errorLogs) {
                Write-Host "   ❌ Fehler in Extension Logs gefunden:" -ForegroundColor Red
                $errorLogs | Select-Object -First 5 | ForEach-Object {
                    Write-Host "      $($_.Line)" -ForegroundColor Gray
                }
            } else {
                Write-Host "   ✅ Keine kritischen Fehler in Logs" -ForegroundColor Green
            }
        } else {
            Write-Host "   ⚠️  OpenAI Extension Logs nicht gefunden" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "   ⚠️  VS Code Logs-Verzeichnis nicht gefunden" -ForegroundColor Yellow
}

Write-Host ""

# Schritt 4: Proxy/Firewall Check
Write-Host "🔥 Schritt 4: Proxy/Firewall Konfiguration prüfen..." -ForegroundColor Yellow

# Proxy Settings prüfen
$proxySettings = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -ErrorAction SilentlyContinue
if ($proxySettings.ProxyEnable -eq 1) {
    Write-Host "   ⚠️  Proxy aktiviert: $($proxySettings.ProxyServer)" -ForegroundColor Yellow
    Write-Host "      Dies könnte Verbindungsprobleme verursachen" -ForegroundColor Gray
} else {
    Write-Host "   ✅ Kein Proxy konfiguriert" -ForegroundColor Green
}

# Windows Firewall prüfen
$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    if ($profile.Enabled -eq $true) {
        Write-Host "   🔥 Firewall aktiv: $($profile.Name)" -ForegroundColor Cyan
    }
}

Write-Host ""

# Schritt 5: REPARATUR-OPTIONEN
Write-Host "🔧 REPARATUR-OPTIONEN:" -ForegroundColor Green -BackgroundColor Black
Write-Host ""

Write-Host "💡 Option 1: Browser-basierte Anmeldung erzwingen" -ForegroundColor Yellow
Write-Host "   1. Öffnen Sie: https://chat.openai.com" -ForegroundColor White
Write-Host "   2. Melden Sie sich mit ChatGPT Plus an" -ForegroundColor White
Write-Host "   3. In VS Code: Ctrl+Shift+P → 'Codex: Open Codex'" -ForegroundColor White
Write-Host "   4. Klick 'Sign in with ChatGPT' → sollte Browser öffnen" -ForegroundColor White
Write-Host ""

Write-Host "💡 Option 2: Extension komplett zurücksetzen" -ForegroundColor Yellow
Write-Host "   1. VS Code schließen" -ForegroundColor White
Write-Host "   2. Löschen: $env:USERPROFILE\.vscode-insiders\extensions\openai.chatgpt-*" -ForegroundColor White
Write-Host "   3. Extension neu installieren" -ForegroundColor White
Write-Host "   4. VS Code neu starten" -ForegroundColor White
Write-Host ""

Write-Host "💡 Option 3: Netzwerk-Reset" -ForegroundColor Yellow
Write-Host "   1. ipconfig /flushdns" -ForegroundColor White
Write-Host "   2. netsh winsock reset" -ForegroundColor White
Write-Host "   3. Computer neu starten" -ForegroundColor White
Write-Host ""

Write-Host "💡 Option 4: Alternative Extension testen" -ForegroundColor Yellow
Write-Host "   1. Installiere: Continue Extension (continue.continue)" -ForegroundColor White
Write-Host "   2. Konfiguriere mit OpenAI API Key" -ForegroundColor White
Write-Host "   3. Teste AI-Funktionen über Continue" -ForegroundColor White
Write-Host ""

# Schritt 6: Automatische Reparatur anbieten
Write-Host "🚀 AUTOMATISCHE REPARATUR STARTEN?" -ForegroundColor Green -BackgroundColor Blue
Write-Host ""
Write-Host "Soll ich automatisch versuchen das Problem zu beheben? (j/n): " -NoNewline -ForegroundColor White
$response = Read-Host

if ($response -eq "j" -or $response -eq "y" -or $response -eq "yes") {
    Write-Host ""
    Write-Host "🔧 Starte automatische Reparatur..." -ForegroundColor Green
    
    # DNS Cache leeren
    Write-Host "   Leere DNS Cache..." -ForegroundColor Cyan
    ipconfig /flushdns | Out-Null
    
    # VS Code Prozesse beenden
    Write-Host "   Beende VS Code Prozesse..." -ForegroundColor Cyan
    Get-Process "*code*" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Start-Sleep 2
    
    # Extension Cache löschen
    Write-Host "   Lösche Extension Cache..." -ForegroundColor Cyan
    $extensionPath = "$env:USERPROFILE\.vscode-insiders\extensions\openai.chatgpt-*"
    Remove-Item -Path $extensionPath -Recurse -Force -ErrorAction SilentlyContinue
    
    # Extension neu installieren
    Write-Host "   Installiere Extension neu..." -ForegroundColor Cyan
    code-insiders --install-extension openai.chatgpt --force 2>$null
    Start-Sleep 3
    
    # Browser für Anmeldung öffnen
    Write-Host "   Öffne Browser für Anmeldung..." -ForegroundColor Cyan
    Start-Process "https://chat.openai.com"
    Start-Sleep 2
    
    # VS Code starten
    Write-Host "   Starte VS Code..." -ForegroundColor Cyan
    code-insiders "D:\Arbeitsverzeichniss"
    
    Write-Host ""
    Write-Host "✅ Automatische Reparatur abgeschlossen!" -ForegroundColor Green
    Write-Host ""
    Write-Host "NÄCHSTE SCHRITTE:" -ForegroundColor White -BackgroundColor Red
    Write-Host "1. Melden Sie sich in chat.openai.com an (Browser-Tab)" -ForegroundColor Cyan
    Write-Host "2. In VS Code: Ctrl+Shift+P → 'Codex: Open Codex'" -ForegroundColor Cyan
    Write-Host "3. Klick 'Sign in with ChatGPT'" -ForegroundColor Cyan
    Write-Host "4. Autorisierung im Browser erteilen" -ForegroundColor Cyan
    
} else {
    Write-Host ""
    Write-Host "ℹ️  Manuelle Reparatur gewählt. Folgen Sie Option 1-4 oben." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "🎯 DIAGNOSE ABGESCHLOSSEN" -ForegroundColor Green -BackgroundColor Black