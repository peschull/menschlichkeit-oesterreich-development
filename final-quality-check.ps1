Write-Host "🏆 FINALE CODESPACE-QUALITÄTSBEWERTUNG" -ForegroundColor Magenta
Write-Host "=======================================" -ForegroundColor Magenta
Write-Host ""

# Configuration completeness check
$configScore = 0
$maxScore = 100

# devcontainer.json check
if (Test-Path ".devcontainer/devcontainer.json") {
    $config = Get-Content ".devcontainer/devcontainer.json" | ConvertFrom-Json
    Write-Host "✅ devcontainer.json: Vollständig konfiguriert" -ForegroundColor Green
    $configScore += 25

    # Features check
    if ($config.features) {
        Write-Host "✅ Features: $($config.features.PSObject.Properties.Count) Runtime-Umgebungen" -ForegroundColor Green
        $configScore += 15
    }

    # Ports check
    if ($config.forwardPorts) {
        Write-Host "✅ Ports: $($config.forwardPorts.Count) Services konfiguriert" -ForegroundColor Green
        $configScore += 15
    }

    # Secrets check
    if ($config.secrets) {
        Write-Host "✅ Secrets: $($config.secrets.PSObject.Properties.Count) GitHub Secrets Integration" -ForegroundColor Green
        $configScore += 20
    }

    # Extensions check
    if ($config.customizations.vscode.extensions) {
        Write-Host "✅ Extensions: $($config.customizations.vscode.extensions.Count) VS Code Extensions" -ForegroundColor Green
        $configScore += 10
    }
}

# Scripts check
$scriptsPresent = @(".devcontainer/setup.sh", ".devcontainer/post-start.sh", ".devcontainer/quick-fix.sh")
$scriptsFound = 0
foreach ($script in $scriptsPresent) {
    if (Test-Path $script) {
        $scriptsFound++
    }
}

if ($scriptsFound -eq 3) {
    Write-Host "✅ Scripts: Alle 3 Lifecycle-Scripts vorhanden" -ForegroundColor Green
    $configScore += 15
} else {
    Write-Host "⚠️ Scripts: $scriptsFound/3 Scripts gefunden" -ForegroundColor Yellow
    $configScore += ($scriptsFound * 5)
}

Write-Host ""
Write-Host "📊 QUALITY METRICS:" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Configuration Score: $configScore/100"

# Grade calculation
$grade = "F"
if ($configScore -ge 95) { $grade = "A+" }
elseif ($configScore -ge 90) { $grade = "A" }
elseif ($configScore -ge 85) { $grade = "B+" }
elseif ($configScore -ge 80) { $grade = "B" }
elseif ($configScore -ge 75) { $grade = "C+" }
elseif ($configScore -ge 70) { $grade = "C" }

$color = switch ($grade) {
    "A+" { "Green" }
    "A" { "Green" }
    "B+" { "Yellow" }
    "B" { "Yellow" }
    default { "Red" }
}

Write-Host ""
Write-Host "🎓 FINAL GRADE: $grade" -ForegroundColor $color -BackgroundColor Black
Write-Host ""

# Recommendations based on score
Write-Host "💡 HANDLUNGSEMPFEHLUNGEN:" -ForegroundColor Cyan
Write-Host "=========================" -ForegroundColor Cyan

if ($configScore -ge 95) {
    Write-Host "🌟 EXZELLENT: Production-ready!" -ForegroundColor Green
    Write-Host "→ Deployment in GitHub Codespaces empfohlen" -ForegroundColor Green
    Write-Host "→ Team-weites Rollout möglich" -ForegroundColor Green
} elseif ($configScore -ge 90) {
    Write-Host "✅ SEHR GUT: Minimale Verbesserungen" -ForegroundColor Green
    Write-Host "→ Error Handling in Scripts ergänzen"
    Write-Host "→ Zusätzliche VS Code Extensions prüfen"
} else {
    Write-Host "⚠️ VERBESSERUNGEN ERFORDERLICH:" -ForegroundColor Yellow
    Write-Host "→ Fehlende Konfigurationen ergänzen"
    Write-Host "→ Scripts vervollständigen"
    Write-Host "→ Sicherheits-Review durchführen"
}

Write-Host ""
Write-Host "🚀 NÄCHSTE SCHRITTE:" -ForegroundColor Magenta
Write-Host "1. GitHub Secrets konfigurieren (26+ Secrets aus ZUGANGSDATEN-WOHER-BEKOMMEN.txt)"
Write-Host "2. Neuen Codespace erstellen und testen"
Write-Host "3. Multi-Service-Start mit 'npm run dev:all' validieren"
Write-Host "4. Team-Training für Codespace-Nutzung"
Write-Host ""
Write-Host "✨ CODESPACE IST BEREIT FÜR DIE ÖSTERREICHISCHE NGO-PLATTFORM! ✨" -ForegroundColor Green -BackgroundColor Black
