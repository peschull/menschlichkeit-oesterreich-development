# Menschlichkeit Österreich — CRM & Public Site Technical Dossier

## 0 Vorbemerkung

Dieses Dossier liefert einen umsetzbaren Entwurf für die Betreuung von drei Domains:

- Public: menschlichkeit-oesterreich.at (KEINE Änderungen auf diesem Server)
- CRM: crm.menschlichkeit-oesterreich.at (Drupal 10 + CiviCRM)
- API: api.menschlichkeit-oesterreich.at (Automations-API, JWT, FastAPI)

Ziel: Mitgliederverwaltung, Mitgliedsbeiträge, SEPA + Kreditkarte, Events, DSGVO, A11y, SEO, Performance.

Hinweis: Generierte Secrets werden nicht im Repo gespeichert; in Deployments jeweils in `/root/infra/secrets.env` (0600 root) ablegen.

---

## 1 Inhaltsverzeichnis (Kurz)

1. Executive Summary
2. Informationsarchitektur & Sitemap
3. Content-Modell & YAML-Blueprint
4. Designsystem (Tokens + Komponenten)
5. Wireframes (mobile/desktop)
6. UX-Flows (Mitglied-werden / Spenden / Event)
7. CiviCRM Fachkonzept
8. Zahlungen: SEPA & Kreditkarte
9. Automations-API (OpenAPI 3.0)
10. Architektur & Security
11. Performance / SEO / A11y
12. Teststrategie & Runbook
13. Annahmen, Risiken, Next Steps

---

## 2 Executive Summary

- Plattformarchitektur: Nginx + PHP-FPM (Drupal 10 + CiviCRM) auf Ubuntu 22.04; Automations-API separater Prozess (FastAPI, uvicorn, behind Nginx reverse proxy).
- Datenbank: Vorhanden; wir binden an bestehende DB (Credentials: `/root/infra/db.md`).
- Auth/Secrets: JWT für API, SiteKey/APIKey serverseitig; keine SiteKeys im Frontend.
- Zahlungen: SEPA via CiviSEPA (Mandate + pain.008 Batches), Kreditkarte via Stripe Payment Intents + Webhooks.
- DSGVO: Einwilligungen als Webform-Felder + CiviCRM-Opt-in-Felder; Export/Deletion-API.

Akzeptanz: HTTPS/HSTS aktiv, IA konsistent, Design-Tokens & Komponenten inkl. Kontraste, OpenAPI valide, Tests & Checklisten vorhanden.

---

## 3 Informationsarchitektur & Sitemap

**Ziele:** Max. 7 Hauptnavigationspunkte, klare Breadcrumb-Strategie, SEO-freundliche URLs.

**Navigationsstruktur (Hauptnav, max 7):**

- Startseite (`/`)
- Themen (`/themen`)
- Mitglied werden (`/mitglied-werden`)
- Spenden (`/spenden`)
- Veranstaltungen (`/veranstaltungen`)
- Aktuelles (`/aktuelles`)
- Über uns (`/ueber-uns`)
  - Kontakt (`/kontakt`), Impressum (`/impressum`), Datenschutz (`/datenschutz`)

Breadcrumb-Strategie:

- Home > Section > Subpage (immer `breadcrumb`-JSON-LD on page)

URL-Strategie / Canonical:

- Human-readable, lowercase, hyphenated
- Content pages: `/themen/:slug` (unique), events: `/veranstaltungen/:yyyy/:mm/:slug`
- Member-portal: under CRM domain: `https://crm.menschlichkeit-oesterreich.at/mein-konto` (protected)

Sitemap (auch als `docs/sitemap.mmd` und XML generierbar):

- See file `docs/sitemap.mmd`

---

## 4 Content-Modell (Tabelle) — Siehe `docs/content-model.md` (Kurz hier)

