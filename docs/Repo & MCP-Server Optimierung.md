# Hier sind **alle auf der Seite dokumentierten Tools/Befehle** (Figma MCP Server):

* **get_code** – Generiert Code für die aktuelle Figma-Auswahl (Standard: React + Tailwind; durch Prompt anpassbar). *Hinweis:* Auswahl-basiertes Prompting funktioniert nur lokal; der Remote-Server braucht einen Link zu Frame/Layer. ([developers.figma.com][1])
  **Beispiel-Prompts:** Framework wechseln („in Vue“ / „Plain HTML + CSS“ / „iOS“), vorhandene Komponenten nutzen („aus `src/components/ui`“), oder kombinieren („Komponenten aus `src/ui` und Styling mit Tailwind“). ([developers.figma.com][1])

* **get_variable_defs (local only)** – Liefert Variablen/Styles der Auswahl (z. B. Farben, Spacing, Typografie). **Beispiele:** alle Tokens auflisten; auf Typen fokussieren (z. B. Farben & Spacing); Namen **und** Werte ausgeben. ([developers.figma.com][1])

* **get_code_connect_map (local only)** – Gibt ein Mapping von Figma-Node-IDs zu Code-Komponenten zurück (inkl. `codeConnectSrc` und `codeConnectName`) zur Verbindung von Design-Elementen mit ihrer Implementierung. ([developers.figma.com][1])

* **get_screenshot** – Erzeugt einen Screenshot der Auswahl, um Layout-Treue im generierten Code zu verbessern (i. d. R. eingeschaltet lassen). ([developers.figma.com][1])

* **create_design_system_rules** – Erstellt Regel-/Instruktionsdateien, damit Agenten designsystem- und tech-stack-konforme Frontend-Outputs erzeugen (Datei anschließend im passenden `rules/` bzw. `instructions/` Pfad speichern). ([developers.figma.com][1])

* **get_metadata** – Gibt eine schlanke XML-Outline der Auswahl (IDs, Namen, Typen, Position/Größe) zurück; nützlich bei großen Designs oder Mehrfachauswahl/ganzer Seite, damit der Agent gezielt `get_code` nur für benötigte Teile aufruft. ([developers.figma.com][1])

Wenn du willst, fasse ich das als kurze Referenz-Tabelle (mit Zweck, lokal/remote, typische Prompts) zusammen.

[1]: https://developers.figma.com/docs/figma-mcp-server/tools-and-prompts/ "Tools and prompts | Developer Docs"


> Zielbild: Production-ready NGO-Plattform mit DSGVO-Konformität, WCAG-AA-Accessibility, Zero-Trust-Security und nachweisbarer Supply-Chain-Sicherheit.

---

## Phase 0: Tiefgründige Analyse & Bestandsaufnahme

_Geschätzte Dauer: 2-3 Tage_

### 🔍 Repository Inventory & Provenance

- [x] **Asset Mapping**: Vollständige Dokumentation aller 19 Plesk-Subdomänen in `docs/infrastructure/SUBDOMAIN-REGISTRY.md`
- [x] **Code Provenance**: Eigenentwicklungen vs. Third-Party-Komponenten je Service erfasst
- [x] **License Audit**: SPDX-kompatible Lizenz-Matrix und Third-Party Notices (`docs/security/LICENSE-AUDIT-2025-10-04.md`, `docs/security/THIRD-PARTY-NOTICES.md`)
- [x] **Technical Debt Assessment**: Codacy MCP Baselines für Maintainability & Duplication erstellt

### 🛡️ Security Threat Modeling (STRIDE/LINDDUN)

- [x] **API Surface Analysis**: FastAPI Endpoints & Auth-Flows modelliert
- [x] **Frontend Attack Vectors**: React/TypeScript Threat Scenarios dokumentiert (`docs/security/FRONTEND-THREAT-MODEL.md`)
- [x] **CRM Security Review**: Drupal 10 + CiviCRM Hardening und Rollenmodell analysiert
- [x] **MCP Server Security**: Tool-Isolation und Input-Validation Threat Model ergänzt (`docs/security/MCP-SERVER-THREAT-MODEL.md`)
- [x] **n8n Workflow Security**: PII-Sanitization Pipelines und Webhook Hardening modelliert

### 📊 DSGVO Data Flow Mapping

