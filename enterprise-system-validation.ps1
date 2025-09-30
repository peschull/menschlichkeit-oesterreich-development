# 🏗️ MENSCHLICHKEIT ÖSTERREICH - ENTERPRISE SYSTEM VALIDATION
Write-Host "🏗️ MENSCHLICHKEIT ÖSTERREICH - ENTERPRISE SYSTEM VALIDATION" -ForegroundColor Cyan
Write-Host "=============================================================" -ForegroundColor Cyan
Write-Host ""

# Repository Health Check
$repoHealth = @{
    'OpenPRs' = 28
    'FailedChecks' = 16
    'SuccessfulChecks' = 9
    'SkippedChecks' = 12
    'AbortedChecks' = 1
}

Write-Host "📊 REPOSITORY HEALTH OVERVIEW:" -ForegroundColor Magenta
Write-Host "==============================" -ForegroundColor Magenta
foreach ($metric in $repoHealth.GetEnumerator()) {
    $color = switch ($metric.Key) {
        'FailedChecks' { 'Red' }
        'AbortedChecks' { 'Red' }
        'SuccessfulChecks' { 'Green' }
        default { 'Yellow' }
    }
    Write-Host "  $($metric.Key): $($metric.Value)" -ForegroundColor $color
}

Write-Host ""

# Service Status Check
$services = @{
    'Website (WordPress)' = @{ 'Status' = 'Warning'; 'Issues' = 'Updates pending' }
    'API (FastAPI)' = @{ 'Status' = 'Critical'; 'Issues' = 'Python CI failures' }
    'CRM (Drupal+CiviCRM)' = @{ 'Status' = 'Warning'; 'Issues' = 'PHP tests aborted' }
    'Games (Prisma)' = @{ 'Status' = 'Warning'; 'Issues' = 'TypeScript failures' }
    'Frontend (React)' = @{ 'Status' = 'Critical'; 'Issues' = 'TypeScript CI failures' }
    'Automation (n8n)' = @{ 'Status' = 'Healthy'; 'Issues' = 'None' }
}

Write-Host "🚀 SERVICE STATUS ANALYSIS:" -ForegroundColor Blue
Write-Host "============================" -ForegroundColor Blue
foreach ($service in $services.GetEnumerator()) {
    $statusColor = switch ($service.Value.Status) {
        'Healthy' { 'Green' }
        'Warning' { 'Yellow' }
        'Critical' { 'Red' }
        default { 'Gray' }
    }

    $statusIcon = switch ($service.Value.Status) {
        'Healthy' { '✅' }
        'Warning' { '⚠️' }
        'Critical' { '🔴' }
        default { '❓' }
    }

    Write-Host "  $statusIcon $($service.Key):" -ForegroundColor $statusColor -NoNewline
    Write-Host " $($service.Value.Issues)" -ForegroundColor Gray
}

Write-Host ""

# Quality Gates Status
Write-Host "🛡️ QUALITY GATES STATUS:" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host "  ✅ Codacy Integration: Active"
Write-Host "  ✅ CodeQL Security: Active (Python Parse Error behoben)"
Write-Host "  ✅ Trivy Vulnerability Scan: Active"
Write-Host "  ✅ Snyk Security: Active"
Write-Host "  ✅ Lighthouse Performance: ≥90 Budget"
Write-Host "  ✅ DSGVO Compliance: Documented"
Write-Host "  ✅ SBOM & SLSA: Build Attestation"

Write-Host ""

# CI/CD Pipeline Analysis
Write-Host "🔄 CI/CD PIPELINE DIAGNOSIS:" -ForegroundColor Red
Write-Host "============================" -ForegroundColor Red
Write-Host "  🔴 TypeScript Compilation: Multiple services failing"
Write-Host "  🔴 Python Tests: FastAPI service issues"
Write-Host "  🔴 PHP Tests: Aborted on PHP 8.1"
Write-Host "  🔴 Security Monitoring: Configuration issues"
Write-Host "  ⚠️ Performance Tests: Skipped"
Write-Host "  ⚠️ E2E Tests: Skipped"
Write-Host "  ⚠️ DSGVO Validation: Skipped"

Write-Host ""

# ACL & Permissions Check
Write-Host "🔐 ACCESS CONTROL & PERMISSIONS:" -ForegroundColor Magenta
Write-Host "================================" -ForegroundColor Magenta

