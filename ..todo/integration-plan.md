# Integrations‑ und Entwicklungsplan für das Projekt „Menschlichkeit Österreich”

## 1 Vorhandene Architektur und Repository‐Übersicht

Das Repository `peschull/menschlichkeit‑oesterreich‑development` enthält mehrere Komponenten:

* **API und CRM** – separate Services unter `api.menschlichkeit‑oesterreich.at` und `crm.menschlichkeit‑oesterreich.at`. Im Quick‑Start‑Dokument werden Node.js, Python, PHP und Docker als Voraussetzungen genannt und erläutert, wie die Dienste (Frontend, API, CRM und Game‑Prototyp) lokal gestartet werden【857750931709268†L1-L240】. Die Services kommunizieren über ein gemeinsam genutztes Netzwerk (`moe‑network`) und nutzen ein Multi‑Service‑Setup.
* **Admin‑/Design‑System** – im Ordner `figma-design-system` finden sich Design‑Tokens und Skripte zur Synchronisation mit Figma. Das Dokument *ADMIN‑FIGMA‑INTEGRATION* beschreibt, wie Directus als Datenhub genutzt wird, um organisation­sabhängige Farb‑ und Feature‑Flags (z. B. `primary_color`, `has_spenden`) in einer Collection `org_theme` zu verwalten【958410027123900†L87-L116】. Es zeigt zudem, wie diese Tokens via Next.js dynamisch als CSS‑Variablen in den Head injiziert werden【958410027123900†L120-L149】.
* **Automation (n8n)** – unter `automation/n8n` liegen Workflows sowie Docker‑Compose‑Dateien. Die Datei `docker-compose.yml` startet einen n8n‑Container mit Redis und PostgreSQL und bindet ihn in das bestehende Netzwerk ein【983310614422925†L5-L40】. Die Anleitung *N8N‑WORKFLOW‑IMPORT‑GUIDE* beschreibt den Import eines GDPR‑Workflows und betont die Verwendung von HMAC‑Signaturen und einer separaten PostgreSQL‑Datenbank für n8n【329721949218354†L46-L68】. Für den Produktivbetrieb existiert eine HTTPS‑Variante mit einem Caddy‑Proxy.
* **Frontend** – der React‑basierte Webauftritt liegt im Ordner `frontend`. Die Production‑Build‑Dokumentation zeigt, dass der Build mit Vite erstellt wird, Feature‑Flags wie „Games”, „Spenden”, „Newsletter” und „Analytics” aktiviert sind und die API‑ und CRM‑Endpoints via .env konfiguriert werden【919455216997748†L38-L50】. Die Deployment‑Anleitung umfasst Nginx‑Konfiguration, CORS‑Einstellungen und Performance‑Ziele (Lighthouse ≥ 90 Punkte)【919455216997748†L105-L156】.
* **Game‑Prototyp** – unter `web/games/prototype` befindet sich das Spiel „Democracy Metaverse – Prototype”. Das Manifest beschreibt eine Progressive‑Web‑App (PWA) für ein interaktives Lernspiel mit demokratischen Werten【769311913929266†L1-L18】. Die Index‑Datei zeigt eine umfangreiche UI mit Dashboard für demokratische Werte, Kapitel‑ und Level‑Auswahl sowie unterschiedlichen Spielbildschirmen (Level, Bosskampf usw.)【941920187732365†L167-L221】. Ein Service Worker implementiert Offline‑Caching, Hintergrund‑Synchronisation von Spielständen und Push‑Benachrichtigungen【356282111022341†L1-L24】.
* **Weitere Komponenten** – ein ELK‑Stack (`automation/elk-stack`) für DSGVO‑konformes Logging; Skripte für Security‑Scans (gitleaks, semgrep) und ein umfangreiches Dokumentenset in `docs` und `quality-reports` (Threat‑Models, Deployment‑Checklisten, rechtliche Verfahrensbeschreibungen).

Die vorhandene Architektur ist somit bereits modular und nutzt moderne Open‑Source‑Technologien. Ziel des folgenden Plans ist es, diesen Stack mit zusätzlichen Open‑Source‑Bausteinen (Directus, Listmonk, Matomo/Plausible, Rocket.Chat, pretix, Meilisearch) zu ergänzen, die vorhandenen Workflows mit n8n zu orchestrieren und das Spiel sowie die Website weiterzuentwickeln.

