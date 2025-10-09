---
title: "Architektur & Systemdesign"
version: "1.0"
updated: "2025-10-09"
tags: ["Architektur", "System", "Datenflüsse", "DevOps"]
links:
  - "00_bestandsaufnahme.md"
  - "01_alignment.md"
  - "02_aktionsplan.md"
  - "03_styleguide.md"
assumptions:
  - "Alle genannten Komponenten basieren auf dem in der Repo dokumentierten Stand (Oktober 2025)."
  - "Die Beschreibung fasst bestehende Analysen zusammen und ergänzt sie um empfohlene Verbesserungen."
---

# 04 — Architektur & Systemdesign

Dieses Dokument gibt einen tiefgehenden Überblick über die bestehende Systemarchitektur der Plattform **Menschlichkeit Österreich** und schlägt Verbesserungen vor. Es ergänzt die Analyse aus `00_bestandsaufnahme.md` und dient als Grundlage für technische Entscheidungen und das DevOps‑Setup.

## 1. Bestehende Architektur

Die Security‑Analyse identifiziert acht Subsysteme: Website, API‑Service, CRM, Spieleplattform, Frontend/SPA, Automations‑Hub, MCP‑Server sowie Design‑System【222545626117737†L425-L449】. Jede Komponente erfüllt eine spezifische Rolle:

1. **Website & Frontend:** Eine Single Page Application (SPA) liefert Seiten wie Home, Spenden, Mitmachen und bettet das Lernspiel „Brücken Bauen“ ein. Die App kommuniziert über REST mit dem API‑Service und lädt statische Assets (Styles, Token) aus dem Design‑System.
2. **API‑Service (FastAPI):** Stellt Endpunkte für Formulare, Spenden, Spielergebnisse und Inhalte bereit. Verwaltet Authentifizierung, Autorisierung und schreibt Daten in die zentrale Datenbank (PostgreSQL).
3. **CRM (CiviCRM/Drupal 10):** Dient als zentrale Plattform für Mitgliederverwaltung, Spendenabrechnung und E‑Mail‑Kommunikation. Die API synchronisiert relevante Datensätze (Personen, Spenden, Consent).
4. **Automations‑Hub (n8n):** Orchestriert Workflows wie Double‑Opt‑In, Spendenquittungen, Event‑Registrierungen, KPI‑Reports. In der aktuellen Analyse läuft der Dienst unverschlüsselt über HTTP【222545626117737†L610-L620】.
5. **Spiel „Brücken Bauen“:** Eine eigenständige Webapplikation im `web/games`‑Verzeichnis, die interaktive Szenarien mit Fortschrittsanzeige und einem Scoreboard anbietet. Sie betont Barrierefreiheit und benötigt keine Anmeldung【651735299895262†L44-L86】.
6. **Design‑System & Tokens:** Figma‑basierte Komponenten und Tokens werden via GitHub Action synchronisiert und in Tailwind CSS integriert (siehe `figma-design-system`). Das Admin‑Portal nutzt die gleiche Basis.
7. **MCP‑Server & Enterprise Upgrade:** Verwalten Abrechnungen, Nutzeraccounts oder analytische Dienste (z. B. Matomo, Uptime Kuma). Details sind teilweise ausgelagert.

### Datenhaltung

Das System nutzt **PostgreSQL** als zentrales Datenlager für Personen, Spenden, Consents und Spielstände. Weitere Dienste wie n8n verwenden Redis als Queue. Der DSGVO‑konforme Consent‑Ledger speichert Einwilligungen mit Version, Zweck und Widerruf【222545626117737†L565-L606】.

### Infrastruktur

Aktuell wird das System auf **Plesk** gehostet. Die Frontend‑App wird über Nginx ausgeliefert, das API‑Service und n8n laufen in Docker‑Containern. Für TLS und Reverse‑Proxy soll ein **Traefik**‑Setup eingeführt werden, um alle Dienste hinter HTTPS zu bündeln【222545626117737†L610-L620】. Eine Redis‑Instanz stellt die Queue für n8n bereit. Design‑Tokens und Assets werden über GitHub Actions synchronisiert.

