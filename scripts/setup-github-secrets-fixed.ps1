#!/usr/bin/env pwsh
# GitHub Secrets Bulk Setup für Menschlichkeit Österreich
# Verwendet GitHub CLI (gh) für Repository und Environment Secrets

param(
    [switch]$ShowSecretsList,
    [switch]$GenerateKeys,  
    [switch]$DryRun,
    [switch]$ValidateSecrets,
    [string]$Environment = "staging",
    [string]$Repository = "peschull/menschlichkeit-oesterreich-development"
)

# Simple output function
function Write-Status {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

Write-Status "🔐 GitHub Secrets Bulk Setup für Menschlichkeit Österreich" "Blue"
Write-Status ("=" * 65) "Blue"

# Test GitHub CLI availability
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Status "❌ GitHub CLI (gh) not found! Please install: https://cli.github.com/" "Red"
    exit 1
}

# Test GitHub authentication
try {
    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Status "❌ GitHub CLI not authenticated. Run: gh auth login" "Red"
        exit 1
    }
    Write-Status "✅ GitHub CLI authenticated" "Green"
} catch {
    Write-Status "❌ GitHub CLI authentication check failed" "Red"
    exit 1
}

# Load secrets from generated file
$secretsFile = "./secrets.production.json"
if (-not (Test-Path $secretsFile)) {
    Write-Status "❌ Secrets file not found: $secretsFile" "Red"
    Write-Status "Run: python3 scripts/generate-production-secrets.py" "Yellow"
    exit 1
}

try {
    $secretsData = Get-Content $secretsFile | ConvertFrom-Json
    Write-Status "✅ Loaded secrets from $secretsFile" "Green"
} catch {
    Write-Status "❌ Failed to parse secrets file: $secretsFile" "Red"
    exit 1
}

# Flatten secrets structure for GitHub upload
$allSecrets = @{}

# Application secrets
foreach ($key in $secretsData.application_secrets.PSObject.Properties.Name) {
    $allSecrets[$key] = $secretsData.application_secrets.$key
}

# Database secrets  
foreach ($dbType in $secretsData.databases.PSObject.Properties.Name) {
    foreach ($dbName in $secretsData.databases.$dbType.PSObject.Properties.Name) {
        $db = $secretsData.databases.$dbType.$dbName
        $prefix = $dbName.ToUpper() -replace '[^A-Z0-9_]', '_'
        
        $allSecrets["${prefix}_DB_HOST"] = $db.host
        $allSecrets["${prefix}_DB_PORT"] = $db.port
        $allSecrets["${prefix}_DB_NAME"] = $db.database
        $allSecrets["${prefix}_DB_USER"] = $db.user
        $allSecrets["${prefix}_DB_PASS"] = $db.password
    }
}

# External tools
foreach ($key in $secretsData.external_tools.PSObject.Properties.Name) {
    $allSecrets[$key] = $secretsData.external_tools.$key
}

# Infrastructure
foreach ($key in $secretsData.infrastructure.PSObject.Properties.Name) {
    $allSecrets[$key] = $secretsData.infrastructure.$key
}

Write-Status "📊 Total secrets to upload: $($allSecrets.Count)" "Cyan"

if ($ShowSecretsList) {
    Write-Status "`n📋 Secrets List:" "Yellow"
    $allSecrets.Keys | Sort-Object | ForEach-Object {
        Write-Status "  • $_" "White"
    }
    exit 0
}

if ($DryRun) {
    Write-Status "`n🔍 DRY RUN - Would upload the following secrets:" "Yellow"
    $allSecrets.Keys | Sort-Object | ForEach-Object {
        $maskedValue = ($allSecrets[$_] -replace '.', '*').Substring(0, [Math]::Min(8, $allSecrets[$_].Length)) + "..."
        Write-Status "  $_ = $maskedValue" "Gray"
    }
    exit 0
}

# Upload secrets to GitHub
$successCount = 0
$failCount = 0

Write-Status "`n⬆️ Uploading secrets to repository environments..." "Blue"

foreach ($secretName in $allSecrets.Keys | Sort-Object) {
    $secretValue = $allSecrets[$secretName]
    
    try {
        # Upload to staging environment
        if ($Environment -eq "staging" -or $Environment -eq "all") {
            $result = gh secret set $secretName --env staging --body $secretValue --repo $Repository 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Status "  ✅ $secretName (staging)" "Green"
                $successCount++
            } else {
                Write-Status "  ❌ $secretName (staging): $result" "Red"
                $failCount++
            }
        }
        
        # Upload to production environment  
        if ($Environment -eq "production" -or $Environment -eq "all") {
            $result = gh secret set $secretName --env production --body $secretValue --repo $Repository 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Status "  ✅ $secretName (production)" "Green"
                $successCount++
            } else {
                Write-Status "  ❌ $secretName (production): $result" "Red"
                $failCount++
            }
        }
    } catch {
        Write-Status "  ❌ $secretName - Exception: $_" "Red"
        $failCount++
    }
}

Write-Status "`n📊 Upload Summary:" "Cyan"
Write-Status "  ✅ Successful: $successCount" "Green"
Write-Status "  ❌ Failed: $failCount" "Red"

if ($failCount -gt 0) {
    Write-Status "`n⚠️ Some secrets failed to upload. Check GitHub CLI permissions and repository access." "Yellow"
    exit 1
} else {
    Write-Status "`n🎉 All secrets uploaded successfully!" "Green"
    exit 0
}