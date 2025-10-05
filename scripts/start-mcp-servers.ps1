# MCP Server Management Script
# Starts all required MCP servers for the development environment

param(
    [switch]$Stop = $false,
    [switch]$Restart = $false
)

$serverProcesses = @()

function Start-McpServer {
    param($Name, $Port, $ScriptPath)

    Write-Host "Starting $Name MCP Server on port $Port..." -ForegroundColor Green

    $process = Start-Process -FilePath "node" -ArgumentList $ScriptPath -WindowStyle Hidden -PassThru
    $serverProcesses += @{Name = $Name; Process = $process; Port = $Port}

    Start-Sleep -Seconds 2
    return $process
}

function Stop-McpServers {
    Write-Host "Stopping all MCP servers..." -ForegroundColor Yellow

    # Stop by process name
    Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object {
        $_.CommandLine -like "*mcp-stub*" -or $_.CommandLine -like "*figma-mcp-server*"
    } | Stop-Process -Force

    Write-Host "All MCP servers stopped." -ForegroundColor Red
}

if ($Stop) {
    Stop-McpServers
    exit 0
}

if ($Restart) {
    Stop-McpServers
    Start-Sleep -Seconds 3
}

# Start Figma HTTP MCP Server
Write-Host "Starting Figma MCP Server..." -ForegroundColor Cyan
Start-Process -FilePath "node" -ArgumentList "$PSScriptRoot\..\servers\src\figma-mcp-server.js" -WindowStyle Hidden

Write-Host ""
Write-Host "All MCP servers started successfully!" -ForegroundColor Green
Write-Host "Use 'scripts\start-mcp-servers.ps1 -Stop' to stop all servers" -ForegroundColor Gray
