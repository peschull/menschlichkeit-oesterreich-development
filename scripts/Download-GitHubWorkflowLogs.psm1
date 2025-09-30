# GitHub Workflow Logs Download & Analysis Module
# Vollständig anpassbares PowerShell-Modul für menschlichkeit-oesterreich-development
# Automatisierte Log-Downloads mit Meta-Analyse und Enterprise-Features

function Download-GitHubWorkflowLogs {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [string]$RepoOwner = "peschull",

        [Parameter(Mandatory=$false)]
        [string]$RepoName = "menschlichkeit-oesterreich-development",

        [Parameter(Mandatory=$false)]
        [string]$GitHubToken,

        [string]$Branch = "main",
        [string]$OutputPath = "$env:USERPROFILE\GitHubLogs\menschlichkeit-oesterreich",
        [int]$MaxRuns = 50,
        [string[]]$WorkflowNames = @(),
        [switch]$ExtractLogs,
        [switch]$MetaAnalysis,
        [switch]$CleanupZips
    )

    # Token Validation und Fallback
    if (-not $GitHubToken) {
        $GitHubToken = $env:GITHUB_TOKEN
        if (-not $GitHubToken) {
            throw "🔐 GitHub Token required! Provide via -GitHubToken parameter or set `$env:GITHUB_TOKEN"
        }
        Write-Host "🔐 Using token from environment variable" -ForegroundColor Gray
    } else {
        Write-Host "� Using token from parameter" -ForegroundColor Gray
    }

    # Token Format Validation
    if (-not ($GitHubToken.StartsWith("ghp_") -or $GitHubToken.StartsWith("github_pat_"))) {
        Write-Host "⚠️ Warning: Token should start with 'ghp_' or 'github_pat_'" -ForegroundColor Yellow
    }

    Write-Host "�🚀 GitHub Workflow Logs Downloader für menschlichkeit-oesterreich-development" -ForegroundColor Cyan
    Write-Host "Repository: $RepoOwner/$RepoName" -ForegroundColor Gray
    Write-Host "Branch: $Branch" -ForegroundColor Gray
    Write-Host "Output: $OutputPath" -ForegroundColor Gray
    Write-Host "Token: $($GitHubToken.Substring(0, [Math]::Min(10, $GitHubToken.Length)))..." -ForegroundColor Gray

    # Create output directory structure
    $logsPath = Join-Path $OutputPath "logs"
    $extractPath = Join-Path $OutputPath "extracted"
    $analysisPath = Join-Path $OutputPath "analysis"

    @($OutputPath, $logsPath, $extractPath, $analysisPath) | ForEach-Object {
        if (!(Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
            Write-Host "📁 Created directory: $_" -ForegroundColor Green
        }
    }

    # Setup headers for GitHub API
    $headers = @{
        Authorization = "Bearer $GitHubToken"
        Accept = "application/vnd.github.v3+json"
        'User-Agent' = 'PowerShell-MenschlichkeitOesterreich-LogDownloader'
    }

    # Get workflow runs with pagination
    Write-Host "`n🔍 Fetching workflow runs..." -ForegroundColor Yellow

    $allRuns = @()
    $page = 1
    $perPage = 100

    do {
        try {
            $runsUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/runs?branch=$Branch&per_page=$perPage&page=$page"
            $response = Invoke-RestMethod -Uri $runsUrl -Headers $headers

            $filteredRuns = $response.workflow_runs
            if ($WorkflowNames.Count -gt 0) {
                $filteredRuns = $filteredRuns | Where-Object { $_.name -in $WorkflowNames }
            }

            $allRuns += $filteredRuns
            Write-Host "  📄 Page $page : $($filteredRuns.Count) runs found" -ForegroundColor Gray

            $page++
        }
        catch {
            Write-Host "❌ Error fetching runs: $($_.Exception.Message)" -ForegroundColor Red
            break
        }
    } while ($response.workflow_runs.Count -eq $perPage -and $allRuns.Count -lt $MaxRuns)

    # Limit to MaxRuns
    $allRuns = $allRuns | Select-Object -First $MaxRuns
    Write-Host "✅ Total runs to process: $($allRuns.Count)" -ForegroundColor Green

    # Download logs for each run
    $downloadResults = @()
    $counter = 0

    foreach ($run in $allRuns) {
        $counter++
        $runId = $run.id
        $workflowName = $run.name -replace '[^a-zA-Z0-9_-]', '_'
        $commit = if ($run.head_commit.id) { $run.head_commit.id.Substring(0,7) } else { "no-commit" }
        $timestamp = ([DateTime]$run.created_at).ToString('yyyy-MM-dd_HH-mm-ss')
        $status = $run.conclusion

        # Create filename with all metadata
        $zipName = "$workflowName-$commit-$runId-$timestamp-$status.zip"
        $zipPath = Join-Path $logsPath $zipName

        Write-Host "[$counter/$($allRuns.Count)] 📥 Downloading: $workflowName (Run #$runId)" -ForegroundColor Cyan

        try {
            $logUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/runs/$runId/logs"

            # Download with progress
            $webClient = New-Object System.Net.WebClient
            $webClient.Headers.Add('Authorization', "Bearer $GitHubToken")
            $webClient.Headers.Add('User-Agent', 'PowerShell-MenschlichkeitOesterreich-LogDownloader')

            $webClient.DownloadFile($logUrl, $zipPath)

            $fileSize = [math]::Round((Get-Item $zipPath).Length / 1KB, 2)
            Write-Host "  ✅ Downloaded: $zipName ($fileSize KB)" -ForegroundColor Green

            $downloadResult = @{
                RunId = $runId
                WorkflowName = $run.name
                Commit = $commit
                Status = $status
                CreatedAt = $run.created_at
                UpdatedAt = $run.updated_at
                ZipPath = $zipPath
                ZipName = $zipName
                FileSizeKB = $fileSize
                DownloadSuccess = $true
            }

            # Extract logs if requested
            if ($ExtractLogs) {
                $extractDir = Join-Path $extractPath "$workflowName-$commit-$runId"
                if (!(Test-Path $extractDir)) {
                    try {
                        Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
                        Write-Host "    📦 Extracted to: $extractDir" -ForegroundColor Gray
                        $downloadResult.ExtractPath = $extractDir
                        $downloadResult.ExtractSuccess = $true
                    }
                    catch {
                        Write-Host "    ⚠️ Extract failed: $($_.Exception.Message)" -ForegroundColor Yellow
                        $downloadResult.ExtractSuccess = $false
                    }
                }
            }

        }
        catch {
            Write-Host "  ❌ Download failed: $($_.Exception.Message)" -ForegroundColor Red
            $downloadResult = @{
                RunId = $runId
                WorkflowName = $run.name
                Status = $status
                DownloadSuccess = $false
                Error = $_.Exception.Message
            }
        }

        $downloadResults += $downloadResult

        # Small delay to avoid rate limiting
        Start-Sleep -Milliseconds 250
    }

    # Generate summary report
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $summaryPath = Join-Path $OutputPath "download-summary-$timestamp.json"

    $summary = @{
        Repository = "$RepoOwner/$RepoName"
        Branch = $Branch
        DownloadTime = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        TotalRuns = $allRuns.Count
        SuccessfulDownloads = ($downloadResults | Where-Object { $_.DownloadSuccess }).Count
        FailedDownloads = ($downloadResults | Where-Object { -not $_.DownloadSuccess }).Count
        TotalSizeKB = ($downloadResults | Where-Object { $_.FileSizeKB } | Measure-Object -Property FileSizeKB -Sum).Sum
        WorkflowBreakdown = $downloadResults | Group-Object WorkflowName | Select-Object Name, Count
        StatusBreakdown = $downloadResults | Group-Object Status | Select-Object Name, Count
        Results = $downloadResults
    }

    $summary | ConvertTo-Json -Depth 10 | Out-File -FilePath $summaryPath -Encoding utf8
    Write-Host "`n📊 Summary saved: $summaryPath" -ForegroundColor Green

    # Meta-Analysis if requested
    if ($MetaAnalysis -and $ExtractLogs) {
        Write-Host "`n🧠 Performing meta-analysis..." -ForegroundColor Magenta
        $metaResults = Invoke-MetaAnalysis -DownloadResults $downloadResults -OutputPath $analysisPath
        Write-Host "📈 Meta-analysis complete: $($metaResults.ReportPath)" -ForegroundColor Green
    }

    # Cleanup ZIP files if requested
    if ($CleanupZips -and $ExtractLogs) {
        Write-Host "`n🧹 Cleaning up ZIP files..." -ForegroundColor Yellow
        $downloadResults | Where-Object { $_.ExtractSuccess } | ForEach-Object {
            Remove-Item $_.ZipPath -Force
            Write-Host "  🗑️ Removed: $($_.ZipName)" -ForegroundColor Gray
        }
    }

    # Final summary
    Write-Host "`n✅ Download Complete!" -ForegroundColor Green
    Write-Host "📁 Logs saved to: $logsPath" -ForegroundColor Gray
    Write-Host "📊 Summary: $($summary.SuccessfulDownloads)/$($summary.TotalRuns) downloads successful" -ForegroundColor Gray
    Write-Host "💾 Total size: $([math]::Round($summary.TotalSizeKB / 1024, 2)) MB" -ForegroundColor Gray

    if ($ExtractLogs) {
        Write-Host "📦 Extracted to: $extractPath" -ForegroundColor Gray
    }

    return $summary
}

