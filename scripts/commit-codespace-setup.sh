#!/bin/bash
# 🚀 Commit optimized Codespace setup for Austrian NGO Platform

set -e

echo "📝 Committing optimized GitHub Codespace configuration..."

# Add all devcontainer changes
git add .devcontainer/

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️ No changes to commit"
    exit 0
fi

# Create detailed commit message
cat > /tmp/codespace-commit-msg << 'EOF'
🚀 feat: Optimize GitHub Codespace for Austrian NGO development

✨ Features:
- Node.js 20 + Python 3.12 + PHP 8.2 stack
- Optimized setup scripts with timeout protection
- Service-specific port forwarding (3000, 8000, 8001)
- Complete VS Code extension suite
- Automatic dependency installation
- Health check and service management scripts

🔧 Technical improvements:
- Fast onCreateCommand with codespace-optimized-setup.sh
- Efficient postCreateCommand with codespace-post-create.sh
- Volume-mounted node_modules for performance
- Pre-configured secrets management
- Comprehensive troubleshooting guide

🎯 Development workflow:
- `./codespace-start.sh` - Start all services
- `./codespace-health.sh` - System health check
- Automatic port forwarding for all Austrian NGO services
- Hot reload enabled for frontend, API, and CRM

Ready for online development in GitHub Codespace! 🇦🹑

Co-authored-by: GitHub Copilot <github-copilot@github.com>
EOF

# Commit with detailed message
git commit -F /tmp/codespace-commit-msg

# Clean up
rm /tmp/codespace-commit-msg

echo "✅ Codespace optimization committed successfully!"
echo "🌐 Ready to create GitHub Codespace with:"
echo "   - Node.js 20, Python 3.12, PHP 8.2"
echo "   - Optimized setup and dependency management"
echo "   - All Austrian NGO services pre-configured"
echo ""
echo "🚀 Next steps:"
echo "1. Push changes: git push origin main"
echo "2. Create new Codespace from GitHub repository"
echo "3. Wait for automatic setup completion"
echo "4. Run ./codespace-start.sh to begin development"