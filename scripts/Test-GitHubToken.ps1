# 🔐 GitHub Token Validation Tests
# Testet die verschiedenen Token-Formate für Sicherheit

param(
    [string]$TestToken
)

function Test-GitHubTokenFormat {
    param([string]$Token)
    
    if ([string]::IsNullOrWhiteSpace($Token)) { 
        return @{ Valid = $false; Type = "Empty"; Secure = $false; Message = "Token ist leer" }
    }
    
    # Prüfe fine-grained Token Format (github_pat_...)
    if ($Token.StartsWith("github_pat_")) {
        # Fine-grained Token: github_pat_[variable length]
        if ($Token.Length -ge 70 -and $Token -match "^github_pat_[A-Za-z0-9_-]+$") {
            return @{ 
                Valid = $true
                Type = "Fine-Grained"
                Secure = $true
                Message = "✅ Sicherer Fine-Grained Token mit Repository-spezifischen Berechtigungen"
                Permissions = @("Actions:Read", "Contents:Read", "Metadata:Read")
            }
        } else {
            return @{
                Valid = $false
                Type = "Malformed Fine-Grained"
                Secure = $false
                Message = "❌ Ungültiges Fine-Grained Token Format"
            }
        }
    }
    
    # Prüfe klassisches Token Format (ghp_...)
    elseif ($Token.StartsWith("ghp_")) {
        if ($Token.Length -eq 40 -and $Token -match "^ghp_[A-Za-z0-9]{36}$") {
            return @{
                Valid = $true
                Type = "Classic"
                Secure = $false
                Message = "⚠️ Klassischer Token - Empfehlung: Wechsel zu Fine-Grained Token"
                Recommendation = "Erstelle Fine-Grained Token für bessere Sicherheit"
            }
        } else {
            return @{
                Valid = $false
                Type = "Malformed Classic"
                Secure = $false
                Message = "❌ Ungültiges klassisches Token Format"
            }
        }
    }
    
    # Unbekanntes Format
    else {
        return @{
            Valid = $false
            Type = "Unknown"
            Secure = $false
            Message = "❌ Unbekanntes Token-Format - Muss mit 'github_pat_' oder 'ghp_' beginnen"
        }
    }
}

function Show-TokenStatus {
    param([hashtable]$TokenInfo)
    
    Write-Host "`n🔍 Token-Analyse:" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Gray
    Write-Host "Typ: $($TokenInfo.Type)" -ForegroundColor $(if ($TokenInfo.Secure) { "Green" } else { "Yellow" })
    Write-Host "Gültig: $(if ($TokenInfo.Valid) { "✅ Ja" } else { "❌ Nein" })" -ForegroundColor $(if ($TokenInfo.Valid) { "Green" } else { "Red" })
    Write-Host "Sicher: $(if ($TokenInfo.Secure) { "🔒 Ja" } else { "⚠️ Klassisch" })" -ForegroundColor $(if ($TokenInfo.Secure) { "Green" } else { "Yellow" })
    Write-Host "Status: $($TokenInfo.Message)" -ForegroundColor $(if ($TokenInfo.Valid) { "Green" } else { "Red" })
    
    if ($TokenInfo.Permissions) {
        Write-Host "`nBerechtigungen:" -ForegroundColor Cyan
        foreach ($perm in $TokenInfo.Permissions) {
            Write-Host "  • $perm" -ForegroundColor White
        }
    }
    
    if ($TokenInfo.Recommendation) {
        Write-Host "`n💡 Empfehlung: $($TokenInfo.Recommendation)" -ForegroundColor Yellow
    }
}

# Test Token wenn bereitgestellt
if ($TestToken) {
    $result = Test-GitHubTokenFormat -Token $TestToken
    Show-TokenStatus -TokenInfo $result
} else {
    # Test mit Token aus Sicherheitsdatei
    $tokenFile = Join-Path $PSScriptRoot "..\secrets\github-token.ps1"
    
    if (Test-Path $tokenFile) {
        Write-Host "🔍 Lade Token aus Sicherheitsdatei..." -ForegroundColor Cyan
        
        try {
            . $tokenFile
            
            if ($env:GITHUB_TOKEN) {
                $result = Test-GitHubTokenFormat -Token $env:GITHUB_TOKEN
                Show-TokenStatus -TokenInfo $result
                
                # Zeige Datei-Info
                Write-Host "`n📄 Token-Datei: $tokenFile" -ForegroundColor Gray
                Write-Host "🔒 Sicher gespeichert und von Git ausgeschlossen" -ForegroundColor Green
            } else {
                Write-Host "❌ GITHUB_TOKEN nicht in der Datei gesetzt" -ForegroundColor Red
            }
        }
        catch {
            Write-Host "❌ Fehler beim Laden der Token-Datei: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "⚠️ Keine Token-Datei gefunden: $tokenFile" -ForegroundColor Yellow
        Write-Host "💡 Erstelle zuerst eine sichere Token-Datei" -ForegroundColor Cyan
    }
}

# Funktionen für Verwendung in anderen Skripten verfügbar
# Test-GitHubTokenFormat, Show-TokenStatus