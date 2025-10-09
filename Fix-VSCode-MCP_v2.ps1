# === Fix-VSCode-MCP_v2.ps1 ===
$ErrorActionPreference = "Stop"
$ts = Get-Date -Format "yyyyMMdd-HHmmss"

function Backup-IfExists([string]$path) {
  if (Test-Path $path) {
    $bak = "$path.bak.$ts"
    Copy-Item $path $bak -Force
    Write-Host "Backup: $bak"
  }
}

function Test-JsonFile([string]$path) {
  if (!(Test-Path $path)) { return $true }
  try {
    $raw = Get-Content $path -Raw
    if ($raw.Trim().Length -eq 0) { return $true }
    $null = $raw | ConvertFrom-Json -AsHashtable
    return $true
  } catch {
    Write-Warning "JSON-Fehler in: $path"
    Write-Warning $_.Exception.Message
    return $false
  }
}

function Ensure-Json([string]$path, [string]$jsonContent) {
  Backup-IfExists $path
  $dir = Split-Path $path -Parent
  if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
  $jsonContent | Set-Content -Path $path -Encoding UTF8
  Write-Host "Wrote: $path"
}

# ---- Kandidaten-Verzeichnisse für VS Code (remote & lokal) ----
$roots = @()

if ($IsWindows) {
  if ($env:APPDATA) { $roots += (Join-Path $env:APPDATA "Code") }
}

$homeDir = $HOME  # NICHT überschreiben, nur lesen
$roots += @(
  (Join-Path $homeDir ".vscode-server/data"),
  (Join-Path $homeDir ".vscode-remote/data"),
  (Join-Path $homeDir ".config/Code"),
  (Join-Path $homeDir ".local/share/code-server"),
  (Join-Path $homeDir ".vscode-server-insiders/data")
) | Where-Object { Test-Path $_ }

if ($roots.Count -eq 0 -and -not $IsWindows) {
  Write-Warning "Kein VS Code-Datenordner gefunden. Prüfe, ob du im richtigen Remote bist."
}

Write-Host "Roots:"; $roots | ForEach-Object { Write-Host " - $_" }

# ---- Ziele (User/Machine) zusammenstellen ----
$targets = @()
foreach ($r in $roots) {
  $u = Join-Path $r "User"
  $m = Join-Path $r "Machine"
  if (Test-Path $u) { $targets += @{ type="User"; dir=$u; root=$r } }
  if (Test-Path $m) { $targets += @{ type="Machine"; dir=$m; root=$r } }
}

# Falls nichts gefunden wurde, Standard anlegen
if ($targets.Count -eq 0) {
  Write-Warning "Keine Settings-Verzeichnisse gefunden – lege Standardpfad in .vscode-server/data/User an."
  $defRoot = Join-Path $homeDir ".vscode-server/data"
  $defUser = Join-Path $defRoot "User"
  New-Item -ItemType Directory -Path $defUser -Force | Out-Null
  $targets += @{ type="User"; dir=$defUser; root=$defRoot }
}

Write-Host "Targets:"; $targets | ForEach-Object { Write-Host (" - {0}: {1}" -f $_.type, $_.dir) }

# ---- Korrekturen pro Ziel ----
foreach ($t in $targets) {
  $dir = $t.dir
  $settingsPath = Join-Path $dir "settings.json"
  $mcpPath      = Join-Path $dir "mcp.json"

  # settings.json korrigieren / anlegen
  if (!(Test-JsonFile $settingsPath)) {
    Write-Host "settings.json defekt -> neu minimal setzen: $settingsPath"
    Ensure-Json $settingsPath '{ "chat.mcp.discovery.enabled": false }'
  } else {
    $raw = (Test-Path $settingsPath) ? (Get-Content $settingsPath -Raw) : "{}"
    if ([string]::IsNullOrWhiteSpace($raw)) { $raw = "{}" }
    try { $json = $raw | ConvertFrom-Json -AsHashtable } catch { $json = @{} }

    $changed = $false
    if (-not $json.ContainsKey("chat.mcp.discovery.enabled") -or $json["chat.mcp.discovery.enabled"] -ne $false) {
      $json["chat.mcp.discovery.enabled"] = $false; $changed = $true
    }
    foreach ($key in @("mcp","mcpServers","chat.mcp.servers")) {
      if ($json.ContainsKey($key)) { $json.Remove($key) | Out-Null; $changed = $true }
    }
    if ($changed) {
      Backup-IfExists $settingsPath
      ($json | ConvertTo-Json -Depth 50) | Set-Content -Path $settingsPath -Encoding UTF8
      Write-Host "settings.json aktualisiert: $settingsPath"
    } else {
      Write-Host "settings.json ok: $settingsPath"
    }
  }

  # mcp.json neutralisieren
  Ensure-Json $mcpPath '{ "servers": {} }'
}

# ---- Workspace .vscode/mcp.json (im aktuellen Projekt) ----
$wsMcpPath = Join-Path (Get-Location) ".vscode/mcp.json"
$wsDir = Split-Path $wsMcpPath -Parent
if (!(Test-Path $wsDir)) { New-Item -ItemType Directory -Path $wsDir -Force | Out-Null }
if (!(Test-JsonFile $wsMcpPath)) {
  Write-Host "Workspace mcp.json defekt -> fixen."
}
Ensure-Json $wsMcpPath '{ "servers": {} }'

# ---- GlobalStorage-Hinweise (nur melden) ----
$gsCandidates = @()
foreach ($r in $roots) {
  $gs1 = Join-Path (Join-Path $r "User") "globalStorage"
  if (Test-Path $gs1) { $gsCandidates += $gs1 }
}
$hits = @()
foreach ($g in $gsCandidates) {
  $hits += Get-ChildItem $g -Recurse -ErrorAction SilentlyContinue | Where-Object {
    $_.FullName -match 'mcp' -or $_.Name -match 'mcp'
  }
}
if ($hits.Count -gt 0) {
  Write-Host "`nHinweis: mögliche MCP-Artefakte in globalStorage:"
  $hits | ForEach-Object { Write-Host $_.FullName }
  Write-Host "Wenn der Fehler bleibt: obige Ordner testweise umbenennen (mit Backup)."
} else {
  Write-Host "Keine offensichtlichen MCP-Artefakte in globalStorage gefunden."
}

Write-Host "`n==> Jetzt in VS Code: 'Developer: Reload Window' und 'MCP: Reset Cached Tools' ausführen."
