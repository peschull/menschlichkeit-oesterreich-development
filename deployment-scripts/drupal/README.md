# Drupal & CiviCRM Secrets Provisioning

These notes describe how to connect the Drupal 10 + CiviCRM stack to the pre-provisioned database and apply the generated credentials.

## 1. Load database credentials
```bash
DB_MD_FILE=/root/infra/db.md
DB_HOST=$(awk -F '[|:=/ ]+' '/DB_HOST/ {print $2; exit}' "$DB_MD_FILE")
DB_NAME=$(awk -F '[|:=/ ]+' '/DB_NAME/ {print $2; exit}' "$DB_MD_FILE")
DB_USER=$(awk -F '[|:=/ ]+' '/DB_USER/ {print $2; exit}' "$DB_MD_FILE")
DB_PASS=$(awk -F '[|:=/ ]+' '/DB_PASS/ {print $2; exit}' "$DB_MD_FILE")
```
Verify each variable is populated before continuing.

## 2. Write `/etc/opt/moe/.env`
```bash
sudo install -d -m 0750 /etc/opt/moe
sudo tee /etc/opt/moe/.env > /dev/null <<'ENV'
DB_HOST=$DB_HOST
DB_NAME=$DB_NAME
DB_USER=$DB_USER
DB_PASS=$DB_PASS
DRUPAL_ADMIN_USER=siteadmin
DRUPAL_ADMIN_PASS=E9f!Q7s$T2n@W5x#L8p%Z3r^C6m&D1v*H4k)J0a?5+N2=R7b
CIVICRM_SITE_KEY=9f3a7c1dbe5402a69c8e1f4b7a0d9c6e2f3b5a790b4c8d1
CIVICRM_API_KEY=7c4e9a1b6d3f8e2c5a7b9d1f4e6c8a2b5d7f9c1a3e5b7
JWT_SECRET=4a7f9c2d5e8b1a3c6f0d2e4b7a9c1f3e5b8d0a2c4f6e8b1
DRUPAL_HASH_SALT=$(openssl rand -hex 32)
ENV
sudo chmod 600 /etc/opt/moe/.env
sudo chown root:root /etc/opt/moe/.env
```

## 3. Drupal `settings.php`
Append the include to `/var/www/crm/web/sites/default/settings.php`:
```php
if (file_exists(__DIR__ . '/settings.local.php')) {
    include __DIR__ . '/settings.local.php';
}
```
Ensure permissions: `sudo chown root:www-data settings.php` and `sudo chmod 640 settings.php`.

## 4. Create `settings.local.php`
```bash
sudo tee /var/www/crm/web/sites/default/settings.local.php > /dev/null <<'PHP'
<?php
$dotenv = parse_ini_file('/etc/opt/moe/.env', false, INI_SCANNER_TYPED);
if (!$dotenv) {
    throw new \RuntimeException('Missing /etc/opt/moe/.env');
}
$databases['default']['default'] = [
    'database' => $dotenv['DB_NAME'],
    'username' => $dotenv['DB_USER'],
    'password' => $dotenv['DB_PASS'],
    'prefix' => '',
    'host' => $dotenv['DB_HOST'],
    'port' => '',
    'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
    'driver' => 'mysql',
];
$settings['hash_salt'] = $dotenv['DRUPAL_HASH_SALT'];
$settings['config_sync_directory'] = '../config/sync';
$GLOBALS['civicrm_setting']['Domain']['site_key'] = $dotenv['CIVICRM_SITE_KEY'];
$GLOBALS['civicrm_setting']['Domain']['userFrameworkResourceURL'] = 'https://crm.menschlichkeit-oesterreich.at/sites/default/files/civicrm/';
$settings['civicrm']['api_key'] = $dotenv['CIVICRM_API_KEY'];
PHP
sudo chmod 600 /var/www/crm/web/sites/default/settings.local.php
sudo chown www-data:www-data /var/www/crm/web/sites/default/settings.local.php
```

## 5. Sanity checks
- `drush sql-connect` succeeds.
- `drush status` shows correct database and hash salt.
- CiviCRM API key visible in Administer » System Settings » API Keys.

## 6. Secrets rotation
Regenerate credentials with `openssl rand -hex 48` and update `/etc/opt/moe/.env`; reload PHP-FPM afterwards (`sudo systemctl reload php8.2-fpm`).
