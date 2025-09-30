# GitHub Actions Log Analyzer & Meta-Validator
# Automatisiert Logs herunterladen und analysieren für Enterprise CI/CD Pipeline

param(
    [string]$Owner = "peschull",
    [string]$Repo = "menschlichkeit-oesterreich-development",
    [string]$Token = $env:GITHUB_TOKEN,
    [int]$MaxRuns = 10,
    [switch]$MetaAnalysis,
    [switch]$DownloadLogs,
    [string]$OutputPath = "./github-logs-analysis"
)

# Ensure output directory exists
if (-not (Test-Path $OutputPath)) {
    New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    Write-Host "📁 Created output directory: $OutputPath" -ForegroundColor Green
}

# GitHub API Headers
$headers = @{
    'Authorization' = "token $Token"
    'Accept' = 'application/vnd.github.v3+json'
    'User-Agent' = 'PowerShell-GitHub-Log-Analyzer'
}

function Get-WorkflowRuns {
    param([int]$Count)

    Write-Host "🔍 Fetching latest $Count workflow runs..." -ForegroundColor Yellow

    try {
        $uri = "https://api.github.com/repos/$Owner/$Repo/actions/runs?per_page=$Count&status=completed"
        $response = Invoke-RestMethod -Uri $uri -Headers $headers -Method Get

        Write-Host "✅ Found $($response.workflow_runs.Count) workflow runs" -ForegroundColor Green
        return $response.workflow_runs
    }
    catch {
        Write-Host "❌ Error fetching workflow runs: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

function Download-WorkflowLogs {
    param(
        [object]$Run,
        [string]$LogPath
    )

    $runId = $Run.id
    $runName = $Run.name -replace '[<>:"/\\|?*]', '_'
    $timestamp = ([datetime]$Run.created_at).ToString('yyyy-MM-dd_HH-mm-ss')
    $fileName = "$timestamp-$runName-$runId.zip"
    $filePath = Join-Path $LogPath $fileName

    Write-Host "📥 Downloading logs for run #$runId ($($Run.name))..." -ForegroundColor Cyan

    try {
        $uri = "https://api.github.com/repos/$Owner/$Repo/actions/runs/$runId/logs"
        Invoke-RestMethod -Uri $uri -Headers $headers -Method Get -OutFile $filePath

        Write-Host "✅ Downloaded: $fileName" -ForegroundColor Green

        # Extract ZIP for analysis
        $extractPath = Join-Path $LogPath "$timestamp-$runName-$runId"
        if (-not (Test-Path $extractPath)) {
            Expand-Archive -Path $filePath -DestinationPath $extractPath -Force
            Write-Host "📦 Extracted to: $extractPath" -ForegroundColor Green
        }

        return @{
            FilePath = $filePath
            ExtractPath = $extractPath
            RunInfo = $Run
        }
    }
    catch {
        Write-Host "❌ Error downloading logs for run #$runId : $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

function Analyze-LogContent {
    param(
        [string]$LogDirectory,
        [object]$RunInfo
    )

    Write-Host "🔬 Analyzing logs in: $LogDirectory" -ForegroundColor Magenta

    $analysis = @{
        RunId = $RunInfo.id
        RunName = $RunInfo.name
        Status = $RunInfo.conclusion
        CreatedAt = $RunInfo.created_at
        Duration = $RunInfo.updated_at
        TotalJobs = 0
        FailedJobs = @()
        Errors = @()
        Warnings = @()
        Performance = @{}
        SecurityIssues = @()
        QualityMetrics = @{}
    }

    # Find all log files
    $logFiles = Get-ChildItem -Path $LogDirectory -Recurse -Filter "*.txt" -ErrorAction SilentlyContinue
    $analysis.TotalJobs = $logFiles.Count

    foreach ($logFile in $logFiles) {
        $jobName = [System.IO.Path]::GetFileNameWithoutExtension($logFile.Name)
        Write-Host "  📋 Analyzing job: $jobName" -ForegroundColor Gray

        try {
            $content = Get-Content -Path $logFile.FullName -Raw -ErrorAction SilentlyContinue

            # Error Detection
            $errors = Select-String -InputObject $content -Pattern '(?i)(error|failed|exception|fatal)' -AllMatches
            if ($errors.Matches.Count -gt 0) {
                $analysis.FailedJobs += $jobName
                $analysis.Errors += @{
                    Job = $jobName
                    Count = $errors.Matches.Count
                    Samples = ($errors.Matches | Select-Object -First 3).Value
                }
            }

            # Warning Detection
            $warnings = Select-String -InputObject $content -Pattern '(?i)(warning|warn|deprecated)' -AllMatches
            if ($warnings.Matches.Count -gt 0) {
                $analysis.Warnings += @{
                    Job = $jobName
                    Count = $warnings.Matches.Count
                }
            }

            # Performance Metrics
            $timeMatches = Select-String -InputObject $content -Pattern '(\d+\.?\d*)\s*(ms|sec|min)' -AllMatches
            if ($timeMatches.Matches.Count -gt 0) {
                $analysis.Performance[$jobName] = $timeMatches.Matches.Count
            }

            # Security Issues
            $securityMatches = Select-String -InputObject $content -Pattern '(?i)(vulnerability|cve-|security|audit)' -AllMatches
            if ($securityMatches.Matches.Count -gt 0) {
                $analysis.SecurityIssues += @{
                    Job = $jobName
                    Count = $securityMatches.Matches.Count
                    Type = "Security Alert"
                }
            }

            # Quality Metrics (ESLint, PHPStan, etc.)
            $qualityMatches = Select-String -InputObject $content -Pattern '(?i)(eslint|phpstan|pytest|coverage|quality)' -AllMatches
            if ($qualityMatches.Matches.Count -gt 0) {
                $analysis.QualityMetrics[$jobName] = $qualityMatches.Matches.Count
            }

        }
        catch {
            Write-Host "    ⚠️ Could not analyze $jobName : $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }

    return $analysis
}

function Generate-MetaReport {
    param([array]$Analyses)

    Write-Host "📊 Generating meta-analysis report..." -ForegroundColor Cyan

    $report = @{
        GeneratedAt = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        TotalRuns = $Analyses.Count
        SuccessRate = 0
        AvgJobsPerRun = 0
        CommonErrors = @{}
        SecurityTrends = @{}
        PerformanceTrends = @{}
        QualityTrends = @{}
        Recommendations = @()
    }

    # Success Rate Calculation
    $successfulRuns = ($Analyses | Where-Object { $_.Status -eq 'success' }).Count
    $report.SuccessRate = [math]::Round(($successfulRuns / $Analyses.Count) * 100, 2)

    # Average Jobs per Run
    $report.AvgJobsPerRun = [math]::Round(($Analyses | Measure-Object -Property TotalJobs -Average).Average, 1)

    # Common Errors Analysis
    $allErrors = $Analyses | ForEach-Object { $_.Errors } | ForEach-Object { $_.Samples }
    $errorGroups = $allErrors | Group-Object | Sort-Object Count -Descending | Select-Object -First 5
    foreach ($errorGroup in $errorGroups) {
        $report.CommonErrors[$errorGroup.Name] = $errorGroup.Count
    }

    # Security Trends
    $securityCount = ($Analyses | ForEach-Object { $_.SecurityIssues }).Count
    $report.SecurityTrends['TotalIssues'] = $securityCount
    $report.SecurityTrends['AveragePerRun'] = [math]::Round($securityCount / $Analyses.Count, 1)

    # Performance Trends
    $perfJobs = $Analyses | ForEach-Object { $_.Performance.Keys } | Group-Object | Sort-Object Count -Descending
    if ($perfJobs.Count -gt 0) {
        $report.PerformanceTrends['MostTestedJob'] = $perfJobs[0].Name
        $report.PerformanceTrends['TestFrequency'] = $perfJobs[0].Count
    }

    # Quality Trends
    $qualityJobs = $Analyses | ForEach-Object { $_.QualityMetrics.Keys } | Group-Object | Sort-Object Count -Descending
    if ($qualityJobs.Count -gt 0) {
        $report.QualityTrends['MostAnalyzedJob'] = $qualityJobs[0].Name
        $report.QualityTrends['AnalysisFrequency'] = $qualityJobs[0].Count
    }

    # Recommendations
    if ($report.SuccessRate -lt 80) {
        $report.Recommendations += "⚠️ CI/CD Success Rate below 80% - investigate common failures"
    }
    if ($securityCount -gt 0) {
        $report.Recommendations += "🛡️ Security issues detected - review and address vulnerabilities"
    }
    if ($report.CommonErrors.Count -gt 3) {
        $report.Recommendations += "🔧 Multiple recurring errors - implement systematic fixes"
    }

    return $report
}

function Export-Results {
    param(
        [array]$Analyses,
        [object]$MetaReport,
        [string]$OutputPath
    )

    $timestamp = (Get-Date).ToString('yyyy-MM-dd_HH-mm-ss')

    # Export individual analyses
    $analysesPath = Join-Path $OutputPath "analyses-$timestamp.json"
    $Analyses | ConvertTo-Json -Depth 10 | Out-File -FilePath $analysesPath -Encoding utf8
    Write-Host "💾 Exported analyses: $analysesPath" -ForegroundColor Green

    # Export meta report
    $reportPath = Join-Path $OutputPath "meta-report-$timestamp.json"
    $MetaReport | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding utf8
    Write-Host "📋 Exported meta report: $reportPath" -ForegroundColor Green

    # Generate human-readable summary
    $summaryPath = Join-Path $OutputPath "summary-$timestamp.md"
    $summary = @"
# GitHub Actions Meta-Analysis Report
Generated: $($MetaReport.GeneratedAt)

## 📊 Overview
- **Total Runs Analyzed:** $($MetaReport.TotalRuns)
- **Success Rate:** $($MetaReport.SuccessRate)%
- **Average Jobs per Run:** $($MetaReport.AvgJobsPerRun)

## 🔍 Key Findings

### Common Errors
$($MetaReport.CommonErrors.GetEnumerator() | ForEach-Object { "- **$($_.Key):** $($_.Value) occurrences" } | Out-String)

### Security Analysis
- **Total Issues:** $($MetaReport.SecurityTrends.TotalIssues)
- **Average per Run:** $($MetaReport.SecurityTrends.AveragePerRun)

### Performance Insights
$($MetaReport.PerformanceTrends.GetEnumerator() | ForEach-Object { "- **$($_.Key):** $($_.Value)" } | Out-String)

### Quality Metrics
$($MetaReport.QualityTrends.GetEnumerator() | ForEach-Object { "- **$($_.Key):** $($_.Value)" } | Out-String)

## 🎯 Recommendations
$($MetaReport.Recommendations | ForEach-Object { "- $_" } | Out-String)

---
*Report generated by GitHub Actions Log Analyzer*
"@

    $summary | Out-File -FilePath $summaryPath -Encoding utf8
    Write-Host "📄 Generated summary: $summaryPath" -ForegroundColor Green
}

# Main Execution
Write-Host "🚀 GitHub Actions Log Analyzer Starting..." -ForegroundColor Cyan
Write-Host "Repository: $Owner/$Repo" -ForegroundColor Gray
Write-Host "Output Path: $OutputPath" -ForegroundColor Gray

if (-not $Token) {
    Write-Host "❌ GitHub token required. Set GITHUB_TOKEN environment variable or use -Token parameter" -ForegroundColor Red
    exit 1
}

# Fetch workflow runs
$runs = Get-WorkflowRuns -Count $MaxRuns
if ($runs.Count -eq 0) {
    Write-Host "❌ No workflow runs found" -ForegroundColor Red
    exit 1
}

$analyses = @()

foreach ($run in $runs) {
    Write-Host "`n🔄 Processing run #$($run.id) - $($run.name) [$($run.conclusion)]" -ForegroundColor Yellow

    if ($DownloadLogs -or $MetaAnalysis) {
        $logData = Download-WorkflowLogs -Run $run -LogPath $OutputPath

        if ($logData -and $MetaAnalysis) {
            $analysis = Analyze-LogContent -LogDirectory $logData.ExtractPath -RunInfo $run
            $analyses += $analysis

            Write-Host "  📊 Analysis complete - Jobs: $($analysis.TotalJobs), Errors: $($analysis.Errors.Count), Warnings: $($analysis.Warnings.Count)" -ForegroundColor Green
        }
    }
}

if ($MetaAnalysis -and $analyses.Count -gt 0) {
    Write-Host "`n🧠 Performing meta-analysis..." -ForegroundColor Magenta
    $metaReport = Generate-MetaReport -Analyses $analyses

    Write-Host "📈 Meta-Analysis Results:" -ForegroundColor Cyan
    Write-Host "  Success Rate: $($metaReport.SuccessRate)%" -ForegroundColor $(if($metaReport.SuccessRate -gt 80) { 'Green' } else { 'Red' })
    Write-Host "  Common Errors: $($metaReport.CommonErrors.Count)" -ForegroundColor Yellow
    Write-Host "  Security Issues: $($metaReport.SecurityTrends.TotalIssues)" -ForegroundColor $(if($metaReport.SecurityTrends.TotalIssues -eq 0) { 'Green' } else { 'Red' })

    Export-Results -Analyses $analyses -MetaReport $metaReport -OutputPath $OutputPath
}

Write-Host "`n✅ GitHub Actions Log Analysis Complete!" -ForegroundColor Green
Write-Host "Check output directory: $OutputPath" -ForegroundColor Gray
