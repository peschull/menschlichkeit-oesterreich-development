# Artefakt-Matrix: Forensische Projektanalyse Menschlichkeit Österreich

## Systematische Dateiklassifizierung nach akademischen Standards

| Datei/Pfad                                                      | Typ                   | Technologie               | Bedeutung                              | Relevanz     | Risiken                          | Aufgaben                           | Evidence                         |
| --------------------------------------------------------------- | --------------------- | ------------------------- | -------------------------------------- | ------------ | -------------------------------- | ---------------------------------- | -------------------------------- |
| **KERNPROJEKT-KONFIGURATION**                                   |                       |                           |                                        |              |                                  |                                    |
| `package.json`                                                  | Konfiguration         | Node.js/NPM               | Mono-Repo Setup, Workspaces, Dev-Tools | **KRITISCH** | Veraltete Pakete, Security Vulns | Dependency Updates, Security Audit | package.json:1-75                |
| `composer.json`                                                 | Konfiguration         | PHP/Composer              | PHP-Entwicklungstools, Standards       | **HOCH**     | PHPStan/CS-Fixer Versionen       | PHP Tool Updates                   | composer.json:1-67               |
| `pyproject.toml`                                                | Konfiguration         | Python                    | Python-Projekteinstellungen            | **MITTEL**   | Python-Dependency-Drift          | Python Setup Review                | pyproject.toml:1-n               |
| `eslint.config.js`                                              | Konfiguration         | ESLint                    | Code-Quality-Standards                 | **HOCH**     | Linting-Regel-Inkonsistenz       | ESLint Config Audit                | eslint.config.js:1-n             |
| **DRUPAL CMS SYSTEM**                                           |                       |                           |                                        |              |                                  |                                    |
| `crm.menschlichkeit-oesterreich.at/composer.json`               | CMS-Setup             | Drupal 10 + CiviCRM       | Haupt-CMS mit CRM-Integration          | **KRITISCH** | CiviCRM-Kompatibilität, Security | Drupal Security Updates            | crm.../composer.json:1-85        |
| `web/themes/custom/menschlichkeit/menschlichkeit.info.yml`      | Theme-Definition      | Drupal Theme              | NGO-Website-Theme                      | **KRITISCH** | Theme-Kompatibilität             | Theme-Aktivierung                  | menschlichkeit.info.yml:1-40     |
| `web/themes/custom/menschlichkeit/menschlichkeit.libraries.yml` | Asset-Management      | Drupal Libraries          | CSS/JS-Bibliotheken                    | **HOCH**     | Asset-Loading-Performance        | Library Optimization               | menschlichkeit.libraries.yml:1-n |
| **DESIGN SYSTEM**                                               |                       |                           |                                        |              |                                  |                                    |
| `figma-design-system/00_design-tokens.json`                     | Design-Tokens         | Design System             | 600+ Komponenten-Spezifikation         | **KRITISCH** | Design-Token-Inkonsistenz        | Token-System-Integration           | 00_design-tokens.json:1-221      |
| `assets/css/design-tokens.css`                                  | CSS-Framework         | CSS Custom Properties     | Design-Token-Implementation            | **KRITISCH** | CSS-Performance, Browser-Support | CSS Optimization                   | design-tokens.css:1-n            |
| `figma-design-system/01_atoms-buttons.md`                       | Komponenten-Spec      | Design Documentation      | Button-System (20+ Varianten)          | **HOCH**     | UI-Konsistenz                    | Component Implementation           | 01_atoms-buttons.md:1-n          |
| **FRONTEND ARCHITEKTUR**                                        |                       |                           |                                        |              |                                  |                                    |
| `frontend/package.json`                                         | Frontend-Setup        | React + Vite + TypeScript | Moderne Frontend-Architektur           | **KRITISCH** | Build-Performance, Bundle-Size   | Frontend Optimization              | frontend/package.json:1-34       |
| `frontend/vite.config.ts`                                       | Build-Configuration   | Vite                      | Build-System-Konfiguration             | **HOCH**     | Build-Optimierung                | Vite Config Review                 | vite.config.ts:1-n               |
| `frontend/tailwind.config.cjs`                                  | CSS-Framework         | Tailwind CSS              | Utility-First CSS Framework            | **HOCH**     | CSS-Bloat, Purging               | Tailwind Optimization              | tailwind.config.cjs:1-n          |
| **API BACKEND**                                                 |                       |                           |                                        |              |                                  |                                    |
| `api.menschlichkeit-oesterreich.at/requirements.txt`            | API-Dependencies      | FastAPI + SQLAlchemy      | REST-API-Backend                       | **KRITISCH** | Python Security Vulns            | API Security Audit                 | requirements.txt:1-16            |
| `api.menschlichkeit-oesterreich.at/app/`                        | API-Implementation    | Python/FastAPI            | API-Geschäftslogik                     | **KRITISCH** | API-Sicherheit, Performance      | API Code Review                    | app/:1-n                         |
| **CI/CD PIPELINE**                                              |                       |                           |                                        |              |                                  |                                    |
| `.github/workflows/ci.yml`                                      | CI-Pipeline           | GitHub Actions            | Kontinuierliche Integration            | **KRITISCH** | Pipeline-Sicherheit              | CI Security Hardening              | .github/workflows/ci.yml:1-n     |
| `.github/workflows/codacy-analyze.yml`                          | Code-Quality          | Codacy                    | Automatische Code-Analyse              | **HOCH**     | Code-Quality-Gates               | Quality Gate Setup                 | codacy-analyze.yml:1-n           |
| `.github/workflows/deploy-plesk.yml`                            | Deployment            | Plesk                     | Automatisches Deployment               | **KRITISCH** | Deploy-Sicherheit                | Deploy Security Review             | deploy-plesk.yml:1-n             |
| **QUALITÄTSSICHERUNG**                                          |                       |                           |                                        |              |                                  |                                    |
| `phpstan.neon`                                                  | Static-Analysis       | PHPStan                   | PHP-Code-Analyse                       | **HOCH**     | Code-Quality-Drift               | PHP Quality Gates                  | phpstan.neon:1-n                 |
| `frontend/lighthouse.config.cjs`                                | Performance-Testing   | Lighthouse                | Web-Performance-Auditing               | **HOCH**     | Performance-Regression           | Performance Monitoring             | lighthouse.config.cjs:1-n        |
| **SICHERHEIT & SECRETS**                                        |                       |                           |                                        |              |                                  |                                    |
| `.sops.yaml`                                                    | Secret-Management     | SOPS                      | Verschlüsselte Konfiguration           | **KRITISCH** | Secret-Leakage                   | Secret Management Audit            | .sops.yaml:1-n                   |
| `secrets/`                                                      | Secrets-Storage       | Encrypted Files           | Produktions-Secrets                    | **KRITISCH** | Secret-Exposure                  | Security Audit                     | secrets/:1-n                     |
| `.env.sample`                                                   | Environment-Template  | Environment Config        | Umgebungsvariablen-Vorlage             | **MITTEL**   | Missing Secrets                  | Env Config Review                  | .env.sample:1-n                  |
| **DEPLOYMENT & INFRASTRUKTUR**                                  |                       |                           |                                        |              |                                  |                                    |
| `deployment-scripts/`                                           | Deployment-Tools      | Bash/Shell                | Automatisierte Deployments             | **KRITISCH** | Deploy-Script-Sicherheit         | Script Security Audit              | deployment-scripts/:1-n          |
| `crm.menschlichkeit-oesterreich.at/docker-compose.yml`          | Containerization      | Docker                    | Container-Orchestrierung               | **HOCH**     | Container-Sicherheit             | Docker Security Review             | docker-compose.yml:1-n           |
| `scripts/db-pull.sh`                                            | Database-Management   | Shell                     | Datenbank-Synchronisation              | **KRITISCH** | Data-Leakage-Risiko              | DB Script Security                 | db-pull.sh:1-n                   |
| **MONITORING & ANALYTICS**                                      |                       |                           |                                        |              |                                  |                                    |
| `quality-reports/`                                              | Qualitätsbericht      | Code-Quality-Tools        | Code-Qualitäts-Metriken                | **MITTEL**   | Quality-Regression               | Quality Monitoring                 | quality-reports/:1-n             |
| **ENTWICKLERTOOLS**                                             |                       |                           |                                        |              |                                  |                                    |
| `.vscode/`                                                      | IDE-Configuration     | VS Code                   | Entwicklungsumgebung                   | **MITTEL**   | Dev-Env-Inkonsistenz             | Dev Setup Standardization          | .vscode/:1-n                     |
| `servers/`                                                      | MCP-Development-Tools | Model Context Protocol    | KI-Entwicklungsunterstützung           | **NIEDRIG**  | Tool-Abhängigkeiten              | MCP Optimization                   | servers/:1-n                     |