## 2. Datenflüsse & Interaktionen

1. **User Journey – Spenden & Kontakt:** Ein:e Besucher:in ruft die Website (SPA) auf, sendet ein Formular (Kontakt, Spende). Die Anfrage geht an das API‑Service, das Validierung und Consent‑Prüfung vornimmt, Einträge in PostgreSQL schreibt und n8n Workflows auslöst (z. B. DOI‑E‑Mail, Spendenquittung).
2. **Game Flow:** Nutzende starten das Lernspiel im Browser. Fragen und Szenarien werden aus einem JSON geladen; Fortschritt und Ergebnisse können lokal gespeichert oder optional an die API übermittelt werden, um Analysen zu ermöglichen. Das Spiel ist barrierefrei und benötigt keine Login‐Daten【651735299895262†L44-L86】.
3. **CRM Synchronisation:** Regelmäßige Cron‑Jobs oder Webhooks synchronisieren Datensätze zwischen API und CRM (CiviCRM). Spenden mit steuerlicher Abzugsfähigkeit werden an das Finanzamt übermittelt (Einwilligung vorausgesetzt). Newsletter‑Abos werden via n8n an Listmonk übertragen.
4. **Admin Backend & Design‑System:** Redakteur:innen verwalten Inhalte und Theming über Directus. Figma‑Tokens werden automatisch per GitHub Action ins Repository geschrieben und via Tailwind in CSS übersetzt, sodass Frontend und Admin‑Portal einheitliche Designs teilen.

## 3. Empfohlene Architekturverbesserungen

1. **TLS & Reverse Proxy implementieren:** Alle Dienste müssen zwingend über HTTPS erreichbar sein. Nutze Traefik oder Caddy als Reverse‑Proxy mit HSTS und automatischen Let’s‑Encrypt‑Zertifikaten【222545626117737†L610-L620】. Dies schützt n8n und die API vor Man‑in‑the‑Middle‑Angriffen.
2. **Service‑Mesh & Authentisierung:** Führe einen zentralen Identity‑Provider (z. B. Keycloak) ein, der die Authentisierung für SPA, API und Admin‑Backend übernimmt. Für interne Kommunikation kann mTLS oder ein Service‑Mesh (z. B. Istio) sinnvoll sein.
3. **Zentralisiertes Secret‑Management:** Lagere API‑Keys und Tokens aus `.env`‑Dateien in ein sicheres Vault (z. B. HashiCorp Vault). Ergänze Git‑Commit‑Signaturen und SBOM‑Generierung, um Supply‑Chain‑Risiken zu minimieren【222545626117737†L640-L654】.
4. **Audit‑Logging & Observability:** Ergänze OpenTelemetry‑gestützte Logs und Metriken in API, n8n und CRM, speichere sie in einem zentralen Log‑Stack (Loki/Grafana). Audit‑Logs müssen nach DSGVO unveränderbar und versioniert sein【222545626117737†L719-L727】.
5. **Horizontale Skalierung:** Plane den Betrieb der Services in Containern (Docker Compose oder Kubernetes), um Lastspitzen abzufangen. Für die Zukunft kann ein Kubernetes‑Cluster den Betrieb vereinfachen, insbesondere bei mehreren Organisationsinstanzen.
6. **API‑Gateway & Rate‑Limiting:** Schalte ein API‑Gateway vor den FastAPI‑Service, um CORS, Throttling und API‑Keys zentral zu verwalten. Nutze JSON Web Tokens (JWT) oder OAuth2 für gesicherte Endpunkte.
7. **Spiel‑Integration:** Die Spiel‑Engine sollte Daten (Scores, Feedback) optional an das Backend senden, damit diese für Reports und Engagement‑Metriken nutzbar sind. Darüber hinaus könnte das Spiel über ein Plugin‑System erweitert werden, um neue Szenarien ohne Codeänderung zu laden.

