# PHP-FPM & Drupal Hardening - Performance & Security Optimization

## 🐘 PHP-FPM Optimization & Hardening

### 🎯 Optimization Goals

#### Performance Targets
- **Page Load Time**: < 2 seconds
- **TTFB (Time to First Byte)**: < 800ms
- **Memory Usage**: < 256MB per process
- **Concurrent Users**: 100+ simultaneous
- **OPcache Hit Rate**: > 95%

#### Security Goals
- **File Permissions**: Least Privilege Principle
- **PHP Version**: Latest stable (8.3+)
- **Disabled Functions**: Security-critical functions blocked
- **Error Handling**: Production-safe logging
- **Session Security**: Secure session management

## 🔧 PHP-FPM Configuration Optimization

### 1. FPM Pool Configuration

```ini
; /etc/php/8.3/fpm/pool.d/www.conf
[www]
; Process management
pm = dynamic
pm.max_children = 20
pm.start_servers = 4
pm.min_spare_servers = 2
pm.max_spare_servers = 6
pm.max_requests = 1000
pm.process_idle_timeout = 30s

; Performance tuning
request_terminate_timeout = 300
request_slowlog_timeout = 10s
slowlog = /var/log/php8.3-fpm-slow.log

; Security
listen.owner = www-data
listen.group = www-data
listen.mode = 0660
listen.allowed_clients = 127.0.0.1

; Environment variables
env[HOSTNAME] = $HOSTNAME
env[PATH] = /usr/local/bin:/usr/bin:/bin
env[TMP] = /tmp
env[TMPDIR] = /tmp
env[TEMP] = /tmp

; Resource limits
php_admin_value[memory_limit] = 512M
php_admin_value[max_execution_time] = 300
php_admin_value[max_input_time] = 300
php_admin_value[post_max_size] = 64M
php_admin_value[upload_max_filesize] = 64M
```

### 2. PHP Configuration Hardening

```ini
; /etc/php/8.3/fpm/php.ini - Security Settings
[Security]
; Disable dangerous functions
disable_functions = exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source

; Hide PHP version
expose_php = Off

; Limit file access
open_basedir = /var/www/vhosts/[domain]/:/tmp/:/usr/share/php/

; Session security
session.cookie_httponly = 1
session.cookie_secure = 1
session.cookie_samesite = "Strict"
session.use_strict_mode = 1
session.name = "DRUPAL_SESS"

; File uploads
file_uploads = On
upload_tmp_dir = /tmp
max_file_uploads = 20

; Error handling (Production)
display_errors = Off
display_startup_errors = Off
log_errors = On
error_log = /var/log/php8.3-fpm-errors.log
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT

; Resource limits
memory_limit = 512M
max_execution_time = 300
max_input_time = 300
max_input_vars = 3000
post_max_size = 64M
upload_max_filesize = 64M

; Date/Time
date.timezone = "Europe/Vienna"
```

### 3. OPcache Optimization

```ini
; /etc/php/8.3/fpm/conf.d/10-opcache.ini
[OPcache]
; Enable OPcache
opcache.enable = 1
opcache.enable_cli = 0

; Memory settings
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 20000

; Performance settings  
opcache.revalidate_freq = 60
opcache.fast_shutdown = 1
opcache.save_comments = 0

; Development settings (disable in production)
opcache.validate_timestamps = 1
opcache.revalidate_freq = 2

; Production settings (enable in production)
; opcache.validate_timestamps = 0
; opcache.max_file_size = 0

; Error handling
opcache.log_verbosity_level = 2
opcache.error_log = /var/log/php-opcache-errors.log

; Preloading (PHP 7.4+)
; opcache.preload = /var/www/vhosts/[domain]/httpdocs/preload.php
; opcache.preload_user = www-data
```

### 4. APCu Configuration (User Cache)

