---
title: n8n – Datenbank-Automation (06)
version: 1.0.0
created: 2025-10-08
lastUpdated: 2025-10-08
status: ACTIVE
priority: high
category: automation
applyTo: automation/**,scripts/**,web/**,api.menschlichkeit-oesterreich.at/**
---
# n8n – Datenbank-Automation (06)

Kurzauftrag: Backups, Health-Checks, Migrations-Notifications und Exporte orchestrieren.

- Backups: Täglich, verschlüsselt, Offsite; Erfolg/Failure melden.
- Health: regelmäßige Queries/HTTP-Checks; Schwellenwerte → Alerts.
- Exporte: DSGVO-Auskunft nur mit Auth und Ablauf-Links; keine Roh-PII per E-Mail.
- Sicherheit: Credentials in n8n-Credentials (verschlüsselt), Rotation ≥ 90 Tage.

Siehe auch: .github/instructions/core/n8n-automation.instructions.md und .github/instructions/dsgvo-compliance.instructions.md
