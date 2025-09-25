# 🚀 GitHub Repository Setup - Anleitung

## 📋 **Status**

✅ **Git Repository**: Bereits initialisiert mit erstem Commit (64 Dateien, 22,858 Zeilen)  
✅ **Umfassende .gitignore**: 200+ Patterns für Multi-Technology-Environment  
✅ **README.md**: Vollständige Projektdokumentation erstellt  
⏳ **GitHub Remote**: Noch zu erstellen und zu pushen

---

## 🔗 **1. GitHub Repository erstellen**

### **Option A: GitHub CLI (Empfohlen)**

```bash
# GitHub CLI authentifizieren
gh auth login

# Repository erstellen und direkt verknüpfen
gh repo create menschlichkeit-oesterreich-development \
    --description "Multi-Technology Development Environment: MCP Servers, WordPress Monorepo, TypeScript/Python/PHP Stack" \
    --public \
    --source=. \
    --remote=origin \
    --push
```

### **Option B: GitHub Web Interface**

1. Gehe zu **[github.com/new](https://github.com/new)**
2. **Repository Name**: `menschlichkeit-oesterreich-development`
3. **Description**:
   ```
   Multi-Technology Development Environment: MCP Servers, WordPress Monorepo, TypeScript/Python/PHP Stack
   ```
4. **Visibility**: Public ✅
5. **Keine** README, .gitignore oder License hinzufügen (bereits vorhanden)
6. Klicke **"Create repository"**

---

## 🔄 **2. Remote Origin hinzufügen und pushen**

```bash
# Remote Origin hinzufügen
git remote add origin https://github.com/DEIN-USERNAME/menschlichkeit-oesterreich-development.git

# Oder mit SSH (falls konfiguriert):
git remote add origin git@github.com:DEIN-USERNAME/menschlichkeit-oesterreich-development.git

# Branch umbenennen zu main (falls nötig)
git branch -M main

# Zu GitHub pushen
git push -u origin main
```

---

## 📊 **3. Repository Konfiguration**

### **🏷️ Topics hinzufügen**

```bash
# Via GitHub CLI
gh repo edit --add-topic "mcp-server,typescript,python,php,wordpress,docker,multi-language"

# Oder über Web Interface → Settings → Topics:
# mcp-server, typescript, python, php, wordpress, docker, multi-language
```

### **🔒 Branch Protection**

```bash
# Main branch protection aktivieren
gh api repos/:owner/:repo/branches/main/protection \
    --method PUT \
    --field required_status_checks='{"strict":true,"contexts":[]}' \
    --field enforce_admins=true \
    --field required_pull_request_reviews='{"required_approving_review_count":1}' \
    --field restrictions='null'
```

---

## 📂 **4. Submodules hinzufügen**

Da wir 2 embedded Git Repositories entfernt haben:

```bash
# WordPress Monorepo als Submodule (falls gewünscht)
git submodule add https://github.com/DEIN-USERNAME/menschlichkeit-oesterreich-monorepo.git menschlichkeit-oesterreich-monorepo

# MCP Servers als Submodule (falls separates Repo gewünscht)
git submodule add https://github.com/DEIN-USERNAME/mcp-servers.git servers

# Submodules committen
git add .gitmodules menschlichkeit-oesterreich-monorepo servers
git commit -m "Add submodules: WordPress monorepo and MCP servers"
git push
```

---

## 🔧 **5. GitHub Actions CI/CD Setup**

### **Workflow-Datei erstellen**

```bash
mkdir -p .github/workflows
```

**`.github/workflows/ci.yml`** erstellen:

```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test-typescript:
    name: TypeScript Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint:js
      - run: npm test

  test-python:
    name: Python Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - run: pip install uv
      - run: uv pip install -e .
      - run: python -m flake8
      - run: python -m pytest

  test-php:
    name: PHP Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: shivammathur/setup-php@v2
        with:
          php-version: '8.1'
      - run: composer install
      - run: ./vendor/bin/phpstan analyse
      - run: ./vendor/bin/phpunit

  docker-build:
    name: Docker Build Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build MCP Server Images
        run: |
          docker build -t mcp-essential ./mcp-servers/essential-stack
          docker build -t mcp-web ./mcp-servers/web-stack
```

---

## 📊 **6. Repository Insights aktivieren**

### **GitHub Web Interface → Settings → General**

- ✅ **Issues** aktivieren
- ✅ **Wiki** aktivieren
- ✅ **Discussions** aktivieren
- ✅ **Projects** aktivieren

### **Security Settings**

- ✅ **Dependabot alerts** aktivieren
- ✅ **Dependabot security updates** aktivieren
- ✅ **Code scanning** aktivieren

---

## 🏆 **7. Badges für README.md**

Nach dem Repository-Setup, README.md erweitern:

```markdown
[![CI/CD Pipeline](https://github.com/DEIN-USERNAME/menschlichkeit-oesterreich-development/actions/workflows/ci.yml/badge.svg)](https://github.com/DEIN-USERNAME/menschlichkeit-oesterreich-development/actions/workflows/ci.yml)
[![GitHub issues](https://img.shields.io/github/issues/DEIN-USERNAME/menschlichkeit-oesterreich-development)](https://github.com/DEIN-USERNAME/menschlichkeit-oesterreich-development/issues)
[![GitHub stars](https://img.shields.io/github/stars/DEIN-USERNAME/menschlichkeit-oesterreich-development)](https://github.com/DEIN-USERNAME/menschlichkeit-oesterreich-development/stargazers)
```

---

## 📝 **8. Nächste Schritte nach Push**

1. **Issues erstellen** für Todo-Liste:

   ```bash
   gh issue create --title "Code Quality Standards evaluieren" --body "Analyse der ESLint 9.x, PHPStan Level 8 und Python Tools"
   gh issue create --title "Build-System & CI/CD analysieren" --body "Docker Multi-Stage-Builds und GitHub Actions"
   gh issue create --title "Security Assessment durchführen" --body "API-Keys, Environment Variables und WordPress Security"
   ```

2. **Releases vorbereiten**:

   ```bash
   gh release create v1.0.0 --title "Initial Release" --notes "Multi-Technology Development Environment Setup"
   ```

3. **Team Collaboration**:
   - Collaborators hinzufügen
   - Teams erstellen
   - Branch policies konfigurieren

---

## 📦 **Current Repository Stats**

- **📁 64 Dateien** committiert
- **📊 22,858 Zeilen** Code
- **🔧 7 Hauptkategorien**: MCP Servers, Stacks, Utilities, WordPress, Package Management, Entwicklungsinfrastruktur, Quality Gates
- **📦 60 Dependencies**: 34× package.json, 8× pyproject.toml, 18× composer.json
- **🐳 Docker-Ready**: Multi-Stage-Builds für alle MCP Server
- **🎯 VS Code Integration**: Tasks, Debugging, Extensions

---

_Nach erfolgreichem GitHub Setup: Datei löschen oder nach `docs/` verschieben_
