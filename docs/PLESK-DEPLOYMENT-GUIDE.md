# Plesk Server Deployment Guide

## 🚀 Schneller Deployment-Prozess für Plesk

### Phase 1: Vorbereitung (5 Minuten)

#### 1.1 Lokale Vorbereitung

```powershell
# SFTP-Sync für Plesk vorbereiten
cd d:\Arbeitsverzeichniss
.\scripts\sftp-sync.ps1 -RemoteHost "your-plesk-server.com" -RemoteUser "your-ftp-user" -DryRun
```

#### 1.2 Plesk-Zugangsdaten sammeln

- **Plesk Control Panel**: `https://your-server.com:8443`
- **FTP/SFTP Host**: `your-server.com`
- **FTP User**: Meist gleich wie Plesk-User
- **Database Root Password**: Aus Plesk Control Panel → Databases

### Phase 2: Database Setup (10 Minuten)

#### 2.1 Upload Database Setup Script

```powershell
# Script hochladen
.\scripts\sftp-sync.ps1 -RemoteHost "your-plesk-server.com" -RemoteUser "your-ftp-user"
```

#### 2.2 Database Setup ausführen

1. **Browser öffnen**: `https://your-domain.com/plesk-db-setup.php?key=MO_SETUP_2025_SECURE_KEY`
2. **Root Password eingeben**: Database Administrator Passwort aus Plesk
3. **Setup starten**: Klick auf "Start Database Setup"
4. **Setup-Script löschen**: Nach erfolgreicher Installation

#### 2.3 Datenbank-Ergebnisse verifizieren

```sql
-- In phpMyAdmin prüfen:
SHOW DATABASES LIKE 'mo_%';
SELECT User, Host FROM mysql.user WHERE User LIKE 'mo_%';
```

### Phase 3: File Upload (15 Minuten)

#### 3.1 WordPress Main Domain

```
Source: menschlichkeit-oesterreich-monorepo/httpdocs/*
Target: /httpdocs/
Status: ✅ Hauptdomain WordPress Installation
```

#### 3.2 API Subdomain (Laravel)

```
Source: menschlichkeit-oesterreich-monorepo/api.menschlichkeit-oesterreich.at/*
Target: /subdomains/api/httpdocs/
Status: 🔄 Laravel API Backend
```

#### 3.3 CRM Subdomain (CiviCRM)

```
Source: menschlichkeit-oesterreich-monorepo/crm.menschlichkeit-oesterreich.at/*
Target: /subdomains/crm/httpdocs/
Status: 📋 CiviCRM Installation
```

### Phase 4: Plesk-Konfiguration (10 Minuten)

#### 4.1 Subdomains erstellen

```
1. Plesk → Websites & Domains
2. Subdomain hinzufügen:
   - api.menschlichkeit-oesterreich.at → /subdomains/api/httpdocs
   - crm.menschlichkeit-oesterreich.at → /subdomains/crm/httpdocs
```

#### 4.2 SSL-Zertifikate aktivieren

```
1. Let's Encrypt für alle Domains aktivieren:
   - ✅ menschlichkeit-oesterreich.at
   - ✅ api.menschlichkeit-oesterreich.at
   - ✅ crm.menschlichkeit-oesterreich.at
2. Force HTTPS redirect aktivieren
```

#### 4.3 PHP-Version setzen

```
Plesk → PHP Settings:
- Main Domain: PHP 8.2+ (WordPress)
- API Subdomain: PHP 8.2+ (Laravel)
- CRM Subdomain: PHP 8.1+ (CiviCRM)
```

### Phase 5: Anwendungs-Konfiguration (15 Minuten)

#### 5.1 WordPress Setup

```bash
# wp-config.php von Setup-Script übernehmen
cp wp-config-plesk.php httpdocs/wp-config.php

# WordPress Salts generieren
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> httpdocs/wp-config.php
```

#### 5.2 Laravel Setup

```bash
# .env Konfiguration
cp laravel-env-plesk.txt subdomains/api/httpdocs/.env

# Laravel Optimierung für Production
cd subdomains/api/httpdocs
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

#### 5.3 CiviCRM Setup

```
1. CiviCRM Installation via Browser
2. URL: https://crm.menschlichkeit-oesterreich.at/civicrm/install
3. Database: mo_civicrm
4. User: mo_crm_user
5. Password: secure_crm_password_2025
```

### Phase 6: Automation & Cron Jobs (10 Minuten)

#### 6.1 Plesk Scheduled Tasks

```bash
# Laravel Queue Worker (alle 5 Minuten)
*/5 * * * * cd /var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/api/httpdocs && php artisan queue:work --stop-when-empty

