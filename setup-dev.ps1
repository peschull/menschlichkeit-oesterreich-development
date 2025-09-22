#!/usr/bin/env pwsh
# Setup script for development environment
# Menschlichkeit Österreich - Development Tools Setup

param(
    [switch]$InstallAll,
    [switch]$InstallNode,
    [switch]$InstallPython, 
    [switch]$InstallComposer,
    [switch]$SetupVscode,
    [switch]$Help
)

function Show-Help {
    Write-Host "🚀 Menschlichkeit Österreich - Development Environment Setup" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Parameters:" -ForegroundColor Yellow
    Write-Host "  -InstallAll       Install all development tools" -ForegroundColor White
    Write-Host "  -InstallNode      Install Node.js dependencies" -ForegroundColor White  
    Write-Host "  -InstallPython    Install Python packages" -ForegroundColor White
    Write-Host "  -InstallComposer  Install PHP Composer and packages" -ForegroundColor White
    Write-Host "  -SetupVscode      Setup VS Code extensions" -ForegroundColor White
    Write-Host "  -Help             Show this help" -ForegroundColor White
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  .\setup-dev.ps1 -InstallAll" -ForegroundColor Gray
    Write-Host "  .\setup-dev.ps1 -InstallNode -SetupVscode" -ForegroundColor Gray
}

function Install-NodeDependencies {
    Write-Host "📦 Installing Node.js dependencies..." -ForegroundColor Green
    
    if (Test-Path "package.json") {
        npm install
        Write-Host "✅ Root dependencies installed" -ForegroundColor Green
    }
    
    # Essential Stack
    if (Test-Path "mcp-servers\essential-stack\package.json") {
        Set-Location "mcp-servers\essential-stack"
        npm install
        Set-Location "..\..\"
        Write-Host "✅ Essential Stack dependencies installed" -ForegroundColor Green
    }
    
    # Web Stack  
    if (Test-Path "mcp-servers\web-stack\package.json") {
        Set-Location "mcp-servers\web-stack"
        npm install --workspaces
        Set-Location "..\..\"
        Write-Host "✅ Web Stack dependencies installed" -ForegroundColor Green
    }
    
    # Servers
    if (Test-Path "servers\package.json") {
        Set-Location "servers"
        npm install
        Set-Location ".."
        Write-Host "✅ Servers dependencies installed" -ForegroundColor Green
    }
}

function Install-PythonPackages {
    Write-Host "🐍 Installing Python packages..." -ForegroundColor Green
    
    $pythonExe = "C:\Program Files\Python313\python.exe"
    
    if (Test-Path $pythonExe) {
        & $pythonExe -m pip install black flake8 mypy isort pytest
        Write-Host "✅ Python linting tools installed" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Python not found. Please install Python 3.11+" -ForegroundColor Red
    }
}

function Install-ComposerTools {
    Write-Host "🎼 Installing PHP Composer tools..." -ForegroundColor Green
    
    # Check if Composer is available
    try {
        composer --version | Out-Null
        composer install --no-dev --optimize-autoloader
        Write-Host "✅ Composer dependencies installed" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Composer not found. Install from https://getcomposer.org/" -ForegroundColor Red
        Write-Host "   Alternative: Use scoop: scoop install composer" -ForegroundColor Yellow
    }
}

function Setup-VscodeExtensions {
    Write-Host "⚙️ Setting up VS Code extensions..." -ForegroundColor Green
    
    $extensions = @(
        "dbaeumer.vscode-eslint",
        "esbenp.prettier-vscode", 
        "streetsidesoftware.code-spell-checker",
        "ms-python.python",
        "bmewburn.vscode-intelephense-client",
        "yzhang.markdown-all-in-one",
        "DavidAnson.vscode-markdownlint"
    )
    
    foreach ($ext in $extensions) {
        Write-Host "Installing $ext..." -ForegroundColor Gray
        code --install-extension $ext
    }
    
    Write-Host "✅ VS Code extensions installed" -ForegroundColor Green
}

function Run-QualityChecks {
    Write-Host "🔍 Running quality checks..." -ForegroundColor Green
    
    # TypeScript/JavaScript
    Write-Host "Checking TypeScript/JavaScript..." -ForegroundColor Gray
    npm run lint:js
    
    # Python  
    Write-Host "Checking Python..." -ForegroundColor Gray
    & "C:\Program Files\Python313\python.exe" -m flake8 servers\ mcp-search\
    
    # Markdown
    Write-Host "Checking Markdown..." -ForegroundColor Gray
    npx markdownlint **/*.md
    
    Write-Host "✅ Quality checks completed" -ForegroundColor Green
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

Write-Host "🚀 Menschlichkeit Österreich Development Setup" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

if ($InstallAll -or $InstallNode) {
    Install-NodeDependencies
}

if ($InstallAll -or $InstallPython) {
    Install-PythonPackages  
}

if ($InstallAll -or $InstallComposer) {
    Install-ComposerTools
}

if ($InstallAll -or $SetupVscode) {
    Setup-VscodeExtensions
}

if ($InstallAll) {
    Write-Host ""
    Run-QualityChecks
}

Write-Host ""
Write-Host "🎉 Setup completed! Use 'npm run lint:js' or VS Code tasks for linting." -ForegroundColor Green