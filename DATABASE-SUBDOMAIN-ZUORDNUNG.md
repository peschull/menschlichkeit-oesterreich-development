# 🔗 DATENBANK-ZUORDNUNG zu SUBDOMÄNEN - Schritt-für-Schritt

## 🎯 **WIE man Datenbanken Subdomänen zuordnet**

Die Zuordnung erfolgt auf **2 Ebenen**:

1. **Plesk-Organisation** (beim Erstellen)
2. **Anwendungskonfiguration** (.env-Dateien)

---

## 📋 **SCHRITT 1: Datenbank-Erstellung in Plesk mit Subdomain-Zuordnung**

### **🔧 Für jede Datenbank separat:**

#### **1️⃣ Laravel API Database:**

```
Plesk → Websites & Domains → Databases → "Add Database"

✅ Database name: mo_laravel_api
✅ Related site: api.menschlichkeit-oesterreich.at  ← WICHTIG!
✅ Database user: laravel_user
✅ Password: [Notieren Sie das Passwort!]
❌ "Access to all databases": DEAKTIVIERT
```

#### **2️⃣ CiviCRM Database:**

```
Plesk → Databases → "Add Database"

✅ Database name: mo_civicrm_data
✅ Related site: crm.menschlichkeit-oesterreich.at  ← WICHTIG!
✅ Database user: civicrm_user
✅ Password: [Anderes Passwort notieren!]
❌ "Access to all databases": DEAKTIVIERT
```

#### **3️⃣ Gaming Platform Database:**

```
Plesk → Databases → "Add Database"

✅ Database name: mo_gaming_platform
✅ Related site: games.menschlichkeit-oesterreich.at  ← WICHTIG!
✅ Database user: gaming_user
✅ Password: [Drittes Passwort notieren!]
❌ "Access to all databases": DEAKTIVIERT
```

---

## 📂 **SCHRITT 2: Konfigurationsdateien pro Subdomain**

### **🗂️ Plesk Verzeichnisstruktur:**

```
/var/www/vhosts/menschlichkeit-oesterreich.at/
├── httpdocs/                           → Hauptdomain
├── api.menschlichkeit-oesterreich.at/
│   └── httpdocs/                       → API-Subdomain
├── crm.menschlichkeit-oesterreich.at/
│   └── httpdocs/                       → CRM-Subdomain
└── games.menschlichkeit-oesterreich.at/
    └── httpdocs/                       → Games-Subdomain
```

### **🔧 Konfiguration pro Subdomain:**

#### **API-Subdomain (.env):**

```bash
# Datei: api.menschlichkeit-oesterreich.at/httpdocs/.env

DB_CONNECTION=mysql
DB_HOST=localhost
DB_PORT=3306
DB_DATABASE=mo_laravel_api
DB_USERNAME=laravel_user
DB_PASSWORD=[IHR_API_PASSWORT_HIER]

# FastAPI URL Format
DATABASE_URL="mysql://laravel_user:[IHR_API_PASSWORT_HIER]@localhost:3306/mo_laravel_api"
```

#### **CRM-Subdomain (Drupal + CiviCRM):**

```php
// Datei: crm.menschlichkeit-oesterreich.at/httpdocs/sites/default/settings.php

$databases['default']['default'] = array(
  'database' => 'mo_civicrm_data',
  'username' => 'civicrm_user',
  'password' => '[IHR_CRM_PASSWORT_HIER]',
  'host' => 'localhost',
  'port' => '3306',
  'driver' => 'mysql',
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_unicode_ci',
);

// CiviCRM Settings
define('CIVICRM_DSN', 'mysql://civicrm_user:[IHR_CRM_PASSWORT_HIER]@localhost:3306/mo_civicrm_data');
```

#### **Games-Subdomain (Prisma .env):**

```bash
# Datei: games.menschlichkeit-oesterreich.at/httpdocs/.env

# Prisma Database URL
DATABASE_URL="mysql://gaming_user:[IHR_GAMING_PASSWORT_HIER]@localhost:3306/mo_gaming_platform"

# Additional Game Config
GAME_DB_HOST=localhost
GAME_DB_NAME=mo_gaming_platform
GAME_DB_USER=gaming_user
GAME_DB_PASS=[IHR_GAMING_PASSWORT_HIER]
```

---

## 🎯 **WICHTIGER PUNKT: "Related Site" in Plesk**

### **📍 Was "Related Site" bedeutet:**

**✅ RICHTIG:**

```
Database: mo_laravel_api
Related site: api.menschlichkeit-oesterreich.at
→ Organisatorische Zuordnung in Plesk
→ Backup-Zuordnung
→ Berechtigungsmanagement
```

**❌ FALSCH:**

```
Database: mo_laravel_api
Related site: menschlichkeit-oesterreich.at (Hauptdomain)
→ Verwirrende Organisation
→ Falsche Backup-Zuordnung
```

### **🔍 Technische Erklärung:**

- **"Related Site"** ist nur für **Plesk-Organisation**
- Die **echte Verbindung** erfolgt über **Konfigurationsdateien**
- Jede Subdomain braucht ihre **eigene .env/.config-Datei**

---

## 📊 **ÜBERSICHT: Wer nutzt welche Datenbank**

| Subdomain   | System           | Datenbank            | User           | Config-Datei   | Related Site                          |
| ----------- | ---------------- | -------------------- | -------------- | -------------- | ------------------------------------- |
| `api.*`     | FastAPI/Laravel  | `mo_laravel_api`     | `laravel_user` | `.env`         | `api.menschlichkeit-oesterreich.at`   |
| `crm.*`     | Drupal+CiviCRM   | `mo_civicrm_data`    | `civicrm_user` | `settings.php` | `crm.menschlichkeit-oesterreich.at`   |
| `games.*`   | Prisma+Next.js   | `mo_gaming_platform` | `gaming_user`  | `.env`         | `games.menschlichkeit-oesterreich.at` |
| Hauptdomain | Next.js Frontend | (keine eigene)       | -              | API-Calls      | `menschlichkeit-oesterreich.at`       |

---

## ✅ **SCHRITT-FÜR-SCHRITT CHECKLIST:**

### **☐ 1. Plesk-Datenbanken erstellen**

- [ ] `mo_laravel_api` → Related: `api.menschlichkeit-oesterreich.at`
- [ ] `mo_civicrm_data` → Related: `crm.menschlichkeit-oesterreich.at`
- [ ] `mo_gaming_platform` → Related: `games.menschlichkeit-oesterreich.at`

### **☐ 2. Passwörter sicher notieren**

- [ ] API-Passwort: `[_____________]`
- [ ] CRM-Passwort: `[_____________]`
- [ ] Gaming-Passwort: `[_____________]`

### **☐ 3. Konfigurationsdateien erstellen**

- [ ] API `.env` mit korrekten DB-Daten
- [ ] CRM `settings.php` mit korrekten DB-Daten
- [ ] Games `.env` mit korrekten DB-Daten

### **☐ 4. Dateien per SFTP hochladen**

- [ ] Zu entsprechenden Subdomain-Verzeichnissen

### **☐ 5. Verbindungen testen**

- [ ] Jede Subdomain einzeln testen

---

## 🚀 **NÄCHSTER SCHRITT:**

**Erstellen Sie jetzt die 3 Datenbanken in Plesk mit der korrekten "Related Site" Zuordnung!**

**Dann sagen Sie mir die 3 Passwörter → Ich erstelle Ihnen die kompletten Konfigurationsdateien!** 🎯
