# PowerShell Build Pipeline für Menschlichkeit Österreich Development

param(
    [Parameter(Mandatory=$false)]
    [string]$Environment = "development",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force = $false
)

Write-Host "🚀 Starting Build Pipeline for Environment: $Environment" -ForegroundColor Green

# Funktion für Error Handling
function Write-BuildError {
    param([string]$Message)
    Write-Host "❌ ERROR: $Message" -ForegroundColor Red
    exit 1
}

# Funktion für Success Messages
function Write-BuildSuccess {
    param([string]$Message)
    Write-Host "✅ SUCCESS: $Message" -ForegroundColor Green
}

# 1. Environment Setup
Write-Host "🔧 Setting up environment..." -ForegroundColor Yellow

# Check Node.js
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-BuildError "Node.js ist nicht installiert oder nicht im PATH"
}

# Check Python
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-BuildError "Python ist nicht installiert oder nicht im PATH"
}

# Check PHP
if (!(Get-Command php -ErrorAction SilentlyContinue)) {
    Write-BuildError "PHP ist nicht installiert oder nicht im PATH"
}

Write-BuildSuccess "Alle required dependencies sind verfügbar"

# 2. Install Dependencies
Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow

try {
    # Node.js Dependencies
    Write-Host "Installing Node.js packages..."
    npm ci --silent
    
    # PHP Dependencies (if composer.json exists)
    if (Test-Path "composer.json") {
        Write-Host "Installing PHP packages..."
        composer install --no-dev --optimize-autoloader
    }
    
    # Python Dependencies (if requirements.txt exists in API)
    if (Test-Path "api.menschlichkeit-oesterreich.at/requirements.txt") {
        Write-Host "Installing Python packages..."
        Set-Location "api.menschlichkeit-oesterreich.at"
        python -m pip install -r requirements.txt
        Set-Location ..
    }
    
    Write-BuildSuccess "Dependencies installation completed"
}
catch {
    Write-BuildError "Failed to install dependencies: $($_.Exception.Message)"
}

# 3. Code Quality Checks
Write-Host "🔍 Running code quality checks..." -ForegroundColor Yellow

try {
    # ESLint
    Write-Host "Running ESLint..."
    npm run lint 2>$null
    
    # Prettier Check
    Write-Host "Checking code formatting..."
    npx prettier --check . 2>$null
    
    Write-BuildSuccess "Code quality checks passed"
}
catch {
    if (!$Force) {
        Write-BuildError "Code quality checks failed. Use -Force to override."
    }
    Write-Host "⚠️  WARNING: Code quality issues found but continuing due to -Force flag" -ForegroundColor Yellow
}

# 4. Build Projects
Write-Host "🏗️  Building projects..." -ForegroundColor Yellow

try {
    # Build Frontend (Next.js)
    if (Test-Path "frontend/package.json") {
        Write-Host "Building Frontend (Next.js)..."
        Set-Location "frontend"
        npm run build
        Set-Location ..
    }
    
    # Build Games (if build script exists)
    if (Test-Path "web/package.json") {
        Write-Host "Building Games platform..."
        Set-Location "web"
        if (Get-Content package.json | Select-String '"build":') {
            npm run build
        }
        Set-Location ..
    }
    
    Write-BuildSuccess "Build completed successfully"
}
catch {
    Write-BuildError "Build failed: $($_.Exception.Message)"
}

# 5. Run Tests (unless skipped)
if (!$SkipTests) {
    Write-Host "🧪 Running tests..." -ForegroundColor Yellow
    
    try {
        # Unit Tests
        Write-Host "Running unit tests..."
        npm run test:unit 2>$null
        
        # E2E Tests (only in CI or if explicitly requested)
        if ($Environment -eq "ci" -or $Force) {
            Write-Host "Running E2E tests..."
            npm run test:e2e 2>$null
        }
        
        Write-BuildSuccess "All tests passed"
    }
    catch {
        if (!$Force) {
            Write-BuildError "Tests failed. Use -Force to override or -SkipTests to skip."
        }
        Write-Host "⚠️  WARNING: Test failures detected but continuing due to -Force flag" -ForegroundColor Yellow
    }
}

# 6. Environment-specific tasks
switch ($Environment) {
    "development" {
        Write-Host "🔧 Development environment setup complete" -ForegroundColor Blue
    }
    "staging" {
        Write-Host "🚀 Staging deployment preparation..." -ForegroundColor Blue
        # Additional staging tasks here
    }
    "production" {
        Write-Host "🏭 Production deployment preparation..." -ForegroundColor Blue
        # Production-specific tasks here
    }
}

# 7. Generate Build Report
$BuildReport = @{
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Environment = $Environment
    NodeVersion = (node --version)
    GitCommit = (git rev-parse --short HEAD 2>$null)
    Success = $true
}

$BuildReport | ConvertTo-Json | Out-File "build-report.json" -Encoding UTF8

Write-Host ""
Write-Host "🎉 Build Pipeline completed successfully!" -ForegroundColor Green
Write-Host "📊 Build report saved to: build-report.json" -ForegroundColor Cyan
Write-Host ""

# Return success exit code
exit 0
