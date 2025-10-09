---
title: Verein – Mitgliederaufnahme (Leitfaden)
version: 1.0.0
created: 2025-10-08
lastUpdated: 2025-10-08
status: ACTIVE
priority: high
category: general
applyTo: **/*
---

# Verein – Mitgliederaufnahme

Ziel: DSGVO‑konforme, transparente Aufnahme neuer Mitglieder gemäß Statuten (§§ 5, 7, 16) und Beitragsordnung.

– Pflichtangaben: Name, Adresse, E‑Mail, Geburtsdatum, Mitgliedsart, Beitragskategorie, Beitrittsdatum, DSGVO‑Einwilligung (Datum/IP)
– Optional: Telefon, Funktionen/Arbeitsgruppen
– Prüfung: Vorstand entscheidet (einfache Mehrheit); Ablehnung ohne Begründung möglich

Ablauf (operativ)
1) Antrag erfassen (digital/elektronisch) – Validierung und Datenminimierung beachten
2) DSGVO‑Hinweise anzeigen, Einwilligungen dokumentieren (Newsletter nur mit Opt‑In, TKG § 107)
3) Beschluss Vorstand dokumentieren (Aufnahme/Ablehnung)
4) Onboarding‑Mail (Statuten/Beitragsordnung/Datenschutz) – österreichisches Deutsch
5) CRM aktualisieren: Mitgliedsart, Beitragskategorie, Zahlungsart, Beitrittsdatum

Compliance & Sicherheit
– Keine PII in Logs (PII‑Sanitizer aktiv)
– Aufbewahrung: Mitgliedsdaten während Mitgliedschaft + 12 Monate (danach löschen/pseudonymisieren), Finanzdaten 7 Jahre (BAO)
– RBAC im CRM: Least Privilege, MFA für Admins

Referenzen
– .github/instructions/verein-statuten.instructions.md
– .github/instructions/mitgliedsbeitraege.instructions.md
– .github/instructions/dsgvo-compliance.instructions.md
