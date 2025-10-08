<?php

/**
 * Drupal + CiviCRM Einstellungen für crm.menschlichkeit-oesterreich.at
 * Werte werden vorzugsweise über Umgebungsvariablen bereitgestellt.
 */

if (!isset($config) || !is_array($config)) {
    $config = [];
}

$env = static function (string $key, $default = null) {
    $value = getenv($key);
    if ($value === false || $value === null || $value === '') {
        return $default;
    }
    return $value;
};

// Datenbankkonfiguration
$crmDbHost = $env('CRM_DB_HOST', 'localhost');
$crmDbPort = (string) $env('CRM_DB_PORT', '3306');
$crmDbName = $env('CRM_DB_NAME', 'mo_crm');
$crmDbUser = $env('CRM_DB_USER', 'svc_crm');
$crmDbPass = $env('CRM_DB_PASS', '');

$databases = [];
$databases['default']['default'] = [
    'database'  => $crmDbName,
    'username'  => $crmDbUser,
    'password'  => $crmDbPass,
    'host'      => $crmDbHost,
    'port'      => $crmDbPort,
    'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
    'driver'    => 'mysql',
    'prefix'    => '',
    'charset'   => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
];

// Sicherheit
$settings['hash_salt'] = $env('DRUPAL_HASH_SALT', hash('sha256', $crmDbName . '_hash_salt'));
$settings['update_free_access'] = FALSE;
$settings['container_yamls'][] = $app_root . '/' . $site_path . '/services.yml';

// Datei- und Pfadkonfiguration
$settings['file_public_path'] = $env('DRUPAL_FILE_PUBLIC_PATH', 'sites/default/files');
$settings['file_private_path'] = $env('DRUPAL_FILE_PRIVATE_PATH', 'sites/default/files/private');
$settings['file_temp_path'] = $env('DRUPAL_FILE_TEMP_PATH', '/tmp');
$config['system.file']['path']['temporary'] = $env(
    'DRUPAL_FILE_TEMPORARY_CONFIG',
    '/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/crm/httpdocs/sites/default/files/tmp'
);

// Trusted Hosts
$baseHost = parse_url($env('CRM_BASE_URL', 'https://crm.menschlichkeit-oesterreich.at'), PHP_URL_HOST);
if ($baseHost) {
    $pattern = '^' . preg_quote($baseHost, '#') . '$';
    $settings['trusted_host_patterns'] = [
        $pattern,
        '^www\.' . preg_quote($baseHost, '#') . '$',
    ];
}

// SMTP / Mail
$config['system.mail']['interface']['default'] = 'smtp';
$config['smtp']['smtp_host'] = $env('CRM_SMTP_HOST', 'localhost');
$config['smtp']['smtp_port'] = $env('CRM_SMTP_PORT', '587');
$config['smtp']['smtp_username'] = $env('CRM_SMTP_USER', 'crm@menschlichkeit-oesterreich.at');
$config['smtp']['smtp_password'] = $env('CRM_SMTP_PASS', '');
$config['smtp']['smtp_protocol'] = $env('CRM_SMTP_PROTOCOL', 'tls');

// Caching / Performance
$settings['cache']['default'] = 'cache.backend.database';
$settings['cache']['bins']['render'] = 'cache.backend.database';
$settings['cache']['bins']['page'] = 'cache.backend.database';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.database';
$config['system.performance']['css']['preprocess'] = TRUE;
$config['system.performance']['js']['preprocess'] = TRUE;

// Logging & Debugging
$config['system.logging']['error_level'] = $env('DRUPAL_ERROR_LEVEL', 'hide');
$settings['rebuild_access'] = FALSE;
$settings['skip_permissions_hardening'] = FALSE;

// Locale
$config['system.site']['default_langcode'] = $env('DRUPAL_DEFAULT_LANGCODE', 'de');
$config['system.regional']['first_day'] = (int) $env('DRUPAL_FIRST_DAY', 1);
$config['system.date']['timezone']['default'] = $env('DRUPAL_TIMEZONE', 'Europe/Vienna');

// Themes
$config['system.theme']['default'] = $env('DRUPAL_DEFAULT_THEME', 'claro');
$config['system.theme']['admin'] = $env('DRUPAL_ADMIN_THEME', 'seven');

// Integrationen
$config['api']['main_site'] = $env('CRM_API_MAIN_SITE', 'https://menschlichkeit-oesterreich.at');
$config['api']['api_endpoint'] = $env('CRM_API_ENDPOINT', 'https://api.menschlichkeit-oesterreich.at');
$config['api']['gaming_platform'] = $env('CRM_GAMING_ENDPOINT', 'https://games.menschlichkeit-oesterreich.at');

// Backups
$config['backup_migrate']['settings']['backup_dir'] = $env(
    'DRUPAL_BACKUP_DIR',
    'sites/default/files/backup_migrate'
);
$config['backup_migrate']['settings']['schedule_enabled'] = filter_var(
    $env('DRUPAL_BACKUP_SCHEDULE_ENABLED', TRUE),
    FILTER_VALIDATE_BOOLEAN
);
$config['backup_migrate']['settings']['schedule_time'] = $env('DRUPAL_BACKUP_SCHEDULE_TIME', '02:00');

// Plesk spezifisch / Doku
$settings['plesk_server'] = $env('DRUPAL_PLESK_SERVER', 'digimagical.com');
$settings['document_root'] = $env(
    'DRUPAL_DOCUMENT_ROOT',
    '/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/crm/httpdocs'
);
$settings['php_version'] = $env('DRUPAL_PHP_VERSION', '8.3.25');
$settings['server_software'] = $env('DRUPAL_SERVER_SOFTWARE', 'Apache FPM');

// Services geladen durch Drupal Standard-Setup.
$settings['container_yamls'][] = __DIR__ . '/services.yml';

// Weitere Konfigurationsdateien
$civicrm_setting_file = __DIR__ . '/civicrm.settings.php';
if (file_exists($civicrm_setting_file)) {
    require_once $civicrm_setting_file;
}

// Load local development override configuration, if available.
if (file_exists(__DIR__ . '/settings.local.php')) {
    include __DIR__ . '/settings.local.php';
}
