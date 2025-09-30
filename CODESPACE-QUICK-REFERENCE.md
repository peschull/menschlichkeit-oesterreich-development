# 🚀 Codespace Quick Reference

## Essential Commands

### Health Check
```bash
# Run complete health check
bash .devcontainer/codespace-health.sh

# Run validation tests
bash validate-codespace-fixes.sh
```

### Start Services
```bash
# Start all services
./codespace-start.sh

# Or individually:
npm run dev:frontend    # Port 3000
npm run dev:api         # Port 8001  
npm run dev:crm         # Port 8000
npm run dev:games       # Port 3001
```

### Emergency Recovery
```bash
# If something goes wrong
bash .devcontainer/emergency-recovery.sh

# Check recovery log
cat /tmp/codespace-recovery.log
```

### Setup & Installation
```bash
# Full setup
npm run codespace:setup

# Individual installations
npm ci --workspaces
composer install
pip install -r api.menschlichkeit-oesterreich.at/requirements.txt
```

## Service Ports

| Service  | Port | URL Pattern |
|----------|------|-------------|
| Frontend | 3000 | `https://CODESPACE-3000.app.github.dev` |
| API      | 8001 | `https://CODESPACE-8001.app.github.dev` |
| CRM      | 8000 | `https://CODESPACE-8000.app.github.dev` |
| Games    | 3001 | `https://CODESPACE-3001.app.github.dev` |
| n8n      | 5678 | `https://CODESPACE-5678.app.github.dev` |

## Documentation

- **English Guide:** `.devcontainer/README.md`
- **German Troubleshooting:** `.devcontainer/CODESPACE-TROUBLESHOOTING.md`
- **Quick Overview:** `CODESPACE-FIX-SUMMARY.txt`
- **Technical Report:** `CODESPACE-FIX-COMPLETE.md`

## Common Issues

### Services not starting?
```bash
# Check what's missing
bash .devcontainer/codespace-health.sh

# Reinstall dependencies
npm ci --workspaces
```

### Permission denied on scripts?
```bash
# Should be automatic now, but if needed:
chmod +x .devcontainer/*.sh scripts/*.sh
```

### Environment files missing?
```bash
# Created automatically, but if needed:
cp .env.example .env
```

## Quality Checks

```bash
# Lint all code
npm run lint:all

# Run tests
npm run test:all

# Build everything
npm run build:all
```

## Validation

```bash
# Validate all fixes
bash validate-codespace-fixes.sh
# Should show: ✅ Passed: 10/10
```

---

**Last Updated:** 2024-01-30
**Status:** All Codespace issues resolved ✅