## 2 Erweiterte Zielarchitektur (Open‑Source)

Die nachfolgende Grafik beschreibt die geplante modulare Architektur. Sie integriert sich in das bestehende `moe‑network` und nutzt Docker‑Compose als Orchestrierung.

| Komponente | Zweck | Integration |
|-----------|------|-------------|
| **Directus** | Headless‑Datenhub auf PostgreSQL zur Verwaltung von Personen, Spenden, Events, Einwilligungen und Org‑Themes. Er ersetzt punktuelle JSON‑Dateien und vereint Daten aus API, Frontend und Game. | Läuft als eigener Dienst. Über `org_theme` können Design‑Tokens aus Figma dynamisch pro Organisation bereitgestellt werden【958410027123900†L87-L116】. n8n nutzt Directus REST/GraphQL für CRUD‑Operationen. |
| **n8n** | Orchestrierung von Formular‑, Spenden‑, Newsletter‑, Event‑ und DSGVO‑Workflows. Nutzt Redis (Queue‑Mode) und PostgreSQL. | Der bestehende `docker-compose.yml` wird erweitert: n8n erhält Queue‑Mode und Credentials für Directus, Listmonk, pretix etc. Neue Workflows automatisieren Double‑Opt‑In, Quittungserstellung, Event‑Registrierungen, Daten‑Exporte, Consent‑Ledger usw. |
| **Listmonk** | Open‑Source‑Newsletter mit Double‑Opt‑In und DSGVO‑Modul. | Registrierungen aus dem Frontend werden via n8n an Listmonk übermittelt. Newsletter‑Formular erhält DOI‑Ablauf und Tag‑Verwaltung. |
| **Matomo oder Plausible (Self‑Hosted)** | Datenschutzfreundliche Web‑Analyse für Website und Game. | Wird im Docker‑Compose integriert und erhält Daten via `api_proxy` (Nginx). Consent‑Manager übergibt Einwilligungssignale; IP‑Anonymisierung aktiviert. |
| **Meilisearch** | Volltextsuche für Website (Blog/FAQ) und Game‑Inhalte. | Indizierung erfolgt über n8n‑Cronjobs und Directus. Frontend bindet die API per SDK ein. |
| **pretix** | Ticketing für Events. | Registrierungen werden via pretix‑Webhook an n8n gesendet; n8n speichert Daten in Directus und sendet Bestätigungs‑E‑Mails. |
| **Rocket.Chat & Zammad** | Community‑Chat und Support‑Ticket‑System. | Beide Dienste werden optional als zusätzliche Container integriert; n8n postet Benachrichtigungen (z. B. bei Spenden oder Helpdesk‑Tickets). |
| **ELK‑Stack** | Zentralisiertes Logging inkl. PII‑Sanitizer. | Bereits vorhanden; wird ergänzt um Log‑Input von Directus, n8n und neuen Diensten. |
| **Traefik/Caddy** | Reverse‑Proxy mit TLS‑Termination. | Für n8n, Directus, Listmonk und Matomo wird Caddy oder Traefik verwendet, analog zur bestehenden `docker-compose.https.yml`. |

## 3 Datenmodell und Workflows

Ein zentrales relationales Schema (PostgreSQL) wird über Directus abgebildet. Es enthält folgende Kern‑Tabellen:

| Tabelle | Wichtige Felder |
|--------|----------------|
| **person** | `id`, `name_official`, `email`, `phone`, `date_of_birth`, `address`, `zvr_bezug`, `created_at` |
| **consent** | `id`, `person_id`, `purpose` (Enum: newsletter, donation, event, cookies), `version`, `text_hash`, `granted_at`, `revoked_at` |
| **donation** | `id`, `person_id`, `amount`, `currency`, `method`, `provider_ref`, `received_at`, `earmark` |
| **subscription** | `id`, `person_id`, `channel` (Enum: newsletter, sms), `status` (pending/active), `doi_token`, `doi_confirmed_at` |
| **event_registration** | `id`, `event_id`, `person_id`, `fields_json`, `status` |
| **media_release** | `id`, `person_id`, `scope`, `expires_at` |
| **audit_log** | `id`, `actor`, `action`, `entity`, `before`, `after`, `ip`, `timestamp` |
| **org_theme** | `org_id`, `primary_color`, `secondary_color`, `logo_url`, `is_donation_enabled`, `requires_birthdate`, `legal_disclaimer` (gemäß ADM‑Figma‑Integration【958410027123900†L87-L116】). |

