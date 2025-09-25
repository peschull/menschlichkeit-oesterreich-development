# CiviCRM Fachkonzept — Mitgliedschaften, Contribution Pages, Jobs

## Mitgliedschaftstypen

1. Ordentlich

- duration: 12 months
- auto_renew: optional (RCUR)
- price: example 60 EUR

2. Ermäßigt

- duration: 12 months
- eligibility: custom field proof_required (file upload)
- price: example 30 EUR

3. Fördernd

- duration: 12 months (suggested), variable amount
- price: open amount

## Status-Regeln

- New: created but payment not completed
- Pending: payment processing (e.g., SEPA pending)
- Current: paid and active
- Grace: X days after due (default 30)
- Expired: past grace period

## Price Sets

- Membership Price Set: membership base (select), optional add-on donation (text or select)

## Contribution Pages

- Page 1: Mitglied werden — includes membership type, contact creation, mandate capture, create user account (Drupal)
- Page 2: Spenden einmalig — amounts, recurring toggle
- Page 3: Spenden recurring — set RCUR

## Receipts & Jahresbescheinigung

- Contribution receipts: emailed immediately after contribution
- Jahresbescheinigung: Yearly job that aggregates contributions per contact, creates PDF and emails

## Jobs & Cron

- cv core:execute (Civi cron) every 5–15 minutes
- CiviSEPA: create batches nightly 02:00, export pain.008
- Mailer: process email queue

## Integration notes

- Webform CiviCRM for front-end forms. Webform submits to Civi via Api4
- Webhooks from Stripe processed by Automations API -> create contribution in Civi
- Sensitive fields: store only what's necessary; mask PAN, store last4 if needed
