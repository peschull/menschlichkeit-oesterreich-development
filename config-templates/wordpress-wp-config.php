# WordPress Configuration für mo_wordpress_main @ digimagical.com
# wp-config.php Konfiguration

<?php
/**
 * Database Configuration für WordPress @ Plesk digimagical.com
 * MariaDB 10.6.22 auf Ubuntu 22.04 mit nginx/1.28.0 und PHP 8.4.11
 */

// ** MySQL settings ** //
/** The name of the database for WordPress */
define('DB_NAME', 'mo_wordpress_main');

/** MySQL database username */
define('DB_USER', 'mo_wp_user');

/** MySQL database password */
define('DB_PASSWORD', 'SECURE_PASSWORD_WP_2025');

/** MySQL hostname (UNIX Socket für bessere Performance) */
define('DB_HOST', 'localhost');

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', 'utf8mb4');

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', 'utf8mb4_unicode_ci');

/**
 * Plesk-optimierte Konfiguration
 * Server: MariaDB 10.6.22 @ digimagical.com
 */

// SSL-Konfiguration (falls externe Verbindungen)
define('MYSQL_SSL_CERT', '');
define('MYSQL_SSL_KEY', '');
define('MYSQL_SSL_CA', '');

// Performance-Optimierungen
define('WP_CACHE', true);
define('COMPRESS_CSS', true);
define('COMPRESS_SCRIPTS', true);
define('CONCATENATE_SCRIPTS', true);

// Database-spezifische Optimierungen
ini_set('mysql.connect_timeout', 10);
ini_set('default_socket_timeout', 10);

/**#@+
 * Authentication Unique Keys and Salts.
 * Generiert über: https://api.wordpress.org/secret-key/1.1/salt/
 */
define('AUTH_KEY',         'put your unique phrase here');
define('SECURE_AUTH_KEY',  'put your unique phrase here');
define('LOGGED_IN_KEY',    'put your unique phrase here');
define('NONCE_KEY',        'put your unique phrase here');
define('AUTH_SALT',        'put your unique phrase here');
define('SECURE_AUTH_SALT', 'put your unique phrase here');
define('LOGGED_IN_SALT',   'put your unique phrase here');
define('NONCE_SALT',       'put your unique phrase here');

/**#@-*/

/**
 * WordPress Database Table prefix.
 */
$table_prefix = 'wp_';

/**
 * For developers: WordPress debugging mode.
 */
define('WP_DEBUG', false);
define('WP_DEBUG_LOG', false);
define('WP_DEBUG_DISPLAY', false);

// Plesk-spezifische Pfade
define('WP_CONTENT_DIR', dirname(__FILE__) . '/wp-content');
define('WP_CONTENT_URL', 'https://menschlichkeit-oesterreich.at/wp-content');

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if (!defined('ABSPATH')) {
    define('ABSPATH', dirname(__FILE__) . '/');
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
?>