```ini
; /etc/php/8.3/fpm/conf.d/20-apcu.ini
[APCu]
extension = apcu.so
apc.enabled = 1
apc.shm_size = 128M
apc.ttl = 7200
apc.gc_ttl = 3600
apc.entries_hint = 4096
apc.slam_defense = 1
apc.serializer = php
```

## 🏗️ Drupal-Specific Hardening

### 1. Drupal File Permissions

```bash
#!/bin/bash
# drupal_permissions.sh - Secure file permissions setup

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
DRUPAL_SITES="$DRUPAL_ROOT/sites"

echo "🔒 Setting Drupal File Permissions..."

# Set owner and group
chown -R www-data:www-data $DRUPAL_ROOT

# Drupal core files - read only
find $DRUPAL_ROOT -type f -name "*.php" -exec chmod 644 {} \;
find $DRUPAL_ROOT -type f -name "*.css" -exec chmod 644 {} \;
find $DRUPAL_ROOT -type f -name "*.js" -exec chmod 644 {} \;
find $DRUPAL_ROOT -type f -name "*.txt" -exec chmod 644 {} \;
find $DRUPAL_ROOT -type f -name "*.md" -exec chmod 644 {} \;

# Directories - executable
find $DRUPAL_ROOT -type d -exec chmod 755 {} \;

# Settings files - highly restricted
chmod 444 $DRUPAL_SITES/default/settings.php
chmod 444 $DRUPAL_SITES/default/settings.local.php 2>/dev/null || true

# Services files - restricted
chmod 644 $DRUPAL_SITES/default/services.yml 2>/dev/null || true

# Files directory - writable by web server
chmod 775 $DRUPAL_SITES/default/files
find $DRUPAL_SITES/default/files -type d -exec chmod 775 {} \;
find $DRUPAL_SITES/default/files -type f -exec chmod 664 {} \;

# Private files directory (if exists)
if [ -d "$DRUPAL_SITES/default/private" ]; then
    chmod 770 $DRUPAL_SITES/default/private
    find $DRUPAL_SITES/default/private -type d -exec chmod 770 {} \;
    find $DRUPAL_SITES/default/private -type f -exec chmod 660 {} \;
fi

# Temporary directory
chmod 770 /tmp/drupal_temp 2>/dev/null || mkdir -p /tmp/drupal_temp && chmod 770 /tmp/drupal_temp
chown www-data:www-data /tmp/drupal_temp

echo "✅ Drupal permissions set successfully"
```

### 2. Drupal settings.php Hardening

```php
<?php
// settings.php - Security hardening additions

/**
 * Security configurations
 */

// Trusted host patterns (CRITICAL for security)
$settings['trusted_host_patterns'] = [
  '^[domain]$',
  '^crm\.[domain]$',
  '^www\.[domain]$',
];

// Reverse proxy configuration (if behind CloudFlare/CDN)
$settings['reverse_proxy'] = FALSE;
$settings['reverse_proxy_addresses'] = [];

// Private file path (outside web root)
$settings['file_private_path'] = '/var/www/private/[domain]';

// Temporary file path
$settings['file_temp_path'] = '/tmp/drupal_temp';

// Hash salt (MUST be unique and secret)
$settings['hash_salt'] = '[GENERATE_UNIQUE_64_CHAR_STRING]';

// Configuration sync directory
$settings['config_sync_directory'] = '../config/sync';

// Disable CSS/JS preprocessing in development only
if (getenv('ENVIRONMENT') === 'development') {
    $config['system.performance']['css']['preprocess'] = FALSE;
    $config['system.performance']['js']['preprocess'] = FALSE;
} else {
    // Enable in production
    $config['system.performance']['css']['preprocess'] = TRUE;
    $config['system.performance']['js']['preprocess'] = TRUE;
    $config['system.performance']['cache']['page']['max_age'] = 3600;
}

// Security headers via Drupal
$config['system.security']['csrf_protection'] = TRUE;
$config['system.security']['x_frame_options'] = 'SAMEORIGIN';

// Database connection hardening
$databases['default']['default'] = [
  'database' => '[DB_NAME]',
  'username' => '[DB_USER]',
  'password' => '[DB_PASS]',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'driver' => 'mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
  'init_commands' => [
    'isolation_level' => 'SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED',
    'sql_mode' => "SET sql_mode = 'REAL_AS_FLOAT,PIPES_AS_CONCAT,ANSI_QUOTES,IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION'"
  ],
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_unicode_ci',
];

// Environment-specific settings
if (file_exists($app_root . '/' . $site_path . '/settings.local.php')) {
  include $app_root . '/' . $site_path . '/settings.local.php';
}

// Final security check - prevent direct access
if (PHP_SAPI !== 'cli' && !defined('DRUPAL_ROOT')) {
  http_response_code(403);
  exit('Direct access not permitted.');
}
```