| Content Type                                | Felder (Typ, Pflicht)                                                                                                               | Taxonomien | SEO-Felder                              | Beispiel-URL                  |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- | ---------: | --------------------------------------- | ----------------------------- |
| Article                                     | Title (text, req), Body (long, req), Teaser (text, opt), Image (media, opt, alt req), Tags (term ref)                               |     Themen | meta_title, meta_description, canonical | /aktuelles/:slug              |
| Landing (Mitglied werden)                   | Title, Hero image, Steps (rich list), Price table (entity ref), CTA (link)                                                          |          - | meta\_\*                                | /mitglied-werden              |
| Event                                       | Title, Body, Start/End datetime, Location (text/entity), Capacity (int), Price type (free/paid/members), Registration (webform ref) |     Themen | meta\_\*                                | /veranstaltungen/2025/09/name |
| Member Profile (Drupal user + Civi contact) | Username, Email, Name, Address, Memberships (Civi relation), Accessible preferences (boolean), Consent records                      |          - | -                                       | crm domain: /user/:uid        |

YAML-Blueprints für Drupal-Content-Types: (siehe Abschnitt 5)

---

## 5 Designsystem (Tokens + Komponenten)

**Design-Tokens (Kurz, vollständige JSON in `docs/design-tokens.json`)**

- Kontrastziele: alle Text-Farben mindestens 4.5:1 gegenüber Hintergrund
- Typographie: system-first + Fallback: Inter (400/600/700) / font-size base 16px; UI target >=24px for touch targets
- Spacing: 4,8,12,16,24,32,48
- Radii: 4,8,999 (pill)
- Shadows: small/medium/large

Core-Komponenten (Props & Accessibility notes):

- Header: Landmark `role=banner`, skiplinks, keyboard focus, responsive nav (hamburger)
- Footer: Landmark `role=contentinfo`, sitemap links, small print
- Card: roles, keyboard focus, image alt required
- CTA: primary/secondary/ghost, aria-labels, focus-visible
- Formular: labels, aria-describedby for errors, error inline + summary
- Accordion: button element toggles panel, `aria-expanded`, keyboard arrow control
- Tabs: roving tabindex, `aria-controls`, `aria-selected`
- Hero: H1 visible on homepage, background-image with color overlay for contrast
- Spenden-/Mitgliedschafts-Widget: accessible form, progress and errors, 1-step and multi-step modes

Komponentenspezifikation: `docs/components.md` (Referenz im Repo)

---

## 6 Wireframes (mobile-first)

Siehe `docs/wireframes.md` für vollständige ASCII/Mermaid-Mockups. Kurz: Breakpoints: 360px, 768px, 1024px.

Beispiel — Startseite (mobile -> desktop):

- Header (logo, hamburger)
- Hero (H1, Kurztext, 1–2 CTAs)
- KPI-Stats (3 cols desktop)
- Themen-Cards (grid)
- CTA: Mitglied werden / Spenden
- Footer

---

## 7 UX-Flows (Mitglied werden / Spenden / Event) — flowcharts

Mermaid-Flows im `docs/ux-flows.mmd` (auch eingebettet unten).

```mermaid
flowchart TD
  A[Start: User öffnet /mitglied-werden] --> B[Wahl: Normal / Ermäßigt / Fördernd]
  B --> C{Mitgliedsformular}
  C --> D[Validierung: Pflichtfelder]
  D -->|ok| E[Wahl Zahlungsmethode]
  E --> F[SEPA Flow]
  E --> G[CC (Stripe) Flow]
  F --> H[SEPA Mandat speichern via CiviSEPA]
  G --> I[Stripe PaymentIntent, Card auth]
  H --> J[Contribution record created]
  I --> J
  J --> K[Send confirmation email + receipt]
  K --> L[Member status = Current]
  D -->|fail| M[Show inline errors]
```

---

## 8 CiviCRM Fachkonzept (Mitgliedschaften & Contribution Pages)

Mitgliedschaftstypen:

- Ordentlich (standard): Dauer 12 Monate, auto-renew optional (RCUR)
- Ermäßigt: für Studierende/Rentner; Nachweis-Field required
- Fördernd: Spendenartige Mitgliedschaft, variable contribution

Status-Regeln (vereinfachte Übersicht):

- New: Zahlung ausstehend (created, not completed)
- Current: Zahlung erhalten, active
- Grace: payment late but grace period X days (z.B. 30)
- Expired: membership ended

