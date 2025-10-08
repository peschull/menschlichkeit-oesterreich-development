<?php

/**
 * CiviCRM Settings – nutzt Umgebungsvariablen für sensible Werte.
 */

$env = static function (string $key, $default = null) {
    $value = getenv($key);
    if ($value === false || $value === null || $value === '') {
        return $default;
    }
    return $value;
};

$crmDbHost = $env('CRM_DB_HOST', 'localhost');
$crmDbPort = (string) $env('CRM_DB_PORT', '3306');
$crmDbName = $env('CRM_DB_NAME', 'mo_crm');
$crmDbUser = $env('CRM_DB_USER', 'svc_crm');
$crmDbPass = $env('CRM_DB_PASS', '');

$dsnUser = rawurlencode($crmDbUser);
$dsnPass = rawurlencode($crmDbPass);
$civiDsn = sprintf(
    'mysql://%s:%s@%s:%s/%s?new_link=true',
    $dsnUser,
    $dsnPass,
    $crmDbHost,
    $crmDbPort,
    $crmDbName
);

define('CIVICRM_DSN', $civiDsn);
define('CIVICRM_DB_HOST', $crmDbHost);
define('CIVICRM_DB_PORT', $crmDbPort);
define('CIVICRM_DB_NAME', $crmDbName);
define('CIVICRM_DB_USER', $crmDbUser);
define('CIVICRM_DB_PASS', $crmDbPass);

$civicrmSiteKey = $env('CIVICRM_SITE_KEY', hash('sha256', $crmDbName . '_site_key'));
$civicrmCredKey = $env('CIVICRM_CRED_KEYS', hash('sha256', $civicrmSiteKey . '_cred'));
$civicrmSignKey = $env('CIVICRM_SIGN_KEYS', hash('sha256', $civicrmSiteKey . '_sign'));
define('CIVICRM_SITE_KEY', $civicrmSiteKey);
define('CIVICRM_CRED_KEYS', $civicrmCredKey);
define('CIVICRM_SIGN_KEYS', $civicrmSignKey);

define('CIVICRM_UF', 'Drupal');
define('CIVICRM_UF_DSN', $civiDsn);
$civicrmBaseUrl = rtrim($env('CIVICRM_BASE_URL', 'https://crm.menschlichkeit-oesterreich.at/'), '/') . '/';
define('CIVICRM_UF_BASEURL', $civicrmBaseUrl);

$civicrmRoot = $env(
    'CIVICRM_ROOT_PATH',
    '/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/crm/httpdocs/'
);
define('CIVICRM_TEMPLATE_COMPILEDIR', $civicrmRoot . 'sites/default/files/civicrm/templates_c/');

define('CIVICRM_MAIL_SMARTY', 1);
define('CIVICRM_MAIL_LOG', 1);
define('CIVICRM_MAILER_BOUNCE_PROCESSING', 1);
define('CIVICRM_MAILING_BASE_URL', $civicrmBaseUrl);

define('CIVICRM_API_MAIN_SITE', $env('CIVICRM_API_MAIN_SITE', 'https://menschlichkeit-oesterreich.at'));
define('CIVICRM_API_ENDPOINT', $env('CIVICRM_API_ENDPOINT', 'https://api.menschlichkeit-oesterreich.at'));
define('CIVICRM_GAMING_INTEGRATION', $env('CIVICRM_GAMING_ENDPOINT', 'https://games.menschlichkeit-oesterreich.at'));

define('CIVICRM_DB_CACHE_CLASS', $env('CIVICRM_DB_CACHE_CLASS', 'CRM_Utils_Cache_Memcache'));
define('CIVICRM_DB_CACHE_HOST', $env('CIVICRM_DB_CACHE_HOST', 'localhost'));
define('CIVICRM_DB_CACHE_PORT', (int) $env('CIVICRM_DB_CACHE_PORT', 11211));
define('CIVICRM_DB_CACHE_TIMEOUT', (int) $env('CIVICRM_DB_CACHE_TIMEOUT', 3600));
define('CIVICRM_DB_CACHE_PREFIX', $env('CIVICRM_DB_CACHE_PREFIX', 'mo_civicrm_'));

define('CIVICRM_DEBUG_LOG_QUERY', 0);
define('CIVICRM_DEBUG_LOG_QUERY_PARAMS', 0);
define('CIVICRM_BACKTRACE', 0);
ini_set('log_errors', 1);
ini_set('error_log', $civicrmRoot . 'sites/default/files/civicrm/ConfigAndLog/CiviCRM.log');

define('CIVICRM_EXTENSIONS_BASE_URL', $civicrmBaseUrl . 'sites/default/files/civicrm/ext/');
define('CIVICRM_EXTENSIONS_BASE_DIR', $civicrmRoot . 'sites/default/files/civicrm/ext/');

define('CIVICRM_UF_LOCALE_CALLBACK', ['CRM_Utils_System_Drupal', 'getUFLocale']);
define('CIVICRM_DEFAULT_LOCALE', $env('CIVICRM_DEFAULT_LOCALE', 'de_AT'));
define('CIVICRM_DEFAULT_CURRENCY', $env('CIVICRM_DEFAULT_CURRENCY', 'EUR'));

define('CIVICRM_CMSDIR', $civicrmRoot);
define('CIVICRM_DOMAIN_ID', (int) $env('CIVICRM_DOMAIN_ID', 1));
define('CIVICRM_DOMAIN_ORG_URL', $env('CIVICRM_DOMAIN_ORG_URL', 'https://menschlichkeit-oesterreich.at'));

define('CIVICRM_API_KEYS', 1);
define('CIVICRM_WEBHOOK_ENABLED', (int) $env('CIVICRM_WEBHOOK_ENABLED', 1));
define('CIVICRM_WEBHOOK_URL', $env('CIVICRM_WEBHOOK_URL', 'https://api.menschlichkeit-oesterreich.at/webhooks/civicrm'));

define('CIVICRM_BACKUP_DIR', $env(
    'CIVICRM_BACKUP_DIR',
    $civicrmRoot . 'sites/default/files/civicrm/backup/'
));
define('CIVICRM_BACKUP_RETENTION_DAYS', (int) $env('CIVICRM_BACKUP_RETENTION_DAYS', 30));

define('CIVICRM_PLESK_SERVER', $env('CIVICRM_PLESK_SERVER', 'digimagical.com'));
define('CIVICRM_PHP_VERSION', $env('CIVICRM_PHP_VERSION', '8.3.25'));
define('CIVICRM_SERVER_MODE', $env('CIVICRM_SERVER_MODE', 'FPM-Apache'));

if (!defined('CIVICRM_SETTINGS_PATH')) {
    define('CIVICRM_SETTINGS_PATH', __DIR__ . '/');
}

$custom_settings = __DIR__ . '/civicrm.custom.php';
if (file_exists($custom_settings)) {
    require_once $custom_settings;
}

$dev_settings = __DIR__ . '/civicrm.local.php';
if (file_exists($dev_settings)) {
    require_once $dev_settings;
}
