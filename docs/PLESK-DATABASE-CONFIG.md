# Plesk Server Datenbank-Konfiguration

## 1. Plesk Database Management

### Database Creation via Plesk Control Panel

```
1. Login to Plesk Control Panel
   - URL: https://your-plesk-server.com:8443
   - Navigate to "Databases" section

2. Create Databases:
   - mo_wordpress (für Hauptdomain)
   - mo_api (für api.menschlichkeit-oesterreich.at)
   - mo_civicrm (für crm.menschlichkeit-oesterreich.at)

3. Database Users:
   - mo_wp_user (WordPress Database)
   - mo_api_user (Laravel API Database)
   - mo_crm_user (CiviCRM Database)
```

### Plesk Database Settings

```sql
-- Character Set: utf8mb4
-- Collation: utf8mb4_unicode_ci
-- MySQL Version: 8.0+ oder MariaDB 10.6+
```

## 2. Remote Database Connection Configuration

### WordPress wp-config.php für Plesk

```php
<?php
// Plesk Database Configuration für WordPress
define('DB_NAME', 'mo_wordpress');
define('DB_USER', 'mo_wp_user');
define('DB_PASSWORD', 'secure_wp_password_2025');
define('DB_HOST', 'localhost'); // Plesk standard localhost
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// Plesk spezifische WordPress Konfiguration
$table_prefix = 'mo_wp_';

// Security Keys (generiert für Plesk Installation)
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

// WordPress Debug (für Plesk Production)
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

// Plesk File Permissions
define('FS_METHOD', 'direct');
define('FS_CHMOD_DIR', (0755 & ~ umask()));
define('FS_CHMOD_FILE', (0644 & ~ umask()));

// WordPress URLs für Plesk
define('WP_HOME', 'https://menschlichkeit-oesterreich.at');
define('WP_SITEURL', 'https://menschlichkeit-oesterreich.at');

if ( !defined('ABSPATH') )
    define('ABSPATH', dirname(__FILE__) . '/');

require_once(ABSPATH . 'wp-settings.php');
?>
```

### Laravel .env für Plesk API Domain

```env
# Laravel Environment für Plesk Server
APP_NAME="Menschlichkeit Österreich API"
APP_ENV=production
APP_KEY=base64:generated-key-here
APP_DEBUG=false
APP_URL=https://api.menschlichkeit-oesterreich.at

# Plesk Database Configuration
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=mo_api
DB_USERNAME=mo_api_user
DB_PASSWORD=secure_api_password_2025

# Cache Configuration für Plesk
CACHE_DRIVER=file
QUEUE_CONNECTION=database
SESSION_DRIVER=database

# Mail Configuration (Plesk SMTP)
MAIL_MAILER=smtp
MAIL_HOST=smtp.menschlichkeit-oesterreich.at
MAIL_PORT=587
MAIL_USERNAME=noreply@menschlichkeit-oesterreich.at
MAIL_PASSWORD=mail_password_here
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=noreply@menschlichkeit-oesterreich.at
MAIL_FROM_NAME="Menschlichkeit Österreich"

# CiviCRM Integration
CIVICRM_URL=https://crm.menschlichkeit-oesterreich.at
CIVICRM_SITE_KEY=your-civicrm-site-key
CIVICRM_API_KEY=your-civicrm-api-key

# WordPress API Integration
WORDPRESS_URL=https://menschlichkeit-oesterreich.at
WORDPRESS_API_KEY=your-wordpress-api-key
```

## 3. Plesk Database Setup Script

### SQL Script für phpMyAdmin (Plesk)

```sql
-- Plesk Database Setup für Menschlichkeit Österreich
-- Ausführung über phpMyAdmin in Plesk

-- 1. WordPress Database Setup
CREATE DATABASE IF NOT EXISTS mo_wordpress
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'mo_wp_user'@'localhost'
IDENTIFIED BY 'secure_wp_password_2025';

GRANT ALL PRIVILEGES ON mo_wordpress.* TO 'mo_wp_user'@'localhost';

-- 2. API Database Setup
CREATE DATABASE IF NOT EXISTS mo_api
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'mo_api_user'@'localhost'
IDENTIFIED BY 'secure_api_password_2025';

GRANT ALL PRIVILEGES ON mo_api.* TO 'mo_api_user'@'localhost';

-- 3. CiviCRM Database Setup
CREATE DATABASE IF NOT EXISTS mo_civicrm
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'mo_crm_user'@'localhost'
IDENTIFIED BY 'secure_crm_password_2025';

GRANT ALL PRIVILEGES ON mo_civicrm.* TO 'mo_crm_user'@'localhost';

-- Apply changes
FLUSH PRIVILEGES;

-- Verify databases
SHOW DATABASES LIKE 'mo_%';

-- Verify users
SELECT User, Host FROM mysql.user WHERE User LIKE 'mo_%';
```