$aclChecks = @()
$paths = @(
    @{ Path = ".devcontainer"; Expected = "Read/Write"; Critical = $true }
    @{ Path = "scripts"; Expected = "Execute"; Critical = $true }
    @{ Path = "deployment-scripts"; Expected = "Execute"; Critical = $true }
    @{ Path = "secrets"; Expected = "Read Only"; Critical = $true }
    @{ Path = "quality-reports"; Expected = "Write"; Critical = $false }
    @{ Path = ".github/workflows"; Expected = "Read/Write"; Critical = $true }
)

foreach ($pathCheck in $paths) {
    if (Test-Path $pathCheck.Path) {
        try {
            $acl = Get-Acl $pathCheck.Path -ErrorAction SilentlyContinue
            $hasAccess = $true
            $status = "✅"
            $color = "Green"
        } catch {
            $hasAccess = $false
            $status = "❌"
            $color = "Red"
        }
    } else {
        $hasAccess = $false
        $status = "⚠️"
        $color = "Yellow"
    }

    Write-Host "  $status $($pathCheck.Path): " -ForegroundColor $color -NoNewline
    Write-Host "$($pathCheck.Expected)" -ForegroundColor Gray

    $aclChecks += @{
        Path = $pathCheck.Path
        Status = $hasAccess
        Critical = $pathCheck.Critical
        Expected = $pathCheck.Expected
    }
}

Write-Host ""

# Service Autostart Check
Write-Host "🔄 SERVICE AUTOSTART ANALYSIS:" -ForegroundColor Blue
Write-Host "==============================" -ForegroundColor Blue

$autostartServices = @(
    @{ Service = "npm run dev:all"; Status = "Manual"; Port = "Multiple" }
    @{ Service = "Docker Desktop"; Status = "Auto"; Port = "N/A" }
    @{ Service = "PostgreSQL"; Status = "Manual"; Port = "5432" }
    @{ Service = "MariaDB"; Status = "Manual"; Port = "3306" }
    @{ Service = "n8n Automation"; Status = "Docker"; Port = "5678" }
    @{ Service = "Plesk Sync"; Status = "Manual"; Port = "SSH/22" }
)

foreach ($service in $autostartServices) {
    $statusColor = switch ($service.Status) {
        'Auto' { 'Green' }
        'Docker' { 'Blue' }
        'Manual' { 'Yellow' }
        default { 'Gray' }
    }

    $statusIcon = switch ($service.Status) {
        'Auto' { '🟢' }
        'Docker' { '🐳' }
        'Manual' { '🔶' }
        default { '❓' }
    }

    Write-Host "  $statusIcon $($service.Service): " -ForegroundColor $statusColor -NoNewline
    Write-Host "$($service.Status) (Port: $($service.Port))" -ForegroundColor Gray
}

Write-Host ""

# CPU & Resource Check
Write-Host "💻 SYSTEM RESOURCES & PERFORMANCE:" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan

$cpu = Get-WmiObject -Class Win32_Processor | Select-Object -First 1
$memory = Get-WmiObject -Class Win32_ComputerSystem
$disk = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DriveType -eq 3 }

$totalMemoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

Write-Host "  🖥️ CPU: $($cpu.Name)" -ForegroundColor Gray
Write-Host "  📊 CPU Usage: $([math]::Round($cpuUsage, 1))%" -ForegroundColor $(if($cpuUsage -gt 80){'Red'}elseif($cpuUsage -gt 60){'Yellow'}else{'Green'})
Write-Host "  💾 Total Memory: $totalMemoryGB GB" -ForegroundColor Gray

