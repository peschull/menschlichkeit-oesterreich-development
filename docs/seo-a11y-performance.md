# SEO / Accessibility / Performance Plan

## Performance Budgets (mobile, 4G)

- HTML ≤ 60 KB
- CSS ≤ 120 KB (critical inline ≤ 14 KB)
- JS initial ≤ 170 KB
- LCP ≤ 2.5s, INP ≤ 200ms, CLS ≤ 0.1

## Lighthouse / Measurement

- Run Lighthouse CI in CI (staging) on key pages: /, /mitglied-werden, /spenden, /veranstaltungen
- Track budgets and fail CI if budgets exceeded

## Caching

- Drupal: enable BigPipe, Dynamic Page Cache, Internal Page Cache
- Varnish optional in front of Nginx for advanced caching
- Nginx: gzip or brotli, long cache for static assets

## Images

- Use responsive image styles + WebP
- Critical images lazy-loaded except hero above-the-fold

## Structured Data (JSON-LD)

- Organization, BreadcrumbList, Event, FAQ, Article

## A11y Checklist (WCAG 2.2 AA)

- Keyboard navigation: all interactive elements reachable
- Focus visible: strong outline on focus
- Forms: labels, aria-describedby for error text
- Contrast: text >= 4.5:1 with background
- Media: captions/transcripts where applicable
