# Secrets Invent| Schlüssel | Umgebung | ---

## 2. Database Credentials (17-DB-Architektur)

### 2.1 Plesk MariaDB (Tier 1 ---

## 4. API-Service (FastAPI, Prisma, Gateway)

| Schlüssel | Ablage |## 7. Email & Communication (SMTP, Webhooks)

| Schlüssel | Ablage | Generierter Wert | Beschreibung |
| --- | --- | --- | --- |
| `SMTP_HOST` | `.env.deployment` | `mail.menschlichkeit-oesterreich.at` | Haupt-SMTP Server |
| `SMTP_PORT` | `.env.deployment` | `587` | STARTTLS Port |
| `SMTP_USER` | `.env.deployment` | `noreply@menschlichkeit-oesterreich.at` | System Email User |
| `SMTP_PASS` | `.env.deployment` | `Q$T#7UknF%VUBlV7` | System Email Password |
| `NOTIFICATION_EMAIL` | `.env.deployment` | `notifications@menschlichkeit-oesterreich.at` | Notification Sender |
| `ADMIN_EMAIL` | `.env.deployment` | `admin@menschlichkeit-oesterreich.at` | Admin Contact |
| `SUPPORT_EMAIL` | `.env.deployment` | `support@menschlichkeit-oesterreich.at` | Support Contact |
| `WEBHOOK_SECRET_GITHUB` | GitHub Secret | `7a9c2e4f1b5d8a3c6f9e2b7d0a5c8e1f` | GitHub Webhook Secret |
| `WEBHOOK_SECRET_FIGMA` | GitHub Secret | `2e7f9a1c4b8d6e0f3a9c7b2e5d8f0a1c` | Figma Webhook Secret |
| `WEBHOOK_SECRET_STRIPE` | GitHub Secret | `9f2a5d8b1e4c7f0a3d6b9e2c5f8a1d4b` | Stripe Webhook Secret |

---

## 8. Weitere Tier-Datenbanken (Complete Database Matrix)

**Plesk MariaDB (5 Datenbanken - localhost)**

| Service | User | Password | Database | Port |
| --- | --- | --- | --- | --- |
| CRM | `svc_crm` | `f9*K2mN8@vL5!pR3Q6Y&D4Hs` | `mo_crm` | 3306 |
| Website | `svc_website` | `T7*bF5&nM1@kP9$cL3XrE6Wq` | `mo_website` | 3306 |
| n8n | `svc_n8n_local` | `W2*rT8&mK4@nP7$fL0YxC5Ds` | `mo_n8n_local` | 3306 |
| Analytics | `svc_analytics` | `R6*mL9&pT2@kF5$nC8XbE1Wv` | `mo_analytics` | 3306 |
| Backups | `svc_backups` | `P4*kT7&mR0@nF3$cL6YxE9Ws` | `mo_backups` | 3306 |

**External MariaDB (9 Datenbanken - external-db1.hosting-provider.at)**

| Service | User | Password | Database | Port |
| --- | --- | --- | --- | --- |
| CRM Staging | `svc_crm_staging` | `K5*mR8&pT1@nF4$cL7YxE0Ws` | `mo_crm_staging` | 3306 |
| Website Staging | `svc_web_staging` | `F2*rT5&mK8@nP1$fL4YxC7Ds` | `mo_web_staging` | 3306 |
| Cache | `svc_cache` | `L0*mK3&pT6@nF9$cR2YxE5Ws` | `mo_cache` | 3306 |
| Sessions | `svc_sessions` | `N8*rF5&mT2@kP9$cL6YxE3Ds` | `mo_sessions` | 3306 |
| Logs | `svc_logs` | `M4*kR7&pT0@nF3$cL9YxE6Ws` | `mo_logs` | 3306 |
| Queue | `svc_queue` | `P1*rT4&mK7@nF0$cL3YxE8Ds` | `mo_queue` | 3306 |
| Search | `svc_search` | `R7*mK0&pT3@nF6$cL2YxE5Ws` | `mo_search` | 3306 |
| Reports | `svc_reports` | `T3*rF6&mK9@nP2$cL5YxE1Ds` | `mo_reports` | 3306 |
| Monitoring | `svc_monitoring` | `F9*mR2&pT5@nK8$cL0YxE4Ws` | `mo_monitoring` | 3306 |

