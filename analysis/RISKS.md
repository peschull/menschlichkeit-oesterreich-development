# Risikoinventur: Menschlichkeit Österreich Website-Projekt

## Systematische Risikoanalyse nach akademischen Standards

| Risiko-ID                           | Risiko                                | Ursache                             | Auswirkung                               | Eintritt (1-5) | Schaden (1-5) | Risikostufe       | Gegenmaßnahme                           | Owner         | Evidence                            |
| ----------------------------------- | ------------------------------------- | ----------------------------------- | ---------------------------------------- | -------------- | ------------- | ----------------- | --------------------------------------- | ------------- | ----------------------------------- |
| **SICHERHEITSRISIKEN**              |                                       |                                     |                                          |                |               |                   |                                         |               |                                     |
| R-001                               | Veraltete Dependencies                | NPM/Composer Packages nicht aktuell | Security Vulnerabilities, Exploits       | **4**          | **5**         | **KRITISCH (20)** | Automated Dependency Updates, SCA-Tools | Security Lead | package.json, composer.json         |
| R-002                               | Secret-Exposure                       | Hardcoded Secrets, .env in Git      | API-Keys kompromittiert, Data-Breach     | **3**          | **5**         | **HOCH (15)**     | SOPS Implementation, Secret Scanning    | DevSecOps     | .sops.yaml, secrets/                |
| R-003                               | Fehlende Content Security Policy      | Keine CSP-Header konfiguriert       | XSS-Attacks, Code-Injection              | **4**          | **4**         | **HOCH (16)**     | CSP-Header in Plesk/Nginx               | Security Lead | servers/SECURITY-HEADERS-WEBSITE.md |
| R-004                               | SQL-Injection in CiviCRM              | Unvalidierte User-Inputs            | Database-Compromise                      | **2**          | **5**         | **HOCH (10)**     | Input Validation, Prepared Statements   | Backend Dev   | crm.../composer.json                |
| R-005                               | Container-Sicherheitslücken           | Veraltete Docker-Base-Images        | Container-Compromise                     | **3**          | **4**         | **MITTEL (12)**   | Security Hardening, Image Scanning      | DevOps        | docker-compose.yml                  |
| **COMPLIANCE & RECHTLICHE RISIKEN** |                                       |                                     |                                          |                |               |                   |                                         |               |                                     |
| R-006                               | DSGVO-Verstoß                         | Kein Consent-Management             | Bußgelder bis 4% Jahresumsatz            | **5**          | **4**         | **KRITISCH (20)** | Cookie-Banner, Privacy-Policy           | Legal/PM      | Fehlt: Cookie-Consent-Tool          |
| R-007                               | Fehlende Barrierefreiheit             | WCAG 2.2 nicht eingehalten          | Diskriminierung, rechtliche Konsequenzen | **4**          | **3**         | **MITTEL (12)**   | WCAG-Audit, Accessibility-Tests         | UX Lead       | web/themes/custom/menschlichkeit/   |
| R-008                               | Lizenz-Compliance-Verletzung          | Unklare Open-Source-Lizenzen        | Urheberrechtsverletzung                  | **2**          | **3**         | **NIEDRIG (6)**   | License-Compliance-Scan                 | Legal         | package.json, composer.json         |
| **TECHNISCHE BETRIEBSRISIKEN**      |                                       |                                     |                                          |                |               |                   |                                         |               |                                     |
| R-009                               | Single Point of Failure Hosting       | Monolithisches Plesk-Hosting        | Kompletter Service-Ausfall               | **3**          | **4**         | **MITTEL (12)**   | Multi-Region-Setup, Redundanz           | DevOps        | deployment-scripts/                 |
| R-010                               | Fehlende Database-Backups             | Kein automatisches Backup-System    | Datenverlust bei Hardware-Failure        | **2**          | **5**         | **HOCH (10)**     | Automated Database Backups              | DBA           | scripts/db-pull.sh                  |
| R-011                               | Performance-Degradation               | Ungünstige Bildgrößen, Bundle-Size  | UX-Defizite, SEO-Ranking-Verlust         | **4**          | **3**         | **MITTEL (12)**   | Image-Optimization, Code-Splitting      | Frontend Dev  | frontend/lighthouse.config.cjs      |
| R-012                               | CI/CD-Pipeline-Failure                | Deployment-Scripts nicht idempotent | Failed Deployments, Downtime             | **3**          | **3**         | **MITTEL (9)**    | Idempotente Scripts, Rollback-Strategy  | DevOps        | .github/workflows/                  |
| **ORGANISATORISCHE RISIKEN**        |                                       |                                     |                                          |                |               |                   |                                         |               |                                     |
| R-013                               | Unklare Rollen & Verantwortlichkeiten | Keine RACI-Matrix                   | Verzögerungen, Duplicate Work            | **4**          | **2**         | **MITTEL (8)**    | RACI-Matrix erstellen                   | PM            | Fehlt: Projektorganisation          |
| R-014                               | Fehlende Dokumentation                | Unvollständige Setup-Guides         | Onboarding-Verzögerungen                 | **3**          | **2**         | **NIEDRIG (6)**   | Documentation-First-Policy              | Tech Writer   | README.md, docs/                    |
| R-015                               | Inadequate Testing Coverage           | Keine automatischen Tests           | Go-Live-Bugs, Quality-Issues             | **4**          | **3**         | **MITTEL (12)**   | Test-Strategy, CI/CD Test-Suites        | QA Lead       | Fehlt: Test-Framework               |
| **BUSINESS-KONTINUITÄTS-RISIKEN**   |                                       |                                     |                                          |                |               |                   |                                         |               |                                     |
| R-016                               | Vendor-Lock-in Plesk                  | Abhängigkeit von Plesk-Provider     | Migration-Schwierigkeiten                | **2**          | **3**         | **NIEDRIG (6)**   | Multi-Cloud-Strategy                    | CTO           | Plesk-Konfiguration                 |
| R-017                               | API-Rate-Limiting                     | Keine Rate-Limiting in FastAPI      | DDoS-Vulnerability, Service-Denial       | **3**          | **3**         | **MITTEL (9)**    | Rate-Limiting, API-Gateway              | Backend Dev   | api.../app/                         |
| R-018                               | Monitoring-Gaps                       | Kein Real-Time-Monitoring           | Fehlerdetektion zu spät                  | **3**          | **2**         | **NIEDRIG (6)**   | APM-Integration (Sentry, Grafana)       | Ops           | Fehlt: Monitoring-Stack             |