- [x] **PII Data Flows**: End-to-End Datenfluss (User → CRM → API → Frontend → ELK) dokumentiert
- [x] **Consent Management**: CiviCRM Consent-Module + API Bridge beschrieben
- [x] **Retention Policies**: ILM 30d/1y/7y für `logs-operational`, `logs-compliance`, `logs-security-audit`
- [x] **PII Sanitization Pipeline**: FastAPI, Drupal/CiviCRM und n8n Logs sanitisiert (`api.menschlichkeit-oesterreich.at/PII-SANITIZATION-README.md`, `crm.menschlichkeit-oesterreich.at/web/modules/custom/pii_sanitizer/README.md`, `automation/n8n/custom-nodes/pii-sanitizer/README.md`)
- [x] **Right to Erasure**: Automatisierte Lösch-Workflows (`automation/privacy/right_to_erasure.py`, `automation/n8n/workflows/right-to-erasure.json`, `docs/legal/RIGHT-TO-ERASURE-WORKFLOW.md`)
- [x] **Cross-Border Transfers**: Hosting in EU-Plesk-Region verifiziert

### 🎯 Attack Surface Review

- [x] **Network Topology**: Subdomain- und Port-Matrix mit Risk-Klassifizierung
- [x] **Authentication Flows**: JWT/Refresh, n8n Webhook Secrets, 2FA-Roadmap dokumentiert (`docs/security/AUTHENTICATION-FLOWS.md`)
- [x] **Secrets Management**: Struktur `config-templates/` + `secrets/` mit Encryption Scripts definiert
- [x] **External Integrations**: Figma, Payment, n8n, WordPress Bridges erfasst

### 📋 Supply Chain Security

- [x] **SBOM Generation**: CycloneDX/SPDX Export für npm/composer/pip in CI (siehe `docs/security/SUPPLY-CHAIN-SECURITY-BLUEPRINT.md`)
- [x] **Vulnerability Scanning**: Trivy via Codacy CLI nach Änderungen verpflichtend
- [x] **Reproducible Builds**: Docker Compose und Lockfiles für deterministische Builds
- [x] **Dependency Pinning**: Versions-Constraints in `package.json`, `composer.lock`, `requirements.txt`

---

## Phase 1: Repository Hygiene & Legacy Cleanup

_Geschätzte Dauer: 1-2 Tage_

### 🧹 Policy-Driven Cleanup

- [x] **Retention Rules**: Automatisierte Aufräum-Skripte (`scripts/purge-logs.py`, `docs/infrastructure/LOG-RETENTION-OPERATIONS.md`)
- [x] **Archive Strategy**: Historische Analysen nach `analysis/archive/` überführen (`scripts/archive-analysis.py`, `docs/infrastructure/ARCHIVE-STRATEGY.md`)
- [x] **Dev Cleanup Script**: `npm run clean` für alle Workspaces (`scripts/clean-workspace.mjs`, `docs/infrastructure/WORKSPACE-HYGIENE.md`)
- [x] **Git LFS Migration**: Große Assets (PDF, Medien) migrieren (`.gitattributes`, `scripts/git-lfs-migrate.sh`, `docs/infrastructure/GIT-LFS-MIGRATION.md`)

### 🔄 Monorepo Dependency Hygiene

- [ ] **Cross-Service Check**: Shared Libraries und API Contracts konsolidieren
- [ ] **Duplicate Detection**: Utility-Funktionen zentralisieren (`packages/shared`)
- [ ] **Workspace Optimierung**: npm/pnpm Workspaces dokumentieren und absichern
- [ ] **Build Graph**: Parallelisierbare Builds und Abhängigkeiten definieren

### 🛡️ Security History Cleanup

- [ ] **Historic Secret Scan**: `git secrets`/`trufflehog` gegen gesamte Historie
- [ ] **Credential Purge**: BFG / git filter-repo bei Funden anwenden
- [ ] **Commit Signing Rollout**: GPG + Sigstore Guidelines veröffentlichen
- [ ] **Branch Protection**: Baseline-Regeln definieren und anwenden

### 📊 Quality Baseline Establishment

