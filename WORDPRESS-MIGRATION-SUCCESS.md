# Migration von WordPress zu Laravel + CiviCRM - Komplett ✅

## 🚀 **Migration erfolgreich vorbereitet - OHNE WordPress**

### 🗂️ **Neue Datenbank-Architektur**

| Datenbankname       | System                    | Status             | Benutzer       |
| ------------------- | ------------------------- | ------------------ | -------------- |
| `mo_laravel_api`    | **Laravel API (PRIMARY)** | ✅ **Aktiv**       | `laravel_user` |
| `mo_civicrm_data`   | **CiviCRM Standalone**    | ✅ **Aktiv**       | `civicrm_user` |
| `mo_wordpress_main` | WordPress (Legacy)        | ⚠️ **Archivieren** | `mo_wp_user`   |

---

## 🔧 **Implementierte Änderungen**

### ✅ **1. .env-Konfiguration aktualisiert**

```env
# Laravel API Database (PRIMARY SYSTEM)
LARAVEL_DB_CONNECTION=mysql
LARAVEL_DB_HOST=127.0.0.1
LARAVEL_DB_PORT=3306
LARAVEL_DB_NAME=mo_laravel_api
LARAVEL_DB_USER=laravel_user
LARAVEL_DB_PASS=SECURE_LARAVEL_2025

# CiviCRM Database (Standalone/Drupal)
CIVICRM_DB_HOST=localhost
CIVICRM_DB_NAME=mo_civicrm_data
CIVICRM_DB_USER=civicrm_user
CIVICRM_DB_PASS=SECURE_CIVICRM_2025

# WordPress Database - DEPRECATED
# WP_DB_STATUS=ARCHIVIERT/OPTIONAL
```

### ✅ **2. Neue DB-Benutzer mit minimalen Rechten**

```sql
-- Laravel API User
CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'SECURE_LARAVEL_2025';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER ON mo_laravel_api.* TO 'laravel_user'@'localhost';

-- CiviCRM User
CREATE USER 'civicrm_user'@'localhost' IDENTIFIED BY 'SECURE_CIVICRM_2025';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER ON mo_civicrm_data.* TO 'civicrm_user'@'localhost';

FLUSH PRIVILEGES;
```

### ✅ **3. Konfigurationsdateien aktualisiert**

- **Laravel**: `config-templates/laravel-env-production.env` (ohne WordPress)
- **CiviCRM**: `config-templates/civicrm-settings.php` (standalone)
- **WordPress**: `config-templates/wordpress-wp-config.php` (archiviert)

### ✅ **4. Migration-Tools erstellt**

- **Migration-Skript**: `scripts/wordpress-migration.ps1`
- **Database-Tester**: `scripts/plesk-db-tester.ps1` (ohne WordPress)
- **Analyse-Tools**: Automatische WordPress-Erkennung

---

## 🎯 **Nächste Plesk-Panel Aktionen**

### **🔴 Sofort erforderlich:**

1. **📊 phpMyAdmin öffnen:**

   ```sql
   -- Neue Benutzer erstellen
   CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'SECURE_LARAVEL_2025';
   CREATE USER 'civicrm_user'@'localhost' IDENTIFIED BY 'SECURE_CIVICRM_2025';

   -- Rechte zuweisen
   GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER ON mo_laravel_api.* TO 'laravel_user'@'localhost';
   GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,INDEX,ALTER ON mo_civicrm_data.* TO 'civicrm_user'@'localhost';

   FLUSH PRIVILEGES;
   ```

2. **🗂️ Website-Zuordnung:**
   - `mo_laravel_api` → **api.menschlichkeit-oesterreich.at**
   - `mo_civicrm_data` → **Drupal-Installation zuweisen** (empfohlen)

3. **🔐 Passwörter ersetzen:**
   - `SECURE_LARAVEL_2025` → Echtes sicheres Passwort
   - `SECURE_CIVICRM_2025` → Echtes sicheres Passwort

### **🟡 WordPress-Archivierung (optional):**

1. **💾 Backup erstellen:**

   ```sql
   mysqldump -u root -p mo_wordpress_main > wp_backup_20250926.sql
   ```

2. **📁 Optionen:**
   - **Archivieren**: `RENAME TABLE mo_wordpress_main TO mo_wordpress_archive;`
   - **Löschen**: `DROP DATABASE mo_wordpress_main;` (nur bei Sicherheit!)

3. **👤 Legacy User:**
   - `mo_wp_user` Rechte prüfen
   - Falls nur WordPress: `DROP USER 'mo_wp_user'@'localhost';`

---

## 🛠️ **Automatisierte Überwachung**

### **Database Connection Tests:**

```powershell
# Neue Architektur testen
.\scripts\plesk-db-tester.ps1 test

# Sicherheitscheck für neue User
.\scripts\plesk-db-tester.ps1 security

# Migration analysieren
.\scripts\wordpress-migration.ps1 analyze
```

### **Performance-Monitoring:**

- **Laravel API**: Primäres System mit höchster Priorität
- **CiviCRM**: Standalone oder Drupal-Integration
- **WordPress**: Optional archiviert, keine aktive Überwachung

---

## 📊 **Vorteile der neuen Architektur**

### ✅ **Sicherheit:**

- **Separate DB-Benutzer** für jedes System
- **Minimale Rechte** pro Anwendung
- **Kein gemeinsamer Legacy-User** (`mo_wp_user`)

### ⚡ **Performance:**

- **Laravel API als Primary** - optimierte Konfiguration
- **UNIX Socket** für alle Verbindungen
- **utf8mb4_unicode_ci** für internationale Inhalte

### 🎯 **Fokus:**

- **Laravel API** → Haupt-Backend für api.menschlichkeit-oesterreich.at
- **CiviCRM** → Datenmanagement (standalone oder Drupal)
- **WordPress** → Optional archiviert, nicht mehr im Fokus

---

**🎉 Migration von WordPress zu Laravel + CiviCRM erfolgreich vorbereitet!**

_Bereit für MariaDB 10.6.22 @ digimagical.com mit separaten DB-Benutzern und optimaler Sicherheit._
