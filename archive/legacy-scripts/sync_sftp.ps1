# PowerShell-Skript für SFTP-Synchronisation mit OpenSSH
# Benötigt keine externen Tools, nur Windows OpenSSH Client

# ====== Server-Zugang ======
$HOST_ADDR = "5.183.217.146"
$USER = "dmpl20230054"
$SSH_KEY = "C:\Users\schul\.ssh\id_ed25519"

# ====== Remote-Webroots (Plesk chroot) ======
$REMOTE_WEBROOT_MAIN = "/httpdocs"
$REMOTE_WEBROOT_API = "/api.menschlichkeit-oesterreich.at"
$REMOTE_WEBROOT_CRM = "/crm.menschlichkeit-oesterreich.at"

# ====== Lokales Monorepo-Ziel ======
$BASE_DIR = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$REPO_DIR = "$BASE_DIR\menschlichkeit-oesterreich-monorepo"
$MAIN_DIR = "$REPO_DIR\httpdocs"
$API_DIR = "$REPO_DIR\api.menschlichkeit-oesterreich.at"
$CRM_DIR = "$REPO_DIR\crm.menschlichkeit-oesterreich.at"

# ====== Hilfsfunktionen ======
function Write-ColorOutput {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [ConsoleColor]$ForegroundColor = [ConsoleColor]::White
    )
    
    $originalColor = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    Write-Output $Message
    $host.UI.RawUI.ForegroundColor = $originalColor
}

