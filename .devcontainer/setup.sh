#!/bin/bash
# Devcontainer setup script for Menschlichkeit Österreich
# Installs all required tools and dependencies

set -e

echo "🚀 Setting up Menschlichkeit Österreich development environment..."

# ============================================================================
# 1. Install uv (Python Package Manager)
# ============================================================================
echo ""
echo "📦 Installing uv (Python Package Manager)..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    
    # Setup shell completion
    mkdir -p ~/.bash_completion.d
    uv generate-shell-completion bash > ~/.bash_completion.d/uv.bash 2>/dev/null || true
    echo 'if [ -f ~/.bash_completion.d/uv.bash ]; then source ~/.bash_completion.d/uv.bash; fi' >> ~/.bashrc || true
    
    echo "✅ uv $(uv --version) installed successfully"
else
    echo "✅ uv already installed: $(uv --version)"
fi

# Ensure uv is in PATH for this session
export PATH="$HOME/.local/bin:$PATH"

# ============================================================================
# 2. Create Required Directories
# ============================================================================
echo ""
echo "📁 Creating required directories..."
mkdir -p quality-reports logs secrets .ai-sandbox deployment-scripts/logs security/sbom
echo "✅ Directories created"

# ============================================================================
# 3. Install Composer (PHP Dependency Manager) if needed
# ============================================================================
echo ""
echo "🐘 Setting up Composer..."
if ! command -v composer &> /dev/null; then
    echo "Installing Composer..."
    
    # Try with wget first (more reliable in restricted environments)
    if command -v wget &> /dev/null; then
        wget -q -O composer-setup.php https://getcomposer.org/installer || echo "⚠️ wget download failed"
        if [ -f composer-setup.php ]; then
            php composer-setup.php --quiet --install-dir=$HOME/.local/bin --filename=composer
            rm composer-setup.php
            echo "✅ Composer installed via wget"
        fi
    # Fallback to curl
    elif command -v curl &> /dev/null; then
        curl -sS https://getcomposer.org/installer -o composer-setup.php || echo "⚠️ curl download failed"
        if [ -f composer-setup.php ]; then
            php composer-setup.php --quiet --install-dir=$HOME/.local/bin --filename=composer
            rm composer-setup.php
            echo "✅ Composer installed via curl"
        fi
    else
        echo "⚠️ Neither wget nor curl available, skipping Composer installation"
    fi
else
    echo "✅ Composer already installed: $(composer --version --no-ansi 2>/dev/null | head -1 || echo 'version unknown')"
fi

# ============================================================================
# 4. Install Python Dependencies (API Service)
# ============================================================================
echo ""
echo "🐍 Installing Python dependencies for API service..."
cd api.menschlichkeit-oesterreich.at

if command -v uv &> /dev/null; then
    echo "Using uv for Python package management..."
    
    # Install minimal requirements first
    if [ -f "requirements-minimal.txt" ]; then
        echo "📦 Installing minimal requirements..."
        uv pip install --system -r requirements-minimal.txt || echo "⚠️ Minimal requirements failed"
    fi
    
    # Install essential packages
    if ! python3 -c "import fastapi, uvicorn" 2>/dev/null; then
        echo "📦 Installing essential packages..."
        uv pip install --system fastapi uvicorn python-dotenv pydantic requests sqlalchemy alembic || echo "⚠️ Essential packages failed"
    fi
    
    # Try full requirements
    if [ -f "requirements.txt" ]; then
        echo "📦 Installing full requirements..."
        uv pip install --system -r requirements.txt || echo "⚠️ Full requirements failed, basic functionality should work"
    fi
else
    echo "⚠️ uv not found, using pip as fallback..."
    
    if [ -f "requirements-minimal.txt" ]; then
        pip install --user --timeout 120 -r requirements-minimal.txt || echo "⚠️ Minimal requirements failed"
    fi
    
    if ! python3 -c "import fastapi, uvicorn" 2>/dev/null; then
        pip install --user --timeout 120 fastapi uvicorn python-dotenv pydantic requests sqlalchemy alembic || echo "⚠️ Essential packages failed"
    fi
    
    if [ -f "requirements.txt" ]; then
        pip install --user --timeout 120 -r requirements.txt || echo "⚠️ Full requirements failed"
    fi
fi

cd ..

# ============================================================================
# 5. Install PHP Dependencies
# ============================================================================
echo ""
echo "🐘 Installing PHP dependencies..."
if [ -f "composer.json" ] && command -v composer &> /dev/null; then
    composer install --no-dev --optimize-autoloader --no-interaction || echo "⚠️ PHP dependencies installation failed"
    echo "✅ PHP dependencies installed"
elif [ -f "composer.json" ]; then
    echo "⚠️ composer.json found but Composer not available"
else
    echo "ℹ️  No composer.json found, skipping PHP dependencies"
fi

