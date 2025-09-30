# 🚀 menschlichkeit-oesterreich GitHub Actions Log Downloader
# Einfaches Script zum Download und Analyse aller Workflow-Logs

# Import des PowerShell-Moduls
Import-Module .\scripts\Download-GitHubWorkflowLogs.psm1 -Force

# Configuration
$repoOwner = "peschull"
$repoName = "menschlichkeit-oesterreich-development"
$githubToken = $env:GITHUB_TOKEN  # Setze via: $env:GITHUB_TOKEN = "dein_token_hier"

if (-not $githubToken) {
    Write-Host "❌ GITHUB_TOKEN environment variable required!" -ForegroundColor Red
    Write-Host "Set it with: `$env:GITHUB_TOKEN = 'your_github_token_here'" -ForegroundColor Yellow
    Write-Host "Create token at: https://github.com/settings/tokens" -ForegroundColor Gray
    exit 1
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

# Optional: Open output folder
$openFolder = Read-Host "`nOpen output folder? (y/n)"
if ($openFolder -eq 'y' -or $openFolder -eq 'yes') {
    $outputPath = "$env:USERPROFILE\GitHubLogs\menschlichkeit-oesterreich"
    if (Test-Path $outputPath) {
        Invoke-Item $outputPath
    }
}