## 4. Plesk-spezifische Konfiguration

### File Manager Upload Structure

```
/httpdocs/ (Hauptdomain WordPress)
├── wp-config.php
├── wp-content/
├── wp-admin/
└── wp-includes/

/subdomains/api/httpdocs/ (Laravel API)
├── .env
├── public/
├── app/
├── config/
└── vendor/

/subdomains/crm/httpdocs/ (CiviCRM)
├── civicrm.settings.php
├── sites/
├── vendor/
└── web/
```

### Plesk Cron Jobs für Automation

```bash
# Laravel Queue Worker (alle 5 Minuten)
*/5 * * * * cd /var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/api/httpdocs && php artisan queue:work --stop-when-empty

# CiviCRM Scheduled Jobs (täglich)
0 2 * * * cd /var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/crm/httpdocs && php bin/cli.php -j

# WordPress Maintenance (wöchentlich)
0 3 * * 0 cd /var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs && wp core update --allow-root

# Database Backup (täglich)
0 1 * * * mysqldump --all-databases > /var/www/vhosts/menschlichkeit-oesterreich.at/backup/db_backup_$(date +%Y%m%d).sql
```

## 5. Plesk Security Configuration

### Database Security Settings

```sql
-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root access
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Set secure passwords policy
SET GLOBAL validate_password.policy = STRONG;
SET GLOBAL validate_password.length = 12;

-- Flush privileges
FLUSH PRIVILEGES;
```

### SSL/TLS Configuration für Domains

```
1. Plesk SSL/TLS Certificates:
   - Hauptdomain: Let's Encrypt für menschlichkeit-oesterreich.at
   - API Subdomain: Let's Encrypt für api.menschlichkeit-oesterreich.at
   - CRM Subdomain: Let's Encrypt für crm.menschlichkeit-oesterreich.at

2. Force HTTPS Redirect in Plesk
3. HSTS Headers aktivieren
4. Mixed Content Protection
```

## 6. Performance Optimization für Plesk

### MySQL/MariaDB Tuning

```sql
-- Plesk MySQL Performance Settings
SET GLOBAL innodb_buffer_pool_size = 512M;
SET GLOBAL max_connections = 200;
SET GLOBAL query_cache_size = 32M;
SET GLOBAL query_cache_type = ON;

-- WordPress specific
SET GLOBAL table_open_cache = 400;
SET GLOBAL sort_buffer_size = 2M;
SET GLOBAL read_buffer_size = 2M;
```

### PHP Configuration (Plesk)

```ini
; PHP Settings für Plesk Domains
memory_limit = 512M
max_execution_time = 300
max_input_vars = 3000
upload_max_filesize = 64M
post_max_size = 64M

; OPcache für Performance
opcache.enable = 1
opcache.memory_consumption = 128
opcache.max_accelerated_files = 4000
opcache.revalidate_freq = 2
```

## 7. Deployment über SFTP zu Plesk

### Upload-Sequenz für Plesk

```
1. Datenbank-Skript über phpMyAdmin ausführen
2. WordPress-Dateien nach /httpdocs/ uploaden
3. Laravel API nach /subdomains/api/httpdocs/ uploaden
4. CiviCRM nach /subdomains/crm/httpdocs/ uploaden
5. Konfigurationsdateien mit Plesk-spezifischen Einstellungen
6. Dateiberechtigungen über Plesk File Manager setzen
7. SSL-Zertifikate aktivieren
8. Cron Jobs konfigurieren
```

Die Plesk-Konfiguration ermöglicht professionelles Hosting mit allen erforderlichen Funktionen für die Multi-Domain-Architektur von Menschlichkeit Österreich.
