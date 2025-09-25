# Static Website

Optimierte statische Seite mit Bootstrap 5 und Performance/A11y‑Verbesserungen.

## Dev / Tests

- Lighthouse Report: `npm run lh:ci -w website`
- Lokaler Server: `npm run serve -w website` → http://localhost:4180

## Hinweise

- CSP/Headers serverseitig setzen: siehe `servers/SECURITY-HEADERS-WEBSITE.md`
- Externe Ressourcen (Bootstrap, Icons, Google Fonts) können optional self‑hosted werden.
- `assets/js/crm-api.js` ist an das FastAPI‑Schema angepasst (`/auth/login`, `/contacts/create`, `/memberships/create`).