**PostgreSQL (3 Datenbanken - pg-cluster.hosting-provider.at)**

| Service | User | Password | Database | Port |
| --- | --- | --- | --- | --- |
| Games/XP | `svc_games` | `qQ#^ql*nWkx3!*AjA5g^CaWq` | `mo_games` | 5432 |
| Analytics | `svc_analytics_pg` | `mM#@wl*kFpx2!&DjB4f&RzEt` | `mo_analytics_pg` | 5432 |
| API Data | `svc_api_data` | `nN$%xl*gVsx4!#CjH6h%MzOp` | `mo_api_data` | 5432 |

**Redis (Optional - redis.hosting-provider.at)**

| Service | Password | Database | Port |
| --- | --- | --- | --- |
| Redis Main | `wW&*zl*tXqx5!$EjK7j&NzLm` | 0 | 6379 |

**GitHub Secrets:** Alle Database-Credentials werden als Secrets im Format `MO_<SERVICE>_DB_*` gepflegt.erierter Wert | Beschreibung |
| --- | --- | --- | --- |
| `JWT_SECRET` | GitHub Secret (repo) & `.env` | `b48f920c67fe8f772d5bfb2c5d1e395a2a1f75310b44e575291d6beeef98c58e` | 64-Zeichen Hex Token |
| `CIVI_BASE_URL` | GitHub Secret / `.env` | `https://crm.menschlichkeit-oesterreich.at` | CRM Endpoint |
| `CIVI_API_KEY` | GitHub Secret | `d6ea11eba1f6233a5f9730a1d663f26d` | identisch mit CiviCRM |
| `CIVI_SITE_KEY` | GitHub Secret | `8d4eec450b860cc4844e71179fae2778a7a298cbb6e067c484b0b4c6df062536` | identisch mit CiviCRM |
| `FRONTEND_ORIGINS` | `.env` | `https://menschlichkeit-oesterreich.at,https://games.menschlichkeit-oesterreich.at` | CORS Whitelist |
| `DATABASE_URL` | `.env.deployment` | `postgresql://svc_games:qQ#^ql*nWkx3!*AjA5g^CaWq@$PG_HOST:5432/mo_games?sslmode=require` | PostgreSQL (Prisma) |
| `N8N_BASE_URL` | `.env`/secret | `https://n8n.menschlichkeit-oesterreich.at` | Automation Layer |
| `N8N_WEBHOOK_SECRET` | `.env`/secret | `114995bd57e569c75a32331e8b83c4caf474bf33ba403fcb` | n8n Webhook Auth |
| `LOG_LEVEL` | optional | `info` | Logging Level |
| `LOG_DIR` | optional | `/var/log/mo-api` | Log Directory |
| `LOG_FILE_ENABLED` | optional | `true` | File Logging aktiviert |6) - LIMIT 5 DBs

| Schlüssel | Ablage | Database | User | Generiertes PW | Referenz |
| --- | --- | --- | --- | --- | --- |
| `MO_MAIN_DB_PASS` | GitHub Secret | `mo_main` | `svc_main` | `tV#&WHlbMRxK@@ociP@Kq13R` | Hauptseite WordPress |
| `MO_VOTES_DB_PASS` | GitHub Secret | `mo_votes` | `svc_votes` | `O#Fk8Pk@nqOgdt0Eocx0Pu72` | Voting System |
| `MO_SUPPORT_DB_PASS` | GitHub Secret | `mo_support` | `svc_support` | `x5pwSZnTrRQPdcKBeZB^A#Ma` | Support Tickets |
| `MO_NEWSLETTER_DB_PASS` | GitHub Secret | `mo_newsletter` | `svc_newsletter` | `8qlH#yATzzzE7l08L47@*#^I` | Newsletter Management |
| `MO_FORUM_DB_PASS` | GitHub Secret | `mo_forum` | `svc_forum` | `2RJn$zkJFkycR71hlZ#wO*H2` | Community Forum |

### 2.2 External MariaDB (Tier 2 - $MYSQL_HOST:3306) - 9 DBs

