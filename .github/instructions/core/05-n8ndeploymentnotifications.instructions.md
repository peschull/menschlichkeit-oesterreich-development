---
title: n8n – Deployment-Benachrichtigungen (05)
version: 1.0.0
created: 2025-10-08
lastUpdated: 2025-10-08
status: ACTIVE
priority: high
category: automation
applyTo: automation/**,deployment-scripts/**,workflows/**
---
# n8n – Deployment-Benachrichtigungen (05)

Kurzauftrag: CI/CD-Events empfangen (GitHub Actions, Pipeline), statusabhängig an Slack/Email/PagerDuty weiterleiten und Issues eröffnen.

- Quellen: GitHub Webhooks, Build-Pipeline, Quality Gates.
- Kanäle: #deployments, E-Mail (kritisch), PagerDuty (kritisch).
- Regeln: Failure ⇒ Issue erstellen, Blocker taggen; Success ⇒ kurze Zusammenfassung.
- Audit: Alle Alarme/Aktionen protokollieren (≤ 90 Tage), keine Secrets/PII loggen.

Siehe auch: .github/instructions/core/n8n-automation.instructions.md und .github/instructions/quality-gates.instructions.md