function Test-SFTPConnection {
    param (
        [string]$HostAddr,
        [string]$User,
        [string]$KeyPath
    )

    try {
        Write-ColorOutput "📡 Teste SFTP-Verbindung zu $User@$HostAddr..." -ForegroundColor Cyan
        
        # Teste, ob der Host auf Port 22 erreichbar ist
        $testConn = Test-NetConnection -ComputerName $HostAddr -Port 22 -WarningAction SilentlyContinue -InformationLevel Quiet
        if (-not $testConn) {
            Write-ColorOutput "❌ Server nicht erreichbar auf Port 22 (SSH/SFTP)" -ForegroundColor Red
            return $false
        }

        # Probiere einen kurzen SFTP-Befehl
        $batchFile = Join-Path $env:TEMP "sftp_test.txt"
        "pwd" | Set-Content -Path $batchFile
        
        $output = & sftp -i "$KeyPath" -o "StrictHostKeyChecking=accept-new" -o "BatchMode=yes" -b "$batchFile" "$User@$HostAddr" 2>&1
        $success = ($LASTEXITCODE -eq 0)
        
        Remove-Item -Path $batchFile -Force -ErrorAction SilentlyContinue
        
        if ($success) {
            Write-ColorOutput "✅ SFTP-Verbindung erfolgreich getestet!" -ForegroundColor Green
            return $true
        } else {
            Write-ColorOutput "❌ SFTP-Verbindung fehlgeschlagen: $output" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-ColorOutput "❌ Fehler beim Testen der SFTP-Verbindung: $_" -ForegroundColor Red
        return $false
    }
}

function Sync-SFTPFolder {
    param (
        [string]$LocalDir,
        [string]$RemoteDir,
        [string]$Description,
        [string[]]$Excludes = @()
    )
    
    # Verzeichnis erstellen falls nicht vorhanden
    if (-not (Test-Path $LocalDir)) {
        New-Item -Path $LocalDir -ItemType Directory -Force | Out-Null
    }
    
    Write-ColorOutput "→ Pull: $Description nach $LocalDir" -ForegroundColor Cyan
    
    # SFTP-Befehle erstellen
    $batchFile = Join-Path $env:TEMP "sftp_commands_$([Guid]::NewGuid().ToString()).txt"
    
    "lcd $LocalDir" | Out-File -FilePath $batchFile -Encoding utf8
    "cd $RemoteDir" | Out-File -FilePath $batchFile -Encoding utf8 -Append
    
    # Die häufigsten Dateien und Verzeichnisse direkt holen
    $getCommands = @(
        "get -r index.php",
        "get -r wp-config.php",
        "get -r wp-admin",
        "get -r wp-includes",
        "get -r wp-content/themes",
        "get -r wp-content/plugins"
    )
    
    # Für API und CRM andere Dateien
    if ($Description -eq "API") {
        $getCommands = @(
            "get -r app",
            "get -r bootstrap",
            "get -r config",
            "get -r database",
            "get -r public",
            "get -r resources",
            "get -r routes",
            "get -r composer.json"
        )
    }
    elseif ($Description -eq "CRM") {
        $getCommands = @(
            "get -r *.php",
            "get -r includes",
            "get -r administrator",
            "get -r components",
            "get -r modules",
            "get -r templates",
            "get -r configuration.php"
        )
    }
    
    # Befehle in Batch-Datei schreiben
    foreach ($cmd in $getCommands) {
        $cmd | Out-File -FilePath $batchFile -Encoding utf8 -Append
    }
    
    try {
        # SFTP-Befehl ausführen
        $result = & sftp -i "$SSH_KEY" -o "StrictHostKeyChecking=accept-new" -b $batchFile "$USER@$HOST_ADDR" 2>&1
        $success = ($LASTEXITCODE -eq 0)
        
        # Ausgabe und Fehler behandeln
        if ($success) {
            Write-ColorOutput "✅ $Description erfolgreich synchronisiert" -ForegroundColor Green
        } else {
            Write-ColorOutput "❌ Fehler beim Synchronisieren von $Description" -ForegroundColor Red
            Write-ColorOutput $result -ForegroundColor Yellow
        }
        
        return $success
    }
    catch {
        Write-ColorOutput "❌ Ausnahmefehler bei $Description`: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
    finally {
        # Aufräumen
        Remove-Item -Path $batchFile -Force -ErrorAction SilentlyContinue
    }
}

# ====== Hauptteil ======
Write-ColorOutput "🚀 SFTP-Sync mit PowerShell und OpenSSH..." -ForegroundColor Cyan
Write-ColorOutput "   Lokales Ziel: $REPO_DIR" -ForegroundColor Cyan

# Verbindung testen
if (-not (Test-SFTPConnection -HostAddr $HOST_ADDR -User $USER -KeyPath $SSH_KEY)) {
    $continue = Read-Host "Trotzdem fortfahren? (j/n)"
    if ($continue -ne "j") {
        exit 1
    }
}

# Hauptverzeichnisse erstellen
if (-not (Test-Path $REPO_DIR)) {
    New-Item -Path $REPO_DIR -ItemType Directory -Force | Out-Null
}

# Synchronisieren
$results = @{}
$results["main"] = Sync-SFTPFolder -LocalDir $MAIN_DIR -RemoteDir $REMOTE_WEBROOT_MAIN -Description "Hauptdomain (WordPress)"
$results["api"] = Sync-SFTPFolder -LocalDir $API_DIR -RemoteDir $REMOTE_WEBROOT_API -Description "API"
$results["crm"] = Sync-SFTPFolder -LocalDir $CRM_DIR -RemoteDir $REMOTE_WEBROOT_CRM -Description "CRM"

# Ergebnisse anzeigen
$errors = @($results.Values | Where-Object { $_ -eq $false })

if ($errors.Count -eq 0) {
    Write-ColorOutput "`n✅ Alle Synchronisationen erfolgreich abgeschlossen!" -ForegroundColor Green
    Write-ColorOutput "✅ Dateien wurden nach $REPO_DIR synchronisiert." -ForegroundColor Green
    Write-ColorOutput "`nNächste Schritte:" -ForegroundColor Yellow
    Write-ColorOutput "1. Ggf. .gitignore anpassen in $REPO_DIR" -ForegroundColor Yellow
    Write-ColorOutput "2. Änderungen mit Git commit + push sichern" -ForegroundColor Yellow
} else {
    Write-ColorOutput "`n⚠️ Es sind Fehler aufgetreten!" -ForegroundColor Red
    Write-ColorOutput "Fehlgeschlagene Synchronisationen:" -ForegroundColor Red
    
    foreach ($key in $results.Keys) {
        if (-not $results[$key]) {
            Write-ColorOutput "- $key" -ForegroundColor Red
        }
    }
    
    Write-ColorOutput "`nHinweise zur Fehlerbehebung:" -ForegroundColor Yellow
    Write-ColorOutput "- Prüfe die Serververbindung manuell: sftp $USER@$HOST_ADDR" -ForegroundColor Yellow
    Write-ColorOutput "- Prüfe, ob die Remote-Verzeichnisse existieren" -ForegroundColor Yellow
    Write-ColorOutput "- Prüfe den SSH-Key: $SSH_KEY" -ForegroundColor Yellow
}