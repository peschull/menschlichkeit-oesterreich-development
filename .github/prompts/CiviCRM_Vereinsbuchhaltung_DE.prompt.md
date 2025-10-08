---
status: DEPRECATED
deprecated_date: 2025-10-08
migration_target: .github/instructions/civicrm-vereinsbuchhaltung.instructions.md
reason: Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System
---

**⚠️ DEPRECATED - NICHT VERWENDEN**

Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt.

- **Status:** DEPRECATED
- **Datum:** 2025-10-08
- **Migration:** .github/instructions/civicrm-vereinsbuchhaltung.instructions.md
- **Grund:** Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/instructions/civicrm-vereinsbuchhaltung.instructions.md

---

---
description: 'Planung & Umsetzung der CiviCRM Vereinsbuchhaltung inkl. SEPA, Beiträge & Spenden'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Erstelle einen detaillierten Aktionsplan zur Einrichtung und Pflege der Vereinsbuchhaltung in CiviCRM (Drupal 10) für `crm.menschlichkeit-oesterreich.at`. Berücksichtige folgende Aspekte:

1. **Systemvorbereitung** – Secrets prüfen (`docs/SECRETS.template.md`), `.env.deployment` füllen, `./scripts/setup-civicrm.sh` planen.
2. **Erweiterungen** – Installation & Konfiguration von CiviSEPA, CiviInvoice, CiviBank, CiviRules, optional CiviAccounts. Nenne CLI-Befehle oder UI-Schritte.
3. **Mitgliedschaft & Beiträge** – Beitragstypen, wiederkehrende Zahlungen, Rechnungserstellung, Export für Steuerberater.
4. **Spendenverwaltung** – Kampagnen, Zuwendungsbestätigungen, Bankabgleich, Exporte für Lexoffice/DATEV.
5. **Rollen / ACLs** – Verantwortlichkeiten (Admin, Buchhaltung, Mitgliederbetreuung, IT) und benötigte Berechtigungen.
6. **Automatisierungen** – CiviRules, Cronjobs, n8n-Workflows, Webhooks.
7. **Verifikation** – Tests (Drush, SEPA-Datei, Rechnungen, CiviRules), Monitoring der Logs und Backups.

**Ausgabeform:**
- Strukturierter Aktionsplan (Abschnitte + nummerierte Schritte)
- Verweise auf relevante Dateien/Skripte (`#file:` Syntax, z. B. `#file:scripts/setup-civicrm.sh`)
- Konkrete Befehle in Codeblöcken
- Hinweise auf notwendige Secrets/Variablen
- Abschließende Checkliste für Livebetrieb