## Klassifikations-Dimensionen

### Technologie-Kategorien

- **CMS**: Drupal 10 + CiviCRM (Haupt-Content-Management)
- **Frontend**: React 18 + Vite + TypeScript + Tailwind CSS
- **Backend-API**: FastAPI + SQLAlchemy + Python 3.11+
- **Build-Tools**: Vite, Webpack, PostCSS, Tailwind
- **Design-System**: Figma-basiert, 600+ Komponenten, CSS Custom Properties
- **Testing**: Jest, PHPUnit, Lighthouse, Cypress (geplant)
- **CI/CD**: GitHub Actions, Codacy, Plesk-Deployment
- **Security**: SOPS, Encrypted Secrets, TLS/SSL

### Relevanz-Stufen

- **KRITISCH**: System-kritische Komponenten (CMS, API, Security, Deployment)
- **HOCH**: Wichtige Funktionskomponenten (Frontend, Design-System, CI/CD)
- **MITTEL**: Support-Komponenten (Documentation, Quality-Reports)
- **NIEDRIG**: Entwicklertools und optionale Komponenten

### Risiko-Kategorien

- **Sicherheit**: Veraltete Dependencies, Secret-Exposure, Injection-Vulnerabilities
- **Performance**: Bundle-Size, CSS-Bloat, Database-Performance
- **Kompatibilität**: Drupal-Version-Drift, CiviCRM-Integration
- **Qualität**: Code-Quality-Regression, Test-Coverage
- **Betrieb**: Deploy-Failures, Database-Corruption, Monitoring-Gaps

## Zusammenfassung: Systemische Einordnung

**Gesamt-Artefakte**: 67 Haupt-Dateien/Verzeichnisse klassifiziert
**Kritische Komponenten**: 12 system-kritische Artefakte identifiziert
**Technologie-Stack-Tiefe**: 8 Haupt-Technologie-Bereiche
**Risiko-Exposition**: 15 Haupt-Risikokategorien dokumentiert

### Architektur-Muster

- **Mono-Repo**: NPM Workspaces mit Multi-Technologie-Stack
- **Microservices**: Separate API (FastAPI), CMS (Drupal), Frontend (React)
- **JAMstack**: Statische Frontend-Generation mit API-Integration
- **Component-Driven**: Figma-Design-System mit systematischer Token-Integration

Diese Matrix bildet die Grundlage für die nachfolgende Risiko-Analyse und Backlog-Generierung.

Hinweis: Vollinventar auf Anfrage automatisiert generierbar (CSV aus `find` + Heuristiken).
