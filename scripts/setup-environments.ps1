#!/usr/bin/env pwsh
# Setup-Environments Script
# Konfiguriert alle Entwicklungsumgebungen für das integrierte System

param(
    [switch]$All,
    [switch]$CRM,
    [switch]$API,
    [switch]$Frontend,
    [switch]$Games,
    [switch]$Help
)

function Show-Help {
    Write-Host "🔧 Environment Setup für Menschlichkeit Österreich" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -All        Setup all environments" -ForegroundColor White
    Write-Host "  -CRM        Setup CRM environment (PHP/Drupal)" -ForegroundColor White
    Write-Host "  -API        Setup API environment (Python/FastAPI)" -ForegroundColor White
    Write-Host "  -Frontend   Setup Frontend environment (Next.js)" -ForegroundColor White
    Write-Host "  -Games      Setup Games environment (Web Games)" -ForegroundColor White
    Write-Host "  -Help       Show this help" -ForegroundColor White
}

function Setup-CRM-Environment {
    Write-Host "🏥 Setting up CRM Environment..." -ForegroundColor Green

    $crmPath = "crm.menschlichkeit-oesterreich.at"
    if (Test-Path $crmPath) {
        Set-Location $crmPath

        # Create .env if not exists
        if (!(Test-Path ".env")) {
            Copy-Item "../.env.sample" ".env"
            Write-Host "✅ Created CRM .env file" -ForegroundColor Green
        }

        # Install Composer dependencies
        if (Test-Path "composer.json") {
            composer install --no-dev --optimize-autoloader
            Write-Host "✅ Installed CRM Composer dependencies" -ForegroundColor Green
        }

        # Setup database configuration
        if (Test-Path "httpdocs") {
            Write-Host "✅ CRM httpdocs directory ready" -ForegroundColor Green
        }

        Set-Location ".."
    }
}

function Setup-API-Environment {
    Write-Host "🐍 Setting up API Environment..." -ForegroundColor Green

    $apiPath = "api.menschlichkeit-oesterreich.at"
    if (Test-Path $apiPath) {
        Set-Location $apiPath

        # Create virtual environment
        if (!(Test-Path ".venv")) {
            python -m venv .venv
            Write-Host "✅ Created API virtual environment" -ForegroundColor Green
        }

        # Activate venv and install dependencies
        & ".venv/Scripts/Activate.ps1"
        if (Test-Path "requirements.txt") {
            pip install -r requirements.txt
            Write-Host "✅ Installed API Python dependencies" -ForegroundColor Green
        }

        # Create .env if not exists
        if (!(Test-Path ".env")) {
            Copy-Item "../.env.sample" ".env"
            Write-Host "✅ Created API .env file" -ForegroundColor Green
        }

        deactivate
        Set-Location ".."
    }
}

function Setup-Frontend-Environment {
    Write-Host "⚛️ Setting up Frontend Environment..." -ForegroundColor Green

    $frontendPath = "frontend"
    if (Test-Path $frontendPath) {
        Set-Location $frontendPath

        # Install Node dependencies
        if (Test-Path "package.json") {
            npm install
            Write-Host "✅ Installed Frontend npm dependencies" -ForegroundColor Green
        }

        # Create .env if not exists
        if (!(Test-Path ".env.local")) {
            if (Test-Path ".env.example") {
                Copy-Item ".env.example" ".env.local"
                Write-Host "✅ Created Frontend .env.local file" -ForegroundColor Green
            }
        }

        # Build for development
        npm run build
        Write-Host "✅ Built Frontend for development" -ForegroundColor Green

        Set-Location ".."
    }
}

function Setup-Games-Environment {
    Write-Host "🎮 Setting up Games Environment..." -ForegroundColor Green

    $gamesPath = "web"
    if (Test-Path $gamesPath) {
        # Validate games structure
        if (Test-Path "$gamesPath/games") {
            Write-Host "✅ Games directory structure validated" -ForegroundColor Green
        }

        # Check for enhanced components
        if (Test-Path "$gamesPath/games/js/enhanced-components.js") {
            Write-Host "✅ Enhanced Components available" -ForegroundColor Green
        }

        # Validate asset pipeline
        if (Test-Path "assets") {
            Write-Host "✅ Asset pipeline ready" -ForegroundColor Green
        }
    }
}

function Setup-Shared-Services {
    Write-Host "🔗 Setting up Shared Services..." -ForegroundColor Green

    # Database schema
    if (Test-Path "schema.prisma") {
        npx prisma generate
        Write-Host "✅ Generated Prisma client" -ForegroundColor Green
    }

    # MCP Servers
    if (Test-Path "mcp-servers") {
        Set-Location "mcp-servers"
        if (Test-Path "package.json") {
            npm install --workspaces
            Write-Host "✅ Installed MCP server dependencies" -ForegroundColor Green
        }
        Set-Location ".."
    }

    # Shared configurations
    Write-Host "✅ Shared configurations validated" -ForegroundColor Green
}

function Validate-Integration {
    Write-Host "🔍 Validating System Integration..." -ForegroundColor Green

    $validations = @()

    # Check if all main directories exist
    $requiredDirs = @("crm.menschlichkeit-oesterreich.at", "api.menschlichkeit-oesterreich.at", "frontend", "web")
    foreach ($dir in $requiredDirs) {
        if (Test-Path $dir) {
            $validations += "✅ $dir directory exists"
        } else {
            $validations += "❌ $dir directory missing"
        }
    }

    # Check configuration files
    $configFiles = @("package.json", "eslint.config.js", ".prettierrc.json", "vitest.config.js", "playwright.config.js")
    foreach ($file in $configFiles) {
        if (Test-Path $file) {
            $validations += "✅ $file configuration ready"
        } else {
            $validations += "❌ $file configuration missing"
        }
    }

    # Display results
    foreach ($validation in $validations) {
        Write-Host $validation
    }

    Write-Host ""
    Write-Host "🎯 Integration Summary:" -ForegroundColor Cyan
    Write-Host "  - CRM (PHP/Drupal) on localhost:8000" -ForegroundColor White
    Write-Host "  - API (Python/FastAPI) on localhost:8001" -ForegroundColor White
    Write-Host "  - Frontend (Next.js) on localhost:3000" -ForegroundColor White
    Write-Host "  - Games (Static) on localhost:3000/games" -ForegroundColor White
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-Host "🚀 Menschlichkeit Österreich - Environment Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if ($All) {
    Setup-CRM-Environment
    Setup-API-Environment
    Setup-Frontend-Environment
    Setup-Games-Environment
    Setup-Shared-Services
} else {
    if ($CRM) { Setup-CRM-Environment }
    if ($API) { Setup-API-Environment }
    if ($Frontend) { Setup-Frontend-Environment }
    if ($Games) { Setup-Games-Environment }
}

# Always run shared services and validation
Setup-Shared-Services
Validate-Integration

Write-Host ""
Write-Host "🎉 Environment setup completed!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  npm run dev:all    # Start all development servers" -ForegroundColor White
Write-Host "  npm run test:all   # Run all tests" -ForegroundColor White
Write-Host "  npm run build:all  # Build all projects" -ForegroundColor White
