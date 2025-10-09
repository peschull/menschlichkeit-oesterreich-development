✅ MIGRIERT – Neue Version verfügbar

Diese Legacy-Prompt-Datei wurde ersetzt.
Bitte verwenden: .github/chatmodes/general/CodeReview_DE.chatmode.md

---
status: MIGRATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/CodeReview_DE.chatmode.md
reason: Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System
---

**✅ MIGRIERT - Neue Version verfügbar**

Diese Datei wurde zu einem moderneren Format migriert.

- **Status:** MIGRATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/CodeReview_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/CodeReview_DE.chatmode.md

---

---
description: 'Führt eine gründliche Code-Überprüfung auf Deutsch durch und identifiziert Qualitäts-, Sicherheits- und Performanceprobleme'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Überprüfen Sie den gesamten Quellcode des Projekts (#githubRepo) und erstellen Sie einen Bericht auf Deutsch. Identifizieren Sie Probleme in Bezug auf Codequalität, Wartbarkeit, Performance und Sicherheit. Der Bericht sollte folgende Abschnitte enthalten:

1. **Überblick** – Eine Zusammenfassung der Projektstruktur, verwendeten Sprachen und Frameworks.
2. **Kritische Probleme** – Schwere Fehler oder Schwachstellen, die dringend behoben werden müssen, inklusive konkreter Lösungsvorschläge und Verweise auf betroffene Dateien mittels `#file:`-Syntax.
3. **Empfohlene Verbesserungen** – Mittlere Priorität: Möglichkeiten zur Optimierung, Refaktorisierung und Verbesserung des Codes. Fügen Sie Beispielcode bei.
4. **Kleinere Hinweise** – Niedrige Priorität: Stil- und Dokumentationshinweise oder kleinere Optimierungen.
5. **Zusammenfassung** – Gesamteinschätzung der Codebasis und Empfehlungen für die nächsten Schritte.

Nutzen Sie Listen oder Tabellen für eine klare Darstellung und halten Sie die Kommentare präzise. Befolgen Sie bewährte Praktiken der verwendeten Programmiersprachen.