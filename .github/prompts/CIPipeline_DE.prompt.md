✅ MIGRIERT – Neue Version verfügbar

Diese Legacy-Prompt-Datei wurde ersetzt.
Bitte verwenden: .github/chatmodes/general/CIPipeline_DE.chatmode.md

---
status: MIGRATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/CIPipeline_DE.chatmode.md
reason: Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System
---

**✅ MIGRIERT - Neue Version verfügbar**

Diese Datei wurde zu einem moderneren Format migriert.

- **Status:** MIGRATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/CIPipeline_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/CIPipeline_DE.chatmode.md

---

---
description: 'Definiert eine Continuous-Integration-Pipeline in deutscher Sprache'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Entwerfen Sie eine CI-Pipeline für das Projekt `${workspaceFolderBasename}`. Die Pipeline sollte in einem gängigen CI-System umgesetzt werden können (z. B. GitHub Actions, GitLab CI, Jenkins). Beschreiben Sie auf Deutsch:

1. **Trigger** – Wann die Pipeline ausgeführt wird (bei Pull-Requests, Push auf bestimmte Branches, Nightly Builds).
2. **Build** – Schritte zum Bauen der Software und Installieren der Abhängigkeiten.
3. **Tests** – Ausführen der automatisierten Tests und Umgang mit dem Ergebnis.
4. **Linting/Analyse** – Ausführen von Linter, statischer Codeanalyse oder Security-Scans.
5. **Artefakte** – Erstellen und Speichern von Build-Artefakten (z. B. Binärdateien, Docker-Images).
6. **Benachrichtigungen** – Wie Entwickler über Fehler oder Erfolge informiert werden (z. B. via E-Mail, Chat-Integrationen).
7. **Beispielkonfiguration** – Geben Sie eine Beispiel-Pipeline in YAML-Form an, etwa für GitHub Actions (`.github/workflows/ci.yml`), die die oben genannten Schritte implementiert.

Verweisen Sie auf vorhandene Projektdateien und passen Sie die Pipeline an die Projektstruktur an.