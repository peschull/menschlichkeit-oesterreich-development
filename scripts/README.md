# Plesk Multi-Domain Setup - Script Uebersicht

Setup-Scripts fuer menschlichkeit-oesterreich.at Multi-Domain Architektur

## Script-Dateien

### SFTP-Synchronisation

- `sync_sftp.ps1` - Synchronisiert lokale Dateien mit dem Plesk Server
  - Lädt Website-Inhalte vom Server herunter
  - Erhält bestehende Konfigurationen
  - Status: Erfolgreich ausgefuehrt

### Database Setup

- `plesk-db-setup.php` - Web-basiertes Database Setup Script
  - Erstellt 3 Datenbanken: mo_wordpress, mo_api, mo_civicrm
  - Konfiguriert Database-User mit sicheren Passwoertern
  - Status: Auf Server hochgeladen

- `plesk-setup-upload.ps1` - Upload Script fuer Database Setup
  - Lädt Database Setup und .env Templates auf Server hoch
  - Status: Erfolgreich ausgefuehrt

- `plesk-upload-simple.ps1` - Vereinfachtes Upload Script
  - Alternative Upload-Methode mit besserer Fehlerbehandlung
  - Status: Erfolgreich ausgefuehrt

### Anleitungen

- `plesk-setup-anleitung.ps1` - Finale Setup-Anleitung
  - Zeigt naechste Schritte nach Upload an
  - Sicherheitshinweise und Best Practices
  - Status: Bereit zur Nutzung

## Multi-Domain Architektur

### Haupt-Domain: menschlichkeit-oesterreich.at

- Pfad: `/httpdocs/`
- Framework: WordPress mit .env-Konfiguration
- Database: `mo_wordpress`
- Features: WP Super Cache, Composer Autoloader, Security Headers

### API-Subdomain: api.menschlichkeit-oesterreich.at

- Pfad: `/api.menschlichkeit-oesterreich.at/`
- Framework: Laravel 12 (PHP 8.2+)
- Database: `mo_api`
- Features: Queue Worker, Vite, Pail Logging

### CRM-Subdomain: crm.menschlichkeit-oesterreich.at

- Pfad: `/crm.menschlichkeit-oesterreich.at/`
- Framework: WordPress + CiviCRM Plugin
- Database: `mo_civicrm`
- Features: Donor Management, Event Organization

## Setup-Status

### Abgeschlossen

1. SFTP-Synchronisation mit Live-Server
2. Analyse der bestehenden Website-Struktur
3. Database Setup Scripts erstellt
4. .env Templates fuer alle 3 Domains generiert
5. Upload aller Setup-Dateien auf Plesk Server

### Aktuell

Database Setup auf Plesk Server ausfuehren:

1. Browser oeffnen: `https://menschlichkeit-oesterreich.at/plesk-db-setup.php?key=MO_SETUP_2025_SECURE_KEY`
2. Database Root-Passwort eingeben
3. Setup ausfuehren (erstellt alle 3 Datenbanken)

### Als Naechstes

1. .env-Dateien von Templates kopieren und anpassen
2. WordPress Salts generieren und einsetzen
3. Laravel App Key generieren: `php artisan key:generate`
4. CiviCRM Site Key und API Keys konfigurieren
5. Setup-Script nach Erfolg loeschen!

## Sicherheit

### Kritische Sicherheitsmassnahmen

- Setup-Script sofort nach Ausfuehrung loeschen
- Sichere Passwoerter fuer alle Database-User
- .env-Dateien niemals in Git einchecken
- Regelmässige Database-Backups

### Generierte Credentials

- Database-User: mo_wp_user, mo_api_user, mo_crm_user
- Sichere, zufällige Passwoerter werden automatisch generiert
- WordPress Salts: https://api.wordpress.org/secret-key/1.1/salt/

## Server-Details

- Plesk Server: 5.183.217.146
- SSH User: dmpl20230054
- SSH Key: C:\Users\schul\.ssh\id_ed25519

## Support

Bei Problemen:

- Plesk Database Manager ueberpruefen
- PHP Error Logs in Plesk ansehen
- .env-Dateien auf korrekte Syntax pruefen
- Scripts erneut ausfuehren falls noetig

Status: Bereit fuer Database Setup