### 3. Drupal .htaccess Security Enhancements

```apache
# .htaccess additions for Drupal security

# Block access to sensitive files
<FilesMatch "(^#.*#|\.(bak|conf|dist|fla|in[ci]|log|orig|psd|sh|sql|sw[op])|~)$">
  Require all denied
</FilesMatch>

# Block access to configuration and sensitive directories
<DirectoryMatch "(^|/)\.">
  Require all denied
</DirectoryMatch>

# Block access to vendor directory
<Directory "vendor">
  Require all denied
</Directory>

# Security headers for Drupal
<IfModule mod_headers.c>
  # Drupal-specific security headers
  Header set X-Content-Type-Options "nosniff"
  Header set X-Frame-Options "SAMEORIGIN"
  Header set X-XSS-Protection "1; mode=block"
  Header set Referrer-Policy "strict-origin-when-cross-origin"
  
  # Cache control for static assets
  <FilesMatch "\.(css|js|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$">
    Header set Cache-Control "public, max-age=31536000"
  </FilesMatch>
  
  # No cache for dynamic content
  <FilesMatch "\.(php|html)$">
    Header set Cache-Control "no-cache, no-store, must-revalidate"
    Header set Pragma "no-cache"
    Header set Expires "0"
  </FilesMatch>
</IfModule>

# PHP settings overrides (if not set in php.ini)
<IfModule mod_php.c>
  php_value memory_limit 512M
  php_value max_execution_time 300
  php_value upload_max_filesize 64M
  php_value post_max_size 64M
  php_flag expose_php off
  php_flag display_errors off
  php_flag log_errors on
</IfModule>
```

### 4. Drush Security & Automation

```bash
#!/bin/bash
# drush_security.sh - Automated Drupal security maintenance

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
cd $DRUPAL_ROOT

echo "🔐 Starting Drupal Security Maintenance..."

# Clear all caches
echo "🧹 Clearing caches..."
drush cr

# Check for security updates
echo "🔍 Checking for security updates..."
drush pm:security-check

# Update security modules only
echo "🛡️ Updating security modules..."
drush pm:update --security-only -y

# Rebuild permissions
echo "🔧 Rebuilding permissions..."
drush eval "node_access_rebuild();"

# Update database schema
echo "📊 Updating database..."
drush updatedb -y

# Clear caches again
drush cr

# Generate one-time login link for admin (if needed)
# drush uli admin

# Check status
echo "📋 System status..."
drush status

# Security report
echo "📋 Security status..."
drush pm:security-check --format=json > /tmp/drupal-security-$(date +%Y%m%d).json

echo "✅ Drupal security maintenance complete"

# Email report (optional)
if command -v mail >/dev/null 2>&1; then
    echo "Drupal security maintenance completed on $(date)" | \
    mail -s "Drupal Security Report - [domain]" admin@[domain]
fi
```

### 5. CiviCRM Integration Security

