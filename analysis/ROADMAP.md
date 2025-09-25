# Roadmap: Menschlichkeit Österreich Website-Entwicklung

## Sequentielle Entwicklungsphasen nach akademischen Standards

| Phase                                         | Zeitraum                        | Ziele                                                     | Meilensteine                                                  | Abhängigkeiten                           | Risiken             | Aufwand         |
| --------------------------------------------- | ------------------------------- | --------------------------------------------------------- | ------------------------------------------------------------- | ---------------------------------------- | ------------------- | --------------- |
| **Phase 1: Security & Compliance Foundation** | **KW 39-41 (25.09-15.10.2025)** | Kritische Sicherheits- und Compliance-Risiken eliminieren | Security-Audit abgeschlossen, DSGVO-Konformität implementiert | Hosting-Zugang, Legal-Review             | R-001, R-002, R-006 | **12 PT**       |
| **Phase 2: Infrastructure & CMS Setup**       | **KW 41-43 (13.10-27.10.2025)** | Drupal CMS mit CiviCRM produktionsreif installieren       | CMS funktional, Theme aktiviert, Backup-System implementiert  | Phase 1 abgeschlossen, Domain/DNS        | R-005, R-009, R-010 | **15 PT**       |
| **Phase 3: Frontend Development**             | **KW 44-47 (28.10-24.11.2025)** | React-Frontend mit Design-System implementieren           | Performance-Budget erfüllt, Accessibility-Konformität         | Design-System finalisiert, API-Endpunkte | R-007, R-011, R-015 | **18 PT**       |
| **Phase 4: Integration & Testing**            | **KW 47-49 (17.11-08.12.2025)** | Vollständige System-Integration und Test-Coverage         | E2E-Tests erfolgreich, Monitoring aktiv                       | Frontend & Backend fertig                | R-012, R-015, R-018 | **12 PT**       |
| **Phase 5: Performance & Optimization**       | **KW 49-50 (01.12-14.12.2025)** | Performance-Optimierung und Go-Live-Vorbereitung          | Lighthouse >90, Load-Tests erfolgreich                        | Integration abgeschlossen                | R-011, R-017        | **8 PT**        |
| **Phase 6: Go-Live & Launch**                 | **KW 51-52 (15.12-31.12.2025)** | Produktions-Launch mit Marketing-Kampagne                 | Website live, Marketing aktiviert                             | Alle Phasen abgeschlossen                | R-009, R-012        | **5 PT**        |
| **Phase 7: Wartung & Monitoring**             | **ab KW 01 (01.01.2026)**       | Kontinuierlicher Betrieb und Weiterentwicklung            | SLA etabliert, Release-Zyklen aktiv                           | Go-Live erfolgreich                      | R-013, R-014, R-016 | **fortlaufend** |

## Kritische Abhängigkeiten & Erfolgskriterien

### Phase 1: Security Foundation (Kritisch)

- **T-001**: Dependency Security Audit
- **T-002**: DSGVO Compliance
- **T-010**: Secret Management
- **Erfolgskriterium**: Alle kritischen CVEs behoben, rechtliche Compliance erreicht

### Phase 2: CMS Infrastructure (Basis)

- **T-005**: Drupal + CiviCRM Setup
- **T-004**: Theme-System-Aktivierung
- **T-013**: Database Backup System
- **Erfolgskriterium**: CMS produktionsreif, 600+ Design-Komponenten verfügbar

### Phase 3: Frontend Excellence (Innovation)

- **T-006**: React Frontend Migration
- **T-007**: FastAPI Backend Completion
- **T-012**: WCAG 2.2 Accessibility
- **Erfolgskriterium**: Moderne Frontend-Architektur, Performance >90, Accessibility AA

## Ressourcen & Budget

- **Gesamt-Aufwand**: 70 Personentage (14 Wochen)
- **Team-Größe**: 5-7 Spezialisten
- **Budget-Rahmen**: €35.000 - €50.000
- **Go-Live-Termin**: 15. Dezember 2025
