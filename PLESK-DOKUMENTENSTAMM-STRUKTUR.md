# 📁 DOKUMENTENSTAMM der 3 DOMAINS/SUBDOMAINS - Plesk Verzeichnisstruktur

## 🗂️ **PLESK VERZEICHNIS-MAPPING für menschlichkeit-oesterreich.at**

### **🏠 Hauptdomain:**

```
📍 Domain: menschlichkeit-oesterreich.at
📂 Plesk-Pfad: /httpdocs/
🎯 Inhalt: Next.js Frontend (aus /frontend/)
📋 Dateien: index.html, _next/, static/, package.json
```

### **🔗 API-Subdomain:**

```
📍 Domain: api.menschlichkeit-oesterreich.at
📂 Plesk-Pfad: /subdomains/api/httpdocs/
🎯 Inhalt: FastAPI Backend (aus /api.menschlichkeit-oesterreich.at/)
📋 Dateien: main.py, app/, requirements.txt, .env
```

### **👥 CRM-Subdomain:**

```
📍 Domain: crm.menschlichkeit-oesterreich.at
📂 Plesk-Pfad: /subdomains/crm/httpdocs/
🎯 Inhalt: CiviCRM + Drupal (aus /crm.menschlichkeit-oesterreich.at/)
📋 Dateien: index.php, sites/, modules/, .env, composer.json
```

### **🎮 Games-Subdomain:**

```
📍 Domain: games.menschlichkeit-oesterreich.at
📂 Plesk-Pfad: /subdomains/games/httpdocs/
🎯 Inhalt: Web Games (aus /web/)
📋 Dateien: index.html, games/, assets/, prisma/
```

---

## 🔍 **VOLLSTÄNDIGE PLESK-VERZEICHNISSTRUKTUR:**

```
/var/www/vhosts/menschlichkeit-oesterreich.at/
├── httpdocs/                                    ← Hauptdomain
│   ├── index.html                              (Next.js Build)
│   ├── _next/                                  (Next.js Assets)
│   ├── static/                                 (Statische Dateien)
│   └── package.json                            (Node Dependencies)
│
├── subdomains/
│   ├── api/
│   │   └── httpdocs/                           ← API-Subdomain
│   │       ├── main.py                         (FastAPI Entry Point)
│   │       ├── app/                            (Python Modules)
│   │       ├── requirements.txt                (Python Dependencies)
│   │       └── .env                            (API Database Config)
│   │
│   ├── crm/
│   │   └── httpdocs/                           ← CRM-Subdomain
│   │       ├── index.php                       (Drupal Entry)
│   │       ├── sites/                          (Drupal Sites)
│   │       │   └── default/
│   │       │       ├── settings.php            (Drupal Config)
│   │       │       └── civicrm.settings.php    (CiviCRM Config)
│   │       ├── modules/                        (Drupal Modules)
│   │       └── vendor/                         (Composer Dependencies)
│   │
│   └── games/
│       └── httpdocs/                           ← Games-Subdomain
│           ├── index.html                      (Games Landing Page)
│           ├── games/                          (Spiel-Dateien)
│           ├── assets/                         (CSS, JS, Bilder)
│           ├── prisma/                         (Database Schema)
│           └── .env                            (Gaming Database Config)
│
├── logs/                                       ← Server Logs
├── statistics/                                 ← Traffic Stats
└── backup/                                     ← Automatische Backups

✅ BESTÄTIGT: PHP 8.3.25 FPM (Apache) auf ALLEN Domains/Subdomains
```

---

## 📋 **DATEI-ZUORDNUNG: Lokaler Workspace → Plesk Server**

### **🚀 Upload-Mapping:**

| Lokaler Ordner                        | Plesk-Ziel                    | Domain      | Beschreibung         |
| ------------------------------------- | ----------------------------- | ----------- | -------------------- |
| `/frontend/dist/`                     | `/httpdocs/`                  | Hauptdomain | Next.js Build Output |
| `/api.menschlichkeit-oesterreich.at/` | `/subdomains/api/httpdocs/`   | api.\*      | Python FastAPI       |
| `/crm.menschlichkeit-oesterreich.at/` | `/subdomains/crm/httpdocs/`   | crm.\*      | Drupal + CiviCRM     |
| `/web/`                               | `/subdomains/games/httpdocs/` | games.\*    | Web Games            |

