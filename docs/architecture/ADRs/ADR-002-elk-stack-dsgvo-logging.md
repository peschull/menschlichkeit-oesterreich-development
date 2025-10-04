---
adr: 002
title: ELK Stack für DSGVO-konformes Logging (Sanitization, Retention, Audit)
status: Proposed
date: 2025-10-04
---

# ELK Stack für DSGVO-konformes Logging

Kontext
- Logs enthalten potentiell PII (z. B. E‑Mail, Namen, IP, Session‑IDs) und unterliegen DSGVO.
- Anforderungen: Sanitization (before ingest), Retention je Log‑Klasse, Audit‑Trail, minimaler Zugriff.
- Ziel: Zentrales Logging (ElasticSearch + Logstash + Kibana) mit Privacy‑Kontrollen und Nachweisbarkeit.

Optionen
- A) Lokal/Datei‑basiert (journald, Files) + manuelle Rotation
  - + Einfach, geringe Kosten
  - − Kein zentrales Suchen/Korrelation, hoher manueller Aufwand
- B) ELK Stack selbst betrieben (Docker/Compose, Plesk‑Integration)
  - + Volle Kontrolle, anpassbare Pipelines (Logstash), OPA/OTel integrierbar
  - − Betrieb/Updates, Storage‑Kosten, Härtung notwendig
- C) Managed Logging (Elastic Cloud, Grafana Cloud, Datadog)
  - + Geringer Betriebsaufwand, SLA
  - − Externe Übermittlung, AV‑Verträge/DSFA nötig

Entscheidung
- Kurzfristig: Option B (ELK on‑prem/own infra) für maximalen Datenschutz, mit Sanitization vor Ingest.
- Perspektive: Option C evaluieren, wenn AV‑Vertrag und EU‑Regionen eindeutig sichergestellt sind.

Konsequenzen
- Technisch: Logstash Pipelines mit PII‑Redaction (Regex/Tokenization), Indizes getrennt nach Klassen
  - `logs-operational` (30d), `logs-compliance` (1y), `logs-security-audit` (7y, WORM‑ähnlich)
- Betrieb: Zugriff über least‑privilege Rollen; Export für Auskunftsersuchen (Art. 15) möglich
- Risiken: Fehlende Sanitization führt zu PII‑Lecks → Pflicht: unit tests für Filter, CI‑Checks

Implementierung (Skizze)
- OpenTelemetry überall, Exporter → Logstash HTTP input
- Logstash Filter: Grok + anonymize/redact E‑Mail, Telefonnummern, IBAN; Hash‑Salt für Korrelation
- ILM Policies in ElasticSearch; Snapshots (verschlüsselt)
- Kibana Spaces/RBAC; Audit‑Log für Administratoraktionen

Referenzen
- Threat Model: `analysis/phase-0/threat-model/STRIDE-LINDDUN-ANALYSIS.md`
- Blueprint: `docs/security/SUPPLY-CHAIN-SECURITY-BLUEPRINT.md`
- Retention: `docs/infrastructure/LOG-RETENTION-OPERATIONS.md`

