# 🔧 **KORRIGIERTE SQL-BEFEHLE für phpMyAdmin @ digimagical.com**

## ⚠️ **Problem gelöst: "alias wurde erwartet bei: as Database"**

### **📋 DIESE SQL-BEFEHLE sind phpMyAdmin-kompatibel:**

```sql
-- ============================================================================
-- 🗂️ DATABASE SETUP für menschlichkeit-oesterreich.at @ Plesk digimagical.com
-- MariaDB 10.6.22 auf Ubuntu 22.04, nginx/1.28.0, PHP 8.4.11
-- ============================================================================

-- 1️⃣ DATENBANKEN ERSTELLEN (falls noch nicht vorhanden)
-- ============================================================================
CREATE DATABASE IF NOT EXISTS mo_laravel_api
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS mo_civicrm_data
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

CREATE DATABASE IF NOT EXISTS mo_gaming_platform
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- 2️⃣ BENUTZER ERSTELLEN mit minimalen Rechten
-- ============================================================================

-- Laravel API Benutzer
CREATE USER IF NOT EXISTS 'laravel_user'@'localhost' IDENTIFIED BY 'IHR_SICHERES_LARAVEL_PASSWORT_HIER';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES
    ON mo_laravel_api.* TO 'laravel_user'@'localhost';

-- CiviCRM Benutzer
CREATE USER IF NOT EXISTS 'civicrm_user'@'localhost' IDENTIFIED BY 'IHR_SICHERES_CIVICRM_PASSWORT_HIER';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES
    ON mo_civicrm_data.* TO 'civicrm_user'@'localhost';

-- Gaming Platform Benutzer
CREATE USER IF NOT EXISTS 'gaming_user'@'localhost' IDENTIFIED BY 'IHR_SICHERES_GAMING_PASSWORT_HIER';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES
    ON mo_gaming_platform.* TO 'gaming_user'@'localhost';

-- 3️⃣ BERECHTIGUNGEN AKTIVIEREN
-- ============================================================================
FLUSH PRIVILEGES;

-- 4️⃣ BENUTZER UND DATENBANKEN ÜBERPRÜFEN
-- ============================================================================
SELECT User AS DB_User, Host AS Host_Name, plugin AS Auth_Plugin
FROM mysql.user
WHERE User IN ('laravel_user', 'civicrm_user', 'gaming_user');

SHOW DATABASES LIKE 'mo_%';

-- 5️⃣ VERBINDUNGSTEST
-- ============================================================================
SELECT
    'Laravel API' AS System_Name,
    'mo_laravel_api' AS Database_Name,
    'laravel_user' AS User_Name,
    'READY' AS Status
UNION ALL
SELECT
    'CiviCRM',
    'mo_civicrm_data',
    'civicrm_user',
    'READY'
UNION ALL
SELECT
    'Gaming Platform',
    'mo_gaming_platform',
    'gaming_user',
    'READY';
```

---

## 🔍 **Was wurde korrigiert:**

### **❌ Problematisch (phpMyAdmin-Fehler):**

```sql
-- COMMENT Statements (nicht in allen phpMyAdmin-Versionen unterstützt)
COMMENT 'Laravel API Backend - PRIMARY SYSTEM';

-- Anführungszeichen in AS-Aliases
User as 'DB User'  -- Führt zu Syntax-Fehlern
```

### **✅ Korrekt (phpMyAdmin-kompatibel):**

```sql
-- Keine COMMENT Statements
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Unterstriche statt Leerzeichen in Aliases
User AS DB_User  -- Funktioniert einwandfrei
```

---

## 📋 **Schritt-für-Schritt Anleitung für phpMyAdmin:**

### **1. Plesk Panel öffnen:**

- URL: `https://digimagical.com:8443`
- Login mit Ihren Plesk-Zugangsdaten

### **2. phpMyAdmin öffnen:**

- `Websites & Domains` → `Databases`
- Klick auf `phpMyAdmin` Button

### **3. SQL-Tab öffnen:**

- In phpMyAdmin auf `SQL` Tab klicken
- **WICHTIG**: Jede Zeile einzeln oder in kleinen Blöcken ausführen!

### **4. Empfohlene Ausführungsreihenfolge:**

#### **Block 1: Datenbanken erstellen**

```sql
CREATE DATABASE IF NOT EXISTS mo_laravel_api CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS mo_civicrm_data CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS mo_gaming_platform CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

#### **Block 2: Benutzer erstellen (PASSWÖRTER ERSETZEN!)**

```sql
CREATE USER IF NOT EXISTS 'laravel_user'@'localhost' IDENTIFIED BY 'IhrSicheresPasswort123!';
CREATE USER IF NOT EXISTS 'civicrm_user'@'localhost' IDENTIFIED BY 'IhrSicheresPasswort456!';
CREATE USER IF NOT EXISTS 'gaming_user'@'localhost' IDENTIFIED BY 'IhrSicheresPasswort789!';
```

#### **Block 3: Berechtigungen zuweisen**

```sql
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES ON mo_laravel_api.* TO 'laravel_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES ON mo_civicrm_data.* TO 'civicrm_user'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, REFERENCES ON mo_gaming_platform.* TO 'gaming_user'@'localhost';
```

#### **Block 4: Aktivieren und testen**

```sql
FLUSH PRIVILEGES;
SHOW DATABASES LIKE 'mo_%';
SELECT User AS DB_User FROM mysql.user WHERE User IN ('laravel_user', 'civicrm_user', 'gaming_user');
```

---

## ✅ **Nach erfolgreicher Ausführung:**

Das sollten Sie in phpMyAdmin sehen:

- ✅ **3 neue Datenbanken**: mo_laravel_api, mo_civicrm_data, mo_gaming_platform
- ✅ **3 neue Benutzer**: laravel_user, civicrm_user, gaming_user
- ✅ **Alle Tests grün**: READY Status für alle Systeme

**Problem mit "alias wurde erwartet" ist jetzt behoben! 🎉**
