# Multi-Service Deployment Guide

## 🚀 Deployment-Workflow für Menschlichkeit Österreich Platform

### Übersicht

Die Austrian NGO Platform besteht aus 6 Services, die koordiniert deployed werden:

1. **Database** (PostgreSQL mit Prisma)
2. **API Backend** (FastAPI/Python)
3. **CRM System** (Drupal 10 + CiviCRM)
4. **Frontend** (React/TypeScript)
5. **Gaming Platform** (Educational Games)
6. **Website** (WordPress)
7. **n8n Automation** (Workflow Engine)

### 📋 Pre-Deployment Checklist

#### 1. Deployment Readiness prüfen

```bash
npm run deploy:readiness
```

Dieser Command prüft:

- ✅ Git Repository Status (clean, synced)
- ✅ Quality Gates (Codacy, ESLint, PHPStan)
- ✅ Security Scans (Trivy, Gitleaks, npm audit)
- ✅ DSGVO Compliance (PII-Check, Consent)
- ✅ Performance Benchmarks (Lighthouse ≥90)
- ✅ Database Migrations
- ✅ Environment Konfiguration
- ✅ Service Dependencies

**Erwartetes Ergebnis:**

```text
✓ DEPLOYMENT READY
  Passed: 42
  Warnings: 3
  Failed: 0
```

#### 2. Quality Gates sicherstellen

```bash
npm run quality:gates
```

Alle Gates müssen **GRÜN** sein:

- Security: 0 vulnerabilities
- Maintainability: ≥85%
- Test Coverage: ≥80%
- Performance: Lighthouse ≥90
- Accessibility: WCAG AA compliance

### 🔄 Deployment-Strategien

#### Option A: Multi-Service Deployment (Standard)

**Für:** Staging und reguläre Production Deployments

```bash
# Staging Deployment
npm run deploy:staging

# Production Deployment (nach Staging-Validierung)
npm run deploy:production
```

**Was passiert:**

1. Pre-Deployment Validation (Quality Gates + Security)
2. Automatische Backups (DB, Config, Code)
3. Database Migrations (Prisma)
4. Service-Builds (API, Frontend, Games)
5. Sequentielles Deployment (Dependency-Order)
6. Health Checks für alle Services
7. Smoke Tests (Playwright E2E)
8. Deployment Report Generation

**Deployment-Reihenfolge:**

```text
DB Migrations → API → CRM → Frontend → Gaming → Website → n8n
```

**Dauer:** ~15-20 Minuten
**Downtime:** Minimal (pro Service ~30s)

#### Option B: Blue-Green Deployment (Zero-Downtime)

**Für:** Kritische Production Updates ohne Ausfallzeit

```bash
npm run deploy:blue-green
```

**Was passiert:**

1. Deploy neue Version zu "GREEN" (inactive)
2. Smoke Tests auf GREEN
3. Nginx Traffic Shifting:
   - 10% zu GREEN (Canary) → 5min Monitoring
   - 50% zu GREEN → 10min Monitoring
   - 100% zu GREEN (Full Rollout)
4. BLUE wird Standby/Rollback-Option

**Dauer:** ~30-40 Minuten (inkl. Monitoring-Phasen)
**Downtime:** 0 Sekunden

**Rollback:** Instant (100% zurück zu BLUE)

### 📊 Post-Deployment Monitoring

#### Automatisches Monitoring starten

```bash
npm run deploy:monitor
```

**Monitored:**

- Service Health Checks (alle 30s)
- System Resources (CPU, Memory, Disk)
- Database Connection Pool
- Error Rates & Response Times
- Performance Metrics (Lighthouse)

**Alerts via n8n Webhook bei:**

- Error Rate > 1%
- Response Time > 500ms
- CPU > 80%
- Memory > 85%
- Disk > 90%

**Monitoring-Dauer:** 1 Stunde (konfigurierbar)

**Output:**

- Real-time Console Logs
- JSON Metrics: `quality-reports/deployment-metrics/*.json`
- Monitoring Report: `quality-reports/monitoring-report-*.md`

### 🔙 Rollback-Prozedur

#### Automatischer Rollback

Rollback wird **automatisch** getriggert bei:

- Health Check Failures (nach Deployment)
- Error Rate > 5%
- Critical Security Alert
- Database Corruption

#### Manueller Rollback

