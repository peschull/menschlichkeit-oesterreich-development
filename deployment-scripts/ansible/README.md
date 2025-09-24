# Ansible Playbook – CRM Deployment

## Inventory example (`inventory/hosts.yml`)
```ini
[crm_hosts]
crm1.menschlichkeit-oesterreich.at ansible_user=deploy ansible_become=true
```

## Run
```bash
ansible-playbook -i inventory/hosts.yml site.yml
```

The playbook will:
1. Install PHP 8.2 + required extensions and tools.
2. Create `/var/www/crm` hierarchy with `www-data` ownership.
3. Rsync the repository payload into place (excluding `vendor` and `node_modules`).
4. Run `composer install` (production-ready autoloader).
5. Link `/etc/opt/moe/settings.local.php` into the Drupal docroot.
6. Generate the Starterkit subtheme (`menschlichkeit_theme`) and enable performance modules (BigPipe, advagg, responsive_image, webp, blazy).
7. Set the subtheme as default, apply cache settings, run `drush updatedb` and `drush cr`.

### Post-Run Checks
- `drush status` shows the new theme and caches enabled.
- `curl -I https://crm.menschlichkeit-oesterreich.at` returns `strict-transport-security` header.
- `systemctl status php8.2-fpm` reports active.