### **🔧 Konfigurationsdateien:**

| Lokale Config                                  | Plesk-Ziel                                | Zweck           |
| ---------------------------------------------- | ----------------------------------------- | --------------- |
| `/config-templates/laravel-env-production.env` | `/subdomains/api/httpdocs/.env`           | API Database    |
| `/config-templates/civicrm-settings.php`       | `/subdomains/crm/httpdocs/sites/default/` | CRM Database    |
| Gaming `.env` (zu erstellen)                   | `/subdomains/games/httpdocs/.env`         | Gaming Database |

---

## 🎯 **PLESK PANEL - Domain Document Root Einstellungen**

### **📂 Wie Sie die Document Roots in Plesk prüfen/ändern:**

#### **1. Hauptdomain:**

```
Plesk → Websites & Domains → menschlichkeit-oesterreich.at
├── Document Root: /httpdocs
├── PHP Version: 8.4.x
└── SSL Certificate: Let's Encrypt ✅
```

#### **2. API-Subdomain:**

```
Plesk → Websites & Domains → api.menschlichkeit-oesterreich.at
├── Document Root: /subdomains/api/httpdocs
├── PHP Version: 8.4.x (für Laravel fallback)
└── Python Support: ✅ (für FastAPI)
```

#### **3. CRM-Subdomain:**

```
Plesk → Websites & Domains → crm.menschlichkeit-oesterreich.at
├── Document Root: /subdomains/crm/httpdocs
├── PHP Version: 8.4.x ✅ (für Drupal + CiviCRM)
└── Composer Support: ✅
```

#### **4. Games-Subdomain:**

```
Plesk → Websites & Domains → games.menschlichkeit-oesterreich.at
├── Document Root: /subdomains/games/httpdocs
├── PHP Version: 8.4.x (für Prisma PHP Client)
└── Node.js Support: ✅ (falls benötigt)
```

---

## 📤 **SFTP/SSH Upload-Struktur:**

### **🔗 VS Code SFTP Extension Targets:**

```json
// .vscode/sftp.json Konfiguration
{
  "host": "digimagical.com",
  "username": "ihr_plesk_user",
  "remotePath": "/httpdocs",
  "uploadOnSave": false,
  "ignore": [".git", "node_modules", ".env.local"]
}
```

### **📂 Upload-Befehle per Ordner:**

```bash
# Hauptdomain (Next.js)
Upload: /frontend/dist/* → /httpdocs/

# API-Subdomain (FastAPI)
Upload: /api.menschlichkeit-oesterreich.at/* → /subdomains/api/httpdocs/

# CRM-Subdomain (Drupal+CiviCRM)
Upload: /crm.menschlichkeit-oesterreich.at/* → /subdomains/crm/httpdocs/

# Games-Subdomain (Web Games)
Upload: /web/* → /subdomains/games/httpdocs/
```

---

## ✅ **CHECKLISTE: Dokumentenstamm Setup**

### **☐ Plesk-Verzeichnisse prüfen:**

- [ ] `/httpdocs/` existiert (Hauptdomain)
- [ ] `/subdomains/api/httpdocs/` existiert
- [ ] `/subdomains/crm/httpdocs/` existiert
- [ ] `/subdomains/games/httpdocs/` zu erstellen

### **☐ Document Root Settings:**

- [ ] Hauptdomain → `/httpdocs`
- [ ] API-Subdomain → `/subdomains/api/httpdocs`
- [ ] CRM-Subdomain → `/subdomains/crm/httpdocs`
- [ ] Games-Subdomain → `/subdomains/games/httpdocs`

### **☐ Upload-Berechtigungen:**

- [ ] SFTP-Zugang funktioniert
- [ ] Schreibrechte in allen Verzeichnissen
- [ ] PHP/Python/Node.js Support aktiviert

---

## 🚀 **NÄCHSTE SCHRITTE:**

1. **Plesk Panel öffnen** und Verzeichnisstruktur prüfen
2. **Games-Subdomain anlegen** (falls noch nicht vorhanden)
3. **Document Root Settings** für alle Domains prüfen
4. **SFTP Upload-Mapping** konfigurieren

**Soll ich Ihnen beim Setup der SFTP-Konfiguration für VS Code helfen?** 🎯
