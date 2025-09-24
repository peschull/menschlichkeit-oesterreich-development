# Projekt — Drupal/CiviCRM

## Stack
- Drupal + CiviCRM, PHP 8.2+, Composer
- Node 20, npm/yarn/pnpm

## Lokale Entwicklung
```bash
composer install
npm ci
npm run lint
```

## CI/Qualität
- GitHub Action **Code Quality**: ESLint + SARIF (Code Scanning)
- Optional **Codacy** (skip, wenn kein Token)

## Deployment (Plesk)
- SSH/Synchronisation:
  - Dry-Run: `scripts/plesk-sync.sh pull` / `scripts/plesk-sync.sh push`
  - Apply:   `scripts/plesk-sync.sh pull --apply` / `... push --apply`
- Datenbank:
  - Pull: `scripts/db-pull.sh`
  - Push (vorsichtig): `scripts/db-push.sh --apply`

## VS Code
- Debug: PHP Xdebug (Port 9003), Node Attach (9229)
- Tasks: Composer install, npm ci, Lint, Drush, DB-Sync, Plesk-Sync

## Konfiguration
1. `.env.sample` → `.env` kopieren und Werte setzen.
2. SSH-Alias `plesk` in `~/.ssh/config` hinterlegen.