- [ ] **Codacy Snapshot**: Qualitatives Ausgangsprofil im Repo dokumentieren
- [ ] **Test Coverage Baseline**: Coverage-Thresholds pro Service festlegen
- [ ] **Performance Baseline**: Lighthouse/Playwright Messpunkte definieren
- [ ] **Security Scorecard**: OWASP ASVS / DevSecOps Maturity initial bewerten

---

## Phase 2: Living Documentation & Governance

_Geschätzte Dauer: 3-4 Tage_

### 📚 Automated Documentation Generation

- [ ] **Automation**: Swagger UI Build Step in CI für FastAPI
- [ ] **Typedoc**: Automatisierte TS-Komponentendokumentation für `frontend/`
- [ ] **Prisma ERD**: Visualisierung der Datenbankmodelle generieren
- [ ] **Design Tokens Docs**: Storybook/Zeroheight Sync mit Figma Tokens

### 🏗️ Architecture Decision Records (ADRs)

- [x] **ADR-001**: Multi-Service Architektur & Plesk Deployment
- [ ] **ADR-002**: ELK Stack für DSGVO Logging
- [ ] **ADR-003**: Drupal/CiviCRM Brücken-Architektur
- [x] **ADR-004**: MCP Server Sicherheitsmodell
- [ ] **ADR-005**: Frontend State & API Communication Patterns

Siehe `docs/architecture/ADRs/ADR-INDEX.md` (automatisch generierbar mit `npm run docs:adr-index`).

### 📖 Operational Playbooks

- [ ] **Dev Runbook**: Onboarding, Lokale Umgebung, Tests, Deploy
- [ ] **Security Incident**: PII Leak, Auth Failure, DDoS Response
- [ ] **DSGVO Requests**: Export/Delete/Consent Verfahren
- [ ] **Performance Troubleshooting**: ELK, DB, Caching Leitfaden
- [ ] **Disaster Recovery**: Backup/Restore, Plesk Rollback

### 👥 Governance Framework

- [ ] **Maintainer RACI**: Verantwortlichkeiten pro Subsystem
- [ ] **Review Policy**: 2-Reviewer Pflicht, Security Sign-off
- [ ] **Release Process**: SemVer, Release Branching, Changelog Automation
- [ ] **Security Champion**: Rolle, Pflichten, Eskalationspfade

### ✅ Compliance Blueprints

- [ ] **DSGVO Checklist**: Automatisierte Prüfmatrix im CI
- [ ] **WCAG AA**: axe-core Pipeline + manuelle Auditvorgaben
- [ ] **Austrian Legal**: Vereinsrechtliche Anforderungen, Aufbewahrungspflichten
- [ ] **Supply Chain**: SLSA Kontrollpunkte & Audit Trail

---

## Phase 3: Zero-Trust CI/CD Pipeline

_Geschätzte Dauer: 4-5 Tage_

### 🔐 Zero-Trust Security Model

- [ ] **Commit Signing**: GPG + Sigstore verpflichtend
- [ ] **Artifact Signing**: Cosign für Images & Bundles
- [ ] **SLSA Attestation**: Build Provenance Artefakte speichern
- [ ] **OIDC Integration**: Keyless Signierung via GitHub Actions

### ⚡ Ephemeral Build Infrastructure

- [ ] **Fresh Runners**: Keine langfristigen Runner, Ephemeral Agents
- [ ] **Container Builds**: Reproduzierbare Build-Container je Sprache
- [ ] **Secrets Rotation**: Automatisierte Schlüsselrotationen implementieren
- [ ] **Secure Caching**: Kurzlebige, signierte Build-Caches

### 🎯 Multi-Stage Pipeline Architecture

1. **Stage 1 – Quality & Security Gates**
   - [ ] ESLint, PHPStan, Flake8/Pylint
   - [ ] Jest/PHPUnit/pytest mit Coverage ≥80%
   - [ ] Secret Scans (GitLeaks, Trufflehog)
   - [ ] Dependency Audits (npm/composer/pip)
2. **Stage 2 – Integration Tests**
   - [ ] FastAPI Integration & Contract Tests
   - [ ] Prisma Migration Smoke Tests
   - [ ] CiviCRM Sync Tests
   - [ ] n8n Workflow Validation
3. **Stage 3 – Security & Compliance**
   - [ ] CodeQL/Semgrep/Bandit SAST
   - [ ] OWASP ZAP / DAST Scans
   - [ ] Container Scans (Trivy/Grype)
   - [ ] License Compliance (FOSSA/ORT)

