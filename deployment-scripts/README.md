# 🚀 Plesk Deployment Scripts

Vollständige Deployment-Automatisierung für **Menschlichkeit Österreich CRM + API** auf Plesk-Server.

## 📋 **Deployment-Reihenfolge**

### **1. CRM Deployment**
```bash
chmod +x deploy-crm-plesk.sh
./deploy-crm-plesk.sh
```
- Installiert **Drupal 10 + CiviCRM**
- Konfiguriert **Database-Verbindung**
- Setzt **Sicherheits-Permissions**
- Erstellt **Admin-Account**

### **2. API Deployment**
```bash
chmod +x deploy-api-plesk.sh
./deploy-api-plesk.sh
```
- Installiert **FastAPI + Python Dependencies**
- Konfiguriert **PHP-Bridge** für Plesk
- Setzt **JWT-Authentifizierung** auf
- Erstellt **Systemd Service**

### **3. Cron Jobs Setup**
```bash
chmod +x setup-cron-jobs.sh
./setup-cron-jobs.sh
```
- Konfiguriert **CiviCRM Scheduled Jobs**
- Setzt **SEPA-Processing** auf
- Erstellt **Log-Rotation**
- Monitoring-Scripts

## 🏗️ **Plesk-Struktur**

```
menschlichkeit-oesterreich.at/
├── httpdocs/                                    # Haupt-Website
├── crm.menschlichkeit-oesterreich.at/
│   ├── httpdocs/                               # CRM Dokumentenstamm
│   │   ├── web/                               # Drupal Webroot
│   │   ├── vendor/                            # Composer Dependencies
│   │   └── composer.json                      # Drupal + CiviCRM
│   └── private/                               # Sichere Dateien
│       ├── logs/                              # Cron & Error Logs
│       ├── cron/                              # Cron Scripts
│       └── deployment-info.txt                # Deployment Info
└── api.menschlichkeit-oesterreich.at/
    ├── public/                                # API Dokumentenstamm
    │   ├── index.php                          # PHP Bridge
    │   └── health.php                         # Health Check
    └── private/                               # FastAPI App
        ├── app/                               # Python Source
        ├── venv/                              # Python Virtual Env
        ├── .env                               # Environment Config
        └── start-api.sh                       # Start Script
```

## ⚙️ **Voraussetzungen**

### **Server Requirements**
- **Plesk** Control Panel
- **PHP 8.2** oder höher
- **Python 3.8+** mit pip
- **Composer** für PHP
- **MySQL/MariaDB** Zugriff
- **SSH-Zugang** für Deployment

### **Plesk Configuration**
1. **Subdomains erstellen** in Plesk:
   - `crm.menschlichkeit-oesterreich.at`
   - `api.menschlichkeit-oesterreich.at`

2. **SSL-Zertifikate** über Plesk Let's Encrypt

3. **Database** erstellen oder bestehende verwenden

## 🔧 **Manual Steps**

### **Nach CRM Deployment**
1. **SSL-Zertifikat** in Plesk aktivieren
2. **CiviCRM API Key** im Admin-Interface setzen
3. **SEPA Extension** installieren (falls benötigt)
4. **Membership Types** konfigurieren

### **Nach API Deployment**
1. **SSL-Zertifikat** in Plesk aktivieren
2. **FastAPI Service** starten/testen
3. **JWT Token** für Frontend generieren
4. **CORS Settings** verifizieren

### **Nach Cron Setup**
1. **Crontab installieren**: `crontab /tmp/civicrm-crontab-*.txt`
2. **Log Monitoring** einrichten
3. **Email Notifications** testen
4. **Backup Strategy** implementieren

## 🧪 **Testing**

### **CRM Testing**
```bash
# Test Drupal Installation
curl -I https://crm.menschlichkeit-oesterreich.at

# Test CiviCRM
curl -I https://crm.menschlichkeit-oesterreich.at/civicrm

# Test Admin Login
# https://crm.menschlichkeit-oesterreich.at/user/login
```

### **API Testing**
```bash
# Health Check
curl https://api.menschlichkeit-oesterreich.at/health

# Test Authentication
curl -X POST https://api.menschlichkeit-oesterreich.at/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"test123"}'

# Test Protected Endpoint
curl -X POST https://api.menschlichkeit-oesterreich.at/contacts/create \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","first_name":"Test","last_name":"User"}'
```

### **Cron Testing**
```bash
# Test CiviCRM Jobs manually
/path/to/crm/private/cron/civicrm-scheduled-jobs.sh

# Check logs
tail -f /path/to/crm/private/logs/civicrm-cron.log

# Health check
/path/to/crm/private/cron/check-cron-health.sh
```

## 🔐 **Security Notes**

- **Environment files** (.env) sind in private/ geschützt
- **Database credentials** werden sicher prompt
- **JWT secrets** automatisch generiert
- **Admin passwords** automatisch generiert
- **File permissions** restriktiv gesetzt
- **HTTPS** wird über Plesk Let's Encrypt erzwungen

## 📊 **Monitoring**

- **Health Check Endpoints** verfügbar
- **Log files** automatisch rotiert
- **Email notifications** für Cron-Fehler
- **Process monitoring** über systemd (API)

## 🎯 **Nach Deployment**

1. **Frontend Integration** mit bestehender Website
2. **SEPA Creditor** Konfiguration
3. **Membership Types** Setup  
4. **Payment Processors** Konfiguration
5. **Email Templates** anpassen
6. **User Training** durchführen

---

**Status:** 🚀 **Produktionsreife Plesk-Deployment-Lösung**