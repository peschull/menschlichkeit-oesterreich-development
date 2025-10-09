# 🚀 MCP Agent Mode - Quick Reference Cheat Sheet

**47 MCP Servers aktiviert** | **Agent Mode: FULL POWER** 🤖

---

## 🗄️ DATABASE QUERIES (9 Servers)

```bash
# PostgreSQL (CiviCRM Production)
@postgres SELECT * FROM civicrm_contact WHERE consent_gdpr = true LIMIT 10
@postgres analyze table civicrm_donation performance
@postgres generate migration to add retention_date column

# MongoDB (Gaming Platform)
@mongodb find top 10 users by XP in gaming.users
@mongodb aggregate donations by month with trends

# MySQL (WordPress/Drupal)
@mysql show tables in wordpress database
@mysql optimize wp_posts table

# SQLite (Local Dev)
@sqlite query SELECT * FROM cache WHERE expired = false

# Elasticsearch (Logs & Search)
@elasticsearch search ERROR in logs from last 24h
@elasticsearch analyze search patterns and suggest improvements

# Redis (Caching)
@redis get all keys matching "session:*"
@redis analyze memory usage and eviction policy

# Neon/Supabase/Firebase (Serverless)
@neon scale database to 2 compute units
@supabase create new user with email verification
@firebase listen to realtime updates on /donations path
```

---

## 🌐 API & INTEGRATION (10 Servers)

```bash
# REST API (Generic HTTP)
@rest-api GET https://api.stripe.com/v1/balance
@rest-api POST https://api.example.com/webhook --data '{"event":"donation"}'

# GraphQL (Universal Gateway)
@graphql query { user(id: 123) { donations { amount date } } }

# Slack (Team Communication)
@slack send "Deployment successful!" to #dev-team
@slack create channel #dsgvo-compliance

# Discord (Community)
@discord post announcement in #general

# SendGrid (Email)
@sendgrid send donation receipt to donor@example.at with PDF

# Twilio (SMS/WhatsApp)
@twilio send SMS to +43 660 1234567: "Donation confirmed"

# Zapier/Make/n8n (Automation)
@zapier create workflow: Stripe → CiviCRM → Email
@n8n trigger deployment-notification workflow
```

---

## ☁️ CLOUD OPERATIONS (3 Providers)

```bash
# AWS (eu-central-1 for GDPR)
@aws list S3 buckets in eu-central-1
@aws upload backup.sql to s3://menschlichkeit-backups/
@aws check RDS performance metrics

# Google Cloud Platform
@gcp run BigQuery: SELECT SUM(amount) FROM donations WHERE country='AT'
@gcp deploy Cloud Run service from gcr.io/menschlichkeit/api:latest

# Microsoft Azure
@azure scale App Service crm.menschlichkeit-oesterreich.at to P2v3
@azure check PostgreSQL slow queries
```

---

## 🏗️ INFRASTRUCTURE & DEVOPS (7 Servers)

```bash
# Terraform (Infrastructure as Code)
@terraform plan production infrastructure changes
@terraform apply with cost estimation

# Kubernetes (Container Orchestration)
@kubernetes scale deployment api-backend --replicas=5
@kubernetes rollback deployment to previous version
@kubernetes get logs for pod api-backend-xyz --tail=100

# Docker (Containers)
@docker build menschlichkeit/api:2.5.0
@docker push to registry
@docker exec crm-container drush cr

# Monitoring (Sentry/Datadog)
@sentry list HIGH severity errors from last 7 days
@datadog show P95 latency for /api/donations in last 24h
```

---

## 📊 PROJECT MANAGEMENT (7 Servers)

```bash
# Jira/Confluence (Atlassian)
@jira create epic "GDPR Article 17 Implementation"
@confluence create page "API v2.5 Release Notes"

# Linear (Modern PM)
@linear create issue "Implement Stripe SEPA" with label high-priority

# Airtable (Flexible DB)
@airtable add donor to "Monthly Supporters" table

# Google Sheets
@google-sheets append donation data to "Q4 2024 Report"

# Todoist/Notion (Tasks/Docs)
@todoist create task "Send thank-you letters" due tomorrow
@notion update "DSGVO Compliance Tracker" database
```

---

## 🎯 POWER WORKFLOWS (Multi-Server)

### 🚀 Complete Donation Processing

```bash
@sequential-thinking execute:
  @stripe create 50 EUR SEPA payment
  → @postgres insert civicrm_contribution
  → @sendgrid send Austrian tax receipt
  → @slack notify #fundraising
  → @notion update dashboard
  → @todoist create thank-you task
```

### 🔒 DSGVO Compliance Audit

```bash
@sequential-thinking audit:
  @postgres find contacts without consent
  → @mongodb check expired retention_date
  → @elasticsearch search logs for PII
  → @codacy scan code for hardcoded data
  → @jira create compliance issues
  → @slack alert #legal-team
```

### 🎨 Design System Deployment

```bash
@sequential-thinking deploy:
  @figma get latest tokens
  → @github create PR
  → @playwright visual regression tests
  → @kubernetes deploy to staging
  → @datadog verify performance
  → @slack notify #design-team
```

---

## 🔐 DSGVO-COMPLIANT REGIONS

```bash
✅ AWS:     eu-central-1 (Frankfurt), eu-west-1 (Ireland)
✅ GCP:     europe-west1 (Belgium), europe-west3 (Frankfurt)
✅ Azure:   West Europe (Netherlands), Germany West Central
```

---

## 🛠️ TROUBLESHOOTING

```bash
# Server nicht verfügbar?
env | grep POSTGRES                    # Check ENV
code --list-extensions | grep copilot  # Check Extensions
Cmd/Ctrl+Shift+P → Reload Window       # Reload VS Code

# Connection Fehler?
@postgres test connection             # Test DB
@aws sts get-caller-identity          # Test AWS Auth
curl -u ${STRIPE_API_KEY}: https://api.stripe.com/v1/balance
```

---

## 📚 FULL DOCUMENTATION

- **Complete Guide:** `quality-reports/MCP-AGENT-MODE-COMPLETE-2025-10-08.md`
- **Environment Template:** `.vscode/mcp-environment-template.sh`
- **MCP Config:** `.vscode/mcp.json` (47 servers)

---

**🤖 Agent Mode Status:** FULLY ACTIVATED ✅  
**Next:** Configure API-Keys → VS Code Reload → Execute Workflows 🚀