**n8n‑Workflows (Beispiele):**

1. **Kontakt/Volunteer‑Formular** – Webhook erhält Daten aus dem Frontend, validiert Felder, speichert Person und Consent in Directus, generiert Bestätigungs‑Mail, erstellt Ticket in Zammad und sendet Slack/Rocket‑Benachrichtigung.
2. **Newsletter‑Signup** – setzt einen Datensatz in `subscription` auf `pending`, generiert DOI‑Token, sendet Bestätigungs‑Mail via Listmonk; bei Bestätigung wird `status` auf `active` gesetzt und der Datensatz an Listmonk übermittelt.
3. **Spendenflow** – empfängt Webhook von Stripe/Mollie/Payrexx, prüft Signatur, speichert `donation`, generiert Quittung (PDF), sendet E‑Mail, trägt Spende in Finanz‑Export ein. Fragt Name laut Melderegister und Geburtsdatum für automatische Spendenmeldung (nötig seit 2017) ab【769311913929266†L1-L18】.
4. **Event‑Registrierung** – pretix‑Webhook → validiert Ticket, legt `event_registration` an, sendet iCal‑Einladung und Wartelisten‑Logik.
5. **Privacy‑Requests (DSGVO)** – Workflow `right-to-erasure` aus der bestehenden Infrastruktur wird ausgebaut: n8n speichert die Anfrage im Audit‑Log und triggert den FastAPI‑Endpoint. Die Import‑Anleitung zeigt, wie der Workflow manuell importiert und aktiviert wird【329721949218354†L46-L68】.
6. **Content Publishing** – Redakteure erstellen Artikel in Directus; beim Publish‑Flag generiert n8n dynamische OG‑Images (z. B. via @vercel/og), posted Social‑Media‑Teaser und sendet Newsletter‑Entwürfe an Listmonk.
7. **Monitoring & Reports** – Cron‑Jobs messen KPIs (Spenden, Registrierungen, DOI‑Rate), nutzen Matomo API und posten wöchentlich automatisierte PDF‑Berichte an Vorstandsmitglieder.

## 4 Implementierungsschritte

### 4.1 Vorbereitung und Infrastruktur

1. **Code‑Stand prüfen:** Stelle sicher, dass alle Dienste lokal lauffähig sind und die bestehenden Container (API, CRM, Frontend, n8n) mittels `docker compose` gestartet wurden【983310614422925†L5-L40】. Führe gitleaks und semgrep aus (siehe `docs/QUICKSTART.md`)【857750931709268†L1-L240】.
2. **Plan für neue Dienste:** Erweitere `automation/n8n/docker-compose.yml` oder nutze ein übergeordnetes `docker-compose.override.yml`. Füge folgende Container hinzu:
   * `directus`: konfiguriert auf die zentrale Datenbank (PostgreSQL). Lege Administrator‑Benutzer an, definiere Collections laut Datenmodell und importiere Figma‑Design‑Tokens als `org_theme`【958410027123900†L87-L116】.
   * `listmonk`: Richte die Datenbank auf denselben PostgreSQL‑Server ein. Aktiviere DOI und konfiguriere SMTP für E‑Mails.
   * `matomo` oder `plausible`: Setze `MATOMO_DATABASE_HOST`, `MATOMO_DATABASE_USER` usw. an. Integriere Cron für GeoIP‑Updates.
   * `meilisearch`: Starte den Dienst mit Master‑Key; implementiere n8n‑Cron, der Content aus Directus indiziert.
   * Optionale: `pretix`, `rocket.chat`, `zammad`, `uptime‑kuma`. Nutze `traefik` oder `caddy` (analog zu `docker-compose.https.yml`) zur TLS‑Terminierung【426713340988998†L7-L72】.