### 🎭 End-to-End & UX Testing

- [ ] **Playwright**: Kern-User-Journeys abdecken
- [ ] **Lighthouse CI**: Performance ≥90, Accessibility ≥90
- [ ] **axe-core**: Automatisierte WCAG Checks
- [ ] **Responsive Tests**: Geräte- & Browsermatrix

### 🚪 Release Gates & Deployment

- [ ] **Quality Gates**: Alle Checks grün, Coverage eingehalten
- [ ] **Manual Approval**: Security Champion Freigabe für Prod
- [ ] **Blue-Green Deployment**: Plesk Zero-Downtime Rollout
- [ ] **Rollback Playbook**: Automatisiertes Failback

---

## Phase 4: Internationalisierung (Industrial Strength)

_Geschätzte Dauer: 2-3 Tage_

### 🌍 i18n Quality Assurance Pipeline

- [ ] **Key Completeness**: Fehlende Übersetzungen automatisch melden
- [ ] **Pluralization Checks**: ICU MessageFormat Validierung
- [ ] **Translation Quality**: Automatisierte Metriken & Review Workflow
- [ ] **Context Screenshots**: Visuelle QA aus dem Build

### 🔄 Translation Workflow Automation

- [ ] **Machine Translation**: DeepL Seed + Confidence Scores
- [ ] **TMS Integration**: Crowdin/Lokalise Pipeline
- [ ] **Reviewer Workflow**: Native Speaker Approval Steps
- [ ] **Release Sync**: Übersetzungs-Freeze vor Deployments

### 🎭 Pseudo-Locale & Layout Testing

- [ ] **en-XX Locale**: 150%-Stringlänge für Layoutstress
- [ ] **RTL Simulation**: Arabisch/Hebräisch Testläufe
- [ ] **Unicode Edge Cases**: Emoji, diakritische Zeichen
- [ ] **Visual Regression**: Screenshot-basierte Vergleiche

### 🚀 Fallback Strategie

- [ ] **Locale Hierarchy**: de-AT → de → en Kaskade in Code und Docs
- [ ] **Partial Translation Handling**: Graceful Degradation
- [ ] **Dynamic Loading**: Lazy-Loading & Code-Splitting der Lokalisationen
- [ ] **CDN Distribution**: Regionale Bereitstellung optimieren

---

## Phase 5: GitHub Governance & Security

_Geschätzte Dauer: 2 Tage_

### 🏛️ Branch Protection as Code

- [ ] **Infrastructure as Code**: Terraform/Probot Policies versionieren
- [ ] **Required Reviews**: Mehrstufige Review-Regeln definieren
- [ ] **Status Checks**: Pflichtchecks (CI, Security, Coverage) erzwingen
- [ ] **Admin Bypass Policy**: Escalation Playbook dokumentieren

### 🛡️ GitHub Security Features

- [ ] **Dependabot**: Update-Strategie & Scheduling
- [ ] **Advanced Security**: CodeQL & Secret Scans aktivieren
- [ ] **Custom Queries**: DSGVO-Datenfluss Detection Rules
- [ ] **Alert Routing**: Slack/E-Mail Integration

### 📋 Community Health

- [ ] **Issue Templates**: Bug/Feature/Security Vorlagen
- [ ] **PR Templates**: Review-Checkliste, Security & Testing Angaben
- [ ] **SECURITY.md**: Responsible Disclosure Policy
- [ ] **FUNDING.yml**: Spenden/Support Optionen

---

## Phase M: MCP-Server Optimierung (über Best Practice hinaus)

_Geschätzte Dauer: 3-4 Tage (iterativ)_

### ✅ Sicherheits- und Zuverlässigkeitsziele

