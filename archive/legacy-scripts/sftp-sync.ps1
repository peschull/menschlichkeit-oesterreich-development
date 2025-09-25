# SFTP Sync Script für Menschlichkeit Österreich Development (PowerShell)

param(
    [string]$RemoteHost = "",
    [string]$RemoteUser = "",
    [int]$RemotePort = 22,
    [switch]$DryRun = $false
)

$LocalBase = "d:\Arbeitsverzeichniss"

# Farben für Output
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
}

Write-Host "🚀 SFTP Sync für Menschlichkeit Österreich Development" -ForegroundColor Blue
Write-Host "========================================================"

# Funktion für SFTP Upload mit WinSCP
function Sync-Directory {
    param(
        [string]$LocalDir,
        [string]$RemoteDir,
        [string]$Description
    )
    
    Write-Host "`n📂 Syncing: $Description" -ForegroundColor Yellow
    Write-Host "   Local:  $LocalDir"
    Write-Host "   Remote: $RemoteDir"
    
    if (-not (Test-Path $LocalDir)) {
        Write-Host "❌ Local directory not found: $LocalDir" -ForegroundColor Red
        return $false
    }
    
    if ($DryRun) {
        Write-Host "🧪 DRY RUN - Would sync: $LocalDir -> $RemoteDir" -ForegroundColor Cyan
        return $true
    }
    
    # WinSCP Batch Script erstellen
    $WinSCPScript = @"
open sftp://${RemoteUser}@${RemoteHost}:${RemotePort}/
option batch abort
option confirm off
mkdir $RemoteDir
cd $RemoteDir
lcd $LocalDir
synchronize remote -delete
exit
"@
    
    $ScriptFile = "$env:TEMP\winscp_batch.txt"
    $WinSCPScript | Out-File -FilePath $ScriptFile -Encoding UTF8
    
    try {
        Write-Host "⬆️  Uploading..." -ForegroundColor Blue
        
        # WinSCP ausführen (falls verfügbar)
        if (Get-Command "WinSCP.exe" -ErrorAction SilentlyContinue) {
            & WinSCP.exe /script=$ScriptFile
            Write-Host "✅ Successfully synced: $Description" -ForegroundColor Green
        }
        # Alternative: PSFTP (PuTTY)
        elseif (Get-Command "psftp.exe" -ErrorAction SilentlyContinue) {
            & psftp.exe -b $ScriptFile $RemoteUser@$RemoteHost
            Write-Host "✅ Successfully synced: $Description" -ForegroundColor Green
        }
        else {
            Write-Host "❌ No SFTP client found. Install WinSCP or PuTTY PSFTP." -ForegroundColor Red
            return $false
        }
        
        return $true
    }
    catch {
        Write-Host "❌ Failed to sync: $Description" -ForegroundColor Red
        Write-Host "Error: $_" -ForegroundColor Red
        return $false
    }
    finally {
        if (Test-Path $ScriptFile) {
            Remove-Item $ScriptFile -Force
        }
    }
}

# Validierung der Konfiguration
if (-not $RemoteHost -or -not $RemoteUser) {
    Write-Host "❌ Please provide RemoteHost and RemoteUser parameters" -ForegroundColor Red
    Write-Host "Usage: .\sftp-sync.ps1 -RemoteHost 'your-server.com' -RemoteUser 'username'" -ForegroundColor Yellow
    Write-Host "Add -DryRun for testing without actual upload" -ForegroundColor Yellow
    exit 1
}

Write-Host "📋 Pre-sync Checks:" -ForegroundColor Yellow
Write-Host "   Remote Host: $RemoteHost"
Write-Host "   Remote User: $RemoteUser"
Write-Host "   Remote Port: $RemotePort"
Write-Host "   Local Base:  $LocalBase"
Write-Host "   Dry Run:     $DryRun"

$SyncResults = @()

# Upload Plesk database setup script first
Write-Host "`n🔧 Uploading Plesk database setup script..." -ForegroundColor Cyan
$PleskScript = @{
    Local = "$PSScriptRoot\..\plesk-db-setup.php"
    Remote = "/httpdocs/plesk-db-setup.php"  
    Description = "Plesk Database Setup Script"
}
$SyncResults += Invoke-SFTPSync @PleskScript

# WordPress Hauptdomain
$SyncResults += Sync-Directory `
    -LocalDir "$LocalBase\menschlichkeit-oesterreich-monorepo\httpdocs" `
    -RemoteDir "/public_html" `
    -Description "WordPress Hauptdomain"

# Laravel API Subdomain
$SyncResults += Sync-Directory `
    -LocalDir "$LocalBase\menschlichkeit-oesterreich-monorepo\api.menschlichkeit-oesterreich.at" `
    -RemoteDir "/subdomains/api/public_html" `
    -Description "Laravel API Subdomain"

# CiviCRM Subdomain (Vorbereitung)
$CiviCRMPath = "$LocalBase\menschlichkeit-oesterreich-monorepo\crm.menschlichkeit-oesterreich.at"
if (Test-Path $CiviCRMPath) {
    $SyncResults += Sync-Directory `
        -LocalDir $CiviCRMPath `
        -RemoteDir "/subdomains/crm/public_html" `
        -Description "CiviCRM Subdomain"
}
else {
    Write-Host "⚠️  CiviCRM directory not found - will be created during CiviCRM integration" -ForegroundColor Yellow
}

# Ergebnisse
$SuccessCount = ($SyncResults | Where-Object { $_ -eq $true }).Count
$TotalCount = $SyncResults.Count

Write-Host "`n🎉 SFTP Sync completed!" -ForegroundColor Green
Write-Host "📊 Results: $SuccessCount/$TotalCount successful" -ForegroundColor Blue

Write-Host "`n📋 Next Steps:" -ForegroundColor Blue
Write-Host "   1. Verify uploads on remote server"
Write-Host "   2. Configure database connections (MariaDB localhost:3306)"
Write-Host "   3. Set up CiviCRM integration"
Write-Host "   4. Configure API automation"