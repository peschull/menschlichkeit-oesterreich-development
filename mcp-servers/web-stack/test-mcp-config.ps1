# MCP Server Configuration Test

Write-Host "Testing MCP Server Configuration..." -ForegroundColor Cyan

# Test if all built servers exist
$servers = @(
    @{ name = "Plesk OpenAPI"; path = ".\servers\plesk-openapi\dist\index.js" },
    @{ name = "WordPress REST"; path = ".\servers\wordpress\dist\index.js" },
    @{ name = "Laravel Integration"; path = ".\servers\laravel\dist\index.js" }
)

$allServersReady = $true

foreach ($server in $servers) {
    if (Test-Path $server.path) {
        Write-Host "✓ $($server.name) server ready" -ForegroundColor Green
    } else {
        Write-Host "✗ $($server.name) server missing: $($server.path)" -ForegroundColor Red
        $allServersReady = $false
    }
}

# Test MCP configuration
$mcpConfigPath = "d:\Arbeitsverzeichniss\.vscode\mcp.json"
if (Test-Path $mcpConfigPath) {
    Write-Host "✓ MCP configuration file exists" -ForegroundColor Green
    
    try {
        $config = Get-Content $mcpConfigPath -Raw | ConvertFrom-Json
        $serverNames = $config.servers | Get-Member -MemberType NoteProperty | ForEach-Object { $_.Name }
        $serverCount = $serverNames.Count
        Write-Host "✓ MCP configuration contains $serverCount servers" -ForegroundColor Green
        
        # List configured servers
        Write-Host "`nConfigured MCP servers:" -ForegroundColor White
        foreach ($serverName in $serverNames) {
            Write-Host "  • $serverName" -ForegroundColor Gray
        }
    } catch {
        Write-Host "✗ MCP configuration file has JSON error: $($_.Exception.Message)" -ForegroundColor Red
        $allServersReady = $false
    }
} else {
    Write-Host "✗ MCP configuration file missing: $mcpConfigPath" -ForegroundColor Red
    $allServersReady = $false
}

Write-Host ""
if ($allServersReady) {
    Write-Host "🎉 All MCP servers are ready for use!" -ForegroundColor Green
    Write-Host "Restart VS Code to load the new MCP servers." -ForegroundColor Yellow
} else {
    Write-Host "❌ Some MCP servers are not ready. Run install-mcp-servers.ps1 first." -ForegroundColor Red
}