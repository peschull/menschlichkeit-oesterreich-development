# Nginx Deployment for menschlichkeit-oesterreich.at

This directory contains ready-to-apply vhost configurations for the CRM and API subdomains.

## Files
- crm.menschlichkeit-oesterreich.at.conf – Drupal 10 + CiviCRM host with PHP-FPM 8.2 integration, security headers, and static asset caching.
- api.menschlichkeit-oesterreich.at.conf – FastAPI host served via Uvicorn socket with locked-down CSP.
- snippets/moe-tls.conf – Shared TLS configuration referencing Let’s Encrypt wildcard certificates.

## Deployment Steps
1. Copy the configs to /etc/nginx/sites-available/ and symlink into sites-enabled/.
2. Ensure the TLS snippet lives at /etc/nginx/snippets/moe-tls.conf with root:root ownership and 0644 permissions.
3. Run nginx -t and systemctl reload nginx.
4. Verify HTTPS and HSTS via curl -I and SSL Labs (expect grade A).
5. Log verification results in /var/log/deployments/moe-<date>.log.

## PHP-FPM Socket
- Expects /run/php/php8.2-fpm.sock; update fastcgi_pass if different.

## API Backend Socket
- Ensure Uvicorn service exposes /run/uvicorn/moe-api.sock (www-data:www-data 660).
- Restart service after deploying config.
