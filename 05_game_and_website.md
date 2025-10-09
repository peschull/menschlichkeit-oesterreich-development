---
title: "Spiel & Website – Status und Weiterentwicklung"
version: "1.0"
updated: "2025-10-09"
tags: ["Game", "Website", "UX", "Lernziele", "Weiterentwicklung"]
links:
  - "00_bestandsaufnahme.md"
  - "01_alignment.md"
  - "02_aktionsplan.md"
  - "03_styleguide.md"
  - "04_architecture.md"
assumptions:
  - "Die Analyse bezieht sich auf den Stand der Dateien im Verzeichnis `web/games` und auf öffentlich sichtbare Website-Komponenten (Oktober 2025)."
---

# 05 — Spiel & Website – Status und Weiterentwicklung

Dieses Dokument analysiert das Lernspiel „Brücken Bauen“ und die Website aus dem Repository, beschreibt die Nutzererfahrung und definiert konkrete Verbesserungsvorschläge. Es ergänzt die vorhergehende Architekturübersicht und den Aktionsplan.

## 1. Bestehender Stand

### 1.1 Spiel „Brücken Bauen“

Das Spiel ist als webbasierte App in `web/games` abgelegt und ohne Login zugänglich. Es vermittelt Empathie und demokratische Werte durch interaktive Szenarien. Merkmal der aktuellen Version:

- **Barrierefreiheit:** Ein Skip‑Link ermöglicht das Überspringen des Intros; der Fortschrittsbalken besitzt ARIA‑Attribute zur Beschreibung für Screenreader【651735299895262†L44-L86】.
- **Niedrige Einstiegshürde:** Keine Registrierung, keine personenbezogenen Daten. Besucher:innen können sofort mit dem Spiel starten【651735299895262†L6-L17】.
- **Zieldefinition:** Der Begrüßungstext hebt hervor, dass Demokratie und Menschenrechte nur durch Empathie erlernt werden können; die Szenarien sensibilisieren für soziale Ungerechtigkeiten【651735299895262†L44-L86】.
- **Technische Umsetzung:** Das Spiel verwendet Vanilla JS; Szenarien sind als JSON hinterlegt; ein Fortschrittsbalken zeigt den Spielstatus. Es existiert keine Anbindung an das Backend.

### 1.2 Website & Frontend

Die Website ist als Single Page Application angelegt. Sie enthält bislang wenige statische Seiten (Start, Spenden), eine Integration des Spiels und ein rudimentäres Impressum. Wichtige Aspekte:

- **Transparenz:** ZVR‑Nummer und Datenschutzinformationen sind nur teilweise vorhanden; die Mission der NGO ist erklärt, Erfolgsgeschichten fehlen.
- **Formulare:** Kontakt‑ und Spendenformulare kommunizieren mit dem API‑Service; Einwilligungstexte sind teilweise implementiert.
- **Design:** Farben und Typografie orientieren sich am Figma‑Design‑System, jedoch sind nicht alle Komponenten konsistent eingebunden.

## 2. Lernziele & User Experience

Das Spiel verfolgt klare didaktische Ziele: Es soll Mitgefühl fördern, Diskriminierung thematisieren und demokratische Prozesse erfahrbar machen. Um diese Ziele zu erreichen, sollten folgende UX‑Prinzipien beachtet werden:

1. **Narrative Kohärenz:** Die Szenarien sollten eine zusammenhängende Geschichte erzählen und die Verbindung zur NGO‑Mission herstellen (z. B. indem reale Projekte am Ende vorgestellt werden).
2. **Progressive Schwierigkeitsgrade:** Die Lerninhalte können schrittweise anspruchsvoller werden; Rückmeldungen sollen positives Verhalten verstärken.
3. **Barrierefreiheit als Design‑Standard:** Neben Skip‑Links und ARIA‑Labels sollten auch Tastaturbedienung, kontrastreiche Farbschemata und einfache Sprache gewährleistet werden. Eine optionale Audioversion kann das Erlebnis für Menschen mit Sehbeeinträchtigungen erweitern.
4. **Gamification & Motivation:** Badges, Level‑Ups oder ein Highscore‑System können die Motivation erhöhen. Dabei darf kein Leistungsdruck entstehen; das Spiel bleibt ein Lernangebot.

## 3. Technische Verbesserungen

