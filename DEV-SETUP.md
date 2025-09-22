# Menschlichkeit Österreich - Development Environment

## 🚀 Schnellstart

```powershell
# Vollständige Einrichtung
.\setup-dev.ps1 -InstallAll

# Oder schrittweise
.\setup-dev.ps1 -InstallNode
.\setup-dev.ps1 -InstallPython
.\setup-dev.ps1 -SetupVscode
```

## 📋 Verfügbare Entwicklungstools

### JavaScript/TypeScript

- **ESLint** - Code-Qualitätsprüfung
- **Prettier** - Code-Formatierung
- **TypeScript** - Typsicherheit

### PHP

- **PHPStan** - Statische Analyse (Level 8)
- **PHP-CS-Fixer** - PSR-12 Coding Standards
- **Composer** - Paketmanagement

### Python

- **Black** - Code-Formatierung
- **Flake8** - Linting
- **MyPy** - Typprüfung
- **isort** - Import-Sortierung
- **pytest** - Testing

### Markdown

- **markdownlint** - Dokumentationsqualität

## 🛠️ VS Code Integration

### Verfügbare Tasks (Ctrl+Shift+P → "Tasks: Run Task")

#### Linting

- `lint:all` - Alle Dateien prüfen
- `lint:js` - JavaScript/TypeScript
- `lint:php` - PHP Dateien
- `lint:python` - Python Code
- `lint:markdown` - Markdown Dokumente

#### Formatierung

- `format:all` - Alle Dateien formatieren
- `format:js` - JavaScript/TypeScript
- `format:php` - PHP Code
- `format:python` - Python Code

#### Tests

- `test:all` - Alle Tests ausführen
- `test:jest` - JavaScript Tests
- `test:pytest` - Python Tests

### Debugging

Konfigurierte Launch-Konfigurationen für:

- Essential Stack MCP Server
- Web Stack MCP Server
- Core Servers
- MCP Bridge
- MCP Search

## 📦 Paketmanagement

### Node.js Dependencies

```powershell
npm install           # Root dependencies
npm run lint:js       # JavaScript/TypeScript linting
npm run format:js     # Code formatting
```

### Python Packages

```powershell
# Über Python 3.13
python -m pip install black flake8 mypy isort pytest

# Linting ausführen
python -m flake8 servers/
python -m black servers/
```

### PHP Tools

```powershell
# Composer installieren (falls nicht vorhanden)
scoop install composer

# Dependencies installieren
composer install

# Code prüfen
composer run stan
composer run cs-fix
```

## ⚙️ Konfigurationsdateien

| Datei                | Zweck                 | Sprache  |
| -------------------- | --------------------- | -------- |
| `.eslintrc.js`       | ESLint Regeln         | JS/TS    |
| `.prettierrc.json`   | Prettier Formatierung | JS/TS    |
| `.php-cs-fixer.php`  | PHP Coding Standards  | PHP      |
| `phpstan.neon`       | PHP Statische Analyse | PHP      |
| `pyproject.toml`     | Python Tools Config   | Python   |
| `.markdownlint.json` | Markdown Regeln       | Markdown |

## 🔧 VS Code Einstellungen

### Empfohlene Extensions

- ESLint (`dbaeumer.vscode-eslint`)
- Prettier (`esbenp.prettier-vscode`)
- Python (`ms-python.python`)
- PHP Intelephense (`bmewburn.vscode-intelephense-client`)
- Markdown All in One (`yzhang.markdown-all-in-one`)
- Markdown Lint (`DavidAnson.vscode-markdownlint`)

### Automatische Formatierung

- Format beim Speichern aktiviert
- Auto-Fix für ESLint beim Speichern
- Sprachspezifische Formatter konfiguriert

## 🎯 Qualitätssicherung

### Pre-Commit Checks

```powershell
# Alle Qualitätsprüfungen
npm run lint:all

# Spezifische Prüfungen
npm run lint:js        # JavaScript/TypeScript
python -m flake8 .     # Python
composer run stan      # PHP
npx markdownlint *.md  # Markdown
```

### CI/CD Integration

Alle Konfigurationen sind bereit für GitHub Actions oder andere CI/CD-Systeme.

## 📁 Workspace-Struktur

```
d:\Arbeitsverzeichniss\
├── mcp-servers/           # MCP Server Implementierungen
│   ├── essential-stack/   # Basis-Tools
│   └── web-stack/         # Web-Tools
├── servers/               # Core Server
├── mcp-bridge/           # Bridge Komponente
├── mcp-search/           # Suchfunktionalität
├── .vscode/              # VS Code Konfiguration
├── setup-dev.ps1         # Entwicklungsumgebung Setup
└── ...                   # Weitere Projekt-Dateien
```

## 🚨 Fehlerbehebung

### Häufige Probleme

#### Node.js Abhängigkeiten

```powershell
# Cache leeren
npm cache clean --force
npm install
```

#### Python Environment

```powershell
# Python-Pfad prüfen
Get-Command python
python --version
```

#### PHP Composer

```powershell
# Composer installieren
scoop install composer
# oder
choco install composer
```

#### VS Code Extensions

```powershell
# Extension manuell installieren
code --install-extension dbaeumer.vscode-eslint
```

---

## 📞 Support

Bei Problemen mit der Entwicklungsumgebung:

1. Prüfen Sie die Konfigurationsdateien in `.vscode/`
2. Verwenden Sie `setup-dev.ps1 -Help` für weitere Optionen
3. Kontrollieren Sie die installierten Tools über VS Code Tasks

**Viel Erfolg bei der Entwicklung! 🎉**
