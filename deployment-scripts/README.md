# 🚀 Deployment System - Menschlichkeit Österreich

Vollständiges Multi-Service Deployment-System mit Quality Gates, Monitoring und automatischem Rollback.

---

## 📋 Inhaltsverzeichnis

1. [Quick Start](#-quick-start)
2. [System-Übersicht](#-system-übersicht)
3. [Deployment Scripts](#-deployment-scripts)
4. [NPM Commands](#-npm-commands)
5. [Quality Gates](#-quality-gates)
6. [Monitoring & Alerting](#-monitoring--alerting)
7. [Rollback Procedures](#-rollback-procedures)
8. [Troubleshooting](#-troubleshooting)

---

## 🚀 Quick Start

### Erstmaliges Setup

```bash
# 1. Environment konfigurieren
npm run deploy:setup-env

# 2. Konfiguration prüfen
cat .env.deployment

# 3. Deployment-Readiness prüfen
npm run deploy:readiness

# 4. Dashboard starten (empfohlen)
npm run deploy:dashboard
```

### Standard Deployment

```bash
# Staging Deployment
npm run deploy:staging

# Production Deployment (nach Validierung)
npm run deploy:production
```

### Zero-Downtime Deployment

```bash
# Blue-Green Deployment
npm run deploy:blue-green
```

---

## 🏗️ System-Übersicht

### Architektur

```
┌─────────────────────────────────────────────────────────┐
│                  DEPLOYMENT PIPELINE                     │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  1. Pre-Deployment Validation (9 Quality Gates)         │
│     ├── Git Status                                      │
│     ├── Code Quality (Codacy, ESLint, PHPStan)         │
│     ├── Security Scan (Trivy, Gitleaks)                │
│     ├── DSGVO Compliance                                │
│     ├── Performance (Lighthouse)                        │
│     ├── Database (Migrations, Backup)                   │
│     ├── Environment Configuration                       │
│     ├── Dependencies                                    │
│     └── CI/CD Status                                    │
│                                                          │
│  2. Backup Creation                                     │
│     ├── Database Backup (pg_dump)                       │
│     └── Configuration Backup                            │
│                                                          │
│  3. Database Migrations                                 │
│     └── Prisma migrate deploy                           │
│                                                          │
│  4. Service Build                                       │
│     ├── API (FastAPI)                                   │
│     ├── Frontend (React/TypeScript)                     │
│     └── Gaming Platform                                 │
│                                                          │
│  5. Sequential Deployment                               │
│     ├── Database                                        │
│     ├── API Backend                                     │
│     ├── CRM System (Drupal + CiviCRM)                   │
│     ├── Frontend                                        │
│     ├── Gaming Platform                                 │
│     ├── Website (WordPress)                             │
│     └── n8n Automation                                  │
│                                                          │
│  6. Smoke Tests                                         │
│     ├── API Health Checks                               │
│     ├── CRM Accessibility                               │
│     ├── Frontend Loading                                │
│     ├── Database Connectivity                           │
│     └── Security Headers                                │
│                                                          │
│  7. Post-Deployment Monitoring                          │
│     ├── Service Health (every 30s)                      │
│     ├── System Resources (CPU, Memory, Disk)            │
│     ├── Error Rate Tracking                             │
│     ├── Response Time Measurement                       │
│     └── Performance Metrics (Lighthouse)                │
│                                                          │
│  8. Alerting (on issues)                                │
│     ├── n8n Webhook                                     │
│     ├── Slack Notification (optional)                   │
│     └── Email Alerts                                    │
│                                                          │
│  9. Automatic Rollback (on critical failure)            │
│     └── < 5 Minuten SLA                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Service Dependencies

```
Database (PostgreSQL)
    ↓
API Backend (FastAPI)
    ↓
CRM System (Drupal + CiviCRM) ←→ API
    ↓
Frontend (React) ←→ API
    ↓
Gaming Platform ←→ API
    ↓
Website (WordPress)
    ↓
n8n Automation ←→ All Services
```

---

## 📜 Deployment Scripts

### Core Scripts

| Script | Beschreibung | Zeilen |
|--------|--------------|--------|
| **deployment-dashboard.sh** | Interaktives Terminal-Dashboard | 388 |
| **deployment-readiness.sh** | Pre-Deployment Quality Gates | 484 |
| **multi-service-deploy.sh** | Multi-Service Orchestration | 426 |
| **blue-green-deploy.sh** | Zero-Downtime Deployment | 306 |
| **deployment-monitoring.sh** | Real-Time Monitoring | 418 |
| **rollback.sh** | Automated Rollback | 423 |
| **smoke-tests.sh** | Post-Deployment Validation | 365 |

### Utility Scripts

| Script | Beschreibung | Zeilen |
|--------|--------------|--------|
| **deployment-config.sh** | Zentrale Konfiguration | 186 |
| **health-check-utils.sh** | Wiederverwendbare Health Checks | 261 |
| **setup-environment.sh** | Interaktives Environment Setup | 303 |

### Legacy Scripts

| Script | Beschreibung | Zeilen |
|--------|--------------|--------|
| **deploy-api-plesk.sh** | API Plesk Deployment | 395 |
| **deploy-crm-plesk.sh** | CRM Plesk Deployment | 303 |
| **setup-cron-jobs.sh** | Cron Job Setup | 355 |

**Gesamt:** 4.613 Zeilen Bash-Code

---

## 💻 NPM Commands

### Deployment

```bash
npm run deploy:dashboard        # 🎨 Interaktives Dashboard starten
npm run deploy:readiness        # ✅ Quality Gates prüfen
npm run deploy:staging          # 🚀 Deploy to Staging
npm run deploy:production       # 🚀 Deploy to Production
npm run deploy:blue-green       # 🔄 Zero-Downtime Deployment
```

### Monitoring & Testing

```bash
npm run deploy:monitor          # 📊 Post-Deployment Monitoring
npm run deploy:smoke-tests      # 🧪 Smoke Tests ausführen
npm run deploy:health-check     # ❤️ Service Health Check
```

### Emergency

```bash
npm run deploy:rollback         # 🔙 Rollback zur vorherigen Version
npm run deploy:rollback -- v2.1.0  # 🔙 Rollback zu spezifischer Version
```

### Setup

```bash
npm run deploy:setup-env        # 🔧 Environment konfigurieren
```

---

## 🛡️ Quality Gates

### 9 Kategorien von Checks

#### 1. Git Status

- ✅ Clean working directory
- ✅ Korrekter Branch (main für Production)
- ✅ Remote synchronized

#### 2. Code Quality

- ✅ Codacy: Maintainability ≥ 85%
- ✅ ESLint: 0 errors
- ✅ PHPStan: Level 6 passed
- ✅ Duplication ≤ 2%

#### 3. Security

- ✅ Trivy: 0 high/critical CVEs
- ✅ Gitleaks: 0 secrets exposed
- ✅ npm audit: 0 vulnerabilities
- ✅ Max CVE Score: 7.0

#### 4. DSGVO Compliance

- ✅ Keine PII in Logs
- ✅ Cookie Consent implementiert
- ✅ Privacy Policy aktuell (< 90 Tage)
- ✅ Data Retention konfiguriert

#### 5. Performance

- ✅ Lighthouse Performance ≥ 90
- ✅ Lighthouse Accessibility ≥ 90
- ✅ Lighthouse Best Practices ≥ 95
- ✅ Lighthouse SEO ≥ 90

#### 6. Database

- ✅ Migrations applied
- ✅ Connection successful
- ✅ Backup vorhanden (< 24h)

#### 7. Environment

- ✅ Config files present
- ✅ Node version correct
- ✅ Environment variables set

#### 8. Dependencies

- ✅ Docker verfügbar
- ✅ PostgreSQL erreichbar
- ✅ PHP installiert
- ✅ Python verfügbar

#### 9. CI/CD

- ✅ GitHub Actions passing
- ✅ Deployment scripts present

### Quality Gate Commands

```bash
# Alle Gates prüfen
npm run deploy:readiness

# Einzelne Checks
npm run quality:gates       # Code Quality
npm run security:scan       # Security
npm run performance:lighthouse  # Performance
npm run compliance:dsgvo    # DSGVO
```

---

## 📊 Monitoring & Alerting

### Real-Time Monitoring

```bash
# Standard (1 Stunde)
npm run deploy:monitor

# Custom Duration (2 Stunden)
npm run deploy:monitor -- 7200
```

### Überwachte Metriken

| Kategorie | Metric | Threshold | Action |
|-----------|--------|-----------|--------|
| **Service Health** | HTTP Status | 200 OK | Alert on failure |
| **Error Rate** | Errors/Requests | > 1% | Alert + Auto-rollback |
| **Response Time** | API latency | > 0.5s (500 ms) | Warning |
| **CPU** | Usage | > 80% | Alert |
| **Memory** | Usage | > 85% | Alert |
| **Disk** | Usage | > 90% | Alert |
| **Database** | Connection Pool | Exhausted | Alert |
| **Performance** | Lighthouse | < 90 | Warning |

### Alert Channels

1. **n8n Webhook** (primary)
   - Real-time alerts
   - Workflow automation

2. **Slack** (optional)
   - Team notifications
   - Deployment announcements

3. **Email** (fallback)
   - Critical alerts
   - Daily reports

### Monitoring Reports

**Automatisch generiert:**

- `quality-reports/deployment-metrics/monitoring-<timestamp>.ndjson`
- `quality-reports/deployment-metrics/lighthouse-<timestamp>.json` (falls Lighthouse aktiv)
- `quality-reports/deployment-metrics/monitoring-report-<YYYYMMDD>.md`

**Inhalt:**

- Service health status
- System resource usage
- Error rate per service
- Response time trends
- Deployment timeline

---

## 🔙 Rollback Procedures

### Automatic Rollback

**Trigger:** Critical deployment failures

- Quality gates failed
- Smoke tests failed
- Error rate > threshold
- Service unavailable

**SLA:** < 5 Minuten

### Manual Rollback

```bash
# Zur vorherigen Version
npm run deploy:rollback

# Zu spezifischer Version
npm run deploy:rollback -- v2.1.0
```

### 10-Step Recovery Process

1. **Pre-Rollback Validation**
   - Backup verification
   - Version check

2. **Database Rollback**
   - `pg_restore` from backup
   - Pre-rollback backup creation

3. **API Rollback**
   - Docker container or Git-based

4. **CRM Rollback**
   - Drupal + CiviCRM restore

5. **Frontend Rollback**
   - Git checkout + rebuild

6. **Gaming Platform Rollback**
   - Version restore

7. **Website Rollback**
   - WordPress DB + code

8. **n8n Rollback**
   - Workflow restoration

9. **Nginx Config Restore**
   - Configuration rollback

10. **Post-Rollback Validation**
    - Health checks
    - Smoke tests

### Rollback Report

Automatisch generiert nach jedem Rollback:

- Rollback reason
- Steps executed
- Duration
- Validation results
- Next steps

---

## 🧪 Smoke Tests

### Automatisch nach Deployment

**API Tests:**

- Health endpoint
- Version endpoint
- Database connection
- Response time

**CRM Tests:**

- Home page accessible
- Login page loads
- CiviCRM available

**Frontend Tests:**

- Home page loads
- Static assets
- Meta tags
- Load time

**Database Tests:**

- Connection
- Migrations applied
- Critical tables exist

**Security Tests:**

- HTTPS redirect
- Security headers
- No sensitive data exposed

### Manual Execution

```bash
npm run deploy:smoke-tests
npm run deploy:smoke-tests -- staging
```

---

## 🔧 Troubleshooting

### Deployment hängt

**Problem:** Deployment-Script reagiert nicht

**Lösung:**

```bash
# 1. Ctrl+C (triggert automatischen Rollback)
# 2. Logs prüfen
tail -f quality-reports/deployment-logs/deployment-$(date +%Y%m%d).log

# 3. Manueller Rollback falls nötig
npm run deploy:rollback
```

### Quality Gates failing

**Problem:** Pre-Deployment Validation schlägt fehl

**Lösung:**

```bash
# 1. Detaillierte Analyse
npm run deploy:readiness

# 2. Einzelne Gates debuggen
npm run quality:gates      # Code Quality Details
npm run security:scan      # Security Issues
npm run test:e2e          # Test Failures

# 3. Issues fixen
# 4. Erneut validieren
npm run deploy:readiness
```

### Services nicht erreichbar

**Problem:** Nach Deployment sind Services down

**Lösung:**

```bash
# 1. Dashboard öffnen
npm run deploy:dashboard

# 2. Service-spezifische Logs
docker logs api-service
docker logs crm-service

# 3. Health Check
npm run deploy:health-check

# 4. Falls kritisch: Rollback
npm run deploy:rollback
```

### Rollback schlägt fehl

**Problem:** Automatischer Rollback funktioniert nicht

**Lösung:**

```bash
# 1. Manueller Rollback mit Version
npm run deploy:rollback -- v2.1.0

# 2. Falls Script fehlschlägt: Manuelle Steps
# a) Database
pg_restore -d $DATABASE_URL /var/backups/postgresql/backup.sql

# b) Services
git checkout v2.1.0
npm run build:all

# c) Health Check
npm run deploy:health-check
```

### n8n Webhook nicht erreichbar

**Problem:** Alerts werden nicht gesendet

**Lösung:**

```bash
# 1. n8n Status prüfen
docker ps | grep n8n

# 2. n8n starten falls nicht laufend
npm run n8n:start

# 3. Webhook-URL testen
curl -X POST "$N8N_ALERT_WEBHOOK" \
  -H "Content-Type: application/json" \
  -d '{"test": "alert"}'

# 4. Falls URL falsch: Environment aktualisieren
nano .env.deployment
# N8N_ALERT_WEBHOOK ändern
```

### Database Connection Timeout

**Problem:** Deployment schlägt fehl wegen DB-Timeout

**Lösung:**

```bash
# 1. Connection String prüfen
echo $DATABASE_URL

# 2. PostgreSQL Status
sudo systemctl status postgresql

# 3. Connection Test
psql "$DATABASE_URL" -c "SELECT 1;"

# 4. Firewall/Network
# Falls remote DB:
ping your-db-host
telnet your-db-host 5432

# 5. Connection Pool
# Erhöhe in .env.deployment:
DB_CONNECTION_POOL_SIZE=50
```

### Insufficient Disk Space

**Problem:** Deployment schlägt fehl wegen Speicherplatz

**Lösung:**

```bash
# 1. Speicherplatz prüfen
df -h

# 2. Alte Backups löschen
find /var/backups/postgresql -type f -mtime +30 -delete

# 3. Docker cleanup
docker system prune -a --volumes

# 4. Logs rotieren
find quality-reports/ -type f -mtime +7 -delete

# 5. npm cache
npm cache clean --force
```

---

## 📚 Weitere Dokumentation

- **[DEPLOYMENT-GUIDE.md](../docs/DEPLOYMENT-GUIDE.md)** - Vollständige Anleitung
- **[DEPLOYMENT-QUICKREF.md](../docs/DEPLOYMENT-QUICKREF.md)** - Quick Reference
- **[DEPLOYMENT-COMPLETE.md](../docs/DEPLOYMENT-COMPLETE.md)** - Success Report

---

## 🎯 Best Practices

### DOs ✅

- **IMMER** `npm run deploy:readiness` vor Deployment ausführen
- **IMMER** Staging vor Production deployen
- **IMMER** Monitoring nach Deployment aktivieren
- **IMMER** Backups vor kritischen Änderungen erstellen
- **IMMER** auf `main` Branch für Production-Deployments
- **IMMER** Git-Tags für Releases verwenden
- **IMMER** n8n Alerts aktiviert haben

### DON'Ts ❌

- **NIEMALS** Quality Gates skippen
- **NIEMALS** direkt zu Production ohne Staging-Test
- **NIEMALS** Secrets in Git committen
- **NIEMALS** Force-Push auf `main`
- **NIEMALS** Deployment ohne Backup
- **NIEMALS** während Peak-Zeiten deployen (außer Hotfix)
- **NIEMALS** Monitoring-Phase überspringen

---

## 🙋 Support

Bei Problemen oder Fragen:

1. **Dashboard konsultieren:** `npm run deploy:dashboard`
2. **Logs prüfen:** `quality-reports/deployment-logs/`
3. **Dokumentation:** Diese README + DEPLOYMENT-GUIDE.md
4. **GitHub Issue:** `gh issue create --label deployment`
5. **Team kontaktieren:** DevOps Team

---

**Version:** 1.0.0  
**Erstellt:** 2025-01-06  
**Status:** ✅ Production Ready  
**Gesamt Code:** 4.613 Zeilen Bash
