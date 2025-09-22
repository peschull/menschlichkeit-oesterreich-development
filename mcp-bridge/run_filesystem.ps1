$ErrorActionPreference = "Stop"

# Auto-Elevation
$current = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($current)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
  Start-Process pwsh -ArgumentList "-NoLogo","-NoProfile","-ExecutionPolicy","Bypass","-File","`"$PSCommandPath`"" -Verb RunAs
  exit
}

# Skriptordner
$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { Split-Path -Parent $PSCommandPath }
Set-Location -Path $scriptDir

# Node sicherstellen
$node = (Get-Command node -ErrorAction SilentlyContinue).Source
if (-not $node) {
  $nodeDir = "C:\Program Files\nodejs"
  if (Test-Path $nodeDir) { $env:PATH = "$nodeDir;$env:PATH" }
  $node = (Get-Command node -ErrorAction Stop).Source
}

# Supergateway prüfen
$supergateway = Join-Path $scriptDir "node_modules\supergateway\dist\index.js"
if (-not (Test-Path $supergateway)) { throw "supergateway nicht gefunden: $supergateway. Bitte im Projektordner 'npm ci' oder 'npm i' ausführen." }

# Allowed Root (alles darunter freigegeben)
$allowedRoot = 'D:\Arbeitsverzeichniss'
if (-not (Test-Path $allowedRoot)) { throw "Allowed root nicht gefunden: $allowedRoot" }

# Filesystem-Server via npx
$fsCmdLine = 'npx -y @modelcontextprotocol/server-filesystem "D:\Arbeitsverzeichniss"'

# ggf. Listener auf 8765 beenden
try {
  $conns = Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue
  if ($conns) { $conns | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force -ErrorAction SilentlyContinue } }
} catch {}

# Supergateway starten
$sgArgs = @(
  $supergateway,
  '--stdio', $fsCmdLine,
  '--outputTransport', 'streamableHttp',
  '--host', '127.0.0.1',
  '--port', '8765',
  '--logLevel','info'
)

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName  = $node
$psi.Arguments = ($sgArgs -join ' ')
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $false
$psi.RedirectStandardError  = $false

$p = [System.Diagnostics.Process]::Start($psi)
$p.WaitForExit()
exit $p.ExitCode
