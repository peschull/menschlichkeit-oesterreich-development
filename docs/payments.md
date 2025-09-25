# Zahlungen — SEPA & Kreditkarte (Stripe)

## Überblick

- SEPA via CiviSEPA: mandate collection and storage in CiviCRM, pain.008 batch export nightly
- Kreditkarte via Stripe: PaymentIntents, SCA-ready flow, webhooks to API

## SEPA Mandate lifecycle

1. User fills IBAN/BIC on signup, agrees to mandate (checkbox with legal text)
2. Mandate stored in CiviCRM via APIv4 + CiviSEPA
3. Pre-notification email X days before debit (configurable, default 7 days)
4. Batches generated nightly (pain.008), operator reviews and uploads to bank
5. Bank returns (e.g., R-transactions) handled via import and CiviCRM job

## SEPA Config

- Mandate types: FRST for first of recurring, RCUR for recurring, OOFF for one-off
- Pain.008 generation: nightly cron 02:00
- Email templates: pre-notify, mandate confirmation, receipt

## Stripe

- Create PaymentIntent server-side:
  - POST `/v1/payments/create-intent` (internal) with amount, currency, customer_id (Civi contact id)
  - Return client_secret to frontend to confirm
- Webhook path: `https://api.menschlichkeit-oesterreich.at/webhooks/stripe`
  - Verify signature
  - On `payment_intent.succeeded` -> POST to `/contributions.create` mapping PaymentIntent -> Civi contribution
  - On `charge.refunded` -> create refund record in Civi

## Test plan (Stripe)

- Use test API keys
- Test cards: 4242 4242 4242 4242 (success), 4000 0000 0000 9995 (insufficient funds), 4000 0025 0000 3155 (SCA required)

## Webhook security

- Validate Stripe signature header
- Use secret stored in `/root/infra/secrets.env`
