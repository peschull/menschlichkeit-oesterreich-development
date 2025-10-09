---
title: n8n – E-Mail-Automation (04)
version: 1.0.0
created: 2025-10-08
lastUpdated: 2025-10-08
status: ACTIVE
priority: high
category: automation
applyTo: automation/**,n8n/**
---
# n8n – E-Mail-Automation (04)

Kurzauftrag: Standardisierte E-Mail-Workflows (Willkommen, Erinnerungen, Kampagnen) über n8n, DSGVO-konform und mit Audit-Log.

- Scope: Trigger (Webhook/IMAP), CiviCRM-API, SMTP/Mailgun, Fehlerpfade & Retry.
- DSGVO: Double-Opt-In/Out respektieren, Consent prüfen, Logs ≤ 90 Tage, keine PII im Klartext.
- Qualität: Testrun im Staging, Benachrichtigung bei Fehlern (#ops), Idempotenz (Dedup).
- Inputs: Form/Webhook Payload, Kontakt-ID/E-Mail.
- Outputs: Versandbestätigung, CRM-Aktualisierung.

Siehe auch: .github/instructions/core/n8n-automation.instructions.md und .github/instructions/dsgvo-compliance.instructions.md
