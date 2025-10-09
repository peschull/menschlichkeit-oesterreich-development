# 🚀 Deployment Quick Reference

## One-Liner Commands

### Pre-Deployment

```bash
npm run deploy:readiness              # Check if ready to deploy
npm run quality:gates                 # Run all quality gates
npm run security:scan                 # Security vulnerability scan
```

### Deployment Execution

```bash
npm run deploy:staging                # Deploy to staging
npm run deploy:production             # Deploy to production
npm run deploy:blue-green             # Zero-downtime deployment
```

### Monitoring & Validation

```bash
npm run deploy:monitor                # Start post-deployment monitoring
npm run test:e2e                      # Run E2E tests
npm run performance:lighthouse        # Performance audit
```

### Emergency

```bash
npm run deploy:rollback               # Rollback to previous version
npm run deploy:rollback -- v2.1.0     # Rollback to specific version
```

---

## Status Indicators

### ✅ Ready to Deploy

```text
✓ Git: Clean & Synced
✓ Quality: All gates passed
✓ Security: 0 vulnerabilities
✓ Tests: All passing
✓ Performance: Lighthouse ≥90
✓ DSGVO: Compliant
```

### ⚠️ Deployment Warning

```text
! Some non-critical issues
! Review warnings before proceeding
! Consider fixing in next iteration
```

### ❌ Deployment Blocked

```text
✗ Critical issues detected
✗ Fix required before deployment
✗ Do NOT deploy
```

---

## Deployment Decision Tree

```text
┌─────────────────────────┐
│ Need to Deploy?         │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ Run: deploy:readiness   │
└───────────┬─────────────┘
            │
            ▼
       ┌────┴────┐
       │ PASSED? │
       └────┬────┘
       Yes  │  No
            │  └──► Fix Issues → Retry
            ▼
┌─────────────────────────┐
│ Critical Update?        │
└───────────┬─────────────┘
       Yes  │  No
            │  └──► deploy:production (Standard)
            ▼
┌─────────────────────────┐
│ deploy:blue-green       │
│ (Zero-Downtime)         │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│ deploy:monitor          │
│ (1 hour)                │
└───────────┬─────────────┘
            │
            ▼
       ┌────┴────┐
       │ Healthy?│
       └────┬────┘
       Yes  │  No
            │  └──► deploy:rollback
            ▼
        ┌───────┐
        │ DONE! │
        └───────┘
```

---

## Service Health Check URLs

```bash
# API Backend
curl https://api.menschlichkeit-oesterreich.at/health

# CRM System
curl https://crm.menschlichkeit-oesterreich.at/user/login

# Frontend
curl https://menschlichkeit-oesterreich.at

# n8n Automation
curl http://localhost:5678/healthz
```

---

## Common Scenarios

### 🔥 Hotfix Deployment (Critical Bug)

```bash
1. git checkout -b hotfix/bug-fix
2. # Fix bug + tests
3. npm run deploy:readiness
4. npm run deploy:blue-green       # Zero-downtime
5. npm run deploy:monitor 300      # 5-min intensive monitoring
```

### 🎉 Feature Release

```bash
1. npm run deploy:readiness
2. npm run deploy:staging
3. # QA Testing on staging...
4. npm run deploy:production
5. npm run deploy:monitor 3600     # 1-hour monitoring
```

### 🗄️ Database Migration

```bash
1. npx prisma migrate dev --name my_migration
2. # Test locally
3. npm run deploy:production       # Includes migration
4. npx prisma studio               # Verify changes
```

### 🔄 Rollback (Something went wrong)

```bash
1. npm run deploy:rollback
2. # Investigate issue in staging
3. # Fix & re-deploy when ready
```

---

## Quality Gates Summary

| Gate              | Threshold     | Command                      |
|-------------------|---------------|------------------------------|
| Security          | 0 CVE HIGH+   | `npm run security:scan`      |
| Maintainability   | ≥85%          | `npm run quality:codacy`     |
| Test Coverage     | ≥80%          | `npm run test:all`           |
| Performance       | Lighthouse≥90 | `npm run performance:lighthouse` |
| Accessibility     | WCAG AA       | (included in Lighthouse)     |
| DSGVO             | Compliant     | `npm run compliance:dsgvo`   |

---

## Alert Thresholds

| Metric            | Warning | Critical |
|-------------------|---------|----------|
| Error Rate        | >0.5%   | >1%      |
| Response Time     | >300ms  | >500ms   |
| CPU Usage         | >70%    | >80%     |
| Memory Usage      | >75%    | >85%     |
| Disk Usage        | >80%    | >90%     |
| DB Connections    | >70%    | >80%     |

---

## Troubleshooting Quick Fixes

### Deployment Stuck?

```bash
# Check deployment logs
tail -f quality-reports/deployment-*.md

# Check service status
systemctl status api-fastapi
docker ps -a
```

### Health Check Failing?

```bash
# Check service logs
journalctl -u api-fastapi -n 100
docker logs api-container --tail 100

# Manual health test
curl -v https://api.menschlichkeit-oesterreich.at/health
```

### Database Issues?

```bash
# Check connection
psql $DATABASE_URL -c "SELECT 1;"

# Check migrations
npx prisma migrate status

# Restore backup
pg_restore -d dbname backups/latest-backup.dump
```

### High Error Rate?

```bash
# Immediate rollback
npm run deploy:rollback

# Investigate logs
grep -i error logs/*.log
```

---

## File Locations

### Deployment Scripts

```text
deployment-scripts/
├── multi-service-deploy.sh      # Standard deployment
├── blue-green-deploy.sh         # Zero-downtime deployment
├── deployment-monitoring.sh     # Post-deployment monitoring
├── rollback.sh                  # Rollback procedure
└── deployment-readiness.sh      # Pre-deployment checks
```

### Reports & Logs

```text
quality-reports/
├── deployment-{VERSION}.md
├── deployment-metrics/*.json
├── monitoring-report-{DATE}.md
└── rollback-{TIMESTAMP}.log
```

### Backups

```text
backups/
└── deployment-{TIMESTAMP}/
    ├── database-backup.dump
    ├── api-env.bak
    └── config-templates-backup/
```

---

## Environment Variables

### Required for Deployment

```bash
export DEPLOYMENT_ENV=production
export DATABASE_URL=postgresql://...
export N8N_ALERT_WEBHOOK=https://n8n.../webhook/alert
export PLESK_HOST=user@server.example.com
```

### Optional

```bash
export AUTO_ROLLBACK=true          # Auto-rollback on failure
export MONITORING_DURATION=3600    # Monitoring duration (seconds)
export ERROR_RATE_THRESHOLD=0.01   # 1% error rate
```

---

## Contact & Escalation

### Automated

- n8n Alerts → Slack/Email/PagerDuty
- GitHub Issues (label: `deployment-issue`)

### Manual

- DevOps Team: See GitHub Team
- Emergency: Via n8n Alert Workflow

---

**📖 Full Documentation:** [DEPLOYMENT-GUIDE.md](./DEPLOYMENT-GUIDE.md)

**🔧 Last Updated:** 2025-10-06