```bash
# Rollback zur vorherigen Version
npm run deploy:rollback

# Rollback zu spezifischer Version
npm run deploy:rollback -- v2.1.0
```

**Rollback-Schritte:**

1. Pre-Rollback Backup (current state)
2. Database Restore
3. API Backend Rollback
4. CRM System Rollback
5. Frontend Rollback
6. Gaming Platform Rollback
7. Website Rollback
8. n8n Workflows Rollback
9. Nginx Config Rollback
10. Post-Rollback Validation

**Rollback-SLA:** < 5 Minuten

**Rollback Report:** `quality-reports/rollback-*.log`

### 📝 Deployment-Szenarien

#### Szenario 1: Hotfix Deployment

**Situation:** Kritischer Bug in Production

```bash
# 1. Hotfix-Branch erstellen
git checkout -b hotfix/critical-bug-fix

# 2. Fix implementieren & testen
npm run test:all
npm run quality:gates

# 3. Fast-Track Deployment
npm run deploy:blue-green  # Zero-Downtime

# 4. Monitoring
npm run deploy:monitor 300  # 5 Minuten intensive Überwachung
```

#### Szenario 2: Feature Release

**Situation:** Geplantes Feature-Release mit neuen Funktionen

```bash
# 1. Pre-Deployment Checks
npm run deploy:readiness

# 2. Staging Deployment
npm run deploy:staging

# 3. Staging Tests & Validation
npm run test:e2e --env=staging
# Manual QA Testing...

# 4. Production Deployment
npm run deploy:production

# 5. 24h Monitoring
npm run deploy:monitor 86400  # 24 Stunden
```

#### Szenario 3: Database Migration

**Situation:** Schema-Änderungen (neue Tabellen/Felder)

```bash
# 1. Prisma Migration erstellen
npx prisma migrate dev --name add_email_verification

# 2. Migration testen (lokal)
npx prisma migrate deploy --preview-feature

# 3. Backup erstellen (automatisch in Deployment)
# 4. Deployment mit Migration
npm run deploy:production

# 5. Migration validieren
npx prisma studio  # GUI für DB-Inspektion
```

#### Szenario 4: Rollback-Szenario

**Situation:** Deployment zeigt kritische Probleme

```bash
# Option A: Automatisch (bei Health Check Failure)
# → Rollback startet automatisch

# Option B: Manuell getriggert
npm run deploy:rollback

# Post-Rollback
# 1. Root Cause Analysis
# 2. Fix im Dev/Staging
# 3. Re-Deployment nach Validierung
```

### 🔐 Security & Compliance

#### Pre-Deployment Security Checks

```bash
# Vollständiger Security Scan
npm run security:scan

# Einzelne Scans
npm run security:trivy       # Container/Dependencies
gitleaks detect              # Secrets Scanning
npm audit --audit-level=high # npm Vulnerabilities
```

#### DSGVO Compliance

```bash
# DSGVO-Check
npm run compliance:dsgvo
```

**Prüft:**

- PII in Logs
- Consent-Management
- Data Retention Policies
- Privacy Policy Aktualität
- Cookie Consent Implementation

#### Credential Management

**NIEMALS committen:**

- `.env` Dateien
- API Keys/Tokens
- Database Credentials
- SSL Private Keys

**Best Practices:**

- GitHub Secrets für CI/CD
- PowerShell Decrypt: `scripts/secrets-decrypt.ps1`
- Secrets Rotation alle 90 Tage

### 📈 Performance Optimierung

#### Lighthouse Audit

```bash
npm run performance:lighthouse
```

**Erwartete Scores:**

- Performance: ≥90
- Accessibility: ≥90
- Best Practices: ≥95
- SEO: ≥90

#### Bundle-Size Check

```bash
npm run build:frontend
du -sh frontend/dist/  # Target: < 200KB
```

### 🛠️ Troubleshooting

#### Problem: Deployment schlägt fehl bei Quality Gates

**Lösung:**

```bash
# 1. Details anzeigen
npm run quality:gates

# 2. Codacy Analyse
npm run quality:codacy

# 3. Spezifische Issues fixen
npm run lint:all
npm run format:all

# 4. Re-validieren
npm run deploy:readiness
```

#### Problem: Health Check schlägt fehl nach Deployment

**Lösung:**