Preisset-Design (Price Set Beispiele):

- Membership Base: amount fixed (e.g., 60 EUR)
- Zusatzspende: optional (amount ranges)
- Payment Instrument: SEPA / Credit Card

Contribution Pages:

- Page: "Mitglied werden" — includes membership line, user account creation, GDPR opt-in checkbox
- Page: "Spenden einmalig" — suggested amounts, recurring toggle

Quittungen & Jahresbescheinigungen:

- Automatische E-Mail mit contribution receipt (templated)
- Jahresbescheinigung: generate CSV/PDF job yearly for contributions; attach to contact record and email

Jobs:

- CiviCRM cron: job.execute alle 5–15 min
- CiviSEPA: batch-creation job nightly (pain.008), SEPA export and posting

---

## 9 Zahlungen: SEPA & Kreditkarte

SEPA (CiviSEPA):

- Mandate: stored (type FRST/RCUR/OOFF as required)
- Workflow: user signs mandate during signup -> Pre-Notification email X Tage vor batch -> pain.008 file created nightly -> bank submission by operator (or via bank connectivity)
- Files: pain.008.001.02 XML standard
- Batch schedule: pain.008 export nightly at 02:00; Pre-notify 7 days prior
- SEPA email templates: Pre-Notification, Mandate confirmation, Receipt

Kreditkarte (Stripe):

- Flow: Frontend posts to backend to create PaymentIntent with amount and currency; frontend handles Card Element -> confirm
- Webhook path: `https://api.menschlichkeit-oesterreich.at/webhooks/stripe`
- Webhook handling: verify signature; create Civi contribution via APIv4 mapping; attach receipt
- Stripe Testplan: use test keys, test cards, SCA flows

Webhook mapping examples in `docs/payments.md` (incl. event types `payment_intent.succeeded`, `charge.refunded`)

---

## 10 Automations-API (OpenAPI 3.0) — Übersicht

- Base: `https://api.menschlichkeit-oesterreich.at/v1`
- Auth: JWT Bearer; short expiry (5 - 15 min), refresh token optional for internal services
- Rate limiting: global 60 r/min; per-key 10 r/min per endpoint
- Endpoints: `/contacts.create`, `/memberships.create`, `/contributions.create`, `/sepa.mandates.create` (optional)

Beispiel-Schema und vollständige OpenAPI in `api/openapi.yaml`.

---

## 11 Architektur (Mermaid)

```mermaid
graph TD
  subgraph Public
    A[Nginx public vhost (menschlichkeit-oesterreich.at)]
  end
  subgraph CRM
    C[Nginx crm.menschlichkeit-oesterreich.at] --> PHPFPM[PHP-FPM pool: crm]
    PHPFPM --> DRUPAL[Drupal 10 + CiviCRM]
    DRUPAL --> DB[(Postgres/MySQL)]
    DRUPAL --> UPLOADS[/var/www/crm/sites/default/files]
  end
  subgraph API
    API_NGINX[Nginx api reverse proxy] --> FASTAPI[FastAPI (uvicorn)]
    FASTAPI --> DB
    FASTAPI --> STRIPE[Stripe Webhooks]
  end
  A --- C
  C --- API_NGINX
```

Server paths & permissions:

- Webroot: `/var/www/crm` (owner `www-data`, files `0640`, dirs `0750` for sensitive files)
- Uploads: `/var/www/crm/sites/default/files` (owner `www-data:www-data` 0755 dirs, 0644 files)
- Secrets: `/root/infra/secrets.env` (0600 root)

---

## 12 Security & DSGVO

Security headers (Nginx snippet):

```nginx
add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
add_header X-Content-Type-Options nosniff;
add_header X-Frame-Options SAMEORIGIN;
add_header Referrer-Policy "no-referrer-when-downgrade";
add_header Content-Security-Policy "default-src 'self'; img-src 'self' data: https:; script-src 'self' 'unsafe-inline' https://js.stripe.com; style-src 'self' 'unsafe-inline' fonts.googleapis.com;";
```

