# Repository-Inventar: Menschlichkeit Österreich Projekt

## Projekt-Repository-Übersicht

Vollständige Dokumentation aller Repositories des **Menschlichkeit Österreich Website-Entwicklungsprojekts** mit exakter Zweckbeschreibung und Verantwortlichkeiten.

**Letzte Aktualisierung**: 25. September 2025  
**Projekt-Status**: Aktive Entwicklung (Phase 1: Security & Compliance Foundation)  
**Gesamt-Repositories**: 6 Haupt-Repos + 3 Entwicklungstools

---

## Haupt-Entwicklungs-Repositories

| Repository-Name                            | Plattform                                                | Zweck                                                                 | Status        | Verantwortliche | Branch-Strategy         |
| ------------------------------------------ | -------------------------------------------------------- | --------------------------------------------------------------------- | ------------- | --------------- | ----------------------- |
| **menschlichkeit-oesterreich-development** | GitHub (peschull/menschlichkeit-oesterreich-development) | **Haupt-Mono-Repo**: Koordination aller Komponenten, CI/CD, Analysis  | **aktiv**     | Projektleitung  | main + feature branches |
| **crm.menschlichkeit-oesterreich.at**      | Lokal (./crm.menschlichkeit-oesterreich.at/)             | **Drupal 10 + CiviCRM**: Haupt-CMS für NGO-Funktionalitäten           | **aktiv**     | Backend Team    | drupal-integration      |
| **api.menschlichkeit-oesterreich.at**      | Lokal (./api.menschlichkeit-oesterreich.at/)             | **FastAPI Backend**: REST-API für User-Management und CRM-Integration | **aktiv**     | Backend Lead    | api-development         |
| **frontend**                               | NPM Workspace (./frontend/)                              | **React 18 + TypeScript**: Moderne Frontend-Architektur mit Vite      | **aktiv**     | Frontend Lead   | frontend-migration      |
| **website**                                | Workspace (./website/)                                   | **Statische Website**: Legacy-HTML für Migration zu React             | **migration** | Frontend Team   | website-legacy          |
| **figma-design-system**                    | Lokal (./figma-design-system/)                           | **Design-System**: 600+ Komponenten-Spezifikationen aus Figma         | **aktiv**     | UX/UI Lead      | design-tokens           |

---

## Infrastruktur & DevOps Repositories

| Repository-Name        | Plattform                     | Zweck                                                               | Status          | Verantwortliche | Deployment       |
| ---------------------- | ----------------------------- | ------------------------------------------------------------------- | --------------- | --------------- | ---------------- |
| **deployment-scripts** | Lokal (./deployment-scripts/) | **Plesk-Deployment**: Automatisierte Deployment-Skripte für Hosting | **aktiv**       | DevOps Lead     | plesk-automation |
| **servers**            | Lokal (./servers/)            | **MCP-Development-Tools**: Model Context Protocol Server-Stubs      | **entwicklung** | Dev Tools Team  | mcp-integration  |
| **.github/workflows**  | GitHub Actions                | **CI/CD-Pipeline**: Automatisierte Tests, Builds, Deployments       | **aktiv**       | DevOps Lead     | multi-branch     |

---

## Sicherheit & Konfiguration