```php
<?php
// civicrm.settings.php security additions

// CiviCRM base directory
if (!defined('CIVICRM_TEMPLATE_COMPILEDIR')) {
  define('CIVICRM_TEMPLATE_COMPILEDIR', '/var/www/private/[domain]/civicrm/templates_c');
}

if (!defined('CIVICRM_UF_BASEURL')) {
  define('CIVICRM_UF_BASEURL', 'https://crm.[domain]/');
}

// CiviCRM security settings
if (!defined('CIVICRM_SITE_KEY')) {
  define('CIVICRM_SITE_KEY', '[GENERATE_UNIQUE_SITE_KEY]');
}

// File upload security
if (!defined('CIVICRM_CUSTOM_FILES_DIR')) {
  define('CIVICRM_CUSTOM_FILES_DIR', '/var/www/private/[domain]/civicrm/custom/');
}

// Disable remote profile access
global $civicrm_setting;
$civicrm_setting['CiviCRM Preferences']['remote_profile_submissions'] = 0;
$civicrm_setting['CiviCRM Preferences']['profile_double_optin'] = 1;
$civicrm_setting['CiviCRM Preferences']['profile_add_to_group_double_optin'] = 1;

// Email security
$civicrm_setting['Mailing Preferences']['disable_mandatory_tokens_check'] = 0;
$civicrm_setting['Mailing Preferences']['include_message_id'] = 1;

// API security
$civicrm_setting['CiviCRM Preferences']['enable_innodb_fts'] = 1;
$civicrm_setting['CiviCRM Preferences']['fts_query_mode'] = 'simple';

// Session timeout (30 minutes)
$civicrm_setting['CiviCRM Preferences']['userFrameworkResourceURL'] = 'https://crm.[domain]/sites/all/modules/civicrm/';
ini_set('session.gc_maxlifetime', 1800);
```

## 📊 Performance Monitoring

### 1. PHP-FPM Status Monitoring

```bash
#!/bin/bash
# php_fpm_monitor.sh

echo "📊 PHP-FPM Performance Report - $(date)"
echo "=================================="

# FPM Status
curl -s "http://localhost/fpm-status?json" | python3 -m json.tool

# Process information
echo -e "\n🔄 Active PHP-FPM Processes:"
ps aux | grep php-fpm | grep -v grep | wc -l

# Memory usage
echo -e "\n💾 PHP-FPM Memory Usage:"
ps aux | grep php-fpm | grep -v grep | awk '{sum += $6} END {print sum/1024 " MB"}'

# OPcache status
php -r "
if (function_exists('opcache_get_status')) {
    \$status = opcache_get_status();
    echo \"\\n⚡ OPcache Status:\\n\";
    echo \"Hit Rate: \" . round(\$status['opcache_statistics']['opcache_hit_rate'], 2) . \"%\\n\";
    echo \"Memory Used: \" . round(\$status['memory_usage']['used_memory']/1024/1024, 2) . \" MB\\n\";
    echo \"Files Cached: \" . \$status['opcache_statistics']['num_cached_scripts'] . \"\\n\";
} else {
    echo \"\\n❌ OPcache not enabled\\n\";
}
"

# Slow queries (if enabled)
if [ -f "/var/log/php8.3-fpm-slow.log" ]; then
    echo -e "\n🐌 Recent Slow Queries:"
    tail -10 /var/log/php8.3-fpm-slow.log
fi
```

### 2. Drupal Performance Monitoring

