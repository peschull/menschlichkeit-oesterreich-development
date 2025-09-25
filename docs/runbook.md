# Runbook — Betrieb & Wartung

## Tages-Checks

- [ ] Check uptime for `crm.menschlichkeit-oesterreich.at`
- [ ] Check `/health` endpoints for API
- [ ] Verify failed cron jobs

## Backups

- DB: nightly dump `mysqldump` or `pg_dump` -> GPG encrypt -> S3 or remote host
- Files: daily rsync of `/var/www/crm/sites/default/files` -> remote
- Retention: 30 days

## Recovery

- Restore DB from latest backup -> restore files -> disable caches -> `drush updatedb` if necessary

## Deploy

- Put site in maintenance mode
- Pull changes -> `composer install` -> `drush cim` -> `drush cr` -> exit maintenance

## Monitoring

- Uptime: UptimeRobot
- Metrics: Prometheus (optional) + Grafana
- Alerts: API error rate > threshold, cron job misses

## Secrets rotation

- Rotate JWT secret and API keys yearly or on suspicion of leak
- Document rotation in `/root/infra/secrets-rotation.md`
