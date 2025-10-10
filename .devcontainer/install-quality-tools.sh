#!/bin/bash
# install-quality-tools.sh - Automatische Installation von Quality/Security Tools
# Teil des Menschlichkeit Österreich Monorepo DevContainer Setup
set -euo pipefail

echo "🔧 Installing Quality & Security Tools..."

# Erstelle bin-Verzeichnis falls nicht vorhanden
mkdir -p ./bin

# 1. Chrome Installation (für Lighthouse Performance Audits)
if ! command -v google-chrome &>/dev/null && ! command -v chromium &>/dev/null; then
  echo "📦 Installing Google Chrome..."
  wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome-keyring.gpg
  echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
  sudo apt-get update -qq
  sudo apt-get install -y google-chrome-stable
  echo "✅ Chrome $(google-chrome --version) installed"
else
  echo "✅ Chrome already installed: $(google-chrome --version 2>/dev/null || chromium --version 2>/dev/null)"
fi

# 2. Trivy Installation (Container/Dependency Security Scanner)
if [ ! -f ./bin/trivy ]; then
  echo "🔍 Installing Trivy..."
  curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ./bin
  chmod +x ./bin/trivy
  echo "✅ Trivy $(./bin/trivy --version | head -1) installed"
else
  echo "✅ Trivy already installed: $(./bin/trivy --version | head -1)"
fi

# 3. Gitleaks Installation (Secrets Scanner)
if [ ! -f ./bin/gitleaks ]; then
  echo "🔐 Installing Gitleaks..."
  curl -sSfL https://github.com/gitleaks/gitleaks/releases/download/v8.22.1/gitleaks_8.22.1_linux_x64.tar.gz | tar -xz -C ./bin gitleaks
  chmod +x ./bin/gitleaks
  echo "✅ Gitleaks $(./bin/gitleaks version) installed"
else
  echo "✅ Gitleaks already installed: $(./bin/gitleaks version)"
fi

echo "🎉 All quality tools installed successfully!"
echo ""
echo "Available Tools:"
echo "  - Chrome: $(google-chrome --version 2>/dev/null || echo 'Not available')"
echo "  - Trivy: $(./bin/trivy --version 2>/dev/null | head -1 || echo 'Not available')"
echo "  - Gitleaks: $(./bin/gitleaks version 2>/dev/null || echo 'Not available')"
echo ""