```bash
# 1. Service Logs prüfen
docker logs api-container
journalctl -u api-fastapi -n 100

# 2. Manueller Health Check
curl https://api.menschlichkeit-oesterreich.at/health

# 3. Rollback wenn kritisch
npm run deploy:rollback

# 4. Root Cause in Staging reproduzieren
npm run deploy:staging
```

#### Problem: Database Migration schlägt fehl

**Lösung:**

```bash
# 1. Migration Status prüfen
npx prisma migrate status

# 2. Problematische Migration identifizieren
cat prisma/migrations/*/migration.sql

# 3. Rollback Migration
npx prisma migrate resolve --rolled-back <MIGRATION_NAME>

# 4. Database wiederherstellen
pg_restore -d dbname backups/latest-backup.dump

# 5. Migration korrigieren & neu deployen
```

### 📚 Deployment-Artefakte

#### Generierte Reports

Nach jedem Deployment:

```text
quality-reports/
├── deployment-{VERSION}.md          # Deployment Summary
├── deployment-metrics/*.json        # Performance Metrics
├── monitoring-report-{DATE}.md      # Monitoring Results
├── rollback-{TIMESTAMP}.log         # Rollback Logs (falls notwendig)
└── lighthouse-{TIMESTAMP}.json      # Performance Audit
```

#### Backups

Automatische Backups bei jedem Deployment:

```text
backups/
├── deployment-{TIMESTAMP}/
│   ├── database-backup.dump         # PostgreSQL Dump
│   ├── api-env.bak                  # API .env
│   ├── crm-settings.php.bak         # CRM Config
│   └── config-templates-backup/     # Alle Config-Templates
```

**Backup-Retention:** 30 Tage (konfigurierbar)

### 🔔 Notification & Alerting

#### n8n Webhook Integration

Automatische Benachrichtigungen via n8n:

**Deployment Start:**

```json
POST https://n8n.menschlichkeit-oesterreich.at/webhook/deployment-start
{
  "version": "v2.3.0",
  "environment": "production",
  "timestamp": "2025-10-06T18:00:00Z"
}
```

**Deployment Success:**

```json
POST https://n8n.menschlichkeit-oesterreich.at/webhook/deployment-success
{
  "version": "v2.3.0",
  "duration": "18m 32s",
  "services": ["api", "crm", "frontend", "gaming", "website", "n8n"],
  "health": "all_healthy"
}
```

**Deployment Failure:**

```json
POST https://n8n.menschlichkeit-oesterreich.at/webhook/deployment-failure
{
  "version": "v2.3.0",
  "error": "Health check failed: API",
  "rollback_triggered": true
}
```

**Monitoring Alerts:**

```json
POST https://n8n.menschlichkeit-oesterreich.at/webhook/deployment-alert
{
  "service": "api",
  "severity": "critical",
  "message": "High error rate: 5.2%"
}
```

### 🎯 Best Practices

#### ✅ DO

1. **Immer Readiness Check zuerst**

   ```bash
   npm run deploy:readiness
   ```

2. **Staging vor Production**

   ```bash
   npm run deploy:staging
   # Tests & Validation...
   npm run deploy:production
   ```

3. **Monitoring nach Deployment**

   ```bash
   npm run deploy:monitor
   ```

4. **Backups validieren**

   ```bash
   ls -lh backups/deployment-*/
   ```

5. **Quality Gates respektieren**
   - Keine Deployments bei failed gates
   - Security Issues zuerst fixen

#### ❌ DON'T

1. **Keine Manual File-Edits auf Production**
   - Immer via Git → CI/CD

2. **Keine Database-Queries direkt auf Production**
   - Nur via Migrations

3. **Keine .env Files in Git**
   - GitHub Secrets verwenden

4. **Keine Quality Gates überspringen**
   - Auch nicht für "Quick Fixes"

5. **Kein Deployment ohne Backup**
   - Automatisch inkludiert, aber verifizieren

### 📞 Support & Eskalation

#### Bei Deployment-Problemen

1. **Self-Service:** Deployment-Logs prüfen
2. **Automated Rollback:** Läuft automatisch bei Failures
3. **Manual Intervention:** `npm run deploy:rollback`
4. **Team-Eskalation:** GitHub Issue mit Label `deployment-issue`
5. **Emergency Contact:** Via n8n Alert-Workflow

---

**Dokumentation erstellt:** 2025-10-06
**Letzte Aktualisierung:** Siehe Git History
**Verantwortlich:** DevOps Team Menschlichkeit Österreich