function Invoke-MetaAnalysis {
    param(
        [array]$DownloadResults,
        [string]$OutputPath
    )

    Write-Host "🔬 Starting meta-analysis of GitHub Actions logs..." -ForegroundColor Cyan

    $metaAnalysis = @{
        AnalysisTime = (Get-Date).ToString('yyyy-MM-dd HH:mm:ss')
        TotalLogsAnalyzed = 0
        ErrorPatterns = @{}
        WarningPatterns = @{}
        PerformanceMetrics = @{}
        SecurityFindings = @{}
        QualityMetrics = @{}
        WorkflowInsights = @{}
    }

    foreach ($result in ($DownloadResults | Where-Object { $_.ExtractSuccess })) {
        Write-Host "  🔍 Analyzing: $($result.WorkflowName)" -ForegroundColor Gray

        $logFiles = Get-ChildItem -Path $result.ExtractPath -Recurse -Filter "*.txt" -ErrorAction SilentlyContinue
        $metaAnalysis.TotalLogsAnalyzed += $logFiles.Count

        foreach ($logFile in $logFiles) {
            $jobName = [System.IO.Path]::GetFileNameWithoutExtension($logFile.Name)

            try {
                $content = Get-Content -Path $logFile.FullName -Raw -ErrorAction SilentlyContinue

                # Error Pattern Analysis
                $errorPatterns = @(
                    'npm ERR!', 'Error:', 'Exception:', 'FAILED', 'fatal:', 'AssertionError',
                    'SyntaxError', 'TypeError', 'ModuleNotFoundError', 'ImportError'
                )

                foreach ($pattern in $errorPatterns) {
                    $matches = Select-String -InputObject $content -Pattern $pattern -AllMatches
                    if ($matches.Matches.Count -gt 0) {
                        if (-not $metaAnalysis.ErrorPatterns.ContainsKey($pattern)) {
                            $metaAnalysis.ErrorPatterns[$pattern] = 0
                        }
                        $metaAnalysis.ErrorPatterns[$pattern] += $matches.Matches.Count
                    }
                }

                # Warning Pattern Analysis
                $warningPatterns = @('WARNING', 'WARN', 'deprecated', 'vulnerability found')
                foreach ($pattern in $warningPatterns) {
                    $matches = Select-String -InputObject $content -Pattern $pattern -AllMatches
                    if ($matches.Matches.Count -gt 0) {
                        if (-not $metaAnalysis.WarningPatterns.ContainsKey($pattern)) {
                            $metaAnalysis.WarningPatterns[$pattern] = 0
                        }
                        $metaAnalysis.WarningPatterns[$pattern] += $matches.Matches.Count
                    }
                }

                # Performance Metrics
                $timePattern = '(\d+\.?\d*)\s*(ms|sec|seconds|minutes)'
                $timeMatches = Select-String -InputObject $content -Pattern $timePattern -AllMatches
                if ($timeMatches.Matches.Count -gt 0) {
                    if (-not $metaAnalysis.PerformanceMetrics.ContainsKey($jobName)) {
                        $metaAnalysis.PerformanceMetrics[$jobName] = @()
                    }
                    $metaAnalysis.PerformanceMetrics[$jobName] += $timeMatches.Matches.Count
                }

                # Security Findings
                $securityPatterns = @('CVE-', 'vulnerability', 'security audit', 'high severity', 'critical severity')
                foreach ($pattern in $securityPatterns) {
                    $matches = Select-String -InputObject $content -Pattern $pattern -AllMatches -CaseSensitive:$false
                    if ($matches.Matches.Count -gt 0) {
                        if (-not $metaAnalysis.SecurityFindings.ContainsKey($pattern)) {
                            $metaAnalysis.SecurityFindings[$pattern] = 0
                        }
                        $metaAnalysis.SecurityFindings[$pattern] += $matches.Matches.Count
                    }
                }

                # Quality Metrics (ESLint, PHPStan, pytest, etc.)
                $qualityTools = @('eslint', 'phpstan', 'pytest', 'coverage', 'sonar', 'codacy')
                foreach ($tool in $qualityTools) {
                    $matches = Select-String -InputObject $content -Pattern $tool -AllMatches -CaseSensitive:$false
                    if ($matches.Matches.Count -gt 0) {
                        if (-not $metaAnalysis.QualityMetrics.ContainsKey($tool)) {
                            $metaAnalysis.QualityMetrics[$tool] = 0
                        }
                        $metaAnalysis.QualityMetrics[$tool] += $matches.Matches.Count
                    }
                }

            }
            catch {
                Write-Host "    ⚠️ Could not analyze $($logFile.Name): $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }

        # Workflow-specific insights
        $workflowKey = $result.WorkflowName
        if (-not $metaAnalysis.WorkflowInsights.ContainsKey($workflowKey)) {
            $metaAnalysis.WorkflowInsights[$workflowKey] = @{
                TotalRuns = 0
                SuccessfulRuns = 0
                FailedRuns = 0
                AverageFileSizeKB = 0
            }
        }

        $metaAnalysis.WorkflowInsights[$workflowKey].TotalRuns++
        if ($result.Status -eq 'success') {
            $metaAnalysis.WorkflowInsights[$workflowKey].SuccessfulRuns++
        } else {
            $metaAnalysis.WorkflowInsights[$workflowKey].FailedRuns++
        }
    }

    # Generate comprehensive report
    $timestamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
    $reportPath = Join-Path $OutputPath "meta-analysis-$timestamp.json"
    $metaAnalysis | ConvertTo-Json -Depth 10 | Out-File -FilePath $reportPath -Encoding utf8

    # Generate human-readable summary
    $readablePath = Join-Path $OutputPath "meta-analysis-summary-$timestamp.md"
    $readableContent = @"
# GitHub Actions Meta-Analysis Report
**Repository:** menschlichkeit-oesterreich-development
**Analysis Time:** $($metaAnalysis.AnalysisTime)
**Total Log Files Analyzed:** $($metaAnalysis.TotalLogsAnalyzed)

## 🚨 Top Error Patterns
$($metaAnalysis.ErrorPatterns.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10 | ForEach-Object { "- **$($_.Key)**: $($_.Value) occurrences" } | Out-String)

## ⚠️ Warning Patterns
$($metaAnalysis.WarningPatterns.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 5 | ForEach-Object { "- **$($_.Key)**: $($_.Value) occurrences" } | Out-String)

## 🛡️ Security Findings
$($metaAnalysis.SecurityFindings.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { "- **$($_.Key)**: $($_.Value) findings" } | Out-String)

## 📊 Quality Tool Usage
$($metaAnalysis.QualityMetrics.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { "- **$($_.Key)**: $($_.Value) mentions" } | Out-String)

## 🔄 Workflow Performance
$($metaAnalysis.WorkflowInsights.GetEnumerator() | ForEach-Object {
    $successRate = if ($_.Value.TotalRuns -gt 0) { [math]::Round(($_.Value.SuccessfulRuns / $_.Value.TotalRuns) * 100, 1) } else { 0 }
    "- **$($_.Key)**: $($_.Value.TotalRuns) runs, $successRate% success rate"
} | Out-String)

---
*Generated by menschlichkeit-oesterreich GitHub Actions Log Analyzer*
"@

    $readableContent | Out-File -FilePath $readablePath -Encoding utf8

    return @{
        ReportPath = $reportPath
        SummaryPath = $readablePath
        Analysis = $metaAnalysis
    }
}

function Get-WorkflowSummary {
    param(
        [string]$RepoOwner = "peschull",
        [string]$RepoName = "menschlichkeit-oesterreich-development",
        [string]$GitHubToken
    )

    # Token Fallback
    if (-not $GitHubToken) {
        $GitHubToken = $env:GITHUB_TOKEN
        if (-not $GitHubToken) {
            Write-Host "❌ GitHub Token required for Get-WorkflowSummary" -ForegroundColor Red
            return @()
        }
    }

    $headers = @{ Authorization = "Bearer $GitHubToken" }
    $workflowsUrl = "https://api.github.com/repos/$RepoOwner/$RepoName/actions/workflows"

    try {
        $workflows = Invoke-RestMethod -Uri $workflowsUrl -Headers $headers

        Write-Host "🔧 Available Workflows in $RepoOwner/$RepoName :" -ForegroundColor Cyan
        foreach ($workflow in $workflows.workflows) {
            Write-Host "  - $($workflow.name) (ID: $($workflow.id), State: $($workflow.state))" -ForegroundColor Gray
        }

        return $workflows.workflows
    }
    catch {
        Write-Host "❌ Error fetching workflows: $($_.Exception.Message)" -ForegroundColor Red
        return @()
    }
}

# Export module functions
Export-ModuleMember -Function Download-GitHubWorkflowLogs, Invoke-MetaAnalysis, Get-WorkflowSummary