- [ ] **Formale Absicherung (Light)**: Property‑Based Tests für Kern‑Contracts/Tools (`mcp-servers/*`) mit randbasierten Inputs und Invarianten.
- [ ] **Isolation pro Tool-Aufruf**: Prozess‑Sandboxing (seccomp‑bpf, bubblewrap/gVisor) oder MicroVMs (Firecracker) je Execution.
- [ ] **Runtime Policy Enforcement**: OPA/Rego‑Policies oder eBPF‑Guards für Ein-/Ausgabe‑Validierung (Schema, Größe, erlaubte Syscalls, Netz‑Ziele).
- [ ] **Confidential Computing Option**: Evaluate TEEs (Intel SGX/TDX, AMD SEV) für hochsensible Operationen; Fallback definieren.
- [ ] **Observability**: OpenTelemetry Traces/Metrics/Logs mit Korrelation zu Request‑IDs; Sensitive Fields per Default redacted.
- [ ] **Anomaly Detection**: Baseline‑Modelle für Request‑Raten, Latenzen, Fehlertypen; automatische Quarantäne/Degradation.
- [ ] **Chaos Engineering**: Fault Injection (Timeouts, Partitions, OOM) und Flooding‑Tests (Backoff, Circuit‑Breaker) im CI‑Modus.
- [ ] **Supply Chain Hardening**: SBOM für MCP (CycloneDX), signierte Images/Bundles (Cosign), Build‑Attestations (SLSA ≥ L3).
- [ ] **Four‑Eyes Release**: Zwei Maintainer signieren Releases (GPG/Sigstore), Policy in Branch‑Protection verankert.
- [ ] **Zero‑Knowledge Audits**: Audit‑Trails beweissicher (Hash‑Chains, Nonce, Timestamps), ohne Nutzergeheimnisse offenzulegen.

### 🔧 Umsetzungsschritte (empfohlen)

- [ ] Test‑Schicht erweitern: Property‑Tests (fast‑check) + Contract Tests je Tool‑Schema.
- [ ] Sandbox‑Adapter: Wrapper, der je Tool im Subprozess mit seccomp‑Profil/namespace startet; File/Net‑Allowlist erzwingt.
- [x] Policy‑Layer: JSON‑Schema für Inputs/Outputs + OPA Gate (deny by default) vor/nach jedem Tool‑Call.
- [ ] Telemetry‑SDK: OTel Exporter (OTLP/gRPC), standardisierte Attribute (service.name, tool.name, request.id).
- [ ] Resilience‑Pattern: Timeouts, Retries (Jitter), Bulkhead, Circuit‑Breaker; Chaos‑Jobs in CI.
- [x] Supply‑Chain Pipeline: CycloneDX SBOM Export (minimal) per Workflow `.github/workflows/sbom-generation.yml`.
- [ ] Release‑Policy: Required reviewers + required signatures; Tag‑Signing enforced.

### 🛡️ Security History Cleanup

Ziel: Versehentlich committete Secrets und sensible Artefakte aus der Git‑Historie entfernen, Token rotieren und Schutzmechanismen verankern.

Empfohlener Ablauf (koordiniert):

1) Inventory & Befund
- Vollständiger History‑Scan: `scripts/security/gitleaks-history-scan.sh`
- Findings konsolidieren: betroffene Pfade (z. B. `.env`, Dumps), konkrete Secrets (PATs, API Keys)

2) Rewrite‑Plan erstellen (Change Freeze!)
- Team informieren, PRs pausieren, Rebase‑Konflikte einkalkulieren
- Liste zu entfernender Pfade/Patterns definieren

3) Git‑Historie bereinigen (git‑filter‑repo)
- Trockenlauf: `FILES_TO_REMOVE=".env,.env.mcp" ./scripts/security/git-history-cleanup.sh --dry-run`
- Ausführung: `FILES_TO_REMOVE=".env,.env.mcp" ./scripts/security/git-history-cleanup.sh`
- Force‑Push: `git push --force --prune origin --all && git push --force --prune origin --tags`

4) Nachbereitung
- Tokenrotation: alle betroffenen Secrets revozieren/neu ausstellen (GitHub PATs, API Keys)
- Zugriff invalidieren: alte Deploy Keys, CI‑Secrets, Webhooks prüfen
- Re‑Clone kommunizieren: Forks/Clones müssen neu aufgesetzt werden

5) Prävention verankern
- Pre‑Commit Hooks: `.pre-commit-config.yaml`; Install: `scripts/setup/install-pre-commit.sh`
- CI‑Gates: Gitleaks, CodeQL, Trivy, SBOM als Pflicht‑Checks (siehe Workflows)
- Branch‑Protection: `scripts/github/require-status-checks.sh` ausführen

Hinweise
- History‑Rewrite ist destruktiv und erfordert enges Team‑Vorgehen.
- Alte Klone enthalten weiterhin die Daten – nur Neu‑Clones sind „sauber“.


