# Tests & Abnahme — Checklisten und Testfälle

## Smoke Tests (prior to launch)

- [ ] Nginx serving `crm.menschlichkeit-oesterreich.at` over HTTPS
- [ ] Drupal responds (200) at `/` and `/user/login`
- [ ] CiviCRM API reachable via Api4
- [ ] DB connection successful using `/root/infra/db.md`
- [ ] Automations API `/v1/health` returns 200

## Functional Tests

- Member signup (SEPA): create contact, store mandate, create contribution (test)
- Member signup (CC): create contact, PaymentIntent success, contribution created
- Donation once: success, receipt emailed
- Event signup: capacity enforced, confirmation email

## SEPA Tests

- Mandate creation (test mode), pain.008 file generation
- Pre-notification email sent X days before
- Simulate SEPA return (R-transaction) and ensure contribution marked accordingly

## Webhook Tests

- Stripe webhook verification: replay test events
- Ensure idempotency: duplicate webhook won't create duplicate contributions

## Load & Performance

- Run load test: `contributions.create` 100 rps for 1 min in staging
- Verify LCP/CLS/INP budgets under target

## Acceptance Criteria (DoD)

- All smoke & functional tests pass
- OpenAPI validated (no errors)
- Security headers present and TLS A+
- WCAG AA checklist items validated
- Backup and monitoring configured