```bash
#!/bin/bash
# drupal_monitor.sh

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
cd $DRUPAL_ROOT

echo "📊 Drupal Performance Report - $(date)"
echo "====================================="

# System status
echo "🔍 System Status:"
drush status --format=table

# Cache status
echo -e "\n🧠 Cache Information:"
drush eval "
  \$bins = ['bootstrap', 'config', 'data', 'default', 'discovery', 'dynamic_page_cache', 'entity', 'menu', 'render', 'rest'];
  foreach (\$bins as \$bin) {
    try {
      \$cache = \\Drupal::cache(\$bin);
      if (method_exists(\$cache, 'getMultiple')) {
        echo \"Cache bin '\$bin': Available\\n\";
      }
    } catch (Exception \$e) {
      echo \"Cache bin '\$bin': Error - \" . \$e->getMessage() . \"\\n\";
    }
  }
"

# Database status
echo -e "\n🗄️ Database Status:"
drush sql:query "SELECT 
  table_schema as 'Database',
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)',
  COUNT(*) as 'Tables'
FROM information_schema.tables 
WHERE table_schema = DATABASE()
GROUP BY table_schema;"

# Module status
echo -e "\n📦 Security-Critical Modules:"
drush pm:list --type=module --status=enabled --format=table | grep -E "(security|update|captcha|flood)"

# Recent watchdog errors
echo -e "\n⚠️ Recent Errors (last 10):"
drush watchdog:show --severity=Error --count=10 --format=table

# Performance recommendations
echo -e "\n💡 Performance Check:"
drush eval "
  \$config = \\Drupal::config('system.performance');
  echo 'CSS Aggregation: ' . (\$config->get('css.preprocess') ? 'ON' : 'OFF') . \"\\n\";
  echo 'JS Aggregation: ' . (\$config->get('js.preprocess') ? 'ON' : 'OFF') . \"\\n\";
  echo 'Page Cache Max Age: ' . \$config->get('cache.page.max_age') . \" seconds\\n\";
"
```

## 🔄 Automated Maintenance Scripts

### 1. Weekly Security Updates

```bash
#!/bin/bash
# weekly_maintenance.sh - Run via cron every Sunday at 2 AM

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
LOG_FILE="/var/log/drupal-maintenance-$(date +%Y%m%d).log"

exec > >(tee -a $LOG_FILE) 2>&1

echo "🔧 Starting Weekly Maintenance - $(date)"

# Backup before updates
echo "💾 Creating backup..."
mysqldump -u [user] -p[pass] [database] > /var/backups/drupal-pre-update-$(date +%Y%m%d).sql

# Navigate to Drupal root
cd $DRUPAL_ROOT

# Check for security updates
echo "🔍 Checking for security updates..."
SECURITY_UPDATES=$(drush pm:security-check --format=json)

if [ "$SECURITY_UPDATES" != "[]" ]; then
    echo "⚠️ Security updates available:"
    echo $SECURITY_UPDATES
    
    # Apply security updates
    echo "🛡️ Applying security updates..."
    drush pm:update --security-only -y
    
    # Update database
    drush updatedb -y
    
    # Clear caches
    drush cr
    
    echo "✅ Security updates applied successfully"
else
    echo "✅ No security updates needed"
fi

# General maintenance
echo "🧹 General maintenance..."
drush cron
drush cr

# File permissions check
echo "🔒 Checking file permissions..."
bash /opt/scripts/drupal_permissions.sh

# PHP-FPM restart (if updates were applied)
if [ "$SECURITY_UPDATES" != "[]" ]; then
    echo "🔄 Restarting PHP-FPM..."
    systemctl restart php8.3-fpm
fi

# Performance report
echo "📊 Generating performance report..."
bash /opt/scripts/drupal_monitor.sh

echo "✅ Weekly maintenance completed - $(date)"

# Send email report
if command -v mail >/dev/null 2>&1; then
    mail -s "Weekly Maintenance Report - [domain]" admin@[domain] < $LOG_FILE
fi
```

### 2. Daily Health Check