### 🔗 Referenzen

- Threat Model Details: `analysis/phase-0/threat-model/STRIDE-LINDDUN-ANALYSIS.md`
- Supply Chain: `docs/security/SUPPLY-CHAIN-SECURITY-BLUEPRINT.md`
- OPA Policy: `mcp-servers/policies/opa/tool-io.rego`
- Seccomp Profil: `mcp-servers/policies/seccomp/node-min.json`
- SBOM CI: `.github/workflows/sbom-generation.yml`
- Seccomp Runner: `scripts/run-mcp-file-server-seccomp.sh`
- Branch Checks Script: `scripts/github/require-status-checks.sh`
### 🧪 HowTo: OPA Policy lokal testen

```bash
# Voraussetzung: opa CLI installiert
scripts/policies/test-opa-policy.sh
```

### 🧪 HowTo: MCP File Server isoliert starten (Demo)

```bash
# Voraussetzung: bubblewrap (bwrap) installiert
chmod +x scripts/run-mcp-file-server-seccomp.sh
./scripts/run-mcp-file-server-seccomp.sh servers/src/file-server/index.js -- --port 7070
```

- OPA in Devcontainer: `.devcontainer/setup.sh` installiert `opa` (optional)
 - OPA in CI: `.github/workflows/phase-0-verify.yml` installiert `opa` vor der Verifikation
 - Branch‑Protection Automatisierung: `.github/workflows/branch-protection.yml` läuft täglich (main + `release/*`)

---

## Abschluss: Definition of Excellence (Beyond Best Practice)

_Abnahmekriterien für „Enterprise‑Ready“_

- [ ] **Vollständige Analyse & Threat‑Model**: STRIDE/LINDDUN dokumentiert, Findings priorisiert, Maßnahmen geplant.
- [ ] **Repository‑Hygiene**: Keine Altlasten/Secrets, LFS korrekt, deterministische Builds (Lockfiles, `npm ci`, SOURCE_DATE_EPOCH).
- [ ] **SBOM & Supply Chain**: SBOMs generiert und signiert; SLSA L3 Attestations vorhanden; Dependency‑Scans gate‑relevant.
- [ ] **Lebende Dokumentation**: Automatisch generiert (Swagger/Typedoc/ERD), ADRs vorhanden, Runbooks/Playbooks vollständig.
- [ ] **Governance & Compliance**: Maintainer‑Rollen, Review‑Policy, Security‑Champion; DSGVO/WCAG Blueprints im CI prüfbar.
- [ ] **Zero‑Trust CI/CD**: Ephemere Runner, signierte Commits/Artefakte, mehrstufige Security‑Gates, Release‑Gates strikt.
- [ ] **I18n QA**: Pseudo‑Locale, Pluralisierungs‑ und Vollständigkeitschecks automatisiert, Fallback‑Kaskade dokumentiert.
- [ ] **GitHub as Code**: Branch‑Protection/Policies versioniert; Security‑Tab (Dependabot, CodeQL) maximal genutzt.
- [ ] **MCP‑Server**: Sandboxed, resilient, observierbar; Policies & Property‑Tests vorhanden; Releases mit Four‑Eyes Prinzip.
- [ ] **Nachweisbarkeit**: DSGVO + WCAG + Supply‑Chain Compliance auditierbar; Artefakte in Releases/Docs verlinkt.


### 🚀 Release Automation

- [ ] **Conventional Commits**: Commitlint & Guidelines
- [ ] **Semantic Release**: Automatisierte Versionierung + Changelog
- [ ] **Multi-Language Release Notes**: Deutsch & Englisch automatisiert
- [ ] **Release Dashboards**: Metrics & Audit Trail

### 👥 Maintainer Lifecycle

- [ ] **Bus Factor Mapping**: Kritische Wissensgebiete dokumentieren
- [ ] **Onboarding Programm**: Checklisten & Schulungen
- [ ] **Access Review**: Quartalsweises Berechtigungs-Audit
- [ ] **24/7 Incident Rota**: Bereitschaft & Eskalationsketten

---

## Phase 6: MCP-Server Optimierung (beyond best practice)

_Geschätzte Dauer: 3-4 Tage_

### 🔒 Formal Verification & Property Testing

