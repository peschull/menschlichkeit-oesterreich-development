---
status: DEPRECATED
deprecated_date: 2025-10-08
migration_target: .github/chatmodes/Dockerisierung_DE.chatmode.md
reason: Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System
---

**⚠️ DEPRECATED - NICHT VERWENDEN**

Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt.

- **Status:** DEPRECATED
- **Datum:** 2025-10-08
- **Migration:** .github/chatmodes/Dockerisierung_DE.chatmode.md
- **Grund:** Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System

**Aktuelle Version verwenden:** .github/chatmodes/Dockerisierung_DE.chatmode.md

---

---
description: 'Erstellt eine Docker-Konfiguration und Anleitung zur Containerisierung auf Deutsch'
mode: 'agent'
tools: ['githubRepo', 'codebase']
---

Erarbeiten Sie eine Docker-Konfiguration, um das Projekt `${workspaceFolderBasename}` in einem Container auszuführen. Ihre Aufgabe umfasst:

* **Dockerfile** – Erstellen Sie ein `Dockerfile`, das den notwendigen Build- und Laufzeitkontext abbildet. Installieren Sie Abhängigkeiten, kopieren Sie den Code und definieren Sie den Startbefehl.
* **Docker-Compose** (optional) – Wenn das Projekt mehrere Dienste hat (z. B. Datenbank, Backend, Frontend), erstellen Sie eine `docker-compose.yml`, die diese Dienste orchestriert.
* **Anleitung** – Schreiben Sie eine Anleitung in Deutsch, wie der Container gebaut und gestartet wird (`docker build …`, `docker run …`), inklusive der Beschreibung benötigter Umgebungsvariablen, Ports und Volumes.
* **Best Practices** – Fügen Sie Hinweise zu Best Practices hinzu (Schlanke Basis-Images, .dockerignore, Multi-Stage Builds, Sicherheit).

Referenzieren Sie relevante Dateien im Repository mittels `#file:`-Syntax und stellen Sie sicher, dass die Containerisierung den Entwicklungs- und Produktionsbetrieb unterstützt.