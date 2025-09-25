# Manuelle Datenbank-Einrichtung im Plesk Control Panel

## Zugriff auf Plesk Panel

- URL: https://5.183.217.146:8443 oder https://menschlichkeit-oesterreich.at:8443
- Benutzer: dmpl20230054
- Passwort: [Ihr Plesk-Passwort]

## Schritt 1: Datenbanken erstellen

### 1. WordPress Datenbank

- Name: `mo_wordpress`
- Benutzer: `mo_wp_user`
- Passwort: [Sicheres Passwort generieren]
- Berechtigungen: Alle Berechtigungen für mo_wordpress

### 2. Laravel API Datenbank

- Name: `mo_api`
- Benutzer: `mo_api_user`
- Passwort: [Sicheres Passwort generieren]
- Berechtigungen: Alle Berechtigungen für mo_api

### 3. CiviCRM Datenbank

- Name: `mo_civicrm`
- Benutzer: `mo_crm_user`
- Passwort: [Sicheres Passwort generieren]
- Berechtigungen: Alle Berechtigungen für mo_civicrm

## Schritt 2: Datenbankverbindung testen

Verwenden Sie phpMyAdmin im Plesk Panel um die Verbindungen zu testen:

1. Gehen Sie zu "Datenbanken" im Plesk Panel
2. Klicken Sie auf "phpMyAdmin" neben jeder Datenbank
3. Melden Sie sich mit den erstellten Benutzerdaten an

## Schritt 3: Konfigurationsdateien aktualisieren

Nach erfolgreicher Datenbankeinrichtung müssen die .env-Dateien aktualisiert werden:

### WordPress (.env)

```env
DB_NAME=mo_wordpress
DB_USER=mo_wp_user
DB_PASSWORD=[generiertes Passwort]
DB_HOST=localhost
DB_PORT=3306
```

### Laravel API (.env)

```env
DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=mo_api
DB_USERNAME=mo_api_user
DB_PASSWORD=[generiertes Passwort]
```

### CiviCRM

CiviCRM-Konfiguration erfolgt über die WordPress-Integration mit separaten Datenbankeinstellungen.

## Troubleshooting

### MariaDB Socket-Authentifizierung

Wenn Socket-Authentifizierung verwendet wird:

- Host sollte 'localhost' sein
- Möglicherweise ist kein Passwort erforderlich für lokale Verbindungen
- Socket-Pfad: `/var/lib/mysql/mysql.sock` oder `/tmp/mysql.sock`

### TCP-Verbindungen

Falls Socket nicht funktioniert:

- Host: `127.0.0.1` statt `localhost`
- Port: `3306` (Standard)
- Passwort ist dann normalerweise erforderlich

### Plesk-spezifische Einstellungen

- Datenbank-Server läuft normalerweise als `mysql` Service
- Root-Zugang kann über Plesk Panel verwaltet werden
- phpMyAdmin ist meist unter "Datenbanken" verfügbar
