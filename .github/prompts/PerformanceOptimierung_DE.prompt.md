✅ MIGRIERT – Neue Version verfügbar

Diese Legacy-Prompt-Datei wurde ersetzt.
Bitte verwenden: .github/chatmodes/general/PerformanceOptimierung_DE.chatmode.md

---
status: MIGRATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/PerformanceOptimierung_DE.chatmode.md
reason: Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System
---

**✅ MIGRIERT - Neue Version verfügbar**

Diese Datei wurde zu einem moderneren Format migriert.

- **Status:** MIGRATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/PerformanceOptimierung_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - migriert zu einheitlichem Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/PerformanceOptimierung_DE.chatmode.md

---

---
description: 'Analysiert den Code und schlägt Performance-Optimierungen auf Deutsch vor'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Analysieren Sie den Code des Projekts `${workspaceFolderBasename}` und identifizieren Sie Bereiche, in denen die Leistung verbessert werden kann. Erstellen Sie einen deutschsprachigen Bericht mit:

1. **Messung der aktuellen Leistung** – Kurze Beschreibung, wie Leistung aktuell gemessen wird (Profiler, Benchmarks).
2. **Identifizierte Engpässe** – Liste von Modulen oder Funktionen, die ineffizient sind (z. B. hohe Laufzeit, hoher Speicherverbrauch). Verweisen Sie auf relevante Dateien via `#file:`.
3. **Optimierungsvorschläge** – Konkrete Empfehlungen zur Optimierung (Algorithmusverbesserungen, Caching, Parallelisierung, Datenbankindizes).
4. **Risiken und Tests** – Hinweise auf mögliche Risiken oder Nebeneffekte der Optimierungen und wie diese getestet werden können.
5. **Priorisierung** – Einschätzung des Aufwands und des erwarteten Nutzens, um die Vorschläge zu priorisieren.

Verwenden Sie klare Überschriften, und stellen Sie gegebenenfalls Beispielcode zur Veranschaulichung der Änderungen bereit.