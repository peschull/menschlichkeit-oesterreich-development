# Content Model — Drupal Content Types, Fields & Taxonomies

## Overview

Enthält Content Types, Felder, Validierungen und Beispiel-URLs. Implementierbar via YAML Blueprints (`config/install/node.type.*.yml`)

## Content Types

1. Article

- machine_name: `article`
- fields:
  - title: (string, required)
  - body: (text_long, required)
  - field_teaser: (text, optional, max 300)
  - field_image: (media image, optional) — alt required
  - field_tags: (entity_reference taxonomy term `themen`)
  - field_published_date: (datetime)
- SEO: metatag module: meta_title, meta_description, canonical
- URL pattern: `/aktuelles/[node:created:custom:Y]/[node:created:custom:m]/[node:title:clean-url]`

2. Landing — Membership

- machine_name: `landing_membership`
- fields:
  - title: (string, required)
  - field_hero: (media image)
  - field_steps: (paragraphs or entity reference list)
  - field_price_set: (entity reference to price set config)
  - field_cta_link: (link)
- URL: `/mitglied-werden`

3. Event

- machine_name: `event`
- fields:
  - title (string, required)
  - field_body (text_long)
  - field_start (datetime, required)
  - field_end (datetime)
  - field_location (text or entity reference)
  - field_capacity (integer)
  - field_registration_webform (entity reference webform)
  - field_price_type (list: free, paid, members-only)
- URL: `/veranstaltungen/[node:field_start:custom:Y]/[node:field_start:custom:m]/[node:title:clean-url]`

4. Page (static)

- machine_name: `page`
- fields: title, body, field_sidebar (optional)
- URL: `/ueber-uns/:slug` or `/kontakt`

5. Member Profile (special mapping):

- Stored primarily as Drupal user + CiviCRM contact. Fields kept minimal in Drupal profile (display-only): membership status, next_payment_date, receipts link

## Taxonomies

- Themen (`themen`): vocabulary for topical tagging
- Zielgruppen (`zielgruppen`): optional

## Media

- Image style presets: hero_large (1200w), card (400w), thumb (160w)
- Serve WebP: use `image_style` + `responsive_image` module with WebP variants

## Forms

- Webform + Webform CiviCRM for signup, donation, event registration
- Webform configuration: GDPR consent checkbox (boolean, required), marketing consent optional

## YAML Blueprint sample (Article)

```yaml
langcode: en
status: true
dependencies: {}
name: article
type: article
description: "News & updates"
third_party_settings: {}
```
