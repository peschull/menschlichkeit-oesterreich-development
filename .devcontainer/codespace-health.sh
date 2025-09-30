#!/bin/bash
# 🏥 Codespace Health Check Script for Austrian NGO Platform

set -e
echo "🏥 Starting Codespace Health Check..."

# Function to log with colors
log_success() {
    echo -e "\033[32m✅ $1\033[0m"
}

log_warning() {
    echo -e "\033[33m⚠️ $1\033[0m"
}

log_error() {
    echo -e "\033[31m❌ $1\033[0m"
}

log_info() {
    echo -e "\033[34mℹ️ $1\033[0m"
}

# Check system requirements
echo "🔍 Checking system requirements..."

# Node.js check
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    if [[ $NODE_VERSION == v20* ]]; then
        log_success "Node.js: $NODE_VERSION (✅ Compatible)"
    else
        log_warning "Node.js: $NODE_VERSION (Expected v20.x)"
    fi
else
    log_error "Node.js not found"
    exit 1
fi

# Python check
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    if [[ $PYTHON_VERSION == *"3.12"* ]]; then
        log_success "Python: $PYTHON_VERSION (✅ Compatible)"
    else
        log_warning "Python: $PYTHON_VERSION (Expected 3.12.x)"
    fi
else
    log_error "Python3 not found"
    exit 1
fi

# PHP check
if command -v php &> /dev/null; then
    PHP_VERSION=$(php --version | head -n1)
    if [[ $PHP_VERSION == *"8.2"* ]]; then
        log_success "PHP: $PHP_VERSION (✅ Compatible)"
    else
        log_warning "PHP: $PHP_VERSION (Expected 8.2.x)"
    fi
else
    log_error "PHP not found"
fi

# Check services status
echo ""
echo "🌐 Checking service health..."

# Check if services are running
services_running=0

# Check Frontend (React)
if curl -s http://localhost:3000 &> /dev/null; then
    log_success "Frontend (Port 3000): Running"
    services_running=$((services_running + 1))
else
    log_info "Frontend (Port 3000): Not running"
fi

# Check API (FastAPI)
if curl -s http://localhost:8001/health &> /dev/null || curl -s http://localhost:8001 &> /dev/null; then
    log_success "API (Port 8001): Running"
    services_running=$((services_running + 1))
else
    log_info "API (Port 8001): Not running"
fi

# Check CRM (Development server)
if curl -s http://localhost:8000 &> /dev/null; then
    log_success "CRM (Port 8000): Running"
    services_running=$((services_running + 1))
else
    log_info "CRM (Port 8000): Not running"
fi

# Check Games
if curl -s http://localhost:3001 &> /dev/null; then
    log_success "Games (Port 3001): Running"
    services_running=$((services_running + 1))
else
    log_info "Games (Port 3001): Not running"
fi

# Check n8n
if curl -s http://localhost:5678 &> /dev/null; then
    log_success "n8n (Port 5678): Running"
    services_running=$((services_running + 1))
else
    log_info "n8n (Port 5678): Not running"
fi

echo ""
echo "📊 Services Summary: $services_running/5 services running"

# Check dependencies
echo ""
echo "📦 Checking dependencies..."

# Check package.json exists
if [ -f "package.json" ]; then
    log_success "Root package.json: Found"
    
    # Check if node_modules exists
    if [ -d "node_modules" ]; then
        log_success "Node modules: Installed"
    else
        log_warning "Node modules: Not installed (run 'npm ci')"
    fi
else
    log_error "Root package.json: Not found"
fi

# Check composer.json
if [ -f "composer.json" ]; then
    log_success "Composer.json: Found"
    
    # Check if vendor exists
    if [ -d "vendor" ]; then
        log_success "PHP vendor directory: Found"
    else
        log_warning "PHP vendor directory: Not found (run 'composer install')"
    fi
else
    log_warning "Composer.json: Not found"
fi

# Check API requirements
if [ -f "api.menschlichkeit-oesterreich.at/requirements.txt" ]; then
    log_success "Python requirements.txt: Found"
else
    log_warning "Python requirements.txt: Not found"
fi

# Check project structure
echo ""
echo "📁 Checking project structure..."

essential_dirs=("frontend" "api.menschlichkeit-oesterreich.at" "crm.menschlichkeit-oesterreich.at" "web" "automation/n8n")

for dir in "${essential_dirs[@]}"; do
    if [ -d "$dir" ]; then
        log_success "Directory $dir: Present"
    else
        log_warning "Directory $dir: Missing"
    fi
done

# Check VS Code workspace
if [ -d ".vscode" ]; then
    log_success "VS Code workspace: Configured"
else
    log_warning "VS Code workspace: Not configured"
fi

# Check Codespace configuration
echo ""
echo "⚙️ Checking Codespace configuration..."

if [ -f ".devcontainer/devcontainer.json" ]; then
    log_success "devcontainer.json: Present"
else
    log_error "devcontainer.json: Missing"
fi

# Check environment files
echo ""
echo "🔐 Checking environment configuration..."

if [ -f ".env.example" ]; then
    log_success ".env.example: Present"
else
    log_warning ".env.example: Missing"
fi

if [ -f ".env" ]; then
    log_success ".env: Present"
else
    log_info ".env: Not present (will be created from .env.example)"
fi

# Generate health summary
echo ""
echo "📋 Health Check Summary:"
echo "=================================="

if [ $services_running -eq 0 ]; then
    echo "🚀 No services running. Start with: ./codespace-start.sh"
elif [ $services_running -lt 3 ]; then
    echo "⚠️ Some services running. Check logs if needed."
else
    echo "✅ Most services are healthy and running!"
fi

echo ""
echo "💡 Quick commands:"
echo "• Start all services: ./codespace-start.sh"
echo "• Check this health: ./codespace-health.sh"
echo "• Setup environment: npm run codespace:setup"
echo "• View logs: ls logs/"
echo ""

echo "🎉 Health check completed!"
exit 0