- [ ] **Property-Based Tests**: Hypothesis/QuickCheck für Core Contracts
- [ ] **Contract Tests**: Pre/Post-Conditions für Tool-Ausgaben
- [ ] **Fuzzing**: AFL++/libFuzzer gegen Parser & Serialisierer
- [ ] **Model Checking**: TLA+/Alloy für Concurrency-Modelle

### 🏰 Isolation & Sandboxing

- [ ] **Rootless Containers**: Default-Ausführungsumgebung absichern
- [ ] **MicroVMs**: Firecracker/gVisor für High-Security Tools
- [ ] **Seccomp/BPF**: Syscall Policies je Tooling-Profil
- [ ] **Resource Limits**: CPU/Memory/IO Caps pro Invocation

### 📊 Runtime Policy Enforcement

- [ ] **OPA/Gatekeeper**: Admission Policies für MCP Requests
- [ ] **eBPF Monitoring**: Low-Level Telemetrie & Blocking
- [ ] **Falco Ruleset**: Runtime Anomalieerkennung
- [ ] **Audit Logging**: Zero-Knowledge fähige Audit Trails

### 🔐 Confidential Computing

- [ ] **TEE Evaluation**: Intel SGX / AMD SEV Proof-of-Concept
- [ ] **Encrypted Memory**: Sensible Operationen in geschützten Bereichen
- [ ] **Remote Attestation**: Vertrauensketten dokumentieren
- [ ] **Key Management**: HSM/HashiCorp Vault Integration

### 📈 Observability & Detection

- [ ] **OpenTelemetry**: Tracing & Metrics Export
- [ ] **Prometheus/Grafana**: Dashboards für Throughput & Errors
- [ ] **ML Anomalieerkennung**: Ungewöhnliche Zugriffe erkennen
- [ ] **Chaos Engineering**: Failure Injection Szenarien

### 🔗 Supply Chain Security (MCP)

- [ ] **SLSA Level 3**: Build- und Release-Attestation
- [ ] **SBOM Exporte**: Signierte MCP Server SBOMs
- [ ] **Dual Control Releases**: Vier-Augen-Prinzip enforced
- [ ] **Transparency Log**: Öffentliche Nachvollziehbarkeit der Releases

---

## Definition of Excellence (Beyond Best Practice)

### ✅ Abschlusskriterien je Phase

- **Phase 0**: Threat Models, Datenflüsse, SBOMs und Attack Surface vollständig dokumentiert
- **Phase 1**: Repository ohne Altlasten, signierte Historie, deterministische Builds
- **Phase 2**: Lebende Dokumentation, ADRs, Runbooks und Governance-Prozesse aktiv
- **Phase 3**: Zero-Trust CI/CD mit SLSA-konformen Artefakten & Release Gates
- **Phase 4**: Vollautomatisierte i18n QA, Pseudo-Locale Tests, stabile Fallbacks
- **Phase 5**: Repository-Governance als Code, Security- und Community-Standards umgesetzt
- **Phase 6**: MCP-Server nachweislich resilient, sandboxed, beobachtbar und auditierbar

### 📊 Kennzahlen & Monitoring

- **Security**: A+ Bewertung, 0 kritische CVEs, laufende Trivy & CodeQL Checks
- **Compliance**: DSGVO/WCAG Audit Reports ohne Abweichungen, dokumentierte Consent Logs
- **Performance**: Lighthouse P ≥90, A11y ≥90, Backend P95 <100ms
- **Reliability**: RTO ≤4h, RPO ≤24h, Monitoring & Alerting etabliert
- **Maintainability**: Codacy Maintainability ≥85, Code Duplication ≤2%
- **Supply Chain**: SLSA Attestations, signierte Releases, SBOM in CI validiert

### ♻️ Kontinuierliche Verbesserungszyklen

- [ ] **Wöchentliche Security Scans** automatisieren und protokollieren
- [ ] **Monatliche Compliance Audits** (DSGVO, WCAG, Lizenz) durchführen
- [ ] **Quartalsweise Architektur Reviews** & Technical-Debt Abbau planen
- [ ] **Jährliche Penetration Tests** dokumentieren und Remediation verfolgen

---

_Letzte Aktualisierung: 2025-10-04_ · _Version: 2.0_ · _Status: Living Document_