## 4. Infrastruktur & DevOps

### Continuous Integration

Der Quickstart‑Guide beschreibt ein Setup mit Node, npm, Docker, Python und PHP. Ergänzend dazu empfehlen wir:

- **Security‑Scans:** Nutze gitleaks für Secrets‑Scans und semgrep für statische Codeanalyse (bereits im Projekt integriert). Ergänze SBOM‑Erstellung via `cyclonedx/cdxgen` und `syft`【222545626117737†L695-L700】.
- **Test‑Orchestrierung:** Integriere Unit‑ und E2E‑Tests (Playwright) in CI‑Pipelines. Zielmetrik: Performance‑Score ≥ 90 & LCP < 2.5 s nach Deployment【541959898361378†L229-L243】.
- **Deployment:** Automatisiere Deployments über GitHub Actions oder GitLab CI/CD. Das `frontend/DEPLOYMENT-READY.md` definiert Umgebungsvariablen wie `VITE_API_BASE_URL`【541959898361378†L36-L44】; nutze Templates, um Environment‑Files sicher zu provisionieren.

### Monitoring & Alerting

- **Uptime‑Monitoring:** Implementiere Uptime Kuma oder Upptime zur Überwachung von HTTPS‑Endpunkten. Definiere Alert‑Regeln für Response‑Zeit und Zertifikatsablauf.
- **Metrics:** Sammle Metriken per Prometheus; visualisiere sie mit Grafana (Spiel‑Nutzung, API‑Latenz, Fehlerquote). Matomo oder Plausible liefern Web‑Analytics, die nach Einwilligung konfiguriert sind.
- **Logging:** Zentralisiere Logs mittels Loki/Elasticsearch. Log‑Richtlinien sollen keine PII speichern und Rotations‑Policies implementieren.

### Backup & Recovery

- **Backups:** Nutze Borg/Borgmatic für Datenbank‑ und Asset‑Backups. Teste regelmäßige Restores (≥ 1×/Monat). Halte die Recovery‑Zeit unter 30 Minuten.
- **Disaster Recovery:** Definiere Runbooks für Ausfall von Plesk, Datenbank oder Reverse‑Proxy. Setze Geo‑Redundanz und Notfallkontaktketten auf.

## 5. Zukunft & Weiterentwicklung

1. **Multi‑Org‑Erweiterung:** Das System soll mehreren Vereinen dienen. Dafür müssen Mandanten‑Trennung, Theme‑Management (Farbpaletten, Logos) und RBAC‑Konzepte in Directus und dem Frontend implementiert werden.
2. **Gamification‑Features:** Ergänze zusätzliche Szenarien, spielerische Elemente (Badges, Levels) und einen Highscore‑Export. Berücksichtige Zugänglichkeit (z. B. Screenreader‑Announcements)【651735299895262†L44-L86】.
3. **Plattform‑API:** Entwickle eine öffentliche API für externe Partner (z. B. Schulen), die Spielstände oder Projektinformationen abrufen möchten. Definiere klare Rate‑Limits und Authentifizierung.
4. **Mobile & PWA:** Optimiere die SPA als Progressive Web App mit Offline‑Fähigkeiten und Push‑Benachrichtigungen. Die LCP‑ und FCP‑Werte müssen auf Mobilgeräten < 2.5 s bleiben【541959898361378†L229-L243】.
5. **AI‑gestützte Auswertungen:** Prüfe mittelfristig den Einsatz von KI (z. B. LLMs), um Feedback aus dem Spiel automatisch zu clustern und personalisierte Lernpfade zu generieren. Berücksichtige dabei Datenschutz und Ethik.

---

Diese Architekturübersicht soll als Living Document dienen. Änderungen an Komponenten, Datenflüssen oder Anforderungen müssen versioniert und in die Roadmap (02) aufgenommen werden.