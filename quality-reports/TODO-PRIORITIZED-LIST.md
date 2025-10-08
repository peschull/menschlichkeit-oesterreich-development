# 🎯 PRIORISIERTE TODO-LISTE - Menschlichkeit Österreich

*Erstellt: 2025-10-07 | Status: Nach MCP-Server Reparatur*

## ⚡ SOFORT (heute - 2h)

### 1. MCP-Server Integration abschließen 🔧
**Status:** Lokal repariert, VS Code Neustart erforderlich  
**Aktion:** `Cmd/Ctrl + Shift + P → "Developer: Reload Window"`  
**Validierung:** Figma MCP & GitHub MCP in Copilot Chat testen  
**Dauer:** 15min

### 2. Branch Protection konfigurieren 🛡️
**Problem:** Git Push blockiert durch fehlende Signierung  
**Lösung:** GitHub Repository → Settings → Branches → Signed commits optional machen  
**Pfad:** `github.com/peschull/menschlichkeit-oesterreich-development/settings/branches`  
**Dauer:** 15min

### 3. Git-Signierung einrichten 🔑
```bash
git config --global user.signingkey [GPG-KEY-ID]
git config --global commit.gpgsign true
git commit --amend --no-edit -S
git push origin chore/figma-mcp-make
```
**Dauer:** 30min

## 🔴 DIESE WOCHE (10h)

### 4. CiviCRM Database initialisieren 💾
**Akzeptanzkriterien:** Drupal + CiviCRM funktionsfähig, Admin-Login  
**Kommandos:**
```bash
cd crm.menschlichkeit-oesterreich.at
./vendor/bin/drush site:install standard --db-url=mysql://svc_crm:$PASSWORD@localhost/mo_crm
./vendor/bin/drush civicrm:install
```
**Schätzung:** 3h | **Fällig:** 2025-10-12

### 5. API Authentication (JWT + Rate Limiting) 🔐
**Features:** Login/Refresh Endpoints, Signierte Tokens, 100 req/min Limit  
**Pfad:** `api.menschlichkeit-oesterreich.at/app/auth/`  
**Tests:** `pytest tests/test_auth_api.py`  
**Schätzung:** 4h | **Fällig:** 2025-10-12

### 6. GitHub Actions CI/CD Pipeline ⚙️
**Workflow:** `push main` → lint → test → build → deploy staging  
**Pfad:** `.github/workflows/deploy-staging.yml`  
**Trigger:** Automated auf main branch  
**Schätzung:** 2h | **Fällig:** 2025-10-12

### 7. Frontend Router (Protected Routes) 🛣️
**Features:** Auth-Guards, 404 Pages, Loading States, Breadcrumbs  
**Pfad:** `frontend/src/router.tsx`  
**Komponenten:** `ProtectedRoute`, `NotFound`, `LoadingSpinner`  
**Schätzung:** 3h | **Fällig:** 2025-10-12

## 🔒 NÄCHSTE WOCHE (16h) - Security Focus

### 8. DSGVO Compliance Implementation 📜
**Features:** Cookie Banner, Data Export (Art. 20), Deletion (Art. 17)  
**Komponenten:** ConsentManager, PrivacyDashboard, DataExportAPI  
**Compliance:** Österreichisches Recht, DSGVO-konform  
**Schätzung:** 6h | **Fällig:** 2025-10-19

### 9. Security Hardening 🛡️
**Features:** CSP Headers, Rate Limiting, Input Validation  
**Konfiguration:** `express-rate-limit`, `helmet`, `joi`  
**Tests:** Security-Tests mit Penetration Testing  
**Schätzung:** 6h | **Fällig:** 2025-10-19

### 10. Backup & Recovery Automation 💾
**Features:** Nightly Backups, Restore Testing, Monitoring  
**Cron:** `02:00 daily` mit Success/Failure Notifications  
**Scripts:** `./scripts/restore-test.sh`  
**Schätzung:** 4h | **Fällig:** 2025-10-19

## 🧾 NOVEMBER - CRM Automatisierung (32h)

### 11. CiviSEPA Setup & SEPA Export 💳
**Features:** Wöchentliche SEPA-XML, Nextcloud Upload, Mail an Buchhaltung  
**Integration:** CiviSEPA + n8n Workflows  
**Compliance:** Österreichische Bankstandards  
**Schätzung:** 6h | **Fällig:** 2025-11-09

### 12. Bankabgleich Automatisierung 🏦
**Features:** SFTP Download, CiviBank Import, Matching Report  
**Integration:** Bank-APIs + CiviCRM  
**Workflow:** n8n Automation  
**Schätzung:** 6h | **Fällig:** 2025-11-09

### 13. Intelligente Beitragslogik 🤖
**Features:** Altersbasierte Tarife, Statuswechsel, Kernel Tests  
**Module:** `mo_membership_rules` (Custom PHP)  
**Tests:** Unit Tests für Geschäftslogik  
**Schätzung:** 4h | **Fällig:** 2025-11-09

## 📊 ERFOLGSMESSUNG

### Quality Gates (müssen grün sein):
- ✅ **MCP Server:** 6/6 aktiv (100% Erfolgsrate)
- ⏳ **Tests:** Coverage ≥80% Backend, ≥70% Frontend  
- ⏳ **Performance:** Lighthouse ≥90, FCP <3s  
- ⏳ **Security:** 0 kritische Findings, CSP aktiv  
- ⏳ **DSGVO:** Vollständige Compliance-Dokumentation

### Milestones:
- **Woche 1:** Basis-Infrastruktur (CiviCRM, Auth, CI/CD)  
- **Woche 2:** Security & Compliance (DSGVO, Hardening)  
- **November:** CRM Automatisierung & Vereinsbuchhaltung  
- **Dezember:** Performance & Monitoring  

### Risiken & Abhängigkeiten:
- **Branch Protection:** Muss vor Git-Push konfiguriert werden  
- **Database Setup:** Erfordert MySQL/PostgreSQL Zugang  
- **SEPA Integration:** Benötigt Bankverbindung & Mandatsdaten  
- **n8n Workflows:** Abhängig von externen APIs (Bank, Nextcloud)

---

**Nächste Aktion:** VS Code neustarten → MCP testen → Branch Protection konfigurieren → CiviCRM Setup beginnen