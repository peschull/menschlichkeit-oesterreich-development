# Codespace Setup - Menschlichkeit Österreich 🇦🇹

## 🚀 Automatische Installation

Dieses Setup wird **automatisch** beim Start eines GitHub Codespaces ausgeführt.

### Was wird installiert?

1. **uv** - Python Package Manager (moderner, schneller als pip)
2. **Python-Dependencies** - API-Service und alle Python-Abhängigkeiten
3. **Node.js Workspaces** - Frontend, Gaming Platform, Automation
4. **Composer Dependencies** - PHP/Drupal für CRM-Service
5. **Prisma Client** - Gaming Platform Datenbank-Client
6. **Git-Konfiguration** - Optimierte Settings

## 🌐 Development Servers

Nach dem Setup alle Services starten:

```bash
# Alle Services starten (empfohlen)
npm run dev:all

# Oder einzelne Services:
npm run dev:frontend    # Frontend (React) → http://localhost:5173
npm run dev:api        # API (FastAPI) → http://localhost:8001
npm run dev:crm        # CRM (Drupal) → http://localhost:8000
npm run dev:games      # Games (Python) → http://localhost:3000
```

## 📦 uv - Python Package Manager

**uv** wird automatisch installiert und bietet:
- ⚡ Bis zu 10x schneller als pip
- 🔒 Sichere Dependency-Auflösung
- 🎯 Kompatibel mit allen pip-Commands

### Nutzung von uv

```bash
# Pakete installieren (ersetzt pip install)
uv pip install <package>

# Requirements-Datei installieren
uv pip install -r requirements.txt

# Paket-Informationen
uv pip show <package>
```

## 🔍 System-Überprüfung

Nach dem Setup wird automatisch angezeigt:
- Node.js Version
- npm Version  
- Python Version
- uv Version
- PHP Version
- Composer Version

### Manuelle Überprüfung

```bash
# Script erneut ausführen
bash .devcontainer/setup-codespace.sh

# Oder einzelne Tools prüfen
uv --version
node --version
python3 --version
```

## 🧪 Quality Gates & Testing

### Quality Gates prüfen
```bash
npm run quality:gates
```

Führt aus:
- ✅ Security Scan (Trivy, Gitleaks)
- ✅ Code Quality (Codacy)
- ✅ Performance Audit (Lighthouse)
- ✅ DSGVO Compliance Check

### Tests ausführen
```bash
npm run test:e2e      # E2E Tests (Playwright)
npm run test:unit     # Unit Tests (Vitest)
pytest tests/         # Python Backend Tests
composer test         # Drupal/PHP Tests
```

## 🔧 Troubleshooting

### uv Installation fehlgeschlagen

```bash
# Manuelle Installation
pip install --upgrade pip
pip install uv

# Testen
uv --version
```

### Python Dependencies Fehler

Falls API-Service nicht startet:

```bash
cd api.menschlichkeit-oesterreich.at

# Mit uv (schneller)
uv pip install -r requirements.txt

# Oder mit pip (falls uv Probleme macht)
pip install -r requirements.txt

# Nur essenzielle Pakete
pip install fastapi uvicorn python-dotenv
```

### npm Workspace Fehler

```bash
# Clean install
npm run clean:dist
npm install --force

# Einzelne Workspaces
npm install --workspace=frontend
npm install --workspace=mcp-servers
```

### Prisma Client Fehler

```bash
# Client neu generieren
npx prisma generate

# Mit Migration
npx prisma migrate dev

# Prisma Studio öffnen (GUI)
npx prisma studio
```

### Network/Timeout Issues

Falls pip während Setup timeoutet:

```bash
cd api.menschlichkeit-oesterreich.at

# Längerer Timeout
pip install --timeout 300 -r requirements.txt

# Oder minimal setup
pip install -r requirements-minimal.txt
```

### Git-Probleme

```bash
# Git-Konfiguration prüfen
git config --list

# Git neu konfigurieren
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

## 🇦🇹 Austrian NGO Compliance

Alle installierten Tools sind DSGVO-konform:
- ✅ Keine Datensammlung durch uv
- ✅ Lokale Entwicklung ohne Cloud-Services  
- ✅ Alle Dependencies mit SPDX-Lizenz dokumentiert
- ✅ PII-Sanitization in 2 Layern (Python + Drupal)

## 📚 Weitere Dokumentation

- **Projekt-Übersicht**: `README.md` im Root
- **Development Guidelines**: `.github/instructions/project-development.instructions.md`
- **Quality Gates**: `.github/instructions/quality-gates.instructions.md`
- **MCP Integration**: `.github/instructions/mcp-integration.instructions.md`
- **Copilot Instructions**: `.github/copilot-instructions.md`

## 📞 Support

Bei Problemen:
1. **GitHub Issues** - Repository Issues erstellen
2. **Logs prüfen** - `cat /tmp/codespace-setup.log`
3. **Dokumentation** - Siehe Abschnitt "Weitere Dokumentation"

---

**Letztes Update:** 2025-01-07  
**Maintainer:** Menschlichkeit Österreich Development Team

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

If services won't start:

1. Check the terminal output for specific error messages
2. Verify prerequisites: `node --version`, `python3 --version`, `php --version`
3. Try restarting individual services
4. Check the `.env` files are properly configured

## 📁 Project Structure

- `frontend/` - React/TypeScript frontend
- `api.menschlichkeit-oesterreich.at/` - FastAPI Python backend
- `crm.menschlichkeit-oesterreich.at/` - CiviCRM PHP application
- `web/` - Educational games
- `automation/n8n/` - Workflow automation
- `scripts/` - Development and deployment scripts
