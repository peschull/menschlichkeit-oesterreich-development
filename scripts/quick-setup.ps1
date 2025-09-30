# 🚀 Quick Setup für GitHub Actions Log Analyzer
# Einfachste Einrichtung und Verwendung für menschlichkeit-oesterreich-development

param(
    [string]$GitHubToken,
    [switch]$SetupOnly,
    [switch]$QuickAnalysis
)

Write-Host "🎯 GitHub Actions Log Analyzer - Quick Setup" -ForegroundColor Cyan
Write-Host "===============================================" -ForegroundColor Gray

# Check if module exists
$modulePath = Join-Path $PSScriptRoot "Download-GitHubWorkflowLogs.psm1"
if (-not (Test-Path $modulePath)) {
    Write-Host "❌ Module not found: $modulePath" -ForegroundColor Red
    exit 1
}

# Import module
try {
    Import-Module $modulePath -Force
    Write-Host "✅ Module loaded successfully" -ForegroundColor Green
}
catch {
    Write-Host "❌ Error loading module: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Token setup - Check für Sicherheitsdatei
$tokenFile = Join-Path $PSScriptRoot "..\secrets\github-token.ps1"
if ((Test-Path $tokenFile) -and -not $env:GITHUB_TOKEN) {
    Write-Host "🔐 Lade Token aus Sicherheitsdatei..." -ForegroundColor Cyan
    try {
        . $tokenFile
        Write-Host "✅ Fine-grained Token geladen" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠️ Fehler beim Laden der Sicherheitsdatei: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

if (-not $GitHubToken -and -not $env:GITHUB_TOKEN) {
    Write-Host "🔐 GitHub Fine-Grained Token Setup Required" -ForegroundColor Yellow
    Write-Host "==========================================" -ForegroundColor Gray
    Write-Host "1️⃣ Erstelle Token: https://github.com/settings/personal-access-tokens/fine-grained" -ForegroundColor White
    Write-Host "2️⃣ Repository: menschlichkeit-oesterreich-development" -ForegroundColor White
    Write-Host "3️⃣ Berechtigungen wählen:" -ForegroundColor White
    Write-Host "   ✅ Actions: Read (Workflow logs lesen)" -ForegroundColor Green
    Write-Host "   ✅ Contents: Read (Repository-Inhalte)" -ForegroundColor Green
    Write-Host "   ✅ Metadata: Read (Repository-Metadaten)" -ForegroundColor Green
    Write-Host "4️⃣ Token kopieren (beginnt mit github_pat_...)" -ForegroundColor White
    Write-Host ""
    
    # Sichere Token-Eingabe
    do {
        $secureToken = Read-Host "GitHub Token eingeben (versteckte Eingabe)" -AsSecureString
        $GitHubToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken))
        
        if (-not $GitHubToken -or $GitHubToken.Length -lt 10) {
            Write-Host "❌ Token zu kurz! Mindestens 10 Zeichen erforderlich." -ForegroundColor Red
        }
    } while (-not $GitHubToken -or $GitHubToken.Length -lt 10)
    
    # Token Validierung
    if ($GitHubToken.StartsWith("ghp_") -or $GitHubToken.StartsWith("github_pat_")) {
        Write-Host "✅ Token Format korrekt" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Unerwartetes Token Format (sollte mit 'ghp_' oder 'github_pat_' beginnen)" -ForegroundColor Yellow
    }
    
    # Session Token setzen
    $env:GITHUB_TOKEN = $GitHubToken
    Write-Host "✅ Token für diese Session gesetzt" -ForegroundColor Green
} else {
    Write-Host "✅ GitHub Token verfügbar" -ForegroundColor Green
}

# Setup-only mode
if ($SetupOnly) {
    Write-Host "`n🎊 Setup abgeschlossen!" -ForegroundColor Green
    Write-Host "Du kannst jetzt folgende Befehle verwenden:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "# Vollständige Analyse:" -ForegroundColor Cyan
    Write-Host "Download-GitHubWorkflowLogs -ExtractLogs -MetaAnalysis" -ForegroundColor White
    Write-Host ""
    Write-Host "# Nur Download:" -ForegroundColor Cyan  
    Write-Host "Download-GitHubWorkflowLogs" -ForegroundColor White
    Write-Host ""
    Write-Host "# Workflows auflisten:" -ForegroundColor Cyan
    Write-Host "Get-WorkflowSummary" -ForegroundColor White
    exit 0
}

# Quick Analysis
if ($QuickAnalysis) {
    Write-Host "`n⚡ Quick Analysis wird gestartet..." -ForegroundColor Green
    try {
        Download-GitHubWorkflowLogs -MaxRuns 5 -ExtractLogs -MetaAnalysis
        Write-Host "`n✅ Quick Analysis abgeschlossen!" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Error during Quick Analysis: $($_.Exception.Message)" -ForegroundColor Red
    }
    exit 0
}

# Interactive Menu
Write-Host "`n📋 Was möchtest du tun?" -ForegroundColor Yellow
Write-Host "========================" -ForegroundColor Gray
Write-Host "1️⃣ Workflows auflisten" -ForegroundColor White
Write-Host "2️⃣ Quick Analysis (5 neueste Runs)" -ForegroundColor White
Write-Host "3️⃣ Vollständige Analyse (30 Runs)" -ForegroundColor White
Write-Host "4️⃣ Nur Downloads (50 Runs)" -ForegroundColor White
Write-Host "5️⃣ Spezifischen Workflow analysieren" -ForegroundColor White
Write-Host "6️⃣ Custom Optionen eingeben" -ForegroundColor White

$choice = Read-Host "`nWähle Option (1-6)"

switch ($choice) {
    "1" {
        Write-Host "`n🔍 Lade Workflow-Liste..." -ForegroundColor Cyan
        try {
            Get-WorkflowSummary
        }
        catch {
            Write-Host "❌ Fehler beim Laden der Workflows: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    "2" {
        Write-Host "`n⚡ Quick Analysis (5 Runs)..." -ForegroundColor Cyan
        try {
            Download-GitHubWorkflowLogs -MaxRuns 5 -ExtractLogs -MetaAnalysis
        }
        catch {
            Write-Host "❌ Fehler bei Quick Analysis: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    "3" {
        Write-Host "`n🧠 Vollständige Analyse (30 Runs)..." -ForegroundColor Cyan
        try {
            Download-GitHubWorkflowLogs -MaxRuns 30 -ExtractLogs -MetaAnalysis -CleanupZips
        }
        catch {
            Write-Host "❌ Fehler bei vollständiger Analyse: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    "4" {
        Write-Host "`n📥 Nur Downloads (50 Runs)..." -ForegroundColor Cyan
        try {
            Download-GitHubWorkflowLogs -MaxRuns 50
        }
        catch {
            Write-Host "❌ Fehler beim Download: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    "5" {
        Write-Host "`n🔍 Verfügbare Workflows:" -ForegroundColor Yellow
        try {
            $workflows = Get-WorkflowSummary
            if ($workflows.Count -gt 0) {
                $workflowName = Read-Host "`nWorkflow-Namen eingeben"
                Download-GitHubWorkflowLogs -WorkflowNames @($workflowName) -MaxRuns 10 -ExtractLogs -MetaAnalysis
            }
        }
        catch {
            Write-Host "❌ Fehler bei spezifischer Analyse: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    "6" {
        Write-Host "`n🛠️ Custom Optionen:" -ForegroundColor Yellow
        $maxRuns = Read-Host "Max Runs (Standard: 20)"
        if (-not $maxRuns) { $maxRuns = 20 }
        
        $extract = Read-Host "Logs extrahieren? (y/n)"
        $meta = Read-Host "Meta-Analyse durchführen? (y/n)"
        $cleanup = Read-Host "ZIPs nach Extraktion löschen? (y/n)"
        
        try {
            $params = @{
                MaxRuns = [int]$maxRuns
            }
            
            if ($extract -eq 'y') { $params.ExtractLogs = $true }
            if ($meta -eq 'y') { $params.MetaAnalysis = $true }
            if ($cleanup -eq 'y') { $params.CleanupZips = $true }
            
            Download-GitHubWorkflowLogs @params
        }
        catch {
            Write-Host "❌ Fehler bei Custom-Analyse: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host "❌ Ungültige Auswahl" -ForegroundColor Red
        exit 1
    }
}

# Abschluss
Write-Host "`n🎊 Vorgang abgeschlossen!" -ForegroundColor Green
Write-Host "📁 Ergebnisse: $env:USERPROFILE\GitHubLogs\menschlichkeit-oesterreich" -ForegroundColor Gray

# Output-Ordner öffnen
$openFolder = Read-Host "`nErgebnis-Ordner öffnen? (y/n)"
if ($openFolder -eq 'y') {
    $outputPath = "$env:USERPROFILE\GitHubLogs\menschlichkeit-oesterreich"
    if (Test-Path $outputPath) {
        Invoke-Item $outputPath
        Write-Host "📂 Ordner geöffnet" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Ordner noch nicht erstellt" -ForegroundColor Yellow
    }
}

Write-Host "`n💡 Tipp: Für zukünftige Nutzung kannst du direkt das Modul verwenden:" -ForegroundColor Cyan
Write-Host "Import-Module .\scripts\Download-GitHubWorkflowLogs.psm1" -ForegroundColor Gray
Write-Host "Download-GitHubWorkflowLogs -ExtractLogs -MetaAnalysis" -ForegroundColor Gray