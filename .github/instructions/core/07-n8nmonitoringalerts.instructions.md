---
title: n8n – Monitoring & Alerts (07)
version: 1.0.0
created: 2025-10-08
lastUpdated: 2025-10-08
status: ACTIVE
priority: high
category: automation
applyTo: automation/**,monitoring/**
---
# n8n – Monitoring & Alerts (07)

Kurzauftrag: Health-, Performance- und Security-Events sammeln, priorisieren und an passende Kanäle routen.

- Severity: critical (PagerDuty+SMS+Mail+Slack), warning (Slack+Mail), info (Mail).
- Quellen: Grafana, Uptime-Checks, Lighthouse, Security-Scanner.
- Routen: Switch/If in n8n; Enrichment mit Kontext (Service, Commit, Link zu Run).
- Nachverfolgung: Tickets bei wiederkehrenden Warnungen; Runbooks verlinken.

Siehe auch: .github/instructions/core/n8n-automation.instructions.md
