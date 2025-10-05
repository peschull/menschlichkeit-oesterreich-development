#!/bin/bash
# Devcontainer setup script for Menschlichkeit Österreich
set -e

echo "🚀 Setting up Menschlichkeit Österreich development environment..."

# Create quality-reports directory
mkdir -p quality-reports

# Install Python dependencies for API service
echo "🐍 Installing Python dependencies for API service..."
cd api.menschlichkeit-oesterreich.at

# Try minimal requirements first (more likely to succeed)
if [ -f "requirements-minimal.txt" ]; then
    echo "📦 Installing minimal Python requirements..."
    pip install --user --timeout 120 -r requirements-minimal.txt || echo "⚠️ Minimal requirements install failed, will try manual install"
fi

# Try full requirements if minimal succeeded or if minimal doesn't exist
if ! python3 -c "import fastapi, uvicorn" 2>/dev/null; then
    echo "📦 Installing essential packages manually..."
    pip install --user --timeout 120 fastapi uvicorn python-dotenv pydantic requests || echo "⚠️ Manual install failed, API server may not work"
fi

# Try full requirements if we have basic packages working
if python3 -c "import fastapi, uvicorn" 2>/dev/null; then
    echo "📦 Attempting full requirements install..."
    pip install --user --timeout 120 -r requirements.txt || echo "⚠️ Full requirements install failed, basic functionality should still work"
fi

cd ..

# Install PHP dependencies (if composer.json exists)
if [ -f "composer.json" ]; then
    echo "🐘 Installing PHP dependencies..."
    composer install --no-dev --optimize-autoloader || echo "⚠️ PHP dependencies installation failed"
fi

# Setup environment files from templates
echo "⚙️ Setting up environment files..."
copy_env_if_missing() {
    if [ -f "$1" ] && [ ! -f "$2" ]; then
        cp "$1" "$2"
        echo "✅ Created $2 from $1"
    fi
}

copy_env_if_missing ".env.example" ".env"
copy_env_if_missing "api.menschlichkeit-oesterreich.at/.env.example" "api.menschlichkeit-oesterreich.at/.env"
copy_env_if_missing "frontend/.env.example" "frontend/.env"
copy_env_if_missing "crm.menschlichkeit-oesterreich.at/.env.example" "crm.menschlichkeit-oesterreich.at/.env"
copy_env_if_missing "automation/n8n/.env.example" "automation/n8n/.env"

# Make scripts executable
chmod +x build-pipeline.sh 2>/dev/null || true
chmod +x scripts/*.sh 2>/dev/null || true
chmod +x deployment-scripts/*.sh 2>/dev/null || true

echo "✅ Devcontainer setup complete!"
echo ""
echo "🎯 Quick Start Commands:"
echo "  npm run dev:all      - Start all development services"
echo "  npm run dev:api      - Start API service only"
echo "  npm run dev:frontend - Start frontend only"
echo "  npm run dev:crm      - Start CRM service only"
echo ""
echo "🔧 If API server fails to start:"
echo "  cd api.menschlichkeit-oesterreich.at"
echo "  pip install --user fastapi uvicorn python-dotenv"
echo ""
echo "📊 Quality Commands:"
echo "  npm run quality:gates - Run all quality checks"
echo "  npm run lint:all     - Run all linters"
echo "  npm run test:all     - Run all tests"
echo ""
echo "🌐 Service URLs (when running):"
echo "  Frontend: http://localhost:5173"
echo "  API: http://localhost:8001"
echo "  CRM: http://localhost:8000"
echo "  Games: http://localhost:3000"

# Optional: Install OPA CLI for policy enforcement if not present
if ! command -v opa >/dev/null 2>&1; then
  echo "🛡️ Installing OPA CLI (optional for MCP policy gates)..."
  OPA_VERSION="v0.63.0"
  ARCH=$(uname -m)
  case "$ARCH" in
    x86_64|amd64) OPA_ARCH="amd64";;
    aarch64|arm64) OPA_ARCH="arm64";;
    *) OPA_ARCH="amd64";;
  esac
  curl -fsSL -o /tmp/opa https://openpolicyagent.org/downloads/${OPA_VERSION}/opa_linux_${OPA_ARCH}
  chmod +x /tmp/opa
  if [ -w /usr/local/bin ]; then
    mv /tmp/opa /usr/local/bin/opa
  else
    mkdir -p "$HOME/.local/bin"
    mv /tmp/opa "$HOME/.local/bin/opa"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
  fi
  echo "✅ OPA installiert ($(opa version 2>/dev/null || echo installed))"
else
  echo "🛡️ OPA bereits vorhanden: $(opa version 2>/dev/null)"
fi