| Schlüssel | Ablage | Database | User | Generiertes PW | Zweck |
| --- | --- | --- | --- | --- | --- |
| `MO_CRM_DB_PASS` | GitHub Secret | `mo_crm` | `svc_crm` | `dD7GRoK0Hhx7!pI7OZcp5MSW` | Drupal 10 + CiviCRM |
| `MO_N8N_DB_PASS` | GitHub Secret | `mo_n8n` | `svc_n8n` | `YctZKfJuEWoYbAhjqMhttIIa` | n8n Automation |
| `MO_HOOKS_DB_PASS` | GitHub Secret | `mo_hooks` | `svc_hooks` | `1BsXvGE!*gRak6d1mzDSt7Y1` | Webhook Logs |
| `MO_CONSENT_DB_PASS` | GitHub Secret | `mo_consent` | `svc_consent` | `0jlTMmE#SJ^Kth@uR^dLvJKA` | DSGVO Consent |
| `MO_GAMES_DB_PASS` | GitHub Secret | `mo_games` | `svc_games` | `qQ#^ql*nWkx3!*AjA5g^CaWq` | Gaming Platform |
| `MO_ANALYTICS_DB_PASS` | GitHub Secret | `mo_analytics` | `svc_analytics` | `J7XalYpZRHUwRs@UoCFl&JLT` | Analytics/Reports |
| `MO_API_STG_DB_PASS` | GitHub Secret | `mo_api_stg` | `svc_api_stg` | `EdxY^LSD8FzXyBvVKGz@51m$` | API Staging |
| `MO_ADMIN_STG_DB_PASS` | GitHub Secret | `mo_admin_stg` | `svc_admin_stg` | `MR9#rhXz41LdPqfiUu%4KW05` | Admin Staging |
| `MO_NEXTCLOUD_DB_PASS` | GitHub Secret | `mo_nextcloud` | `svc_nextcloud` | `Fx79UHBBcGjLRPcd^sW3X#@K` | Nextcloud Files |

### 2.3 External PostgreSQL (Tier 3 - $PG_HOST:5432) - 3 DBs

| Schlüssel | Ablage | Database | User | Generiertes PW | Zweck |
| --- | --- | --- | --- | --- | --- |
| `PG_IDP_DB_PASS` | GitHub Secret | `mo_idp` | `svc_idp` | `$sxl1YQJGBOym&5ZmqlVp4!H` | Keycloak IDP |
| `PG_GRAFANA_DB_PASS` | GitHub Secret | `mo_grafana` | `svc_grafana` | `px&Zt6skKLMZUzm11oV0pR&f` | Grafana Metrics |
| `PG_DISCOURSE_DB_PASS` | GitHub Secret | `mo_discourse` | `svc_discourse` | `Fcp5ROEt7j71VMFJvaLBm0qN` | Discourse Forum |

### 2.4 Database Connection Hosts

| Schlüssel | Ablage | Beispielwert | Beschreibung |
| --- | --- | --- | --- |
| `MYSQL_HOST` | GitHub Secret | `external-mysql.menschlichkeit-oesterreich.at` | External MariaDB Host |
| `PG_HOST` | GitHub Secret | `external-pg.menschlichkeit-oesterreich.at` | External PostgreSQL Host |
| `REDIS_HOST` | GitHub Secret | `external-redis.menschlichkeit-oesterreich.at` | External Redis Host |
| `REDIS_PASSWORD` | GitHub Secret | `El!yWfFt#cpJ9bSOVe$8` | Redis Auth Password |

---

## 3. CRM / CiviCRM (Drupal 10) - Spezielle Secrets

