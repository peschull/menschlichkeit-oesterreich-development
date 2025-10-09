✅ MIGRIERT – Neue Version verfügbar

Diese Legacy-Prompt-Datei wurde ersetzt.
Bitte verwenden: .github/chatmodes/general/README_DE.chatmode.md

---
status: MIGRATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/README_DE.chatmode.md
reason: Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System
---

**✅ MIGRIERT - Neue Version verfügbar**

Diese Datei wurde zu einem moderneren Format migriert.

- **Status:** MIGRATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/README_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/README_DE.chatmode.md

---

# Prompt- und Chatmode-Repository (vereinheitlicht)

Diese Struktur konsolidiert alle Prompt-/Instruktionsdateien des Repos unter `.github/prompts/`.

- Globale Leitlinien: `.github/prompts/global/` (Glossar, Stil, Guardrails)
- Chatmodes: `.github/prompts/chatmodes/` (YAML pro Modus, Beispiele, Tests)
- CI-Validierung: `.github/workflows/prompt-ci.yml` prüft Schema-Compliance und SemVer

Wichtige Regeln:
- YAML-Schlüssel auf Englisch; Inhalte (Texte) auf Deutsch.
- Versionierung nach SemVer (MAJOR.MINOR.PATCH).
- Jedes Chatmode-YAML hat eine passende `_examples.md`.
- Tests als Assertions im YAML; CI führt Schema-Checks aus (keine inhaltliche Ausführung).

Siehe auch:
- `global/00_glossary.md`
- `global/01_style_guide.md`
- `global/02_guardrails.md`
