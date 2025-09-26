# 🔧 PLESK-PANEL DATENBANK-SETUP (Fehler #1044 Lösung)

## ⚠️ **Problem gelöst: MySQL #1044 - Keine CREATE DATABASE Berechtigung**

### **🎯 LÖSUNG 1: Plesk Panel verwenden (EMPFOHLEN)**

Da Sie keine MySQL-Admin-Rechte haben, nutzen Sie das Plesk Panel:

#### **📋 Schritt-für-Schritt:**

1. **Plesk Panel öffnen:**
   - URL: `https://digimagical.com:8443`
   - Login mit Ihren Plesk-Zugangsdaten

2. **Zu Databases navigieren:**
   - `Websites & Domains`
   - `Databases`
   - Klick auf `Add Database`

3. **Datenbank 1 erstellen:**

   ```
   Database name: mo_laravel_api
   Database user: laravel_user
   Password: [IHR_SICHERES_PASSWORT]
   ✅ Related site: menschlichkeit-oesterreich.at
   ```

4. **Datenbank 2 erstellen:**

   ```
   Database name: mo_civicrm_data
   Database user: civicrm_user
   Password: [IHR_SICHERES_PASSWORT]
   ✅ Related site: menschlichkeit-oesterreich.at
   ```

5. **Datenbank 3 erstellen:**

   ```
   Database name: mo_gaming_platform
   Database user: gaming_user
   Password: [IHR_SICHERES_PASSWORT]
   ✅ Related site: menschlichkeit-oesterreich.at
   ```

6. **Charset einstellen:**
   - Nach Erstellung jeder DB: `phpMyAdmin` öffnen
   - Datenbank auswählen → `Operations` Tab
   - `Collation`: `utf8mb4_unicode_ci` auswählen
   - `Go` klicken

---

### **🎯 LÖSUNG 2: MySQL Root-Zugang (falls verfügbar)**

Falls Sie root/admin Zugang haben:

#### **In phpMyAdmin als Administrator anmelden:**

1. **Logout aus aktuellem phpMyAdmin**
2. **Re-Login mit root/admin Credentials**
3. **Diese vereinfachte SQL-Syntax verwenden:**

```sql
-- EINFACHE SYNTAX ohne CHARACTER SET (erst mal)
CREATE DATABASE mo_laravel_api;
CREATE DATABASE mo_civicrm_data;
CREATE DATABASE mo_gaming_platform;

-- BENUTZER ERSTELLEN
CREATE USER 'laravel_user'@'localhost' IDENTIFIED BY 'IhrPasswort123';
CREATE USER 'civicrm_user'@'localhost' IDENTIFIED BY 'IhrPasswort456';
CREATE USER 'gaming_user'@'localhost' IDENTIFIED BY 'IhrPasswort789';

-- BERECHTIGUNGEN
GRANT ALL PRIVILEGES ON mo_laravel_api.* TO 'laravel_user'@'localhost';
GRANT ALL PRIVILEGES ON mo_civicrm_data.* TO 'civicrm_user'@'localhost';
GRANT ALL PRIVILEGES ON mo_gaming_platform.* TO 'gaming_user'@'localhost';

FLUSH PRIVILEGES;
```

4. **Character Set nachträglich einstellen:**
   - Jede DB einzeln auswählen
   - `Operations` Tab → `Collation` → `utf8mb4_unicode_ci`

---

### **🔍 Warum der Fehler auftrat:**

```
ERROR: #1044 - Benutzer 'utf8mb4'@'%' hat keine Zugriffsberechtigung
```

**Ursachen:**

1. ❌ **Keine CREATE DATABASE Rechte** - Ihr phpMyAdmin-User ist kein Administrator
2. ❌ **SQL-Parsing Problem** - MySQL interpretiert `CHARACTER SET utf8mb4` falsch
3. ❌ **Plesk Sicherheit** - Normale Benutzer dürfen keine DBs erstellen

**Lösung:**
✅ **Plesk Panel nutzen** - Hat automatisch die richtigen Berechtigungen
✅ **Vereinfachte SQL-Syntax** - Weniger Parsing-Probleme
✅ **Character Set nachträglich** - Sicherer Weg

---

## 🎯 **EMPFEHLUNG:**

**Nutzen Sie LÖSUNG 1 (Plesk Panel)** - das ist der sicherste und einfachste Weg!

Nach der Datenbank-Erstellung können Sie dann die `.env` Datei mit den neuen Zugangsdaten aktualisieren.

**Soll ich Ihnen dabei helfen? 🚀**