# ============================================================================
# 6. Setup Environment Files
# ============================================================================
echo ""
echo "⚙️ Setting up environment files..."
copy_env_if_missing() {
    if [ -f "$1" ] && [ ! -f "$2" ]; then
        cp "$1" "$2"
        echo "✅ Created $2"
    fi
}

copy_env_if_missing ".env.example" ".env"
copy_env_if_missing "api.menschlichkeit-oesterreich.at/.env.example" "api.menschlichkeit-oesterreich.at/.env"
copy_env_if_missing "frontend/.env.example" "frontend/.env"
copy_env_if_missing "crm.menschlichkeit-oesterreich.at/.env.example" "crm.menschlichkeit-oesterreich.at/.env"
copy_env_if_missing "automation/n8n/.env.example" "automation/n8n/.env"
copy_env_if_missing "web/.env.example" "web/.env"

# ============================================================================
# 7. Install Node.js Dependencies (Workspaces)
# ============================================================================
echo ""
echo "📦 Installing Node.js dependencies..."
if command -v npm &> /dev/null; then
    # Install root dependencies
    npm install || echo "⚠️ npm install failed, continuing..."
    
    # Install workspace dependencies
    echo "📦 Installing workspace dependencies..."
    npm install --workspaces || echo "⚠️ Some workspace installations failed"
    
    echo "✅ Node.js dependencies installed"
else
    echo "⚠️ npm not found, skipping Node.js dependencies"
fi

# ============================================================================
# 8. Make Scripts Executable
# ============================================================================
echo ""
echo "🔧 Making scripts executable..."
chmod +x build-pipeline.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x deployment-scripts/*.sh 2>/dev/null || true
chmod +x .devcontainer/*.sh 2>/dev/null || true
echo "✅ Scripts made executable"

# ============================================================================
# 9. Setup Git Configuration
# ============================================================================
echo ""
echo "📝 Configuring Git..."
git config --global --add safe.directory /workspaces/menschlichkeit-oesterreich-development || true
echo "✅ Git configured"

# ============================================================================
# 10. Install Security Tools (Trivy, Gitleaks)
# ============================================================================
echo ""
echo "🛠️ Installing security tools..."

# Install Trivy if not present
if ! command -v trivy &> /dev/null && [ -d "bin" ]; then
    echo "Installing Trivy..."
    curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ./bin 2>/dev/null || echo "⚠️ Trivy installation failed"
fi

# Install Gitleaks if not present
if ! command -v gitleaks &> /dev/null && [ -d "bin" ]; then
    echo "Installing Gitleaks..."
    GITLEAKS_VERSION=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' 2>/dev/null)
    if [ -n "$GITLEAKS_VERSION" ]; then
        wget -q "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_x64.tar.gz" -O gitleaks.tar.gz 2>/dev/null || echo "⚠️ Gitleaks download failed"
        if [ -f gitleaks.tar.gz ]; then
            tar -xzf gitleaks.tar.gz -C ./bin gitleaks 2>/dev/null
            rm gitleaks.tar.gz
            chmod +x ./bin/gitleaks
            echo "✅ Gitleaks ${GITLEAKS_VERSION} installed"
        fi
    fi
fi

# ============================================================================
# Summary
# ============================================================================
echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "✅ Devcontainer setup complete!"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "🎯 Quick Start Commands:"
echo "  npm run dev:all      - Start all development services"
echo "  npm run dev:api      - Start API service (FastAPI, Port 8001)"
echo "  npm run dev:frontend - Start Frontend (React + Vite, Port 5173)"
echo "  npm run dev:crm      - Start CRM (Drupal + CiviCRM, Port 8000)"
echo "  npm run dev:games    - Start Games (Python HTTP Server, Port 3000)"
echo ""
echo "🔧 Python Package Management:"
echo "  uv --version         - Check uv installation"
echo "  uv pip install <pkg> - Install Python package"
echo "  uv pip list          - List installed packages"
echo "  uv cache clean       - Clean uv cache"
echo ""
echo "� PHP Package Management:"
echo "  composer --version   - Check Composer installation"
echo "  composer install     - Install PHP dependencies"
echo "  composer update      - Update PHP dependencies"
echo ""
echo "📊 Quality & Testing:"
echo "  npm run quality:gates - Run ALL quality checks"
echo "  npm run lint:all     - Run all linters"
echo "  npm run test:unit    - Run unit tests (Vitest)"
echo "  npm run test:e2e     - Run E2E tests (Playwright)"
echo "  npm run security:scan - Run security scans"
echo ""
echo "🌐 Service URLs (when running):"
echo "  Frontend:  http://localhost:5173"
echo "  API:       http://localhost:8001 (Docs: /docs)"
echo "  CRM:       http://localhost:8000"
echo "  Games:     http://localhost:3000"
echo ""
echo "═══════════════════════════════════════════════════════════════════"