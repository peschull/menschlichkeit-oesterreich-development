# 🚀 GitHub Codespace - Quick Start & Troubleshooting

## ✅ Quick Start (Recommended)

### Starting a New Codespace

1. **Create Codespace:**
   - Go to GitHub repository
   - Click "Code" → "Codespaces" → "Create codespace on main"
   - Wait 2-3 minutes for initial setup

2. **After Codespace Starts:**
   ```bash
   # Check health status
   bash .devcontainer/codespace-health.sh
   
   # Start all services
   ./codespace-start.sh
   ```

3. **Access Services:**
   - Frontend: Port 3000 (auto-forwarded)
   - API: Port 8001
   - CRM: Port 8000
   - Games: Port 3001
   - n8n: Port 5678

## 🔧 Common Issues & Solutions

### Issue 1: "Codespace hangs during setup"

**Symptoms:** Codespace creation takes >10 minutes or appears frozen

**Solutions:**
```bash
# Option A: Wait for automatic recovery (recommended)
# The setup scripts have automatic fallbacks and will complete eventually

# Option B: Manual recovery
bash .devcontainer/emergency-recovery.sh

# Option C: Restart Codespace
# In VS Code: Codespace → Restart Codespace
```

### Issue 2: "Services won't start"

**Symptoms:** `./codespace-start.sh` reports errors

**Solutions:**
```bash
# Check what's missing
bash .devcontainer/codespace-health.sh

# Install missing dependencies
npm ci --workspaces
composer install
pip install -r api.menschlichkeit-oesterreich.at/requirements.txt

# Try starting services again
./codespace-start.sh
```

### Issue 3: "Environment variables missing"

**Symptoms:** Services fail with configuration errors

**Solutions:**
```bash
# Create .env files from templates
cp .env.example .env

# For API service
cp .env.example api.menschlichkeit-oesterreich.at/.env

# For Frontend
cp .env.example frontend/.env

# Check environment
env | grep -E "(NODE|PYTHON|PHP)"
```

### Issue 4: "Permission denied on scripts"

**Symptoms:** `bash: ./script.sh: Permission denied`

**Solutions:**
```bash
# Fix all script permissions
chmod +x .devcontainer/*.sh scripts/*.sh deployment-scripts/*.sh

# Or run with bash explicitly
bash .devcontainer/codespace-health.sh
```

### Issue 5: "PHP version mismatch"

**Symptoms:** Health check shows PHP 8.3 instead of 8.2

**Solutions:**
```bash
# This is expected and usually OK
# The devcontainer requests PHP 8.2 but may get 8.3
# Most code is compatible

# If you need exact 8.2:
# Rebuild Codespace: Codespace → Rebuild Container
```

### Issue 6: "Port forwarding not working"

**Symptoms:** Cannot access services via forwarded URLs

**Solutions:**
```bash
# In VS Code:
# 1. Go to "PORTS" tab (bottom panel)
# 2. Right-click port → "Forward Port"
# 3. Set visibility to "Public" if needed

# Check if services are actually running:
netstat -tlnp | grep -E "(3000|8000|8001)"

# Or check with lsof:
lsof -i :3000
```

## 📋 Available Scripts

### Health & Diagnostics
```bash
# System health check
bash .devcontainer/codespace-health.sh

# Detailed diagnostics
bash .devcontainer/emergency-recovery.sh
```

### Service Management
```bash
# Start all services
./codespace-start.sh

# Start individual services
npm run dev:frontend    # Port 3000
npm run dev:api         # Port 8001
npm run dev:crm         # Port 8000
npm run dev:games       # Port 3001
```

### Development
```bash
# Install all dependencies
npm run codespace:setup

# Run quality checks
npm run lint:all
npm run test:all

# Build everything
npm run build:all
```

## 🎯 Best Practices

### 1. Use Codespace Prebuilds
- Prebuilds are automatically created on push to main
- New Codespaces will start much faster (<30 seconds)
- Dependencies are pre-installed

### 2. Regular Health Checks
```bash
# Run health check daily
bash .devcontainer/codespace-health.sh

# Check logs if something fails
ls -la logs/
cat logs/*.log
```

### 3. Keep Dependencies Updated
```bash
# Update npm dependencies
npm update --workspaces

# Update PHP dependencies
composer update

# Update Python dependencies
pip install --upgrade -r api.menschlichkeit-oesterreich.at/requirements.txt
```

### 4. Save Your Work Regularly
```bash
# Codespaces auto-save, but commit often
git add .
git commit -m "Your changes"
git push
```

## 🆘 Emergency Recovery

If Codespace is completely broken:

```bash
# Step 1: Run emergency recovery
bash .devcontainer/emergency-recovery.sh

# Step 2: Check recovery log
cat /tmp/codespace-recovery.log

# Step 3: If still broken, rebuild
# VS Code: Codespace → Rebuild Container

# Step 4: Last resort - delete and recreate
# GitHub → Settings → Delete Codespace
# Then create a new one
```

## 📊 What Was Fixed

### Recent Improvements (2024)

1. ✅ **Script Permissions:** All scripts now executable via .gitattributes
2. ✅ **PHP Version:** Fixed to request 8.2 specifically
3. ✅ **Error Handling:** Scripts continue on non-critical errors
4. ✅ **Environment Files:** Automatic .env creation from templates
5. ✅ **Fallback Mechanisms:** npm ci falls back to npm install
6. ✅ **Better Logging:** All operations logged with timestamps
7. ✅ **Prebuild Workflow:** Faster Codespace startup via GitHub Actions
8. ✅ **Health Checks:** Comprehensive diagnostics available

### Configuration Updates

- **devcontainer.json:** Simplified and optimized
- **Setup Scripts:** Enhanced error handling and recovery
- **Post-Create:** Better dependency installation with fallbacks
- **Emergency Recovery:** Always exits successfully to prevent blocking

## 🔗 Useful Links

- [Codespace Documentation](https://docs.github.com/en/codespaces)
- [devcontainer.json Reference](https://containers.dev/implementors/json_reference/)
- [VS Code Remote Development](https://code.visualstudio.com/docs/remote/remote-overview)

## 📞 Getting Help

### For Project-Specific Issues
- Create an issue in GitHub repository
- Tag with `codespace` label
- Include output from `bash .devcontainer/codespace-health.sh`

### For GitHub Codespace Issues
- GitHub Support: https://support.github.com
- Check GitHub Status: https://www.githubstatus.com/

---

**Last Updated:** 2024-01-30
**Maintained by:** Austrian NGO Development Team
