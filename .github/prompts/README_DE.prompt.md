---
status: DEPRECATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/README_DE.chatmode.md
reason: Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System
---

**⚠️ DEPRECATED - NICHT VERWENDEN**

Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt.

- **Status:** DEPRECATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/README_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/README_DE.chatmode.md

---

---
description: 'Erstellt vollständige README-Dateien korrekt verlinkt in deutscher Sprache für das Repository'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Ihre Aufgabe ist es, eine professionelle, umfassende `README.md` auf Deutsch für das Projekt `${workspaceFolderBasename}` zu erstellen. Analysieren Sie das gesamte Repository (#githubRepo), um Zweck, Architektur, Funktionen und Abhängigkeiten zu verstehen. Die README sollte enthalten:

1. **Projektbeschreibung** – Eine prägnante Zusammenfassung des Ziels und der Motivation des Projekts.
2. **Inhaltsverzeichnis** – Ein strukturiertes Inhaltsverzeichnis mit Links zu den einzelnen Abschnitten.
3. **Installation** – Detaillierte Schritte zur lokalen Installation, einschließlich aller Voraussetzungen und Befehle.
4. **Verwendung** – Beispiele für die Benutzung der Software, inklusive Befehle oder Codebeispiele.
5. **Architektur** – Eine Beschreibung der Hauptkomponenten und deren Zusammenwirken.
6. **Beitragen** – Richtlinien für Beiträge (Branch-Namen, Commit-Nachrichten, Style-Guidelines).
7. **Lizenz** – Informationen zur Lizenz und Link zur Lizenzdatei.
8. **Kontakt/Support** – Hinweise, wie man Fragen stellt oder Fehler meldet.

Verwenden Sie deutsche Sprache, klare Überschriften und listenartige Aufzählungen. Stellen Sie sicher, dass die Datei nützliche Informationen für neue und bestehende Entwickler enthält.