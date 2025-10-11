# GitHub Codespace Setup - Menschlichkeit Österreich

## 🚀 Quick Start

When your Codespace starts, it will automatically:

1. Install Node.js dependencies
2. Attempt to install Python dependencies for the API service
3. Set up environment files from examples
4. Configure development ports

## 🌐 Development Servers

After setup, you can start the development environment:

```bash
# Start all services
npm run dev:all

# Or start individual services:
npm run dev:frontend    # Frontend (React) - http://localhost:5173
npm run dev:api        # API (FastAPI) - http://localhost:8001
npm run dev:crm        # CRM (PHP) - http://localhost:8000
npm run dev:games      # Games (Python) - http://localhost:3000
```

## 🔧 Troubleshooting

### Python Dependencies Issue

If the API service fails to start due to missing dependencies:

```bash
cd api.menschlichkeit-oesterreich.at
pip install -r requirements.txt
# OR for minimal setup:
pip install fastapi uvicorn python-dotenv
```

### Network/Timeout Issues

If pip installation times out during setup:

```bash
cd api.menschlichkeit-oesterreich.at
pip install --timeout 300 -r requirements.txt
# OR install essentials only:
pip install -r requirements-minimal.txt
```

### Environment Configuration

The setup automatically creates `.env` files from examples. To customize:

1. **API Configuration**: Edit `api.menschlichkeit-oesterreich.at/.env`
2. **Frontend Configuration**: Edit `frontend/.env`
3. **CRM Configuration**: Edit `crm.menschlichkeit-oesterreich.at/.env`

## 📊 Quality & Testing

```bash
# Run quality gates
npm run quality:gates

# Run linting
npm run lint:all

# Run tests
npm run test:all
```

## 🐳 Docker Services

For advanced features requiring Docker:

```bash
# Start n8n automation
npm run n8n:start

# View n8n logs
npm run n8n:logs
```

## 🆘 Getting Help

### Quick Status Check

```bash
# Check all services and pull requests status
npm run status:check

# Detailed information with system resources
npm run status:verbose

# Export status as JSON
npm run status:json
```

### Manual Troubleshooting

If services won't start:

1. Check the terminal output for specific error messages
2. Verify prerequisites: `node --version`, `python3 --version`, `php --version`
3. Try restarting individual services
4. Check the `.env` files are properly configured

For more help, see:
- [Codespace Status Checker](../..dokum/CODESPACE-STATUS-CHECKER.md)
- [Codespace Troubleshooting](../..dokum/CODESPACE-TROUBLESHOOTING.md)

## 📁 Project Structure

- `frontend/` - React/TypeScript frontend
- `api.menschlichkeit-oesterreich.at/` - FastAPI Python backend
- `crm.menschlichkeit-oesterreich.at/` - CiviCRM PHP application
- `web/` - Educational games
- `automation/n8n/` - Workflow automation
- `scripts/` - Development and deployment scripts
