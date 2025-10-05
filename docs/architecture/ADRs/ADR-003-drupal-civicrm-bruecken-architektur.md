---
adr: 003
title: Drupal/CiviCRM Brücken-Architektur (API‑Bridge, Consent, Sync)
status: Proposed
date: 2025-10-04
---

# Drupal/CiviCRM Brücken-Architektur

Kontext
- CRM (Drupal 10 + CiviCRM) verwaltet Mitglieder/Spenden; Frontend/API interagieren über definierte Schnittstellen.
- Anforderungen: DSGVO‑konforme Consent‑Flows, Sync zwischen CRM und API‑Daten, robuste Fehlerbehandlung.

Optionen
- A) Direkte DB‑Kopplung (API greift auf CRM‑DB zu)
  - + Einfach
  - − Bricht Isolation, Sicherheitsrisiken, Schema‑Kopplung
- B) REST/GraphQL‑Bridge (empfohlen)
  - + Saubere Verträge, Ratenbegrenzung, Auditierbarkeit
  - − Mehr Overhead, Versionierung nötig
- C) Event‑basierte Synchronisation (n8n/Queues)
  - + Entkopplung, Retry, Backpressure
  - − Eventual Consistency, Komplexität

Entscheidung
- Primär B (API‑Bridge mit klaren Endpunkten) + Ergänzung C für Async‑Sync (Newsletter‑Opt‑ins, Spenden‑Events).

Konsequenzen
- API‑Versionierung, OpenAPI‑Verträge, Code‑Gen für Client
- Consent‑Objektmodell standardisieren, Herkunft/Beweis (Double Opt-In) speichern
- Fehlerbehandlung/Retry Policies, Dead‑Letter Queue für Sync‑Fehler

Implementierung (Skizze)
- API `POST /consents`, `GET /contacts/:id`, `POST /donations`
- n8n Workflows für Batch‑Sync und Retries
- CiviCRM Webhooks → API, mit HMAC‑Signatur + Replay‑Schutz

Security & Compliance
- Auth (JWT/MTLS), Rate Limiting, Audit‑Logs
- PII‑Sanitization in Logs (vor ELK), Retention Policies beachten

Referenzen
- Threat Model: `analysis/phase-0/threat-model/STRIDE-LINDDUN-ANALYSIS.md`
- Consent/PII: `docs/legal/RIGHT-TO-ERASURE-WORKFLOW.md`, `docs/security/AUTHENTICATION-FLOWS.md`