3. **Netzwerk erweitern:** Erstelle ein gemeinsames Netzwerk `moe-platform` oder erweitere `moe-network` als `external`. Alle Dienste verwenden dieses Netzwerk, sodass API‑Calls via Service‑Namen funktionieren.
4. **Secrets verwalten:** Nutze `.env` für sensible Daten. Verschlüssele secrets optional mit `sops` und versioniere nur verschlüsselte Dateien. Stelle `N8N_WEBHOOK_SECRET` und HMAC‑Keys ein【329721949218354†L46-L68】; generiere JWT‑Secrets für FastAPI und API‑Keys für Listmonk und pretix.

### 4.2 Directus konfigurieren

1. **Collection‑Anlage:** Melde dich im Directus‑Admin an, erstelle Collections entsprechend des oben beschriebenen Schemas. Definiere Relations (1‑n, n‑m) und nutze Validations (z. B. `email` unique). Ergänze `org_theme` zur Speicherung von Branding‑Informationen【958410027123900†L87-L116】.
2. **Rollen & Berechtigungen:** Lege Rollen für „Admin”, „Redakteur”, „Volunteer‑Manager” etc. an. Verknüpfe sie mit den entsprechenden CRUD‑Rechten und Filterregeln (z. B. Volunteers dürfen nur ihre Daten sehen). Aktiviere MFA für Admins.
3. **Webhooks:** Konfiguriere Directus‑Webhooks, die bei Änderungen an `person`, `consent`, `donation` oder `event_registration` n8n triggern. Nutze HMAC‑Signaturen; validiere diese in n8n.

### 4.3 n8n‑Workflows implementieren

1. **Repository strukturieren:** Halte n8n‑Workflows im Verzeichnis `automation/n8n/workflows`. Unterteile nach Domain (e.g. `donations/`, `subscriptions/`, `events/`). Versioniere Workflows als JSON; erstelle Import‑/Export‑Scripts.
2. **Setup Queue‑Mode:** Passe Umgebungsvariablen an (`EXECUTIONS_PROCESS=queue`, `QUEUE_BULL_REDIS_HOST=redis-n8n`). Aktiviere Basic‑Auth und Metrics【983310614422925†L5-L40】.
3. **Standard‑Nodes:** Nutze HTTP‑Request‑Nodes für Directus und Listmonk; Postgres‑Nodes für Abfragen; Function‑Nodes für Signatur‑Validierung und PDF‑Generierung (z. B. mit `@n8n-community/pdf` Package).
4. **Consent Ledger:** Jeder Workflow, der personenbezogene Daten verarbeitet, schreibt einen Eintrag in `audit_log`. Nutze `consent`‑Tabelle zur Versionsverwaltung von Einwilligungs­texten (Text‑Hash). Bei Widerruf wird `revoked_at` gesetzt.
5. **Error‑Handling:** Implementiere Catch‑Nodes; schreibe Fehler in eine separate Collection; versende Alerts via Rocket.Chat. Definiere Retry‑Strategien bei externen API‑Fehlern.

### 4.4 Frontend‑Integration

1. **Umgebungsvariablen:** Ergänze `.env.production` des Frontends um Directus‑Base‑URL und neue Dienste. Beispiel: `VITE_DIRECTUS_URL=https://cms.menschlichkeit-oesterreich.at`.
2. **APIs nutzen:** Implementiere React‑Hooks (z. B. mit SWR) für Daten aus Directus und Meilisearch. Für Spenden und Events werden Requests an die API gesendet; n8n orchestriert im Hintergrund.
3. **Consent‑Management:** Integriere einen Consent‑Manager (z. B. consentmanager oder Cookiebot) und binde Web‑Analyse nur nach Einwilligung ein. Der Service‑Worker des Games nutzt eine separate Caching‑Strategie【356282111022341†L11-L24】; stelle sicher, dass Analytics‑Requests erst nach Consent abgerufen werden.
4. **Design‑System:** Binde die Figma‑Tokens via Tailwind Configuration ein. Die Dokumentation zeigt, wie Tokens aus Directus geladen und zur Laufzeit als CSS‑Variablen gesetzt werden【958410027123900†L120-L149】. Nutze `framer-motion` und `@shadcn/ui` Komponenten (bereits in den Abhängigkeiten enthalten) für konsistente UI.
5. **SEO & Performance:** Verwende React Helmet zum Setzen von Metadaten; generiere OG‑Bilder dynamisch (siehe n8n‑Workflow). Führe Lighthouse‑Tests (im Build‑Script integriert) durch und erreiche die Zielwerte ≥ 90【919455216997748†L105-L156】.

