#!/bin/bash
# Bash equivalent for setup-environments.ps1
# Sets up environment files for all services

set -e

echo "🔧 Setting up environment files for all services..."

# Function to copy .env.example to .env if not exists
setup_env() {
    local dir=$1
    local env_file="${dir}/.env"
    local example_file="${dir}/.env.example"
    
    if [ -f "$example_file" ] && [ ! -f "$env_file" ]; then
        cp "$example_file" "$env_file"
        echo "✅ Created ${env_file}"
    elif [ -f "$env_file" ]; then
        echo "ℹ️  ${env_file} already exists, skipping"
    else
        echo "⚠️  ${example_file} not found, skipping ${dir}"
    fi
}

# Setup environment files for each service
setup_env "."
setup_env "api.menschlichkeit-oesterreich.at"
setup_env "frontend"
setup_env "crm.menschlichkeit-oesterreich.at"
setup_env "automation/n8n"
setup_env "web"

echo "✅ Environment setup complete!"