| Repository-Name | Plattform                  | Zweck                                                          | Status    | Verantwortliche | Encryption    |
| --------------- | -------------------------- | -------------------------------------------------------------- | --------- | --------------- | ------------- |
| **secrets/**    | Lokal (SOPS-verschlüsselt) | **Secret-Management**: Verschlüsselte Produktions-Secrets      | **aktiv** | DevSecOps       | SOPS + GPG    |
| **.vscode/**    | Workspace-Config           | **Entwicklungsumgebung**: VS Code-Konfiguration und MCP-Server | **aktiv** | Dev Tools Team  | lokale config |

---

## Dokumentations-Repositories

| Repository-Name      | Plattform                  | Zweck                                                               | Status    | Verantwortliche  | Format          |
| -------------------- | -------------------------- | ------------------------------------------------------------------- | --------- | ---------------- | --------------- |
| **docs/**            | Lokal (./docs/)            | **Projekt-Dokumentation**: Architecture, Setup-Guides, Runbooks     | **aktiv** | Technical Writer | Markdown        |
| **analysis/**        | Lokal (./analysis/)        | **Forensische Analyse**: Executive Summary, Risks, Backlog, Roadmap | **aktiv** | Project Manager  | JSON + Markdown |
| **quality-reports/** | Lokal (./quality-reports/) | **Quality-Metrics**: Code-Quality-Berichte und Performance-Daten    | **aktiv** | QA Lead          | Reports         |

---

## Repository-Beziehungen & Abhängigkeiten

### Mono-Repo-Struktur

Das Projekt verwendet eine **Mono-Repo-Architektur** mit NPM Workspaces:

```
menschlichkeit-oesterreich-development/
├── frontend/                    # React-Frontend-Workspace
├── website/                     # Legacy-Website-Workspace
├── api.menschlichkeit-oesterreich.at/     # FastAPI-Backend
├── crm.menschlichkeit-oesterreich.at/    # Drupal-CMS
├── figma-design-system/         # Design-System-Specs
├── deployment-scripts/          # Deployment-Automation
├── servers/                     # MCP-Development-Tools
├── docs/                        # Dokumentation
├── analysis/                    # Projekt-Analyse
└── .github/workflows/           # CI/CD-Pipeline
```

### Deployment-Workflow

1. **Entwicklung** → lokale Workspaces
2. **Integration** → GitHub Actions CI/CD
3. **Staging** → Plesk-Test-Environment
4. **Produktion** → Plesk-Live-Environment

### Branching-Strategy

- **main**: Produktions-ready Code
- **chore/ci-install-before-eslint**: Aktuelle Feature-Entwicklung
- **feature/\***: Feature-Branches per Component
- **hotfix/\***: Kritische Fixes

---

## Repository-Zugriffs-Matrix

| Team-Rolle          | Haupt-Repo | Frontend | Backend | CMS   | Deployment | Secrets |
| ------------------- | ---------- | -------- | ------- | ----- | ---------- | ------- |
| **Project Manager** | Admin      | Read     | Read    | Read  | Read       | Read    |
| **Frontend Lead**   | Write      | Admin    | Read    | Read  | Read       | None    |
| **Backend Lead**    | Write      | Read     | Admin   | Admin | Read       | Read    |
| **DevOps Lead**     | Write      | Read     | Read    | Write | Admin      | Admin   |
| **Security Lead**   | Write      | Write    | Write   | Write | Write      | Admin   |
| **UX/UI Lead**      | Read       | Write    | None    | Write | None       | None    |

---

## Repository-Maintenance-Zyklen

### Täglich

- **Dependency-Updates**: Automated Dependabot/Renovate
- **Security-Scans**: Codacy, npm audit, composer audit
- **Backup-Verification**: CMS und API-Datenbanken

### Wöchentlich

- **Code-Quality-Review**: PHPStan, ESLint, Lighthouse
- **Performance-Monitoring**: Core Web Vitals, API Response Times
- **Documentation-Updates**: README-Synchronisation

### Monatlich

- **Security-Audit**: Vollständige Vulnerability-Scans
- **Repository-Cleanup**: Archived Branches, Unused Dependencies
- **Access-Review**: Team-Berechtigungen und Secret-Rotation

---

## Notfall-Kontakte & Recovery

| Repository        | Primary Owner   | Backup Owner     | Recovery-Procedure                |
| ----------------- | --------------- | ---------------- | --------------------------------- |
| **Haupt-Repo**    | Project Manager | DevOps Lead      | GitHub Organization Recovery      |
| **CMS (Drupal)**  | Backend Lead    | DBA              | Database Point-in-Time Recovery   |
| **API (FastAPI)** | Backend Lead    | Senior Developer | Docker Container Rollback         |
| **Secrets**       | DevSecOps       | Security Lead    | SOPS Key Recovery + Re-encryption |

### Emergency-Recovery-Runbook

1. **Repository-Loss**: Fork from last-known-good backup
2. **Secret-Compromise**: Immediate key rotation + re-deployment
3. **CI/CD-Failure**: Manual deployment via deployment-scripts/
4. **Database-Corruption**: Point-in-Time Recovery von daily backups

---

## Compliance & Audit-Trail

### Git-Commit-Standards

- **Conventional Commits**: `feat:`, `fix:`, `chore:`, `security:`
- **Signed Commits**: GPG-Signatur für alle Production-Commits
- **Branch-Protection**: main-Branch protected, required PR-Reviews

### Audit-Requirements

- **Change-Tracking**: Alle Repository-Änderungen in Git-History
- **Access-Logging**: GitHub Audit-Log für Zugriffs-Tracking
- **Deployment-Trail**: Deployment-History in GitHub Actions

**Nächste Review**: 25. Oktober 2025 (Ende Phase 2: CMS Setup)

---

_Dieses Dokument wird bei jeder Projektphase aktualisiert und ist Teil der Projekt-Governance-Dokumentation._
