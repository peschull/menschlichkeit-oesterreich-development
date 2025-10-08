---
status: DEPRECATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/DatenbankSchema_DE.chatmode.md
reason: Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System
---

**⚠️ DEPRECATED - NICHT VERWENDEN**

Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt.

- **Status:** DEPRECATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/DatenbankSchema_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/DatenbankSchema_DE.chatmode.md

---

---
description: 'Erstellt ein Datenbankschema und -modellierung auf Deutsch'
mode: 'ask'
tools: ['githubRepo']
---

Entwickeln Sie ein Datenbankschema für das Projekt `${workspaceFolderBasename}`. Analysieren Sie die Anforderungen anhand des vorhandenen Codes (#githubRepo) und formulieren Sie auf Deutsch:

* **Domänenmodell** – Beschreibung der wichtigsten Entitäten und deren Beziehungen.
* **Tabellenstruktur** – Angabe der Tabellen mit Spalten, Datentypen, Primär- und Fremdschlüsseln.
* **Normalisierung** – Hinweise zur Normalform, um Redundanz zu vermeiden und Konsistenz zu gewährleisten.
* **Indizes und Performance** – Empfehlungen zu Indizes und anderen Performance-Optimierungen.
* **Migrationen** – Hinweise zur Erstellung von Datenbankmigrationen für zukünftige Änderungen.

Stellen Sie das Schema in Tabellenform dar und erläutern Sie designrelevante Entscheidungen in deutscher Sprache.