## Risiko-Matrix (Quantitative Bewertung)

### Risikostufen-Klassifikation

- **KRITISCH (16-25)**: Sofortiger Handlungsbedarf
- **HOCH (10-15)**: Prioritäre Behandlung innerhalb 1 Woche
- **MITTEL (6-11)**: Behandlung innerhalb 1 Monat
- **NIEDRIG (1-5)**: Behandlung innerhalb 3 Monaten

### Verteilung nach Risikostufe

- **KRITISCH**: 2 Risiken (R-001, R-006)
- **HOCH**: 3 Risiken (R-002, R-003, R-010)
- **MITTEL**: 8 Risiken (R-005, R-007, R-009, R-011, R-012, R-013, R-015, R-017)
- **NIEDRIG**: 5 Risiken (R-008, R-014, R-016, R-018)

### Risiko-Kategorien-Verteilung

- **Sicherheit**: 5 Risiken (28%)
- **Compliance**: 3 Risiken (17%)
- **Technisch**: 6 Risiken (33%)
- **Organisatorisch**: 3 Risiken (17%)
- **Business-Kontinuität**: 1 Risiko (5%)

## Sofortmaßnahmen (KRITISCHE Risiken)

### R-001: Dependency-Security-Audit

```bash
# NPM Security Audit
npm audit --audit-level critical
npm update

# Composer Security Check
composer audit
composer update --with-all-dependencies

# Python Security Check
pip-audit -r api.menschlichkeit-oesterreich.at/requirements.txt
```

### R-006: DSGVO-Compliance-Implementation

1. **Cookie-Consent-Tool**: Integration von CookieBot oder ähnlichem
2. **Privacy-Policy**: Rechtskonforme Datenschutzerklärung
3. **Data-Processing-Audit**: Mapping aller Datenflüsse
4. **User-Rights-Implementation**: DSGVO-Auskunfts-/Löschrechte