| Schlüssel | Ablage | Generierter Wert | Beschreibung | Referenz |
| --- | --- | --- | --- | --- |
| `CRM_DB_HOST` | `.env.deployment`, GitHub Secret | `$MYSQL_HOST` | Externe MariaDB (Tier 2) | `database-operations-mcp.instructions.md` |
| `CRM_DB_PORT` | dito | `3306` | MariaDB Port |  |
| `CRM_DB_NAME` | dito | `mo_crm` | CRM Database Name |  |
| `CRM_DB_USER` | dito | `svc_crm` | CRM Database User |  |
| `CRM_DB_PASS` | dito | `dD7GRoK0Hhx7!pI7OZcp5MSW` | ☝️ Siehe Tier 2 oben |  |ispielwert | Kommentar / Verweis |
| --- | --- | --- | --- | --- |
| `SSH_HOST` | global | GitHub Secret (repo) | `plesk-server.domain.com` | Plesk Host (`plesk-deployment.instructions.md`) |
| `SSH_PORT` | global | GitHub Secret | `22` | Standard 22 oder abweichend |
| `SSH_USER` | global | GitHub Secret | `dmpl20230054` | Plesk System User |
| `SSH_PRIVATE_KEY` | global | GitHub Secret | `-----BEGIN OPENSSH PRIVATE KEY-----...` | ed25519 Deploy-Key (Base64 oder Klartext) |
| `SSH_TARGET_DIR` | global | GitHub Secret | `/var/www/vhosts/menschlichkeit-oesterreich.at` | Plesk Document Root |
| `SSH_POST_DEPLOY_CMD` | global | GitHub Secret (optional) | `php artisan migrate --force` | Befehle nach Deploy |jekt-Template)

> Referenzen:  
>
> - `.github/instructions/*.instructions.md` (Plesk, Datenbanken, Quality Gates)  
> - `.github/prompts/0*_*.prompt.md` (Deployment-/Rollout-Workflows)  
> - `.github/modes/deployment-operations.mode.md` (CI/CD & MCP Interaktion)  
> - PowerShell Helpers `scripts/setup-github-secrets.ps1`, `scripts/migrate-to-github-secrets.ps1`, `scripts/extract-secrets-for-github.ps1`

Dieses Dokument dient als **Checkliste** für sämtliche benötigten Secrets/Variablen.  
Trage Werte je nach Scope in **GitHub Actions (Environments)** bzw. lokale `.env.deployment` ein.  
Alle Beispiele sind Platzhalter – niemals echte Secrets committen.

---

## 1. Deployment & Infrastruktur

| Schlüssel | Umgebung | Ablage | Kommentar / Verweis |
| --- | --- | --- | --- |
| `SSH_HOST` | global | GitHub Secret (repo) | Plesk Host (`plesk-deployment.instructions.md`) |
| `SSH_PORT` | global | GitHub Secret | Standard 22 oder abweichend |
| `SSH_USER` | global | GitHub Secret | z. B. `dmpl20230054` |
| `SSH_PRIVATE_KEY` | global | GitHub Secret | ed25519 Deploy-Key (Base64 oder Klartext) |
| `SSH_TARGET_DIR` | global | GitHub Secret | z. B. `/var/www/vhosts/...` |
| `SSH_POST_DEPLOY_CMD` | global | GitHub Secret (optional) | Befehle nach Deploy (z. B. `php artisan migrate --force`) |
| `STAGING_REMOTE_HOST` | staging | GitHub Environment `staging` | Siehe Workflow `deploy-staging.yml` |
| `STAGING_REMOTE_USER` | staging | GitHub Environment `staging` |  |
| `STAGING_REMOTE_PORT` | staging | GitHub Environment `staging` | Falls ≠ 22 |
| `STAGING_DEPLOY_KEY` | staging | GitHub Environment `staging` | Privater Key |
| `PRODUCTION_REMOTE_HOST` | production | GitHub Environment `production` |  |
| `PRODUCTION_REMOTE_USER` | production | GitHub Environment `production` |  |
| `PRODUCTION_REMOTE_PORT` | production | GitHub Environment `production` |  |
| `PRODUCTION_DEPLOY_KEY` | production | GitHub Environment `production` |  |
| `SAFE_DEPLOY_AUTO_CONFIRM` | CI | GitHub Environment | Auf `true` setzen (Skript `safe-deploy.sh`) |

---

## 2. CRM / CiviCRM (Drupal 10)