DSGVO flows:

- Consent captured at Webform + stored in CiviCRM contact custom field (timestamp, source, text)
- Data access/export: provide `/api/export/contact/{id}` (internal, authenticated) to generate download package
- Erasure: implement `DELETE /api/contacts/{id}` to trigger erasure workflow (mark, queue, anonymize) with manual review for donations

Roles & ACL:

- Drupal roles: Site Admin (minimal), CRM Manager, Finance (payments), Event Manager, Support
- Principle: Least privilege — only Finance can see full contribution payment details; Support sees contact data with sensitive fields masked

---

## 13 Performance, SEO, A11y

Performance budgets (mobile, 4G):

- HTML ≤ 60 KB
- CSS ≤ 120 KB (critical inline ≤ 14 KB)
- JS initial ≤ 170 KB
- LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1

Optimizations:

- Drupal: BigPipe, dynamic page cache, render-cache, image styles + WebP
- Nginx: Brotli/Gzip, cache static for long TTLs, cache headers
- Asset pipeline: critical CSS inlined, deferred non-critical JS, modular components

SEO/Schema JSON-LD snippets (Organization, Breadcrumbs, Event):

```json
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Menschlichkeit Österreich",
  "url": "https://menschlichkeit-oesterreich.at",
  "logo": "https://menschlichkeit-oesterreich.at/logo.png",
  "sameAs": []
}
```

A11y checklist (WCAG 2.2 AA highlights):

- Keyboard access: test all forms, modals
- Focus visible: custom focus styles
- Color contrast >= 4.5:1 for text
- Form labels, aria-\* for dynamic content

---

## 14 Tests & Abnahme

Testarten:

- Smoke tests: Drupal up, CiviCRM API reachable, DB connection
- Functional: Member signup (SEPA/CC), Donation (once/recurring), Event signup
- SEPA tests: mandate creation, export pain.008, simulate bank return
- Webhooks: Stripe webhook replay
- Load tests: endpoints `/v1/contributions.create` at target traffic

Launch checklist (Tech/UX/SEO/A11y) — see `docs/tests-acceptance.md`.

---

## 15 Runbook & Betrieb (Kurz)

- Cron: set system cron for Drupal `cron.php` + Civi `cv core:execute` every 5–15min
- Backup: nightly DB dump (GPG encrypted), daily files sync; retention 30 days
- Monitoring: uptime (UptimeRobot), cert expiry (certbot email & cron), API health endpoint `/health` returning JSON

Health endpoint example (FastAPI):

```python
from fastapi import FastAPI
app = FastAPI()
@app.get('/health')
def health():
    return {"status":"ok"}
```

---

## 16 Annahmen & Risiken

- Annahme: DB existiert und ist erreichbar, wir erhalten credentials in `/root/infra/db.md`.
- Risiko: SEPA-Bankintegration erfordert operative Bankzugänge; mitigieren: Start mit manuellem Export/Upload, später SFTP/APIs.
- Risiko: DSGVO Löschanforderungen vs. Buchhaltungspflicht; mitigieren: Pseudonymisierung + retained required financial data per law.

---

## 17 Next Steps (konkret)

- 1. Read DB creds at `/root/infra/db.md` and validate connection (ssh + test script)
- 2. Create environment files `/root/infra/secrets.env` with JWT_SECRET, CiviCRM_SiteKey, APIKey, Drupal admin password
- 3. Install Drupal 10 + CiviCRM with provided DB (non-destructive setup)
- 4. Configure CiviSEPA + Stripe test keys; run SEPA test flow
- 5. Deploy API (FastAPI) behind Nginx and validate OpenAPI endpoints

---

## 18 Dateien (Dateibaum Referenz)

```
docs/technical-dossier.md  (dieses Dokument)
docs/design-tokens.json
docs/components.md
docs/wireframes.md
docs/ux-flows.mmd
docs/sitemap.mmd
api/openapi.yaml
api/examples/contact-create.json
```

---

## 19 Kontakt & Verantwortliche

- Contact Email: admin@menschlichkeit-oesterreich.at

---

_Ende des Dossiers._
