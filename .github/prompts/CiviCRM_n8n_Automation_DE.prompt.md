---
status: MIGRATED
deprecated_date: 2025-10-08
migration_target: .github/instructions/core/civicrm-n8n-automation.instructions.md
reason: Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System
---

**✅ MIGRIERT - Neue Version verfügbar**

Diese Datei wurde zu einem moderneren Format migriert.

- **Status:** MIGRATED
- **Datum:** 2025-10-08
- **Migration:** .github/instructions/core/civicrm-n8n-automation.instructions.md
- **Grund:** Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/instructions/core/civicrm-n8n-automation.instructions.md

---

---
description: 'Konzipiert einen vollständigen Automationsplan (CiviCRM + n8n + Plesk + Monitoring) für Beiträge & Spenden'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Analyse den aktuellen Stand der Vereinsbuchhaltung (CiviCRM) und entwirf einen Automationsplan, der folgende Bereiche abdeckt:

1. **Mitgliedschaften & Beiträge** – Regelwerke für Beitragstypwechsel, Altersgrenzen, Statusänderungen (CiviRules + Custom PHP). Nenne Dateien/Module (`#file:`) und Tests.
2. **SEPA-Export & Versand** – Cronjobs (Plesk), SEPA-Datei, Mail an Buchhaltung, Archiv (Nextcloud), Validierungen.
3. **Bankabgleich** – n8n Workflow (SFTP Download, CiviBank Import, Matching Report).
4. **Rechnungsversand & Mahnwesen** – automatische Rechnungen, Mahnstufen, Eskalation (CiviRules, CiviInvoice).
5. **Monitoring & Alerts** – n8n Monitoring Flow, Slack/Mail Alerts (offene Rechnungen, Mandatsablauf, Kampagnenfortschritt). Optional Deployment Monitoring.
6. **Buchhaltungs-Export** – JSON/CSV Export, Push an Lexoffice/sevDesk/DATEV, Monatsabschluss.
7. **Zuwendungsbestätigungen** – Schwellenwerte, Jahreszusammenfassung, PDF-Archivierung.

**Output-Anforderungen:**
- Detaillierter Aktionsplan (Abschnitte + nummerierte Schritte)
- Verweise auf relevante Dateien/Skripte (`#file:` Syntax)
- Konkrete Befehle/Workflows in Code- oder JSON-Blöcken
- Hinweise auf benötigte Secrets (aus `docs/SECRETS.template.md`)
- Abschließende Test-/Monitoring-Checkliste
