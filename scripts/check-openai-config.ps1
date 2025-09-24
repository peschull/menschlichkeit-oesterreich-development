<#
.SYNOPSIS
  Statisches Audit: durchsucht Workspace nach OpenAI/ChatGPT/Codex-Konfigurationen.
  Keine Netzwerkaufrufe, nur Lesezugriff auf Dateien im Workspace.

.USAGE
  pwsh -NoProfile -ExecutionPolicy Bypass .\scripts\check-openai-config.ps1

.OUTPUT
  Konsolenausgabe: Gefundene Dateien, Auszüge und Repo-Referenzen.
#>

$ErrorActionPreference = 'Stop'

# Dateien, die wir prüfen wollen
$paths = @(
  'secrets/production/api-keys.yaml',
  '.vscode/settings.json',
  'scripts/openai-test.ps1',
  'docs/openai-setup.md',
  'enterprise-upgrade/docs/13_chatgpt-repair-status.md'
)

Write-Host "== Statisches OpenAI/ChatGPT Audit (kein Netzwerk) ==`n"

foreach ($p in $paths) {
  if (Test-Path $p) {
    Write-Host "----- $p -----" -ForegroundColor Cyan
    try {
      Get-Content $p -TotalCount 200 | ForEach-Object { Write-Host "  $_" }
    }
    catch {
      Write-Host "  (Fehler beim Lesen) $_" -ForegroundColor Yellow
    }
    Write-Host ""
  }
  else {
    Write-Host "Missing: $p" -ForegroundColor DarkYellow
  }
}

Write-Host "== Repo-weit: Suche nach Schlüsselwörtern openai/chatgpt/codex/OPENAI_API_KEY ==`n"
try {
  $matches = Select-String -Path .\**\* -Pattern 'openai|chatgpt|codex|OPENAI_API_KEY' -SimpleMatch -ErrorAction SilentlyContinue | Select-Object -First 500
  if ($matches) {
    foreach ($m in $matches) {
  $file = $m.Path
  $line = $m.LineNumber
  $text = $m.Line.Trim()
  Write-Host "$($file):$line -> $text"
    }
  }
  else { Write-Host "Keine Treffer gefunden." }
}
catch {
  Write-Host "Fehler bei Repo-Suche: $_" -ForegroundColor Red
}

Write-Host "`nAudit abgeschlossen." -ForegroundColor Green
