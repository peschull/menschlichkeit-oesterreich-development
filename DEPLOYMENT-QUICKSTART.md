# 🚀 Deployment System - Schnellstart

> **Vollständige Multi-Service Deployment-Infrastruktur mit Quality Gates und automatischem Rollback**

---

## ⚡ Quick Commands

```bash
# 🎨 Interaktives Dashboard (EMPFOHLEN)
npm run deploy:dashboard

# 🔧 Erstmaliges Setup
npm run deploy:setup-env

# ✅ Readiness Check
npm run deploy:readiness

# 🚀 Deployment
npm run deploy:staging       # Staging
npm run deploy:production    # Production
npm run deploy:blue-green    # Zero-Downtime

# 📊 Monitoring
npm run deploy:monitor       # Post-Deployment Monitoring
npm run deploy:smoke-tests   # Smoke Tests

# 🔙 Rollback
npm run deploy:rollback      # Zur vorherigen Version
```

**Monitoring-Ausgaben**
- `quality-reports/deployment-metrics/monitoring-<timestamp>.ndjson`
- `quality-reports/deployment-metrics/lighthouse-<timestamp>.json` (falls Lighthouse aktiv)
- `quality-reports/deployment-metrics/monitoring-report-<YYYYMMDD>.md`

---

## 📦 System-Komponenten

### Deployment Scripts (13 Dateien, 4.613 Zeilen)

| Script | Funktion | Größe |
|--------|----------|-------|
| 🎨 **deployment-dashboard.sh** | Interaktives Terminal-Dashboard | 388 Zeilen |
| ✅ **deployment-readiness.sh** | 9 Quality Gates Validation | 484 Zeilen |
| 🚀 **multi-service-deploy.sh** | 12-Phasen Orchestration | 426 Zeilen |
| 🔄 **blue-green-deploy.sh** | Zero-Downtime Deployment | 306 Zeilen |
| 📊 **deployment-monitoring.sh** | Real-Time Monitoring | 418 Zeilen |
| 🔙 **rollback.sh** | 10-Step Recovery (< 5min) | 423 Zeilen |
| 🧪 **smoke-tests.sh** | Post-Deployment Tests | 365 Zeilen |
| 🔧 **deployment-config.sh** | Zentrale Konfiguration | 186 Zeilen |
| ❤️ **health-check-utils.sh** | Health Check Funktionen | 261 Zeilen |
| 🛠️ **setup-environment.sh** | Environment Setup | 303 Zeilen |

### NPM Commands (11)

```json
{
  "deploy:dashboard": "Interaktives Dashboard",
  "deploy:setup-env": "Environment konfigurieren",
  "deploy:readiness": "Quality Gates prüfen",
  "deploy:staging": "Deploy to Staging",
  "deploy:production": "Deploy to Production",
  "deploy:blue-green": "Zero-Downtime Deploy",
  "deploy:monitor": "Monitoring starten",
  "deploy:rollback": "Rollback durchführen",
  "deploy:smoke-tests": "Smoke Tests",
  "deploy:health-check": "Health Check",
  "deploy:multi-service": "Multi-Service Deploy"
}
```

---

## 🛡️ Quality Gates (9 Kategorien)

| # | Gate | Checks | Blocker |
|---|------|--------|---------|
| 1 | **Git Status** | Clean dir, Branch, Sync | Uncommitted changes |
| 2 | **Quality** | Codacy, ESLint, PHPStan | Maintainability < 85% |
| 3 | **Security** | Trivy, Gitleaks, npm audit | CVE ≥ 7.0 |
| 4 | **DSGVO** | PII, Consent, Privacy | PII unverschlüsselt |
| 5 | **Performance** | Lighthouse (P/A11y/BP/SEO) | Score < 90 |
| 6 | **Database** | Migrations, Backup | Backup > 24h |
| 7 | **Environment** | Config, Node Version | Missing .env |
| 8 | **Dependencies** | Docker, PostgreSQL, PHP | Missing deps |
| 9 | **CI/CD** | GitHub Actions | Failing workflows |

---

## 📊 Deployment Flow

