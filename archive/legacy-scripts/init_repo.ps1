# Initialisiert das Monorepo, führt einen Sync aus und pusht zu GitHub
param(
  [string]$GithubRemote = "git@github.com:DEIN-USER/menschlichkeit-oesterreich-monorepo.git",
  [ValidateSet("winscp","sftp","ssh-tar")][string]$Mode = "ssh-tar"
)

$ErrorActionPreference = "Stop"
$BASE = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$REPO = Join-Path $BASE "menschlichkeit-oesterreich-monorepo"

New-Item -ItemType Directory -Force -Path (Join-Path $REPO "httpdocs") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $REPO "api.menschlichkeit-oesterreich.at") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $REPO "crm.menschlichkeit-oesterreich.at") | Out-Null

Write-Host "🚀 Starte Sync-Modus: $Mode" -ForegroundColor Cyan
switch ($Mode) {
  "winscp" { & "$PSScriptRoot\sync_winscp.cmd" }
  "sftp"   { & "$PSScriptRoot\sync_sftp.ps1" }
  default   { & "$PSScriptRoot\sync_ssh_tar.ps1" }
}

# Git initialisieren
Set-Location $REPO
if (-not (Test-Path ".git")) {
  git init | Out-Null
  git checkout -b main | Out-Null
  git remote add origin $GithubRemote
}

# Schutz: Nicht committen, wenn nichts da
$changes = git status --porcelain
if ([string]::IsNullOrWhiteSpace($changes)) {
  Write-Host "ℹ️ Keine Änderungen zum Committen gefunden." -ForegroundColor Yellow
} else {
  git add .
  git commit -m "Initial import from server"
}

# Push (erster Push setzt Upstream, danach normal)
try {
  git push -u origin main
} catch {
  Write-Host "⚠️ Push fehlgeschlagen. Prüfe, ob das Remote-Repo leer ist und ob du Zugriffsrechte hast." -ForegroundColor Yellow
}

Write-Host "✅ Fertig." -ForegroundColor Green