# CiviCRM Scheduled Jobs (täglich 2:00)
0 2 * * * cd /var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/crm/httpdocs && php bin/cli.php -j -u admin

# WordPress Updates (sonntags 3:00)
0 3 * * 0 cd /var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs && wp core update --allow-root

# Database Backup (täglich 1:00)
0 1 * * * mysqldump --single-transaction --routines --triggers --all-databases | gzip > /var/www/vhosts/menschlichkeit-oesterreich.at/backup/backup_$(date +\%Y\%m\%d).sql.gz
```

#### 6.2 Email-Konfiguration

```
Plesk → Mail Settings:
- SMTP aktivieren für alle Domains
- SPF Records setzen
- DKIM aktivieren
- DMARC Policy konfigurieren
```

### Phase 7: Testing & Verification (15 Minuten)

#### 7.1 Domain-Tests

```bash
# WordPress Main
curl -I https://menschlichkeit-oesterreich.at
# Expected: 200 OK, WordPress headers

# Laravel API
curl -I https://api.menschlichkeit-oesterreich.at/health
# Expected: 200 OK, JSON response

# CiviCRM
curl -I https://crm.menschlichkeit-oesterreich.at
# Expected: 200 OK, CiviCRM installation or login
```

#### 7.2 Database-Verbindungen testen

```php
// Test-Script für alle Verbindungen
<?php
$connections = [
    'WordPress' => ['mo_wordpress', 'mo_wp_user', 'secure_wp_password_2025'],
    'API' => ['mo_api', 'mo_api_user', 'secure_api_password_2025'],
    'CiviCRM' => ['mo_civicrm', 'mo_crm_user', 'secure_crm_password_2025']
];

foreach ($connections as $name => $config) {
    try {
        $pdo = new PDO("mysql:host=localhost;dbname={$config[0]}", $config[1], $config[2]);
        echo "✅ $name: Connection successful\n";
    } catch (Exception $e) {
        echo "❌ $name: Connection failed - {$e->getMessage()}\n";
    }
}
?>
```

#### 7.3 Performance-Check

```bash
# Page Speed Test
curl -w "@curl-format.txt" -o /dev/null -s https://menschlichkeit-oesterreich.at

# Database Performance
mysql -u root -p -e "SHOW GLOBAL STATUS LIKE 'Slow_queries';"
```

## 🎯 Deployment Checklist

### Pre-Deployment

- [ ] Plesk-Zugangsdaten verfügbar
- [ ] Domain DNS auf Server zeigt
- [ ] Backup von existierenden Daten
- [ ] SSL-Zertifikate geplant

### During Deployment

- [ ] Database Setup Script erfolgreich
- [ ] Alle Dateien hochgeladen
- [ ] Subdomains erstellt
- [ ] SSL aktiviert
- [ ] PHP-Versionen konfiguriert

### Post-Deployment

- [ ] Alle Domains erreichbar (HTTP 200)
- [ ] Database-Verbindungen funktionieren
- [ ] WordPress Admin zugänglich
- [ ] Laravel API responses
- [ ] CiviCRM Installation abgeschlossen
- [ ] Cron Jobs aktiviert
- [ ] Email-Versand funktioniert
- [ ] Performance-Monitoring aktiviert

## ⚡ Schnell-Deployment (30 Minuten total)

```powershell
# 1. SFTP Upload starten (5 min)
.\scripts\sftp-sync.ps1 -RemoteHost "server.com" -RemoteUser "user"

# 2. Database Setup (5 min)
# Browser: https://domain.com/plesk-db-setup.php?key=MO_SETUP_2025_SECURE_KEY

# 3. Plesk Konfiguration (10 min)
# - Subdomains erstellen
# - SSL aktivieren
# - PHP-Versionen setzen

# 4. Anwendungs-Setup (10 min)
# - wp-config.php anpassen
# - Laravel .env konfigurieren
# - CiviCRM installieren

# 5. Testing & Go-Live ✅
```

Nach diesem Guide ist die komplette Menschlichkeit Österreich Website mit allen drei Domains (WordPress, API, CiviCRM) auf dem Plesk-Server produktiv!