| Schlüssel | Ablage | Beschreibung | Referenz |
| --- | --- | --- | --- |
| `CRM_DB_HOST` | `.env.deployment`, GitHub Secret | Externe MariaDB (Tier 2) | `database-operations-mcp.instructions.md`, `CRM-CIVICRM-SETUP.md` |
| `CRM_DB_PORT` | dito | Meist 3306 |  |
| `CRM_DB_NAME` | dito | `mo_crm` |  |
| `CRM_DB_USER` | dito | `svc_crm` |  |
| `CRM_DB_PASS` | dito | Starkes PW (`openssl rand -base64 24`) |  |
| `CRM_BASE_URL` | `.env.deployment` | `https://crm.menschlichkeit-oesterreich.at` | Produktions-URL |  |
| `CRM_SITE_NAME` | `.env.deployment` | `Menschlichkeit Österreich CRM` | Anzeigename Drupal |  |
| `CRM_ADMIN_USER` | `.env.deployment` | `admin` | Admin-Login |  |
| `CRM_ADMIN_PASS` | `.env.deployment` | `C*&&t#JWx@2T8Ami` | Admin-Passwort (generiert) |  |
| `CRM_ADMIN_MAIL` | `.env.deployment` | `admin@menschlichkeit-oesterreich.at` | Admin-Mail |  |
| `CIVICRM_SITE_KEY` | `.env.deployment`, GitHub Secret | `8d4eec450b860cc4844e71179fae2778a7a298cbb6e067c484b0b4c6df062536` | 64 Zeichen Hex (generiert) |  |
| `CIVICRM_API_KEY` | GitHub Secret | `d6ea11eba1f6233a5f9730a1d663f26d` | API v4 Key (generiert) | `MCPMultiServiceDeployment_DE.prompt.md` |
| `CIVICRM_DOMAIN_ORG_URL` | `.env.deployment` | `https://menschlichkeit-oesterreich.at` | Hauptdomain |  |
| `CIVICRM_WEBHOOK_URL` | `.env.deployment` | `https://api.menschlichkeit-oesterreich.at/webhooks/civicrm` | Endpoint FastAPI |  |
| `CRM_SMTP_HOST` | `.env.deployment` | `mail.menschlichkeit-oesterreich.at` | SMTP Host |  |
| `CRM_SMTP_PORT` | `.env.deployment` | `587` | SMTP Port (STARTTLS) |  |
| `CRM_SMTP_USER` | `.env.deployment` | `civicrm@menschlichkeit-oesterreich.at` | SMTP User |  |
| `CRM_SMTP_PASS` | `.env.deployment` | `Q$T#7UknF%VUBlV7` | SMTP Password (generiert) |  |
| `CRM_SMTP_PROTOCOL` | `.env.deployment` | `tls` | Verschlüsselung |  |

Skript `scripts/setup-civicrm.sh` nutzt `.env.deployment`. Ohne die Werte bricht das Setup ab.

---

## 3. API-Service (FastAPI, Prisma, Gateway)

| Schlüssel | Ablage | Beschreibung |
| --- | --- | --- |
| `JWT_SECRET` | GitHub Secret (repo) & `.env` | Mindestens 32 Zeichen |
| `CIVI_BASE_URL` | GitHub Secret / `.env` | CRM Endpoint |
| `CIVI_API_KEY` | GitHub Secret | identisch mit CiviCRM |
| `CIVI_SITE_KEY` | GitHub Secret | identisch mit CiviCRM |
| `FRONTEND_ORIGINS` | `.env` | Kommagetrennte Whitelist |
| `DATABASE_URL` | `.env.deployment` | PostgreSQL (Prisma) |
| `MYSQL_HOST`, `PG_HOST`, `REDIS_HOST`, `*_PASSWORD` | `.env`/Secrets | Siehe „Database Matrix“ in `database-operations-mcp.instructions.md` |
| `N8N_BASE_URL`, `N8N_WEBHOOK_SECRET` | `.env`/secret | Schnittstelle zum Automation Layer |
| `LOG_LEVEL`, `LOG_DIR`, `LOG_FILE_ENABLED` | optional | Logging config |

---

## 5. Automation & Monitoring (n8n, Alerts, Social)

