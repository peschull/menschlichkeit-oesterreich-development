# PowerShell MCP Server Installer
param(
    [switch]$SkipInstall,
    [switch]$BuildOnly,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

if (!$Quiet) {
    Write-Host "=== MCP Web Stack Server Installation ===" -ForegroundColor Cyan
    Write-Host "Installing optimized MCP servers for Plesk, Laravel, and WordPress" -ForegroundColor Green
}

# Check if Node.js is available
try {
    $nodeVersion = node --version
    if (!$Quiet) {
        Write-Host "Node.js version: $nodeVersion" -ForegroundColor Green
    }
} catch {
    Write-Error "Node.js is not installed or not in PATH. Please install Node.js first."
    exit 1
}

# Navigate to web-stack directory
$webStackPath = "d:\Arbeitsverzeichniss\mcp-servers\web-stack"
if (!(Test-Path $webStackPath)) {
    Write-Error "Web stack directory not found: $webStackPath"
    exit 1
}

Set-Location $webStackPath

if (!$SkipInstall) {
    # Install main dependencies
    if (!$Quiet) {
        Write-Host "Installing main package dependencies..." -ForegroundColor Yellow
    }
    
    try {
        npm install --silent
        if ($LASTEXITCODE -ne 0) {
            throw "npm install failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Error "Failed to install main dependencies: $_"
        exit 1
    }

    # Install workspace dependencies
    if (!$Quiet) {
        Write-Host "Installing workspace dependencies..." -ForegroundColor Yellow
    }
    
    try {
        npm install --workspaces --silent
        if ($LASTEXITCODE -ne 0) {
            throw "npm install --workspaces failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-Error "Failed to install workspace dependencies: $_"
        exit 1
    }
}

# Build all servers
if (!$Quiet) {
    Write-Host "Building MCP servers..." -ForegroundColor Yellow
}

try {
    npm run build --silent
    if ($LASTEXITCODE -ne 0) {
        throw "npm run build failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Error "Failed to build servers: $_"
    exit 1
}

# Verify build outputs
$servers = @("plesk-openapi", "wordpress", "laravel")
$allBuilt = $true

foreach ($server in $servers) {
    $distPath = Join-Path $webStackPath "servers\$server\dist\index.js"
    if (!(Test-Path $distPath)) {
        Write-Warning "Build output missing for $server server: $distPath"
        $allBuilt = $false
    } else {
        if (!$Quiet) {
            Write-Host "✓ $server server built successfully" -ForegroundColor Green
        }
    }
}

if (!$allBuilt) {
    Write-Error "Some servers failed to build properly"
    exit 1
}

if (!$BuildOnly) {
    # Update VS Code MCP configuration
    $mcpConfigPath = "d:\Arbeitsverzeichniss\.vscode\mcp.json"
    $mcpConfig = @{
        servers = @{
            "github" = @{
                url = "https://api.githubcopilot.com/mcp/"
                type = "http"
            }
            "playwright" = @{
                type = "stdio"
                command = "npx"
                args = @("@playwright/mcp@latest")
            }
            "deepwiki" = @{
                type = "http"
                url = "https://mcp.deepwiki.com/sse"
            }
            "figma" = @{
                type = "http" 
                url = "http://127.0.0.1:3845/mcp"
            }
            "sequentialthinking-global" = @{
                type = "stdio"
                command = "npx"
                args = @("-y", "@modelcontextprotocol/server-sequential-thinking@latest")
            }
            "plesk-openapi" = @{
                type = "stdio"
                command = "node"
                args = @("./mcp-servers/web-stack/servers/plesk-openapi/dist/index.js")
                env = @{
                    NODE_ENV = "production"
                }
            }
            "wordpress-rest" = @{
                type = "stdio"
                command = "node"
                args = @("./mcp-servers/web-stack/servers/wordpress/dist/index.js")
                env = @{
                    NODE_ENV = "production"
                }
            }
            "laravel-integration" = @{
                type = "stdio"
                command = "node"
                args = @("./mcp-servers/web-stack/servers/laravel/dist/index.js")
                env = @{
                    NODE_ENV = "production"
                }
            }
            "filesystem" = @{
                type = "stdio"
                command = "node"
                args = @("./servers/src/filesystem/dist/index.js")
                env = @{
                    NODE_ENV = "production"
                }
            }
            "memory" = @{
                type = "stdio"
                command = "node"
                args = @("./servers/src/memory/dist/index.js")
                env = @{
                    NODE_ENV = "production"
                }
            }
            "sequential-thinking-local" = @{
                type = "stdio"
                command = "node"
                args = @("./servers/src/sequentialthinking/dist/index.js")
                env = @{
                    NODE_ENV = "production"
                }
            }
        }
        inputs = @()
    }

    # Ensure .vscode directory exists
    $vscodeDir = Split-Path $mcpConfigPath
    if (!(Test-Path $vscodeDir)) {
        New-Item -ItemType Directory -Path $vscodeDir -Force | Out-Null
    }

    # Write MCP configuration
    try {
        $mcpConfig | ConvertTo-Json -Depth 5 | Set-Content $mcpConfigPath -Encoding UTF8
        if (!$Quiet) {
            Write-Host "✓ VS Code MCP configuration updated" -ForegroundColor Green
        }
    } catch {
        Write-Warning "Failed to update MCP configuration: $_"
    }
}

if (!$Quiet) {
    Write-Host ""
    Write-Host "=== Installation Complete ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Available MCP servers:" -ForegroundColor White
    Write-Host "  • Plesk OpenAPI Server    - For Plesk hosting automation" -ForegroundColor Gray
    Write-Host "  • WordPress REST Server   - For WordPress content management" -ForegroundColor Gray  
    Write-Host "  • Laravel Integration     - For Laravel development and Artisan" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Usage in VS Code:" -ForegroundColor White
    Write-Host "  1. Restart VS Code to load new MCP servers" -ForegroundColor Gray
    Write-Host "  2. Use GitHub Copilot with @plesk-openapi, @wordpress-rest, @laravel-integration" -ForegroundColor Gray
    Write-Host "  3. See README.md for configuration and examples" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    Write-Host "  - Configure server connections using respective *_configure tools" -ForegroundColor Gray
    Write-Host "  - Check logs in VS Code Output panel > MCP Server" -ForegroundColor Gray
    Write-Host ""
}

exit 0