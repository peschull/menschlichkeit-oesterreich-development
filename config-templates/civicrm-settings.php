<?php

/**
 * CiviCRM Configuration für mo_civicrm_data @ digimagical.com
 * settings.php oder wp-config.php Integration
 * MariaDB 10.6.22 auf Ubuntu 22.04
 */

// CiviCRM Database Configuration - STANDALONE (ohne WordPress)
// Dedicated civicrm_user (NICHT mo_wp_user)
define('CIVICRM_DSN', 'mysql://civicrm_user:SECURE_CIVICRM_2025@localhost/mo_civicrm_data?new_link=true');

// CiviCRM Database Character Set
define('CIVICRM_DB_CHARSET', 'utf8mb4');
define('CIVICRM_DB_COLLATE', 'utf8mb4_unicode_ci');

// CiviCRM Template Compilation Directory
define('CIVICRM_TEMPLATE_COMPILEDIR', '/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/wp-content/uploads/civicrm/templates_c/');

// CiviCRM Upload Directory
define('CIVICRM_UF_BASEURL', 'https://menschlichkeit-oesterreich.at/');
define('CIVICRM_UPLOAD_DIR', '/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/wp-content/uploads/civicrm/upload/');

// CiviCRM Custom Files Directory
define('CIVICRM_CUSTOM_PHP_DIR', '/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/wp-content/uploads/civicrm/custom/');
define('CIVICRM_CUSTOM_TEMPLATE_DIR', '/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/wp-content/uploads/civicrm/custom/templates/');

// CiviCRM Extensions Directory  
define('CIVICRM_EXT_DIR', '/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/wp-content/uploads/civicrm/ext/');
define('CIVICRM_EXT_URL', 'https://menschlichkeit-oesterreich.at/wp-content/uploads/civicrm/ext/');

// CiviCRM Site Key (Unique identifier)
define('CIVICRM_SITE_KEY', 'GENERATE_UNIQUE_SITE_KEY_HERE');

// CiviCRM User Framework (WordPress Integration)
define('CIVICRM_UF', 'WordPress');
define('CIVICRM_UF_DSN', 'mysql://mo_wp_user:SECURE_PASSWORD_WP_2025@localhost/mo_wordpress_main?new_link=true');

// Performance Settings
define('CIVICRM_CACHE_TYPE', 'ArrayCache');
define('CIVICRM_SMARTY_DEFAULT_ESCAPE', 'htmlentities');

// Security Settings
define('CIVICRM_SIGN_KEYS', 'GENERATE_SIGNING_KEYS_HERE');
define('CIVICRM_CRYPT_KEYS', 'GENERATE_ENCRYPTION_KEYS_HERE');

// Email Configuration (Plesk SMTP)
define('CIVICRM_MAIL_SMTP', '1');
define('CIVICRM_MAIL_SMTP_SERVER', 'smtp.menschlichkeit-oesterreich.at');
define('CIVICRM_MAIL_SMTP_PORT', '587');
define('CIVICRM_MAIL_SMTP_AUTH', '1');
define('CIVICRM_MAIL_SMTP_USERNAME', 'civicrm@menschlichkeit-oesterreich.at');
define('CIVICRM_MAIL_SMTP_PASSWORD', 'MAIL_PASSWORD_HERE');

// Logging & Debugging
define('CIVICRM_DEBUG_LOG_QUERY', 0);
define('CIVICRM_BACKTRACE', 0);

// Plesk-spezifische Konfiguration
define('CIVICRM_SERVER_INFO', 'MariaDB 10.6.22 @ digimagical.com');
define('CIVICRM_WEBSERVER', 'nginx/1.28.0');
define('CIVICRM_PHP_VERSION', '8.4.11');

// Website Assignment Information
// TODO: Assign mo_civicrm_data to a specific website in Plesk Panel
// Current Status: ❌ Noch keiner Website zugewiesen
// Recommendation: Assign to menschlichkeit-oesterreich.at for backup & access control

/**
 * Alternative Configuration for WordPress wp-config.php Integration:
 * 
 * // Add to wp-config.php after database configuration:
 * 
 * // CiviCRM Database
 * define('CIVICRM_DSN', 'mysql://mo_wp_user:SECURE_PASSWORD_WP_2025@localhost/mo_civicrm_data?new_link=true');
 * define('CIVICRM_UF_DSN', 'mysql://mo_wp_user:SECURE_PASSWORD_WP_2025@localhost/mo_wordpress_main?new_link=true');
 * 
 * // CiviCRM Site Configuration
 * define('CIVICRM_SITE_KEY', 'GENERATE_UNIQUE_SITE_KEY_HERE');
 * define('CIVICRM_UF', 'WordPress');
 * 
 * // CiviCRM Directories
 * define('CIVICRM_TEMPLATE_COMPILEDIR', WP_CONTENT_DIR . '/uploads/civicrm/templates_c/');
 * define('CIVICRM_UF_BASEURL', get_site_url() . '/');
 */

// Performance Optimization für MariaDB
ini_set('mysql.connect_timeout', 10);
ini_set('default_socket_timeout', 10);

// Character Set Enforcement
$GLOBALS['civicrm_db_charset'] = 'utf8mb4';
$GLOBALS['civicrm_db_collate'] = 'utf8mb4_unicode_ci';
