# 🏗️ Menschlichkeit Österreich - Multi-Technology Development Environment

**Comprehensive Model Context Protocol (MCP) Server Stack with Web Development Infrastructure**

[![TypeScript](https://img.shields.io/badge/TypeScript-5.7.2-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Python](https://img.shields.io/badge/Python-3.13.7-green?logo=python)](https://www.python.org/)
[![PHP](https://img.shields.io/badge/PHP-8.4.12-purple?logo=php)](https://www.php.net/)
[![Docker](https://img.shields.io/badge/Docker-Multi--Stage-blue?logo=docker)](https://www.docker.com/)
[![Node.js](https://img.shields.io/badge/Node.js-22.19.0-brightgreen?logo=node.js)](https://nodejs.org/)

---

## 🎯 **Projektübersicht**

Dieses Repository vereint **7 Hauptkomponenten** einer vollständigen Entwicklungsinfrastruktur für die digitale Plattform von **Menschlichkeit Österreich**:

### 🔧 **1. Model Context Protocol (MCP) Servers**
- **8 Core Server**: `filesystem`, `git`, `fetch`, `time`, `memory`, `everything`, `sequentialthinking`
- **Technologie-Stack**: TypeScript/Python mit `@modelcontextprotocol/sdk`
- **Container-Ready**: Individuelle Docker Multi-Stage-Builds

### 🏢 **2. Organisation-spezifische MCP Stacks**
- **Essential Stack**: Stripe-Integration, Mailchimp-Automation, Google Services
- **Web Stack**: WordPress-Management, Laravel-APIs, Plesk OpenAPI-Server

### ⚙️ **3. Utility-Komponenten**
- **mcp-bridge**: WebSocket-Bridge für MCP-Kommunikation
- **mcp-search**: Python-basierte Suchfunktionalität mit FastMCP

### 🌐 **4. WordPress-Monorepo**
- **httpdocs/**: Hauptdomain WordPress-Installation
- **api.menschlichkeit-oesterreich.at**: Dedizierte API-Endpunkte
- **crm.menschlichkeit-oesterreich.at**: CRM-System Integration

### 📦 **5. Multi-Language Package Management**
- **34× package.json** (Node.js/TypeScript Projekte)
- **8× pyproject.toml** (Python-Projekte mit `uv`)
- **18× composer.json** (PHP-Projekte)

### 🛠️ **6. Entwicklungsinfrastruktur**
- **Release-Management**: Python-Script mit Git-Integration
- **VS Code**: Tasks, Debugging-Konfigurationen, Extensions
- **Quality Gates**: ESLint 9.x, PHPStan Level 8, Python (black/flake8)

### 🔧 **7. Qualitätssicherung**
- **Testing**: Jest (TypeScript), pytest (Python), PHPUnit
- **Formatierung**: Prettier, PHP-CS-Fixer (PSR-12), Black
- **Dokumentation**: Markdownlint, JSDoc, Python docstrings

---

## 🚀 **Quick Start**

### **Voraussetzungen**
```bash
# Node.js & npm
node -v  # >= 18.0.0
npm -v   # >= 10.0.0

# Python & uv
python --version  # >= 3.11
pip install uv    # Moderner Python Package Manager

# PHP & Composer
php -v      # >= 8.1
composer -V # >= 2.0

# Docker
docker -v   # Für Container-Builds
```

### **Installation**
```bash
# Repository klonen
git clone <repository-url>
cd menschlichkeit-oesterreich-development

# Alle Dependencies installieren
npm run setup:dev

# Entwicklungsumgebung starten
npm run dev:all
```

---

## 🏗️ **Architektur-Übersicht**

```
📁 Arbeitsverzeichnis/
├── 🔧 mcp-servers/                 # MCP Server Stacks
│   ├── essential-stack/            # Stripe, Mailchimp, Google
│   └── web-stack/                  # WordPress, Laravel, Plesk
├── 📦 servers/                     # Core MCP Servers
│   └── src/                        # TypeScript/Python Implementierung
├── 🌐 menschlichkeit-oesterreich-monorepo/
│   ├── httpdocs/                   # WordPress Hauptdomain
│   ├── api.*/                      # API-Endpunkte
│   └── crm.*/                      # CRM-System
├── ⚙️ mcp-bridge/                  # WebSocket-Bridge
├── 🔍 mcp-search/                  # Python-Search-Engine
├── 🛠️ .vscode/                     # VS Code Konfiguration
└── 📋 package.json                 # Workspace Management
```

---

## 🌐 **WordPress Monorepo Management**

### **Verzeichnisstruktur**
- **`/httpdocs`**: Hauptdomain (WordPress)
- **`/api.menschlichkeit-oesterreich.at`**: API-Endpunkte
- **`/crm.menschlichkeit-oesterreich.at`**: CRM-System

### **SFTP/SSH Synchronisation**

Drei Varianten zur Auswahl:

```powershell
# PowerShell + OpenSSH (einfach)
.\scripts\sync_sftp.ps1

# WinSCP (schnell, mit Filtern)
.\scripts\sync_winscp.cmd

# SSH + tar (Fallback, ohne SFTP-Subsystem)
.\scripts\sync_ssh_tar.ps1
```

### **Git Initialisierung & Push**

```powershell
cd .\menschlichkeit-oesterreich-monorepo
git init
git checkout -b main
git remote add origin git@github.com:DEIN-USER/menschlichkeit-oesterreich-monorepo.git
git add .
git commit -m "Initial import from Plesk"
git push -u origin main
```

---

## 🛠️ **Verfügbare Commands**

### **🔨 Build & Development**
```bash
# Alle Projekte bauen
npm run build:all

# Development-Server starten
npm run dev:essential    # Essential Stack
npm run dev:web          # Web Stack

# Einzelne MCP Server starten
npm run start:wordpress  # WordPress MCP Server
npm run start:laravel    # Laravel MCP Server
npm run start:plesk      # Plesk OpenAPI Server
```

### **🧪 Testing & Quality**
```bash
# Code-Quality prüfen
npm run lint:js          # ESLint für JavaScript/TypeScript
npm run lint:php         # PHPStan für PHP
python -m flake8         # Python Linting

# Tests ausführen
npm run test:all         # Alle Tests
npm run test:jest        # Jest (TypeScript)
npm run test:pytest      # Python Tests

# Code formatieren
npm run format           # Prettier
npm run format:php       # PHP-CS-Fixer
python -m black .        # Python Black
```

### **🐳 Docker & Deployment**
```bash
# Docker Images bauen
docker build -t mcp-server-essential ./mcp-servers/essential-stack
docker build -t mcp-server-web ./mcp-servers/web-stack

# Alle MCP Server Images
for server in servers/src/*/; do
    docker build -t "mcp-server-$(basename $server)" "$server"
done
```

---

## 📋 **MCP Server Endpoints**

| **Server** | **Typ** | **Port** | **Beschreibung** |
|------------|---------|----------|------------------|
| `essential-stack` | TypeScript | `3001` | Stripe, Mailchimp, Google APIs |
| `web-stack` | TypeScript | `3002` | WordPress, Laravel, Plesk |
| `filesystem` | Python | `3003` | Dateisystem-Operationen |
| `git` | Python | `3004` | Git-Repository-Management |
| `fetch` | Python | `3005` | HTTP-Request-Handling |
| `time` | Python | `3006` | Zeitzone-Management |
| `memory` | TypeScript | `3007` | Speicher-Persistierung |
| `mcp-search` | Python | `3008` | Such-Engine mit FastMCP |

---

## 🔒 **Sicherheit & Best Practices**

### **🛡️ Security Checklist**
- ✅ **Dependencies**: Regelmäßige `npm audit` und `safety check`
- ✅ **Secrets**: Environment Variables (.env) niemals committen
- ✅ **Docker**: Multi-Stage-Builds für minimale Image-Größen
- ✅ **API-Keys**: Sichere Speicherung in Umgebungsvariablen
- ✅ **WordPress**: Plugin-Updates und Security-Hardening

### **🔍 Code Quality Gates**
```bash
# Automatische Quality Checks
npm run lint:all         # ESLint, PHPStan, Flake8
npm run test:coverage    # Test-Coverage prüfen
npm run security:audit   # Dependency-Vulnerability-Scan
```

---

## ⚠️ **Troubleshooting**

### **WordPress/SFTP Issues**
- **SFTP Fehler 255**: Nutze `sync_ssh_tar.ps1` (SFTP wird serverseitig geblockt)
- **SSH Key/Host-Key**: Einmal `ssh dmpl20230054@5.183.217.146` aufrufen und Host-Key akzeptieren
- **Große Uploads**: `wp-content/uploads` sind bewusst ausgeschlossen (.gitignore)

### **MCP Server Debugging**
```bash
# Server-Logs anzeigen
npm run logs:essential   # Essential Stack Logs
npm run logs:web         # Web Stack Logs
docker logs <container>  # Docker Container Logs
```

### **Python Environment Issues**
```bash
# uv Environment reparieren
uv venv --python 3.11
uv pip install -e .

# Virtual Environment aktivieren
.venv\Scripts\activate    # Windows
source .venv/bin/activate # Unix/macOS
```

---

## 📚 **Entwickler-Dokumentation**

### **🔧 MCP Server Development**
- [MCP Protocol Documentation](https://modelcontextprotocol.io/)
- [Server Implementation Guide](./docs/MCP_SERVER_DEVELOPMENT.md)
- [Custom Tool Development](./docs/CUSTOM_TOOLS.md)

### **🌐 WordPress Integration**
- [WordPress REST API Setup](./docs/WORDPRESS_INTEGRATION.md)
- [Plugin Development Guide](./docs/WP_PLUGIN_DEVELOPMENT.md)
- [Multisite Configuration](./docs/WP_MULTISITE_SETUP.md)

### **🐳 Docker & Deployment**
- [Docker Multi-Stage Builds](./docs/DOCKER_SETUP.md)
- [Production Deployment](./docs/PRODUCTION_DEPLOYMENT.md)
- [CI/CD Pipeline](./docs/CICD_PIPELINE.md)

---

## 🤝 **Contributing**

### **🔀 Workflow**
1. **Fork** das Repository
2. **Feature Branch** erstellen: `git checkout -b feature/amazing-feature`
3. **Commits** durchführen: `git commit -m 'Add amazing feature'`
4. **Tests** sicherstellen: `npm run test:all`
5. **Pull Request** erstellen

### **📝 Code Style**
- **TypeScript**: ESLint + Prettier (Airbnb Config)
- **Python**: Black + Flake8 + mypy
- **PHP**: PSR-12 + PHPStan Level 8
- **Commit Messages**: [Conventional Commits](https://conventionalcommits.org/)

---

## 📄 **License**

Dieses Projekt steht unter der **MIT License** - siehe [LICENSE](LICENSE) für Details.

---

## 🏢 **Organisation**

**Menschlichkeit Österreich**
- 🌐 **Website**: [menschlichkeit-oesterreich.at](https://menschlichkeit-oesterreich.at)
- 📧 **E-Mail**: info@menschlichkeit-oesterreich.at
- 🔗 **GitHub**: [@menschlichkeit-oesterreich](https://github.com/menschlichkeit-oesterreich)

---

## 🙏 **Danksagung**

Besonderer Dank an:
- **Model Context Protocol Team** für die MCP-Spezifikation
- **TypeScript Community** für hervorragende Tooling
- **Python Community** für moderne Package-Management (uv)
- **WordPress Community** für offene Plattform-Architektur

---

*Letzte Aktualisierung: 22. September 2025*
