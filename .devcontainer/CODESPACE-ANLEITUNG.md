# 🚀 GitHub Codespace Setup für Menschlichkeit Österreich

## ✅ Codespace ist bereit!

Dein GitHub Codespace für das **Austrian NGO Multi-Service Platform** ist komplett eingerichtet und optimiert.

### 🎯 Sofort loslegen

```bash
# Alle Services starten
./codespace-start.sh

# System-Health prüfen
./codespace-health.sh

# Oder einzelne Services via npm
npm run dev:all
```

### 🌐 Verfügbare Services & Ports

| Service      | Port | URL                                         | Beschreibung      |
| ------------ | ---- | ------------------------------------------- | ----------------- |
| **Frontend** | 3000 | `https://yourcodespace-3000.app.github.dev` | React Frontend    |
| **CRM**      | 8000 | `https://yourcodespace-8000.app.github.dev` | CiviCRM/Drupal    |
| **API**      | 8001 | `https://yourcodespace-8001.app.github.dev` | FastAPI Backend   |
| **Games**    | 3001 | `https://yourcodespace-3001.app.github.dev` | Educational Games |
| **Debug**    | 5678 | `https://yourcodespace-5678.app.github.dev` | Debugging         |

### 💡 Wichtige Befehle

```bash
# Entwicklung
npm run dev:frontend    # Nur Frontend
npm run dev:api        # Nur API
npm run dev:crm        # Nur CRM

# Quality Gates
npm run quality:gates   # Alle Qualitäts-Checks
npm run lint:all       # Linting
npm run format:all     # Code-Formatierung

# Testing
npm run test:e2e       # Playwright E2E Tests
npm run test:unit      # Unit Tests

# Deployment (Dry-Run)
./scripts/safe-deploy.sh --dry-run
```

### 🔧 Development Workflow

1. **Erste Schritte:**

   ```bash
   ./codespace-start.sh
   ```

2. **Code bearbeiten:** VS Code Editor verwenden

3. **Testen:**

   ```bash
   npm run test:unit
   npm run test:e2e
   ```

4. **Quality Check:**

   ```bash
   npm run quality:gates
   ```

5. **Commit & Push:** Git Integration verwenden

### 📁 Projekt-Struktur

```
.
├── frontend/                 # React Frontend
├── api.menschlichkeit-oesterreich.at/  # FastAPI Backend
├── crm.menschlichkeit-oesterreich.at/  # CiviCRM System
├── web/                     # Educational Games
├── website/                 # WordPress Website
├── automation/n8n/         # n8n Workflows
├── scripts/                 # Deployment Scripts
└── .devcontainer/           # Codespace Config
```

### 🐛 Troubleshooting

**Services starten nicht?**

```bash
./codespace-health.sh    # Status prüfen
pkill -f "node\|python\|php"  # Alle stoppen
./codespace-start.sh     # Neu starten
```

**Port nicht erreichbar?**

- VS Code → Ports Tab → Port manuell forwarden
- Oder: `Ctrl+Shift+P` → "Forward a Port"

**npm/composer Probleme?**

```bash
cd frontend && npm ci    # Frontend Dependencies
composer install         # PHP Dependencies
pip install -r api.menschlichkeit-oesterreich.at/requirements.txt  # Python
```

### 🎨 VS Code Features

- **Auto-Format:** Beim Speichern aktiviert
- **ESLint:** Automatische Code-Fixes
- **Extensions:** Alle wichtigen Extensions vorinstalliert
- **IntelliSense:** Für PHP, Python, TypeScript, React
- **Git Integration:** Komplett konfiguriert

### 🔐 Secrets & Environment

Alle Secrets sind automatisch aus GitHub Codespace Secrets geladen:

- `PLESK_HOST` - Plesk Server
- `SSH_PRIVATE_KEY` - SSH Schlüssel
- `CODACY_API_TOKEN` - Code Quality
- `SNYK_TOKEN` - Security Scanning

### 🚀 Performance Optimiert

- **Node Modules:** Volume-mounted für Geschwindigkeit
- **Docker Cache:** Für schnelle Container-Builds
- **Dependencies:** Pre-installed und cached
- **Hot Reload:** Für alle Services aktiviert

### 📞 Support

Bei Problemen:

1. `./codespace-health.sh` ausführen
2. Logs in `./logs/` prüfen
3. GitHub Issues erstellen
4. README.md im Root-Verzeichnis konsultieren

**Viel Erfolg bei der Entwicklung! 🇦🇹**
