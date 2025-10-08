---
description: 'Erstellt einen detaillierten Architekturplan für das Projekt auf Deutsch'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Ziel ist es, einen technischen Architekturplan für das Projekt `${workspaceFolderBasename}` in deutscher Sprache zu erstellen. Nutzen Sie den vorhandenen Code und die Struktur des Repositories (#githubRepo), um folgende Punkte zu dokumentieren:

1. **Übersicht** – Eine kurz gefasste Beschreibung des Systems und seiner Hauptziele.
2. **Komponenten** – Auflistung der Hauptmodule, Bibliotheken und Dienste sowie deren Aufgaben.
3. **Datenfluss** – Erläuterung der Interaktionen zwischen Komponenten, ggf. ergänzt um Sequenz- oder Flow-Diagramme (als beschreibender Text).
4. **Schnittstellen und APIs** – Beschreibung der internen und externen Schnittstellen, inklusive Datenformate und Protokolle.
5. **Abhängigkeiten** – Angabe externer Abhängigkeiten oder Dienste wie Datenbanken, Authentifizierungsdienste oder externe APIs.
6. **Deployment** – Hinweise zur Bereitstellung und Skalierung (siehe ggf. separate Docker/CI-Promptdateien).

Formulieren Sie den Plan klar und präzise in deutscher Sprache und referenzieren Sie relevante Dateien im Repository per `#file:`-Link. Die Struktur soll als Grundlage für weitere Dokumentation dienen.