```
1. Pre-Validation (9 Quality Gates)
         ↓
2. Backup Creation (DB + Config)
         ↓
3. Database Migrations (Prisma)
         ↓
4. Service Build (API, Frontend, Gaming)
         ↓
5. Sequential Deploy:
   Database → API → CRM → Frontend → Gaming → Website → n8n
         ↓
6. Smoke Tests (API, CRM, Frontend, DB, Security)
         ↓
7. Post-Deployment Monitoring (30s intervals)
         ↓
8. Alerting (n8n, Slack, Email)
         ↓
9. Auto-Rollback (on critical failure, < 5min)
```

---

## 📈 Monitoring Metrics

| Metric | Threshold | Action |
|--------|-----------|--------|
| Error Rate | > 1% | Alert + Auto-rollback |
| Response Time | > 0.5s (500 ms) | Warning |
| CPU | > 80% | Alert |
| Memory | > 85% | Alert |
| Disk | > 90% | Alert |
| Lighthouse Score | < 90 | Warning |

---

## 🔧 Erstmaliges Setup

```bash
# 1. Environment konfigurieren
npm run deploy:setup-env

# Folgende Werte werden abgefragt:
# - Production URLs (API, CRM, Frontend, Admin)
# - Staging URLs
# - Database Connection String
# - Plesk Configuration (optional)
# - n8n Alert Webhook
# - Quality Thresholds
# - System Thresholds

# 2. Konfiguration validieren
cat .env.deployment

# 3. Deployment testen
npm run deploy:readiness
```

---

## 🚀 Deployment-Szenarien

### Standard Deployment
```bash
npm run deploy:readiness    # Quality Gates
npm run deploy:staging      # Staging Deploy
npm run deploy:monitor      # Monitoring (1h)
npm run deploy:production   # Production Deploy
```

### Zero-Downtime Deployment
```bash
npm run deploy:blue-green
# → Deploy to GREEN
# → Smoke Tests
# → Traffic Shift: 10% → 50% → 100%
# → Full Cutover
```

### Hotfix Deployment
```bash
git checkout -b hotfix/critical-fix
# ... fix implementieren ...
npm run deploy:readiness
npm run deploy:production --force  # Skip non-critical
npm run deploy:monitor -- 1800     # Monitor 30min
```

### Rollback
```bash
# Automatisch bei Failure
# ODER manuell:
npm run deploy:rollback                # Zur vorherigen Version
npm run deploy:rollback -- v2.1.0      # Zu spezifischer Version
```

---

## 📚 Dokumentation

| Dokument | Beschreibung |
|----------|--------------|
| **[deployment-scripts/README.md](deployment-scripts/README.md)** | Vollständige System-Dokumentation |
| **[docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)** | Detaillierte Anleitung |
| **[docs/DEPLOYMENT-QUICKREF.md](docs/DEPLOYMENT-QUICKREF.md)** | Quick Reference |
| **[docs/DEPLOYMENT-COMPLETE.md](docs/DEPLOYMENT-COMPLETE.md)** | Success Report |

---

## 🎯 Best Practices

### ✅ DOs
- Dashboard verwenden: `npm run deploy:dashboard`
- Quality Gates prüfen vor Deployment
- Staging vor Production deployen
- Monitoring nach Deployment aktivieren
- Git-Tags für Releases verwenden

### ❌ DON'Ts
- Quality Gates nicht skippen
- Nicht direkt zu Production ohne Staging
- Keine Secrets in Git committen
- Kein Force-Push auf `main`
- Kein Deployment ohne Backup

---

## 🔍 Troubleshooting

### Deployment hängt
```bash
Ctrl+C  # Triggert Auto-Rollback
npm run deploy:rollback
```

### Quality Gates failing
```bash
npm run deploy:readiness  # Details
npm run quality:gates     # Code Quality
npm run security:scan     # Security
```

### Services down
```bash
npm run deploy:dashboard  # Status prüfen
npm run deploy:rollback   # Falls kritisch
```

---

## ✅ Status

**Version:** 1.0.0  
**Erstellt:** 2025-01-06  
**Status:** ✅ Production Ready  
**Code:** 4.613 Zeilen Bash  
**Scripts:** 13 Deployment-Scripts  
**Commands:** 11 NPM-Commands  

---

## 🚀 Nächste Schritte

1. **Environment Setup:** `npm run deploy:setup-env`
2. **Readiness Check:** `npm run deploy:readiness`
3. **Dashboard starten:** `npm run deploy:dashboard`
4. **Ersten Deploy:** `npm run deploy:staging`

**Happy Deploying! 🎉**