### 4.5 Game‑Prototyp weiterentwickeln

Der „Democracy Metaverse”‑Prototyp demonstriert ein ambitioniertes Spielkonzept als statische HTML‑/JS‑PWA. Um das Spiel produktionsreif zu machen, werden folgende Schritte empfohlen:

1. **Framework‑Migration:** Portiere den Prototyp in eine modulare Architektur. Empfehlenswert ist **React + Three.js/Phaser** oder **Next.js** mit React‑Server‑Components. Dadurch lassen sich States, Routen und Komponenten besser strukturieren, und das Spiel kann in den bestehenden Frontend‑Stack integriert werden.
2. **State‑Management & Speicherung:** Nutze einen zentralen Store (z. B. Zustand oder Redux Toolkit) zur Verwaltung von Spielfortschritt, Werten und Einstellungen. Synchronisiere Fortschritt über die API – speichere Spielstände als JSON in Directus (`save_game` Collection) und ermögliche Background‑Sync via Service‑Worker【356282111022341†L428-L463】.
3. **Barrierefreiheit:** Berücksichtige WCAG 2.2: alle interaktiven Elemente müssen tastatur­bedienbar sein; ARIA‑Attribute wie `role=progressbar` sind bereits im Prototyp vorhanden【941920187732365†L94-L123】. Ergänze Screen‑Reader‑Texte, ausreichende Farbkontraste, skalierbare Schriftgrößen und einen „Barrierefreiheits‑Modus”.
4. **Multiplayer & Sozialer Kontext:** Füge optionale soziale Elemente hinzu, z. B. Ranglisten, Kooperations‑Level oder Diskussionen via Rocket.Chat‑Integration. Dabei müssen Datenschutz‑Vorgaben (Pseudonymisierung, Einwilligungen) gewahrt bleiben.
5. **Gamification & Fortschritt:** Erweitere das Level‑System um Missionsziele, Quiz‑Elemente und Rückmeldungen. N8n‑Workflows können Meilenstein‑E‑Mails oder Badge‑Benachrichtigungen versenden.
6. **Analytics & A/B‑Testing:** Nutze Matomo/Plausible zur Analyse des Spielverlaufs und zur Optimierung der Lernziele. Starte A/B‑Tests (z. B. alternative Level‑Reihenfolge) und werte sie via n8n‑Report aus.
7. **Deployment als PWA:** Behalte die PWA‑Funktion bei – offline‑Caching, Push‑Notifications und Hintergrund‑Synchronisation sind in `sw.js` schon implementiert【356282111022341†L1-L24】. Prüfe, ob Browser‑APIs (File Handling, Protocol Handler) weiterhin nötig sind; update gegebenenfalls Manifest.

## 5 Weiterentwicklung der Website

Neben dem Spiel erfordert auch die restliche Website kontinuierliche Weiterentwicklung:

