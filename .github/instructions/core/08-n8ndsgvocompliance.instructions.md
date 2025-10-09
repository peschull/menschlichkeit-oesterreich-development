---
title: n8n – DSGVO-Compliance (08)
version: 1.0.0
created: 2025-10-08
lastUpdated: 2025-10-08
status: ACTIVE
priority: critical
category: compliance
applyTo: automation/**,crm.menschlichkeit-oesterreich.at/**,api.menschlichkeit-oesterreich.at/**
---
# n8n – DSGVO-Compliance (08)

Kurzauftrag: DSGVO-Prozesse automatisieren (Auskunft, Berichtigung, Löschung, Einschränkung, Übertragbarkeit, Widerspruch) – sicher und nachweisbar.

- Identität prüfen; Fristen: 30 Tage (+60 bei Komplexität, informieren).
- Finanzdaten (BAO §132): nie löschen vor Ablauf (7 Jahre) → Pseudonymisieren.
- Protokoll: Wer/Was/Wann; Backups markieren; Links zeitlich begrenzen (≤ 7 Tage).
- Sicherheit: TLS, 2FA, Verschlüsselung „at rest“, keine PII in Logs.

Siehe auch: .github/instructions/dsgvo-compliance.instructions.md und .github/instructions/core/n8n-automation.instructions.md
