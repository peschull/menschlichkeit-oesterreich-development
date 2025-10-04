Architecture Decision Records (ADRs)

Zweck
- ADRs dokumentieren wichtige Architekturentscheidungen inkl. Kontext, Optionen, Entscheidung und Konsequenzen.
- Quelle der Wahrheit: versioniert im Repo, leicht reviewbar, referenzierbar aus Threat Model und Roadmap.

Konventionen
- Ordner: `docs/architecture/ADRs/`
- Template: `000-template.md`
- Dateiname: `ADR-<nr>-<kebab-case-titel>.md`
- Nummerierung: fortlaufend (dreistellig), beginnend bei 001
- Sprache: Deutsch (kurz und präzise)

Lebenszyklus
- Status: Proposed → Accepted → Superseded → Rejected
- Änderungen an einer Entscheidung erzeugen ein neues ADR, das das alte „superseded“.

Inhalt (Kurzfassung)
- Kontext: Problem, Zielbild, Annahmen
- Optionen: Alternativen mit Vor-/Nachteilen
- Entscheidung: Getroffene Wahl + Begründung
- Konsequenzen: Trade‑offs, Migrationsfolgen, Risiken
- Referenzen: Tickets, Threat Model, Blueprints

Index
- Automatisch generierbar via `npm run docs:adr-index` (siehe `scripts/docs/generate-adr-index.mjs`).

