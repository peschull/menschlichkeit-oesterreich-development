---
status: DEPRECATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/APIDesign_DE.chatmode.md
reason: Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System
---

**⚠️ DEPRECATED - NICHT VERWENDEN**

Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt.

- **Status:** DEPRECATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/APIDesign_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/APIDesign_DE.chatmode.md

---

---
description: 'Entwirft eine API-Spezifikation in deutscher Sprache für eine geplante Schnittstelle'
mode: 'agent'
tools: ['runCommands', 'runTasks', 'edit', 'runNotebooks', 'search', 'new', 'extensions', 'runTests', 'usages', 'vscodeAPI', 'think', 'problems', 'changes', 'testFailure', 'openSimpleBrowser', 'fetch', 'githubRepo', 'pylance mcp server', 'copilotCodingAgent', 'activePullRequest', 'openPullRequest', 'getPythonEnvironmentInfo', 'getPythonExecutableCommand', 'installPythonPackage', 'configurePythonEnvironment']
---

Entwerfen Sie eine API-Spezifikation auf Deutsch für eine neue oder bestehende Schnittstelle im Projekt `${workspaceFolderBasename}`. Die Spezifikation sollte enthalten:

* **Zweck der API** – Beschreibung, welche Funktionalität die API bereitstellt und für wen sie gedacht ist.
* **Endpoint-Auflistung** – Liste aller Endpunkte mit HTTP-Methode, URL, erforderlichen Parametern und zurückgegebenen Daten.
* **Datenmodelle** – Beschreibung der Datenstrukturen (Request/Response-Schemas) mit Feldern, Datentypen und Bedeutungen.
* **Authentifizierung/Autorisierung** – Angabe der Sicherheitsmechanismen (z. B. OAuth, API-Keys).
* **Beispiele** – Beispielanfragen und -antworten zur Veranschaulichung der Nutzung.
* **Fehlerbehandlung** – Definition von Fehlercodes und deren Bedeutung.
* **Versionsstrategie** – Wie zukünftige Änderungen an der API gehandhabt werden (Versionierung).

Nutzen Sie Klartext und strukturierte Tabellen, um Informationen übersichtlich darzustellen. Verweisen Sie bei Bedarf auf bestehende API-Dateien im Repository via `#file:`.