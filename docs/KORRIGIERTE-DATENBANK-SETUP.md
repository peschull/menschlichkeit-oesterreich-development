# ✅ KORRIGIERTE Datenbankeinrichtung - Eindeutige Namen

# Menschlichkeit Österreich Multi-Domain Setup

## 🚨 WICHTIG: Verwenden Sie diese korrigierte Version!

Die vorherige Version hatte einen Fehler, bei dem CiviCRM und API dieselben Daten angezeigt haben.
Verwenden Sie diese korrigierten Datenbanknamen:

---

## 📊 WordPress Hauptdomain

- **Datenbankname**: `mo_wordpress_main`
- **Benutzername**: `mo_wp_user`
- **Beschreibung**: Main WordPress website database

## 📊 Laravel API Subdomain

- **Datenbankname**: `mo_laravel_api`
- **Benutzername**: `mo_api_user`
- **Beschreibung**: Laravel API subdomain database

## 📊 CiviCRM Subdomain

- **Datenbankname**: `mo_civicrm_data`
- **Benutzername**: `mo_crm_user`
- **Beschreibung**: CiviCRM subdomain database

---

## 🔧 Zugriff auf korrigierte Version:

**Neue URL (ohne Cache-Probleme):**
https://menschlichkeit-oesterreich.at/plesk-manual-database-creation-fixed.php?key=MO_SETUP_2025_SECURE_KEY

Diese Version wird:
✅ Eindeutige Datenbanknamen für alle drei Domains anzeigen
✅ Separate sichere Passwörter für jeden Benutzer generieren  
✅ Korrekte .env-Konfigurationen für jede Domain bereitstellen

---

## 🎯 Nach der Datenbankeinrichtung:

### WordPress (.env):

```env
DB_NAME=mo_wordpress_main
DB_USER=mo_wp_user
DB_PASSWORD=[von Skript generiertes Passwort]
```

### Laravel API (.env):

```env
DB_DATABASE=mo_laravel_api
DB_USERNAME=mo_api_user
DB_PASSWORD=[von Skript generiertes Passwort]
```

### CiviCRM Konfiguration:

```env
CIVICRM_DB_NAME=mo_civicrm_data
CIVICRM_DB_USER=mo_crm_user
CIVICRM_DB_PASS=[von Skript generiertes Passwort]
```

---

**⚠️ Verwenden Sie ausschließlich die neue korrigierte URL!**
