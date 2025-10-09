# AGENTS.md

## Zweck
Diese Datei enthält zentrale, workspace‑weite Anweisungen, die automatisch auf alle Chat‑Anfragen angewendet werden. Verwenden Sie diese Datei, wenn mehrere KI‑Agenten im selben Arbeitsbereich dieselben Richtlinien teilen sollen.

## Aktivieren
**Voraussetzung:** Die Einstellung `chat.useAgentsMdFile` muss in VS Code aktiviert sein, damit AGENTS.md erkannt und verwendet wird.

## Format und Verhalten
- Die Datei ist eine normale Markdown‑Datei.  
- Leerzeichen zwischen den Anweisungen werden ignoriert; Anweisungen können als einzelne Zeilen, Absätze oder durch Leerzeilen getrennt geschrieben werden.  
- Verwenden Sie Markdown‑Links, um auf Dateien oder URLs im Repository zu verweisen.  
- VS Code wendet die Anweisungen aus AGENTS.md automatisch auf alle Chat‑Anfragen im Arbeitsbereich an.

## Allgemeine Richtlinien (Beispiele)
- **Konventionen:** Folge den Projekt‑Coding‑Standards; Priorisiere Lesbarkeit und Konsistenz.  
- **Naming:** Verwende sprechende Namen für Funktionen, Klassen und Variablen; Variablen in camelCase; Konstanten in UPPER_SNAKE_CASE.  
- **Dokumentation:** Jeder öffentliche API‑Endpunkt benötigt eine kurze Beschreibung, Eingabeparameter und Beispielantworten.  
- **Tests:** Schreibe unit tests für neue Funktionen; bei kritischer Logik erhöhe die Testabdeckung.  
- **Sicherheit:** Keine privaten Schlüssel, Passwörter oder Secrets in Code oder Beispielen veröffentlichen; beschreibe stattdessen, wie Secrets geladen werden sollen.  
- **Fehlerbehandlung:** Fehler immer klar melden; verwende strukturierte Fehlerobjekte mit Code und kurzer Nachricht.  
- **Performance:** Vermeide unbounded loops und unnötige Allokationen in hot paths.  
- **Barrierefreiheit:** UI‑Änderungen müssen die zugängliche Navigation und ARIA‑Attribute berücksichtigen.

## Sprache / Stil
- Schreibe klare, prägnante Sätze.  
- Bevorzuge aktive Stimme.  
- Verwende englische Terminologie für technischen Code‑Kontext, deutsch für Projekt‑Management‑Notizen, sofern nicht anders vereinbart.

## ApplyTo / Umfangssteuerung
AGENTS.md gilt workspace‑weit und kann nicht per applyTo eingeschränkt werden. Für ordnerspezifische oder dateitypbezogene Regeln nutzen Sie stattdessen separate `.instructions.md`‑Dateien mit `applyTo`‑Frontmatter.

## Beispiele für häufige Tasks

### Code Style (TypeScript)
- **Anweisung:** Follow the project TypeScript guidelines: always use strict types, prefer readonly where applicable, and include JSDoc for exported types.

### Pull Request Beschreibung
- **Anweisung:** Schreibe eine PR‑Beschreibung mit: Kurzbeschreibung, Liste wichtiger Änderungen, Migrationshinweise (falls nötig), Tests performed.

### Code Review
- **Anweisung:** Prüfer prüfen: Sicherheit, Performance, Tests, Einhaltung von Coding‑Guidelines, und Breaking Changes.

## Referenz auf andere Anweisungsdateien
- Referenzen zu projektinternen Anweisungen sollten als Markdown‑Links angegeben werden, z. B.:  
  - [general-coding.instructions.md](./guidance/general-coding.instructions.md)  
  - [backend-review-guidelines.md](./guidance/backend-review-guidelines.md)

## Beispiele: konkrete Anweisungen (einzelne Statements)
- Follow PEP 8 where Python is used.  
- Use functional components with hooks for React.  
- Always include error boundary handling in UI components.  
- Use prepared statements or parameterized queries for DB access.

## Tipps zur Pflege
- Halte Anweisungen kurz und eigenständig; jede Anweisung als einzelne, einfache Aussage.  
- Für aufgabenspezifische/Sprachspezifische Regeln mehrere `.instructions.md` Dateien anlegen und `applyTo` verwenden.  
- Versioniere AGENTS.md im Repository, damit Teams Änderungen nachvollziehen können.  
- Synchronisiere Benutzer‑Anweisungsdateien über Settings Sync, wenn nötig.

## Hinweise zu den VS Code Einstellungen
- Alternativ zu AGENTS.md können Sie Anweisungen per Workspace‑ oder User‑Einstellungen für spezielle Szenarien definieren (z. B. Code‑Review, Commit‑Message‑Generierung, Pull‑Request‑Beschreibung).  
- Empfohlene Einstellungen (Beispiel):  
  - `github.copilot.chat.pullRequestDescriptionGeneration.instructions`  
  - `github.copilot.chat.reviewSelection.instructions`

## Generierung und Editieren
- VS Code kann für Ihren Workspace eine passende Anweisungsdatei generieren; prüfen und anpassen nach Bedarf.  
- Um eine Anweisungsdatei zu ändern, verwenden Sie die Chat‑Konfiguration oder den Befehl "Chat: Configure Instructions".

## Wartung
- Prüfen Sie AGENTS.md periodisch (z. B. bei Major‑Releases oder Team‑Konvention‑Änderungen).  
- Dokumentieren Sie Änderungen in Commit‑Messages oder im Changelog.

---
*Letzte Anpassung: Fügen Sie projekt‑spezifische Regeln unten an (z. B. CI‑Checks, Linter‑Konfigurationen, Branching‑Schema).*