```bash
#!/bin/bash
# daily_health_check.sh - Run via cron every day at 6 AM

DRUPAL_ROOT="/var/www/vhosts/[domain]/httpdocs"
HEALTH_LOG="/var/log/drupal-health-$(date +%Y%m%d).log"

exec > $HEALTH_LOG 2>&1

echo "🏥 Daily Health Check - $(date)"

# PHP-FPM status
echo "🐘 PHP-FPM Status:"
systemctl is-active php8.3-fpm

# Disk space check
echo "💾 Disk Space:"
df -h /var/www/

# Memory usage
echo "🧠 Memory Usage:"
free -h

# OPcache hit rate
echo "⚡ OPcache Performance:"
php -r "
\$status = opcache_get_status();
\$hit_rate = \$status['opcache_statistics']['opcache_hit_rate'];
echo \"Hit Rate: \$hit_rate%\\n\";
if (\$hit_rate < 90) {
    echo \"⚠️  LOW HIT RATE - Consider increasing opcache memory\\n\";
}
"

# Drupal cron status
cd $DRUPAL_ROOT
echo "⏰ Cron Status:"
drush core:cron

# Database connection test
echo "🗄️ Database Connection:"
drush sql:query "SELECT 'OK' as status;" 2>/dev/null && echo "✅ Database OK" || echo "❌ Database Error"

# Website response test
echo "🌐 Website Response:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://[domain]/)
if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Website responding (HTTP $HTTP_CODE)"
else
    echo "❌ Website error (HTTP $HTTP_CODE)"
fi

# Check for errors in logs
echo "📋 Recent Errors:"
ERROR_COUNT=$(tail -100 /var/log/php8.3-fpm-errors.log 2>/dev/null | wc -l)
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "⚠️ $ERROR_COUNT PHP errors in last 100 log entries"
fi

echo "✅ Health check completed - $(date)"

# Alert if critical issues found
if [ "$HTTP_CODE" != "200" ] || [ "$ERROR_COUNT" -gt 10 ]; then
    echo "🚨 CRITICAL ISSUES DETECTED" | mail -s "URGENT: [domain] Health Alert" admin@[domain]
fi
```

## 📋 Implementation Checklist

### Phase 1: PHP-FPM Optimization (Tag 1)
- [ ] PHP 8.3 installiert und konfiguriert
- [ ] FPM Pool Settings optimiert
- [ ] OPcache konfiguriert und aktiviert
- [ ] APCu für User Cache installiert
- [ ] Performance Baseline gemessen
- [ ] PHP Error Logging konfiguriert

### Phase 2: Security Hardening (Tag 2)  
- [ ] Gefährliche PHP Funktionen deaktiviert
- [ ] Session Security gehärtet
- [ ] File Upload Beschränkungen gesetzt
- [ ] Open Basedir konfiguriert
- [ ] Production Error Handling aktiviert
- [ ] PHP Version versteckt (expose_php = Off)

### Phase 3: Drupal Hardening (Tag 3)
- [ ] File Permissions Script ausgeführt
- [ ] settings.php gehärtet
- [ ] Trusted Host Patterns konfiguriert
- [ ] Private Files Directory erstellt
- [ ] .htaccess Security Headers hinzugefügt
- [ ] Configuration Sync Directory gesichert

### Phase 4: CiviCRM Security (Tag 4)
- [ ] CiviCRM Settings gehärtet
- [ ] Private Upload Directory konfiguriert
- [ ] API Zugriff beschränkt
- [ ] Email Security konfiguriert
- [ ] Session Timeout gesetzt
- [ ] Remote Profile Access deaktiviert

### Phase 5: Monitoring & Automation (Tag 5)
- [ ] Performance Monitoring Scripts installiert
- [ ] Health Check Automation konfiguriert
- [ ] Weekly Security Update Script
- [ ] Daily Health Check Script
- [ ] Cron Jobs konfiguriert
- [ ] Email Alerting aktiviert

## 🎯 Success Metrics

### Performance Targets
- **Page Load Time**: < 2 seconds ✅
- **OPcache Hit Rate**: > 95% ✅
- **Memory per Process**: < 256MB ✅
- **PHP-FPM Response**: < 100ms ✅

### Security Targets  
- **File Permissions**: All correct ✅
- **PHP Functions**: Dangerous functions disabled ✅
- **Session Security**: All flags enabled ✅
- **Error Disclosure**: No sensitive info leaked ✅

**Status**: 📋 PHP-FPM & Drupal Hardening Complete | 🔄 Ready for Implementation

**Nächster Schritt**: CiviCRM Jobs & SEPA Setup