1. **Framework‑Modernisierung:** Die aktuelle Vanilla‑JS‑Implementierung erleichtert das Verständnis, ist jedoch schwer skalierbar. Der Einsatz einer leichten Spielebibliothek wie **Phaser 3** oder **React Three Fiber** kann die Wartbarkeit erhöhen und Animationen vereinfachen. Wichtig: Die Barrierefreiheit muss erhalten bleiben.
2. **Datengetriebene Szenarien:** Statt statischer JSON‑Dateien können Szenarien aus der Datenbank (PostgreSQL) via API geladen werden. Das erleichtert die Erweiterung des Spiels, ohne den Code anpassen zu müssen.
3. **Offline‑Fähigkeit & PWA:** Als Progressive Web App kann das Spiel offline geladen und später synchronisiert werden. Dazu sind Service Worker und ein Cache‑Management zu implementieren. Die LCP‑ und FCP‑Ziele bleiben < 2.5 s laut Deployment‑Guide【541959898361378†L229-L243】.
4. **Analytics & Consent:** Integriere datenschutzfreundliches Tracking (Matomo/Plausible) mit Einwilligung, um Nutzungsmuster zu verstehen und das Spiel zu verbessern. Anonyme Event‑Daten (z. B. Verweildauer, Szenario‑Abbrüche) können in Dashboards visualisiert werden.
5. **Feedback‑Mechanismus:** Eine Option, anonymes Feedback oder Verbesserungsvorschläge zu geben, kann in n8n verarbeitet und in das Consent‑Ledger eingebunden werden.

## 4. Content & Narrativ

Um das Spiel und die Website stärker zu verzahnen, empfiehlt sich ein abgestimmtes Storytelling:

- **Mission & Werte:** Erkläre auf der Startseite, warum das Spiel existiert, und verlinke die Lerninhalte mit aktuellen Projekten und Spendenmöglichkeiten.
- **Blog & Geschichten:** Berichte über Menschen, die von Projekten profitieren, und integriere diese Geschichten als Bonusinhalte im Spiel.
- **Call‑to‑Action:** Am Spielende sollten Nutzer:innen eingeladen werden, den Newsletter zu abonnieren oder zu spenden (Double‑Opt‑In). Das API‑Service und n8n orchestrieren die Datenübergabe.

## 5. Website‑Optimierung & Spenden

1. **Informationsarchitektur:** Ergänze zentrale Seiten wie „Über uns“, „Projekte“, „Transparenz“, „FAQ“. Nutze das YAML‑Frontmatter, um die Navigation abzubilden und interne Links zu erleichtern (siehe Styleguide).
2. **Spenden‑Flow:** Implementiere Spendenformulare mit klaren Betragsoptionen, Spendenzweck und Einwilligung zur steuerlichen Absetzbarkeit. Die API verarbeitet die Zahlung über PSD2‑konforme Dienstleister und n8n generiert eine Spendenquittung.
3. **Mitmach‑Formulare & Events:** Nutze Tally oder self‑hosted Alternativen (siehe Aktionsplan) und integriere sie in n8n. Bewerbe anstehende Events (Protestaktionen, Workshops) mit Kalenderintegration.
4. **Mehrsprachigkeit:** Bereite die Website auf mehrere Sprachen vor (Deutsch/Englisch). Nutze i18n‑Bibliotheken und pflege alle Inhalte in der Datenbank.

## 6. SEO & Performance

Die Seite und das Spiel sollten Suchmaschinenfreundlichkeit und Performance‑Standards erfüllen:

- **Metadaten & semantische HTML:** Verwende aussagekräftige Meta‑Tags (Title, Description, OpenGraph); setze strukturiertes Daten‑Markup (Schema.org) ein.
- **Lighthouse‑Scores:** Zielwerte: Performance ≥ 90, Accessibility ≥ 90, Best Practices ≥ 95, SEO ≥ 90【541959898361378†L229-L243】. Nutze Lazy Loading, Bild‑Optimierung (Squoosh) und Caching.
- **Sitemap & Robots:** Generiere automatisch eine Sitemap.xml und setze `robots.txt`, um Crawling zu steuern.
- **Accessible Links & Buttons:** Stelle sicher, dass Links beschreibend sind („Jetzt spenden“ statt „Klick hier“); Buttons benötigen eindeutige Labels.

## 7. Weiterentwicklung & Vision

1. **Modulare Lernmodule:** Baue zusätzliche Spiele oder Quiz‑Module (z. B. zu Klimagerechtigkeit, soziale Gerechtigkeit). Jedes Modul kann separat aktiviert werden und nutzt die gleiche Datenbasis.
2. **Integration mit Bildungseinrichtungen:** Erstelle Lehrmaterialien, Arbeitsblätter und Lehrerhandbücher, die das Spiel begleiten. Biete APIs, damit Schulen eigene Berichte erhalten.
3. **Community‑Features:** Implementiere ein Forum oder Chat (z. B. Rocket.Chat) zur Diskussion von Szenarien, Feedback und ehrenamtlichen Aktionen. Moderation und Netiquette sind wichtig.
4. **Barrierefreiheit kontinuierlich verbessern:** Nutze Tools wie axe, WAVE und Siteimprove, um regelmässig zu testen. Plane Nutzertests mit Menschen mit Behinderungen.
5. **Offene Schnittstellen & Plugins:** Dokumentiere die Spiel‑API und erlaube Drittentwickler:innen, eigene Szenarien oder Erweiterungen zu erstellen. Ein Plugin‑System fördert Wachstum und Nachhaltigkeit.

---

Dieses Dokument bildet die Grundlage für die Weiterentwicklung des Spiels und der Website. Alle vorgeschlagenen Maßnahmen sollten in den Aktionsplan (02) überführt und entsprechend priorisiert werden.