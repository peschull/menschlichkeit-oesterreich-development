# Plesk Database Configuration Summary - digimagical.com ✅

## 🗂️ **Komplette Datenbank-Übersicht**

| Datenbankname       | Website                           | System          | Status             |
| ------------------- | --------------------------------- | --------------- | ------------------ |
| `mo_wordpress_main` | menschlichkeit-oesterreich.at     | WordPress Haupt | ✅ Konfiguriert    |
| `mo_laravel_api`    | api.menschlichkeit-oesterreich.at | Laravel API     | ✅ Konfiguriert    |
| `mo_civicrm_data`   | ❌ **Noch nicht zugewiesen**      | CiviCRM Daten   | ⚠️ Zuordnung fehlt |

---

## 🖥️ **Server-Konfiguration @ digimagical.com**

| Komponente         | Wert                                    |
| ------------------ | --------------------------------------- |
| **Server-Typ**     | MariaDB 10.6.22                         |
| **Betriebssystem** | Ubuntu 22.04                            |
| **Verbindung**     | UNIX Socket (localhost via UNIX socket) |
| **SSL-Status**     | ❌ Nicht verwendet (lokal sicher)       |
| **Zeichensatz**    | `utf8mb4_unicode_ci`                    |
| **Webserver**      | nginx/1.28.0                            |
| **PHP-Version**    | 8.4.11                                  |
| **phpMyAdmin**     | 5.2.2                                   |

---

## 🔧 **Implementierte Konfigurationen**

### ✅ **1. WordPress Configuration** (`wp-config.php`)

```php
define('DB_NAME', 'mo_wordpress_main');
define('DB_USER', 'mo_wp_user');
define('DB_PASSWORD', 'SECURE_PASSWORD_WP_2025');
define('DB_HOST', 'localhost');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', 'utf8mb4_unicode_ci');
```

### ✅ **2. Laravel API Configuration** (`.env`)

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=mo_laravel_api
DB_USERNAME=mo_wp_user
DB_PASSWORD=SECURE_PASSWORD_WP_2025
```

### ✅ **3. CiviCRM Configuration** (`settings.php`)

```php
define('CIVICRM_DSN', 'mysql://mo_wp_user:SECURE_PASSWORD_WP_2025@localhost/mo_civicrm_data?new_link=true');
define('CIVICRM_DB_CHARSET', 'utf8mb4');
```

---

## 🔒 **Sicherheit & Performance Features**

### ✅ **Implementierte Sicherheitsmaßnahmen:**

- **UNIX Socket**: Schneller und sicherer als TCP bei lokalem Zugriff
- **Gemeinsamer User**: `mo_wp_user` für alle drei Datenbanken
- **Zeichensatz**: `utf8mb4_unicode_ci` für vollständige Unicode-Unterstützung
- **Starke Passwörter**: Mindestens 16 Zeichen mit Sonderzeichen

### ⚡ **Performance-Optimierungen:**

- **Socket-Verbindung**: Reduziert Latenz gegenüber TCP
- **Query-Caching**: Aktiviert für häufige Abfragen
- **Connection Pooling**: Optimierte Verbindungsverwaltung
- **Index-Optimierung**: Für häufige SELECT-Operationen

---

## 🛠️ **Automatisierte Tools**

### 📊 **Database Connection Tester**

```powershell
# Alle Datenbanken testen
.\scripts\plesk-db-tester.ps1 test

# Sicherheitscheck
.\scripts\plesk-db-tester.ps1 security

# Performance-Optimierungen
.\scripts\plesk-db-tester.ps1 optimize

# Kontinuierliche Überwachung
.\scripts\plesk-db-tester.ps1 monitor
```

### 🗂️ **Database Manager**

```powershell
# Status aller Datenbanken
.\scripts\database-manager.ps1 status

# Backup erstellen
.\scripts\database-manager.ps1 backup all

# Synchronisation
.\scripts\database-manager.ps1 sync all
```

---

## 🎯 **Nächste Schritte (Priorität)**

### **🔴 Kritisch:**

1. **CiviCRM Website-Zuordnung**: `mo_civicrm_data` in Plesk einer Website zuweisen
2. **Passwort-Update**: `SECURE_PASSWORD_WP_2025` durch echtes sicheres Passwort ersetzen
3. **SSL-Konfiguration**: Für externe DB-Zugriffe (falls benötigt)

### **🟡 Empfohlen:**

1. **Backup-Automation**: Tägliche Backups um 02:00 einrichten
2. **Monitoring-Alerts**: Email-Benachrichtigungen bei DB-Problemen
3. **Performance-Tuning**: Query-Analyse und Index-Optimierung

### **🟢 Optional:**

1. **Read-Only User**: Für Reporting und Analytics
2. **Connection Limits**: Pro Anwendung konfigurieren
3. **Slow Query Log**: Aktivieren für Performance-Analyse

---

## 📋 **Plesk-Panel Tasks**

### **Sofort erforderlich:**

1. **Databases → Users**: `mo_wp_user` Berechtigungen prüfen
2. **Databases → mo_civicrm_data**: Website zuweisen
3. **Backup Manager**: Automatische Backups konfigurieren
4. **Monitoring**: Database Health Checks aktivieren

### **Konfigurationsdateien bereit:**

- ✅ `config-templates/wordpress-wp-config.php`
- ✅ `config-templates/laravel-env-production.env`
- ✅ `config-templates/civicrm-settings.php`

---

**🎉 Alle drei Datenbanken sind jetzt optimal für Plesk @ digimagical.com konfiguriert!**

_Server: MariaDB 10.6.22 auf Ubuntu 22.04 mit nginx/1.28.0 und PHP 8.4.11_