| Schlüssel | Ablage | Generierter Wert | Beschreibung |
| --- | --- | --- | --- |
| `N8N_USER` | GitHub Secret | `admin` | n8n Admin User |
| `N8N_PASSWORD` | GitHub Secret | `M9#kR7$nP4@wL6&qX8*B2` | n8n Admin Password (24 chars) |
| `N8N_ENCRYPTION_KEY` | GitHub Secret | `84b3f1cc92a8e5f41d9be0c73e6a2f58d2b4f91e` | 40-Zeichen Hex Key |
| `N8N_DB_MYSQLDB_HOST` | GitHub Secret | `external-db1.hosting-provider.at` | External MariaDB Host |
| `N8N_DB_MYSQLDB_DATABASE` | GitHub Secret | `mo_n8n_prod` | n8n Database Name |
| `N8N_DB_MYSQLDB_USER` | GitHub Secret | `svc_n8n` | n8n DB User |
| `N8N_DB_MYSQLDB_PASSWORD` | GitHub Secret | `m9*SfP2xVn@w!KzQe6Y*R8Bp` | n8n DB Password |
| `N8N_ALERT_WEBHOOK` | GitHub Secret / `.env` | `https://hooks.slack.com/services/T03K8Q2M5/B06T9R4N8/xyz123` | Notification Hook |
| `SLACK_WEBHOOK` | GitHub Secret / `.env` | `https://hooks.slack.com/services/T03K8Q2M5/B06T9R4N8/AbCdEf123456` | Slack Channel Alerts |
| `EMAIL_RECIPIENTS` | `.env.deployment` | `alerts@menschlichkeit-oesterreich.at,admin@menschlichkeit-oesterreich.at` | Alert-Distribution |
| `LINKEDIN_ACCESS_TOKEN` | GitHub Secret | `AQV8...` | LinkedIn API Token (Manual Setup) |
| `X_BEARER_TOKEN` | GitHub Secret | `AAAA...` | X/Twitter API Token (Manual Setup) |
| `FB_PAGE_TOKEN` | GitHub Secret | `EAA...` | Facebook Page Token (Manual Setup) |
| `MASTODON_ACCESS_TOKEN` | GitHub Secret | `xyz-abc...` | Mastodon API Token (Manual Setup) |
| `SAFE_DEPLOY_REMOTE_*` | GitHub Secret | Auto-generiert | Workflow-derived aus STAGING_/PRODUCTION_ |

---

## 6. Quality & Security Tooling

| Schlüssel | Ablage | Generierter Wert | Beschreibung |
| --- | --- | --- | --- |
| `CODACY_TOKEN` | GitHub Secret | `b4f8e92c-d5a1-4e3f-9b2d-7c5e8a1f4c6e` | Codacy Organization Token |
| `CODACY_PROJECT_TOKEN` | GitHub Secret | `a1b2c3d4e5f6789012345678901234567890abcd` | Project-spezifischer Token |
| `CODACY_API_TOKEN` | GitHub Secret | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` | API Access Token |
| `SNYK_TOKEN` | GitHub Secret | `12345678-1234-1234-1234-123456789012` | Snyk CLI & Action Token |
| `SONAR_TOKEN` | GitHub Secret (optional) | `squ_1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p` | SonarCloud Token |
| `TRIVY_TOKEN` | GitHub Secret (optional) | `ghp_abcdefghij1234567890KLMNOP` | Trivy Security Scans |
| `GITLEAKS_CONFIG` | `.gitleaks.toml` | Path: `.gitleaks.toml` | Secret Scanning Config |
| `JWT_SECRET` | siehe API Service | `b48f920c67fe8f772d5bfb2c5d1e395a2a1f75310b44e575291d6beeef98c58e` | Gleicher Wert |

**PowerShell-Script:** `scripts/setup-github-secrets.ps1 -ShowSecretsList` listet alle Token auf.

---

## 6. Weitere Tier-Datenbanken (siehe „Database Matrix“)

Für die 17 Datenbanken aus `database-operations-mcp.instructions.md` werden je nach Dienst die Secrets `MO_<SERVICE>_DB_USER`, `MO_<SERVICE>_DB_PASS` oder PostgreSQL-Pendants (`PG_<SERVICE>_DB_PASS`) gepflegt.  
Empfehlung: Als GitHub Secrets (Environment) hinterlegen und bei Bedarf via CI einlesen.

---

## 7. `.env.deployment` Quick Reference

Der Wizard `npm run deploy:setup-env` legt folgende Gruppen an:

- Basis-URLs (`API_URL`, `FRONTEND_URL`, `CRM_URL`, Staging-URLs)  
- CRM-Block (siehe Abschnitt 2)  
- Plesk-Konfiguration (`PLESK_HOST`, `PLESK_API_KEY`, …)  
- Alerting (`N8N_ALERT_WEBHOOK`, `SLACK_WEBHOOK`, `EMAIL_RECIPIENTS`)  
- Quality Gates (`MIN_MAINTAINABILITY`, `MAX_DUPLICATION`, …)  
- System-Thresholds (`CPU_THRESHOLD`, `RESPONSE_TIME_THRESHOLD`, …)  
- Deployment (`MAX_DEPLOYMENT_TIME`, `ROLLBACK_SLA`, …)  
- Feature Flags (`AUTO_BACKUP_BEFORE_DEPLOY`, `TRIVY_SCAN_ENABLED`, …)

Nach dem Ausfüllen: `npm run deploy:readiness` und ggf. `./scripts/setup-civicrm.sh` ausführen.

---

## 8. Geheimnis-Generierung & Rotation

```bash
openssl rand -hex 32       # CIVICRM_SITE_KEY, JWT_SECRET, n8n Encryption Key
openssl rand -base64 24    # DB-/SMTP-Passwörter
ssh-keygen -t ed25519 -C "github-actions@menschlichkeit-oesterreich.at"
```

- Secrets regelmäßig rotieren (`SSH_PRIVATE_KEY`, `CRM_DB_PASS`, `JWT_SECRET`, `N8N_PASSWORD`).
- Nach jeder Rotation CI-Workflows (`deploy-staging.yml`, `quality.yml`) laufen lassen und Logs prüfen.

---

## 9. Validierung & Security Verification

### A) GitHub Secrets Configuration

```bash
# 1. Navigate to Repository Settings
https://github.com/peschull/menschlichkeit-oesterreich-development/settings/secrets/actions

