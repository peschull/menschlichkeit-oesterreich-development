# Datenbank-Konfiguration für Menschlichkeit Österreich Development

## MariaDB Server Configuration

- **Host:** localhost
- **Port:** 3306 (Standard)
- **Version:** v10.6.22
- **Engine:** MariaDB

## Datenbank-Schema

### WordPress Hauptdomain

```sql
-- WordPress Datenbank
CREATE DATABASE IF NOT EXISTS mo_wordpress
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'mo_wp_user'@'localhost'
IDENTIFIED BY 'secure_password_wp';

GRANT ALL PRIVILEGES ON mo_wordpress.* TO 'mo_wp_user'@'localhost';
```

### Laravel API Domain

```sql
-- Laravel API Datenbank
CREATE DATABASE IF NOT EXISTS mo_api
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'mo_api_user'@'localhost'
IDENTIFIED BY 'secure_password_api';

GRANT ALL PRIVILEGES ON mo_api.* TO 'mo_api_user'@'localhost';
```

### CiviCRM Subdomain

```sql
-- CiviCRM Datenbank
CREATE DATABASE IF NOT EXISTS mo_civicrm
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'mo_crm_user'@'localhost'
IDENTIFIED BY 'secure_password_crm';

GRANT ALL PRIVILEGES ON mo_civicrm.* TO 'mo_crm_user'@'localhost';
```

## Verbindungskonfiguration

### WordPress wp-config.php

```php
// WordPress Datenbank-Konfiguration
define('DB_NAME', 'mo_wordpress');
define('DB_USER', 'mo_wp_user');
define('DB_PASSWORD', 'secure_password_wp');
define('DB_HOST', 'localhost:3306');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');

// WordPress Debug (Development)
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);

// WordPress REST API
define('WP_REST_API', true);
```

### Laravel .env

```env
# Laravel API Datenbank-Konfiguration
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=mo_api
DB_USERNAME=mo_api_user
DB_PASSWORD=secure_password_api

# Laravel App Configuration
APP_NAME="MO API"
APP_ENV=development
APP_DEBUG=true
APP_URL=https://api.menschlichkeit-oesterreich.at

# Laravel Cache & Queue
CACHE_DRIVER=database
QUEUE_CONNECTION=database
SESSION_DRIVER=database
```

### CiviCRM civicrm.settings.php

```php
// CiviCRM Datenbank-Konfiguration
define('CIVICRM_UF', 'Standalone');
define('CIVICRM_UF_DSN', 'mysql://mo_crm_user:secure_password_crm@localhost:3306/mo_civicrm');
define('CIVICRM_DSN', 'mysql://mo_crm_user:secure_password_crm@localhost:3306/mo_civicrm');

// CiviCRM Pfade
define('CIVICRM_TEMPLATE_COMPILEDIR', '/var/www/subdomains/crm/templates_c');
define('CIVICRM_UF_BASEURL', 'https://crm.menschlichkeit-oesterreich.at');
```

## Performance-Optimierung

### MariaDB Konfiguration (my.cnf)

```ini
[mysqld]
# Performance Tuning
innodb_buffer_pool_size = 256M
innodb_log_file_size = 64M
innodb_flush_log_at_trx_commit = 2
innodb_flush_method = O_DIRECT

# Charset
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci

# Connection Limits
max_connections = 200
max_user_connections = 150

# Query Cache
query_cache_type = 1
query_cache_size = 64M
query_cache_limit = 2M
```

## Backup-Strategie

### Automatisierte Backups

```bash
#!/bin/bash
# Database Backup Script

BACKUP_DIR="/var/backups/mysql"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# WordPress Backup
mysqldump -u mo_wp_user -p mo_wordpress > $BACKUP_DIR/wordpress_$TIMESTAMP.sql

# API Backup
mysqldump -u mo_api_user -p mo_api > $BACKUP_DIR/api_$TIMESTAMP.sql

# CiviCRM Backup
mysqldump -u mo_crm_user -p mo_civicrm > $BACKUP_DIR/civicrm_$TIMESTAMP.sql

# Komprimierung
gzip $BACKUP_DIR/*_$TIMESTAMP.sql

# Cleanup (older than 30 days)
find $BACKUP_DIR -name "*.sql.gz" -mtime +30 -delete
```

## Monitoring & Logs

### Datenbank-Monitoring

- **Performance Schema:** aktiviert für Query-Analyse
- **Slow Query Log:** aktiviert für Performance-Debugging
- **Error Log:** kontinuierliche Überwachung
- **Binary Logs:** für Point-in-Time Recovery

### Verbindungs-Tests

```bash
# WordPress Verbindung testen
mysql -u mo_wp_user -p -h localhost -P 3306 mo_wordpress -e "SHOW TABLES;"

# API Verbindung testen
mysql -u mo_api_user -p -h localhost -P 3306 mo_api -e "SHOW TABLES;"

# CiviCRM Verbindung testen
mysql -u mo_crm_user -p -h localhost -P 3306 mo_civicrm -e "SHOW TABLES;"
```