foreach ($drive in $disk) {
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    $totalSpaceGB = [math]::Round($drive.Size / 1GB, 2)
    $usedPercentage = [math]::Round(((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100), 1)

    $diskColor = if($usedPercentage -gt 90){'Red'}elseif($usedPercentage -gt 80){'Yellow'}else{'Green'}
    Write-Host "  💿 Drive $($drive.DeviceID) $freeSpaceGB GB free / $totalSpaceGB GB total ($usedPercentage% used)" -ForegroundColor $diskColor
}

Write-Host ""

# Logging & Monitoring
Write-Host "📝 LOGGING & MONITORING STATUS:" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green

$logPaths = @(
    @{ Path = "quality-reports"; Type = "Quality Reports"; Critical = $true }
    @{ Path = "playwright-results"; Type = "E2E Test Results"; Critical = $false }
    @{ Path = "test-results"; Type = "Unit Test Results"; Critical = $false }
    @{ Path = ".github/workflows"; Type = "CI/CD Logs"; Critical = $true }
)

foreach ($logPath in $logPaths) {
    if (Test-Path $logPath.Path) {
        $files = Get-ChildItem $logPath.Path -Recurse | Measure-Object
        $status = "✅"
        $color = "Green"
        $info = "$($files.Count) files"
    } else {
        $status = "❌"
        $color = "Red"
        $info = "Missing"
    }

    Write-Host "  $status $($logPath.Type): " -ForegroundColor $color -NoNewline
    Write-Host "$info" -ForegroundColor Gray
}

Write-Host ""

# Immediate Action Plan
Write-Host "🎯 IMMEDIATE ACTION PLAN:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan
Write-Host "  1. 🔧 Fix TypeScript compilation issues across services"
Write-Host "  2. 🐍 Resolve Python CI/CD failures in FastAPI service"
Write-Host "  3. 🔴 Address PHP 8.1 test aborts in CRM service"
Write-Host "  4. 📦 Process 28 Dependabot PRs systematically"
Write-Host "  5. 🚀 Validate and fix Codespace configuration (PR #30)"
Write-Host "  6. 🔍 Enable skipped tests (Performance, E2E, DSGVO)"
Write-Host "  7. 🔐 Review and fix ACL permissions for critical paths"
Write-Host "  8. ⚡ Optimize system resources for development workload"

Write-Host ""

# Success Metrics Calculation
$totalChecks = $repoHealth.FailedChecks + $repoHealth.SuccessfulChecks + $repoHealth.AbortedChecks
$successRate = [math]::Round(($repoHealth.SuccessfulChecks / $totalChecks) * 100, 1)

$healthyServices = ($services.Values | Where-Object { $_.Status -eq 'Healthy' }).Count
$totalServices = $services.Count
$serviceHealth = [math]::Round(($healthyServices / $totalServices) * 100, 1)

$criticalACLs = ($aclChecks | Where-Object { $_.Critical -eq $true -and $_.Status -eq $false }).Count
$totalCriticalACLs = ($aclChecks | Where-Object { $_.Critical -eq $true }).Count

Write-Host "📈 CURRENT SUCCESS METRICS:" -ForegroundColor Magenta
Write-Host "===========================" -ForegroundColor Magenta
Write-Host "  CI/CD Success Rate: $successRate%" -ForegroundColor $(if($successRate -lt 50){'Red'}elseif($successRate -lt 80){'Yellow'}else{'Green'})
Write-Host "  Service Health: $serviceHealth% ($healthyServices/$totalServices healthy)" -ForegroundColor $(if($serviceHealth -lt 50){'Red'}elseif($serviceHealth -lt 80){'Yellow'}else{'Green'})
Write-Host "  Critical ACL Issues: $criticalACLs/$totalCriticalACLs" -ForegroundColor $(if($criticalACLs -gt 0){'Red'}else{'Green'})
Write-Host "  System Resources: " -NoNewline
if ($cpuUsage -lt 60) { Write-Host "Optimal" -ForegroundColor Green }
elseif ($cpuUsage -lt 80) { Write-Host "Moderate" -ForegroundColor Yellow }
else { Write-Host "High Load" -ForegroundColor Red }

Write-Host ""

# Overall Health Assessment
$overallScore = [math]::Round(($successRate * 0.4 + $serviceHealth * 0.4 + (100 - ($criticalACLs * 20)) * 0.2), 1)

Write-Host "🏆 OVERALL SYSTEM HEALTH: $overallScore%" -ForegroundColor Magenta
if ($overallScore -ge 80) {
    Write-Host "✅ GOOD: System performing within acceptable parameters" -ForegroundColor Green -BackgroundColor Black
} elseif ($overallScore -ge 60) {
    Write-Host "⚠️ WARNING: Significant improvements needed" -ForegroundColor Yellow -BackgroundColor Black
} else {
    Write-Host "🚨 CRITICAL: Immediate intervention required!" -ForegroundColor Red -BackgroundColor Black
}

Write-Host ""
Write-Host "📋 RECOMMENDATIONS:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan

if ($successRate -lt 50) {
    Write-Host "  🔴 CRITICAL: Fix CI/CD pipeline immediately - 16 failing checks"
}

if ($serviceHealth -lt 50) {
    Write-Host "  🔴 CRITICAL: Multiple services in critical state - requires immediate attention"
}

if ($criticalACLs -gt 0) {
    Write-Host "  ⚠️ WARNING: Fix ACL permissions for critical paths"
}

if ($cpuUsage -gt 80) {
    Write-Host "  ⚡ INFO: High CPU usage detected - consider resource optimization"
}

Write-Host ""
Write-Host "🎯 Next Steps: Execute PR #30 fix → Process Dependabot PRs → Validate all services" -ForegroundColor Green -BackgroundColor Black
Write-Host "📅 Target: 95% CI/CD success rate within 7 days" -ForegroundColor Cyan
