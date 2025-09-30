# 🚀 menschlichkeit-oesterreich GitHub Actions Log Downloader
# Einfaches Script zum Download und Analyse aller Workflow-Logs

# Import des PowerShell-Moduls
Import-Module .\scripts\Download-GitHubWorkflowLogs.psm1 -Force

# Configuration
$repoOwner = "peschull"
$repoName = "menschlichkeit-oesterreich-development"

# Token Management - Sichere Eingabe
$githubToken = $env:GITHUB_TOKEN

if (-not $githubToken) {
    Write-Host "🔐 GitHub Token Setup" -ForegroundColor Cyan
    Write-Host "============================================" -ForegroundColor Gray
    Write-Host "1️⃣ Erstelle Token: https://github.com/settings/tokens" -ForegroundColor Yellow
    Write-Host "2️⃣ Berechtigungen: repo + workflow" -ForegroundColor Yellow
    Write-Host "3️⃣ Token hier eingeben (wird nicht angezeigt)" -ForegroundColor Yellow
    Write-Host ""
    
    # Sichere Token-Eingabe ohne Anzeige
    $secureToken = Read-Host "GitHub Token eingeben" -AsSecureString
    $githubToken = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken))
    
    if (-not $githubToken -or $githubToken.Length -lt 10) {
        Write-Host "❌ Ungültiger Token!" -ForegroundColor Red
        Write-Host "Token muss mindestens 10 Zeichen haben und mit 'ghp_' beginnen" -ForegroundColor Yellow
        exit 1
    }
    
    # Validation: GitHub Token Format
    if (-not $githubToken.StartsWith("ghp_") -and -not $githubToken.StartsWith("github_pat_")) {
        Write-Host "⚠️ Token Format Warning: Erwartet 'ghp_' oder 'github_pat_' Prefix" -ForegroundColor Yellow
        $continue = Read-Host "Trotzdem fortfahren? (y/n)"
        if ($continue -ne 'y' -and $continue -ne 'yes') {
            exit 1
        }
    }
    
    Write-Host "✅ Token akzeptiert!" -ForegroundColor Green
    Write-Host ""
}

Write-Host "🎯 menschlichkeit-oesterreich GitHub Actions Log Analyzer" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Gray

# Menu für verschiedene Optionen
Write-Host "`n📋 Available Options:" -ForegroundColor Yellow
Write-Host "1️⃣  Download all workflow logs (last 50 runs)" -ForegroundColor White
Write-Host "2️⃣  Download + Extract + Meta-Analysis" -ForegroundColor White  
Write-Host "3️⃣  List available workflows" -ForegroundColor White
Write-Host "4️⃣  Download specific workflow only" -ForegroundColor White
Write-Host "5️⃣  Quick analysis (last 10 runs)" -ForegroundColor White

$choice = Read-Host "`nSelect option (1-5)"

switch ($choice) {
    "1" {
        Write-Host "`n🚀 Downloading all workflow logs..." -ForegroundColor Green
        Download-GitHubWorkflowLogs -RepoOwner $repoOwner -RepoName $repoName -GitHubToken $githubToken -MaxRuns 50
    }
    
    "2" {
        Write-Host "`n🧠 Full analysis with extraction and meta-analysis..." -ForegroundColor Green
        Download-GitHubWorkflowLogs -RepoOwner $repoOwner -RepoName $repoName -GitHubToken $githubToken -MaxRuns 30 -ExtractLogs -MetaAnalysis -CleanupZips
    }
    
    "3" {
        Write-Host "`n📋 Fetching available workflows..." -ForegroundColor Green
        Get-WorkflowSummary -RepoOwner $repoOwner -RepoName $repoName -GitHubToken $githubToken
    }
    
    "4" {
        Write-Host "`n🔍 Available workflows:" -ForegroundColor Yellow
        $workflows = Get-WorkflowSummary -RepoOwner $repoOwner -RepoName $repoName -GitHubToken $githubToken
        
        if ($workflows.Count -gt 0) {
            $workflowName = Read-Host "`nEnter workflow name to download"
            Download-GitHubWorkflowLogs -RepoOwner $repoOwner -RepoName $repoName -GitHubToken $githubToken -WorkflowNames @($workflowName) -ExtractLogs
        }
    }
    
    "5" {
        Write-Host "`n⚡ Quick analysis (last 10 runs)..." -ForegroundColor Green
        Download-GitHubWorkflowLogs -RepoOwner $repoOwner -RepoName $repoName -GitHubToken $githubToken -MaxRuns 10 -ExtractLogs -MetaAnalysis
    }
    
    default {
        Write-Host "❌ Invalid selection. Please run the script again." -ForegroundColor Red
        exit 1
    }
}

Write-Host "`n✅ Operation completed! Check the GitHubLogs folder in your user directory." -ForegroundColor Green
Write-Host "📁 Full path: $env:USERPROFILE\GitHubLogs\menschlichkeit-oesterreich" -ForegroundColor Gray

# Token-Sicherheit: Aus Speicher löschen
if ($githubToken) {
    $githubToken = $null
    Write-Host "🔒 Token aus Speicher gelöscht (Sicherheit)" -ForegroundColor Gray
}

# Optional: Token für Session speichern
if (-not $env:GITHUB_TOKEN) {
    $saveToken = Read-Host "`nToken für diese PowerShell-Session speichern? (y/n)"
    if ($saveToken -eq 'y' -or $saveToken -eq 'yes') {
        # Token nur für aktuelle Session setzen (nicht persistent)
        $env:GITHUB_TOKEN = $githubToken
        Write-Host "✅ Token für Session gespeichert. Nächste Ausführung wird Token automatisch finden." -ForegroundColor Green
    }
}

# Optional: Open output folder
$openFolder = Read-Host "`nOpen output folder? (y/n)"
if ($openFolder -eq 'y' -or $openFolder -eq 'yes') {
    $outputPath = "$env:USERPROFILE\GitHubLogs\menschlichkeit-oesterreich"
    if (Test-Path $outputPath) {
        Invoke-Item $outputPath
    }
}