# 2. Create Environments (staging, production)
# 3. Configure all secrets per environment using generated values from above tables
```

### B) Local Environment Validation

```bash
# 1. Copy environment template
cp .env.example .env.deployment

# 2. Fill with generated values from sections 1-8
# 3. Test database connections
npm run db:test-connections

# 4. Validate API endpoints
npm run api:health-check

# 5. Test CiviCRM setup
cd crm.menschlichkeit-oesterreich.at && drush status
```

### C) Security Validation

```bash
# 1. Run Gitleaks scan
gitleaks detect --source . --verbose

# 2. Verify no secrets in git history
git log --all --full-history -- **/*.env
git log --all --full-history --grep="password\|secret\|key"

# 3. Test SMTP authentication
npm run test:smtp-auth

# 4. Validate webhook signatures
npm run test:webhook-signatures
```

### D) Helper Scripts

| Script | Purpose | Usage |
| --- | --- | --- |
| `scripts/setup-github-secrets.ps1` | Mass-upload secrets | `-ShowSecretsList`, `-GenerateKeys` |
| `scripts/migrate-to-github-secrets.ps1` | Migration helper | Auto-detect existing secrets |
| `scripts/extract-secrets-for-github.ps1` | Export for CI/CD | Generate JSON for workflows |
| `scripts/validate-secrets.sh` | Connection testing | Test all 17 databases |
| `scripts/rotate-secrets.sh` | Security rotation | Monthly rotation of critical secrets |

### E) Compliance & Documentation

```bash
# 1. DSGVO-Check: Ensure no PII in secrets
grep -r "email\|name\|address" .env* | grep -v example

# 2. Update instructions when secrets change
echo "$(date): Updated database credentials for external-db1" >> INSTRUCTIONS-UPDATE-SUMMARY.md

# 3. Backup encrypted secrets
gpg --encrypt --recipient admin@menschlichkeit-oesterreich.at .env.deployment

# 4. Test disaster recovery
./scripts/restore-from-backup.sh --dry-run
```

### F) Monitoring & Alerts

- **Secret Expiration:** Calendar reminders for 90-day rotation
- **Failed Authentication:** n8n workflow for DB connection failures  
- **Security Scanning:** Weekly Gitleaks + Trivy scans via GitHub Actions
- **Access Logging:** GitHub Audit Log for secret access

> **CRITICAL:** Alle generierten Werte sind Beispiele. Produziere NEUE Secrets für Produktionsumgebung mit `scripts/generate-production-secrets.py`.

---

**Status:** ✅ Vollständiges Template mit 17-Database-Matrix und allen generierten Werten
**Last Update:** $(date)
**Next Review:** $(date -d "+30 days")
