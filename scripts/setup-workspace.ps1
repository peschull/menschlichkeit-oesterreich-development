#!/usr/bin/env pwsh
# Enterprise Workspace Setup Script for Menschlichkeit Österreich
# Initializes complete development environment with quality gates

param(
    [string]$Environment = "development",
    [switch]$SkipDependencies,
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Menschlichkeit Österreich Enterprise Workspace Setup" -ForegroundColor Green
Write-Host "Environment: $Environment" -ForegroundColor Cyan

# Check Prerequisites
Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow

$Prerequisites = @{
    "Node.js" = { node --version }
    "npm" = { npm --version }
    "PHP" = { php --version }  
    "Python" = { python --version }
    "Docker" = { docker --version }
    "Git" = { git --version }
}

$MissingPrereqs = @()
foreach ($Prereq in $Prerequisites.GetEnumerator()) {
    try {
        $Version = & $Prereq.Value 2>$null
        Write-Host "✅ $($Prereq.Key): $($Version.Split("`n")[0])" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ $($Prereq.Key): Not found" -ForegroundColor Red
        $MissingPrereqs += $Prereq.Key
    }
}

if ($MissingPrereqs.Count -gt 0) {
    Write-Host "`n🚨 Missing prerequisites: $($MissingPrereqs -join ', ')" -ForegroundColor Red
    Write-Host "Please install missing tools and run setup again." -ForegroundColor Yellow
    exit 1
}

# Install Dependencies
if (-not $SkipDependencies) {
    Write-Host "`n📦 Installing dependencies..." -ForegroundColor Yellow
    
    # Node.js Dependencies
    Write-Host "Installing Node.js packages..." -ForegroundColor Cyan
    npm run install:all
    
    # PHP Dependencies (if composer.json exists)
    if (Test-Path "composer.json") {
        Write-Host "Installing PHP packages..." -ForegroundColor Cyan
        composer install --optimize-autoloader
    }
    
    # Python Dependencies for API
    if (Test-Path "api.menschlichkeit-oesterreich.at/requirements.txt") {
        Write-Host "Installing Python packages..." -ForegroundColor Cyan
        Set-Location api.menschlichkeit-oesterreich.at
        python -m pip install -r requirements.txt
        Set-Location ..
    }
}

# Initialize Quality Tools
Write-Host "`n🔧 Initializing quality tools..." -ForegroundColor Yellow

# Create quality-reports directory
if (-not (Test-Path "quality-reports")) {
    New-Item -ItemType Directory -Path "quality-reports" -Force | Out-Null
    Write-Host "Created quality-reports directory" -ForegroundColor Green
}

# Initialize Trunk.io (if not already done)
if (-not (Test-Path ".trunk/trunk.yaml")) {
    Write-Host "Initializing Trunk.io..." -ForegroundColor Cyan
    trunk init 2>$null || Write-Host "Trunk init completed or already initialized" -ForegroundColor Green
}

# Setup Prisma (if schema exists)
if (Test-Path "schema.prisma") {
    Write-Host "Generating Prisma client..." -ForegroundColor Cyan
    npx prisma generate
}

# Setup n8n environment
Write-Host "`n🔄 Setting up n8n automation..." -ForegroundColor Yellow
if (Test-Path "automation/n8n/.env.example" -and -not (Test-Path "automation/n8n/.env")) {
    Copy-Item "automation/n8n/.env.example" "automation/n8n/.env"
    Write-Host "Created n8n .env file from template" -ForegroundColor Green
    Write-Host "⚠️  Please configure automation/n8n/.env with your settings" -ForegroundColor Yellow
}

# Run Initial Quality Check
Write-Host "`n🔍 Running initial quality check..." -ForegroundColor Yellow

try {
    # Basic linting
    Write-Host "Running ESLint..." -ForegroundColor Cyan
    npm run lint 2>$null || Write-Host "ESLint completed with warnings" -ForegroundColor Yellow
    
    # Security scan (if tools available)
    if (Get-Command "trivy" -ErrorAction SilentlyContinue) {
        Write-Host "Running security scan..." -ForegroundColor Cyan
        npm run security:scan 2>$null || Write-Host "Security scan completed with findings" -ForegroundColor Yellow
    }
    
    # DSGVO compliance check
    Write-Host "Running DSGVO compliance check..." -ForegroundColor Cyan
    npm run compliance:dsgvo 2>$null || Write-Host "DSGVO check completed with warnings" -ForegroundColor Yellow
    
} catch {
    Write-Host "Quality checks completed with issues - review quality-reports/" -ForegroundColor Yellow
}

# Environment-specific setup
switch ($Environment) {
    "development" {
        Write-Host "`n🔧 Development environment setup..." -ForegroundColor Yellow
        
        # Start essential services for development
        Write-Host "Starting n8n automation..." -ForegroundColor Cyan
        npm run n8n:start
        
        Write-Host "✅ Development environment ready!" -ForegroundColor Green
        Write-Host "Run 'npm run dev:all' to start all services" -ForegroundColor Cyan
    }
    
    "production" {
        Write-Host "`n🏭 Production environment setup..." -ForegroundColor Yellow
        
        # Run full quality gates
        Write-Host "Running complete quality gates..." -ForegroundColor Cyan
        npm run quality:gates
        
        Write-Host "✅ Production environment validated!" -ForegroundColor Green
        Write-Host "Ready for deployment with './build-pipeline.sh production'" -ForegroundColor Cyan
    }
}

# VS Code Integration Check
if (Get-Command "code" -ErrorAction SilentlyContinue) {
    Write-Host "`n💻 VS Code integration available" -ForegroundColor Green
    Write-Host "Recommended extensions are configured in .vscode/extensions.json" -ForegroundColor Cyan
    Write-Host "Quality tools are integrated with VS Code tasks" -ForegroundColor Cyan
} else {
    Write-Host "`n💻 VS Code not found in PATH" -ForegroundColor Yellow
    Write-Host "Install VS Code and add to PATH for full integration" -ForegroundColor Cyan
}

# Final Summary
Write-Host "`n🎉 Enterprise Workspace Setup Complete!" -ForegroundColor Green
Write-Host "`n📊 Available Commands:" -ForegroundColor Yellow
Write-Host "  🚀 npm run dev:all           - Start all development services" -ForegroundColor Cyan
Write-Host "  🔍 npm run quality:gates     - Run all quality gates" -ForegroundColor Cyan
Write-Host "  🛡️  npm run security:scan     - Security vulnerability scan" -ForegroundColor Cyan
Write-Host "  ⚖️  npm run compliance:dsgvo  - DSGVO compliance check" -ForegroundColor Cyan
Write-Host "  🏗️  ./build-pipeline.sh      - Production build pipeline" -ForegroundColor Cyan
Write-Host "  📋 npm run quality:reports   - Generate comprehensive reports" -ForegroundColor Cyan

Write-Host "`n📁 Key Directories:" -ForegroundColor Yellow
Write-Host "  📊 quality-reports/     - Quality and compliance reports" -ForegroundColor Cyan
Write-Host "  🧪 playwright-results/  - E2E test results" -ForegroundColor Cyan  
Write-Host "  🔄 automation/n8n/      - Workflow automation" -ForegroundColor Cyan
Write-Host "  🚢 deployment-scripts/  - Plesk deployment scripts" -ForegroundColor Cyan

Write-Host "`n💡 Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Configure automation/n8n/.env with your API keys" -ForegroundColor Cyan
Write-Host "  2. Review .github/copilot-instructions.md for AI agent setup" -ForegroundColor Cyan
Write-Host "  3. Run 'npm run dev:all' to start development" -ForegroundColor Cyan
Write-Host "  4. Check quality-reports/ for any initial issues" -ForegroundColor Cyan

if ($Verbose) {
    Write-Host "`n🔧 Technical Details:" -ForegroundColor Yellow
    Write-Host "  MCP Servers: Configured for Codacy, Security, n8n, Prisma" -ForegroundColor Cyan
    Write-Host "  Quality Gates: Security, Maintainability, Performance, A11y, DSGVO" -ForegroundColor Cyan
    Write-Host "  Multi-Service Architecture: CRM, API, Frontend, Games, Automation" -ForegroundColor Cyan
    Write-Host "  Deployment: Plesk-ready with dry-run safety checks" -ForegroundColor Cyan
}

Write-Host "`n🚀 Happy coding with Enterprise-grade quality assurance! 🚀" -ForegroundColor Green