1. **Barrierefreiheit & UX:** Stelle sicher, dass alle Seiten der Website Level AA der WCAG 2.2 erfüllen. Nutze Tools wie WAVE, axe DevTools und das in `docs/security/FRONTEND‑THREAT‑MODEL.md` beschriebene Threat‑Model, um potenzielle XSS‑Risiken zu minimieren.
2. **Spenden & Fundraising:** Integriere RaiseNow/Donorbox oder FundraisingBox über ein DSGVO‑konformes Widget; verwende SCA‑konforme Zahlungsprozesse. N8n übernimmt nachgelagert Quittungserstellung und Spendenmeldung (ZVR‑Nummer anführen). Kommuniziere Spendenabsetzbarkeit klar im Frontend.
3. **Event‑Modul & CRM:** Koppeln der pretix‑Events mit dem CRM (CiviCRM) via n8n. Zeige kommende Veranstaltungen auf der Website und ermögliche Registrierungen. Automatisiere Wartelisten und No‑Show‑Management.
4. **Community & Newsletter:** Biete über Rocket.Chat thematische Räume (z. B. für Eltern, Lehrer, Jugendliche). Nutze Listmonk für Newsletter‑Kampagnen und segmentiere Abonnenten nach Interessen. Implementiere ein Double‑Opt‑In‑Modal.
5. **Suche & Wissensdatenbank:** Implementiere Meilisearch‑basierte Suche über Blog‑Posts, FAQs und Game‑Inhalte. Nutze Synonym‑Listen und Filteroptionen. Wähle Lunr.js als Fallback für Client‑only‑Suche, falls Meilisearch nicht geladen ist.
6. **Continuous Integration/Deployment:** Nutze GitHub Actions (vorhanden in `.github/workflows`) zur automatischen Ausführung von Tests, Security‑Scans, Build‑Artefakten und Plesk‑Deployment. Ergänze Jobs für Directus Schema Migrations, n8n Workflow Validation und Docker Scans.
7. **Monitoring & Backup:** Ergänze Uptime Kuma oder Upptime für Status‑Seiten. Nutze Prometheus + Grafana für interne Metriken. Automatisiere Backups mit Borgmatic; teste monatlich Restore‑Prozeduren.

## 6 Roadmap und Zeitplan

Ein iterativer Plan stellt sicher, dass bestehende Funktionalität nicht gefährdet wird. Zeitangaben sind Vorschläge – die tatsächliche Dauer hängt von Team‑Kapazitäten ab.

| Phase (2 Wochen) | Schwerpunkte |
|-----------------|---------------|
| **1. Analyse & Setup** | Ist‑Analyse des Systems; Datenmodell finalisieren; Docker‑Compose um neue Dienste erweitern; Directus installieren; GitHub Actions für neue Dienste einrichten. |
| **2. n8n‑Workflows & Consent‑Ledger** | Implementieren der Kontakt‑, Newsletter‑ und Spenden‑Workflows; Consent‑Ledger und Audit‑Log einführen; Testen mit Staging‑Daten. |
| **3. Frontend‑Integration** | Erweiterung der React‑App um Directus‑Abfragen; Consent‑Manager integrieren; Meilisearch‑Suche implementieren; UI‑Komponenten mit Figma‑Tokens synchronisieren. |
| **4. Game‑Migration (MVP)** | Portierung des Spiels in React/Phaser; State‑Management und API‑Speicherung implementieren; Basic Level‑Flow bereitstellen; PWA‑Funktionen testen. |
| **5. Events & Community** | pretix‑Integration; Rocket.Chat & Zammad einrichten; Event‑Seiten im Frontend; n8n‑Workflows für Tickets und Benachrichtigungen. |
| **6. Analytics & Reports** | Matomo/Plausible einbinden; KPI‑Dashboards in Grafana oder Directus; automatisierte wöchentliche Reports via n8n. |
| **7. Hardening & Go‑Live** | Security‑Audit (OWASP Top 10, Semgrep); Lasttests; Backup‑Recovery‑Proben; Rechtsdokumente (Impressum, Datenschutzerklärung, AGB) finalisieren. |
| **8. Iteration & Skalierung** | Feedback aus Pilotphase auswerten; weitere Levels und Mini‑Spiele entwickeln; Personalisierung und A/B‑Testing einführen; Internationalisierung (mehrsprachigkeit). |

## 7 Schlussbemerkung

Dieser Plan integriert die bestehenden Stärken des Projekts „Menschlichkeit Österreich” – modernes Frontend, n8n‑Automationen und einen ambitionierten Game‑Prototyp – mit einer umfassenden Open‑Source‑Plattform. Durch Directus als zentralen Datenhub, n8n als Orchestrierungs‑Layer und zusätzliche Dienste wie Listmonk, Matomo und Meilisearch wird eine skalierbare und DSGVO‑konforme Infrastruktur geschaffen. Die Weiterentwicklung des Spiels sowie der Website orientiert sich an Best‑Practices (Barrierefreiheit, Performance, Security) und gewährleistet eine nachhaltige digitale Plattform für sozialpolitische Bildung.

