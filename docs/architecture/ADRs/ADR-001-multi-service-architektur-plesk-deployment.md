---
adr: 001
title: Multi-Service Architektur & Plesk Deployment
status: Accepted
date: 2025-10-04
---

# Multi-Service Architektur & Plesk Deployment

Kontext
- Mehrere Services (Frontend, API, CRM/Drupal+CiviCRM, n8n, Web/Games) werden gemeinsam entwickelt und auf Plesk betrieben.
- Anforderungen: Trennung von Zuständigkeiten, schnelle Deployments, DSGVO‑Konformität, Zero‑Trust‑CI/CD.

Optionen
- Monolith auf Plesk (ein PHP/Node Stack)
- Multi‑Service mit separaten Subdomains (heute)
- Vollcontainerisierte Umgebung (Kubernetes oder Compose)

Entscheidung
- Multi‑Service + Subdomains auf Plesk mit klarer Trennung der Build‑/Deploy‑Pipelines.

Konsequenzen
- Pro: Klare Verantwortlichkeiten, zielgerichtete Security‑Härtung pro Service, unabhängige Deployments.
- Contra: Mehr CI‑Komplexität, Cross‑Service‑Versionierung nötig.
- Compliance: Datenschutzhinweise pro Subsystem, Logs/Retention je Service.

Referenzen
- Netzwerk/Ports: `docs/Repo & MCP-Server Optimierung.md`
- Threat Model: `analysis/phase-0/threat-model/STRIDE-LINDDUN-ANALYSIS.md`
- Deploy: `.github/workflows/plesk-deployment.yml`
