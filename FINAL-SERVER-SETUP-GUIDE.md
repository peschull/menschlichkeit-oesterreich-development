# 🚀 **FINAL SERVER SETUP GUIDE**
## Complete Go-Live für Menschlichkeit Österreich CRM

### 🎯 **AKTUELLE SITUATION:**
- ✅ **Website LIVE:** https://www.menschlichkeit-oesterreich.at (200 OK)
- ✅ **Files deployed:** CRM + API Dateien auf Server
- ✅ **SSL aktiv:** Alle 3 Domains verschlüsselt
- 🔄 **Next:** Server-Setup für komplettes Go-Live

---

## 📋 **SSH SERVER SETUP COMMANDS:**

### **1. SSH Verbindung herstellen:**
```bash
ssh dmpl20230054@5.183.217.146
```

### **2. CRM-System (Drupal 10 + CiviCRM) aktivieren:**
```bash
# Wechsel in CRM-Verzeichnis
cd /var/www/vhosts/menschlichkeit-oesterreich.at/crm.menschlichkeit-oesterreich.at/httpdocs/

# Composer Dependencies installieren
composer install --no-dev --optimize-autoloader

# Drupal Installation vorbereiten
chmod -R 755 web/
chown -R www-data:www-data web/sites/default/files/
chmod 666 web/sites/default/settings.php

# Drupal Site Installation
php web/core/scripts/drupal site-install --db-url="mysql://mo_crm_user:PASSWORD@localhost/mo_civicrm_data" --account-name=admin --account-pass=ADMIN_PASSWORD --site-name="Menschlichkeit Österreich CRM"

# CiviCRM Extension aktivieren
drush en civicrm -y
drush civicrm-install --dbhost=localhost --dbname=mo_civicrm_data --dbuser=mo_crm_user --dbpass=PASSWORD
```

### **3. API-Service (FastAPI + JWT) starten:**
```bash
# Wechsel in API-Verzeichnis  
cd /var/www/vhosts/menschlichkeit-oesterreich.at/api.menschlichkeit-oesterreich.at/httpdocs/

# Python Dependencies installieren
python3 -m pip install --user -r requirements.txt

# Environment-Variablen setzen
cp .env.example .env
nano .env  # DATABASE_URL, JWT_SECRET, etc. konfigurieren

# API Service als Background-Prozess starten
nohup python3 main.py > api.log 2>&1 &
```

### **4. Systemd Service für API (empfohlen):**
```bash
# Service-Datei erstellen
sudo nano /etc/systemd/system/crm-api.service

# Inhalt der Service-Datei:
[Unit]
Description=CRM FastAPI Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/vhosts/menschlichkeit-oesterreich.at/api.menschlichkeit-oesterreich.at/httpdocs/
Environment=PATH=/usr/bin:/usr/local/bin
ExecStart=/usr/bin/python3 main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# Service aktivieren
sudo systemctl daemon-reload
sudo systemctl enable crm-api
sudo systemctl start crm-api
sudo systemctl status crm-api
```

### **5. Nginx/Apache Konfiguration prüfen:**
```bash
# Nginx Config für API-Subdomain
sudo nano /etc/nginx/sites-available/api.menschlichkeit-oesterreich.at

# Proxy-Pass für FastAPI hinzufügen:
location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}

# Config testen und neu laden
sudo nginx -t
sudo systemctl reload nginx
```

---

## 🧪 **TESTING NACH SERVER-SETUP:**

### **1. CRM-Backend testen:**
```bash
# Browser öffnen:
curl -I https://crm.menschlichkeit-oesterreich.at
# Erwartung: 200 OK (statt 403)

# Drupal Admin-Login testen:
# https://crm.menschlichkeit-oesterreich.at/user/login
```

### **2. API-Service testen:**
```bash
# Health Check
curl -I https://api.menschlichkeit-oesterreich.at/health
# Erwartung: 200 OK (statt 500)

# API Documentation
curl https://api.menschlichkeit-oesterreich.at/docs
```

### **3. Website-Integration testen:**
```bash
# Login-Funktionalität
# Browser: https://www.menschlichkeit-oesterreich.at/login.html
# → Registrierung/Login testen

# Member-Area  
# Browser: https://www.menschlichkeit-oesterreich.at/member-area.html
# → Dashboard, Profile, SEPA testen
```

---

## 📊 **GO-LIVE VALIDATION CHECKLIST:**

### **System Status:**
- [ ] **CRM-Backend:** https://crm.menschlichkeit-oesterreich.at → 200 OK
- [ ] **API-Service:** https://api.menschlichkeit-oesterreich.at/health → 200 OK  
- [ ] **Website Integration:** Login/Member-Area funktional
- [ ] **SEPA-System:** IBAN-Validation & Mandate-Creation
- [ ] **Database:** CiviCRM Contacts/Memberships CRUD

### **Security Checks:**
- [ ] **SSL-Zertifikate:** Alle 3 Domains HTTPS-Only
- [ ] **JWT-Authentication:** Token-Generation/Validation
- [ ] **Input-Validation:** XSS/SQL-Injection Protection
- [ ] **DSGVO-Compliance:** Consent-Management aktiv

### **Performance Tests:**
- [ ] **Response Times:** < 2 Sekunden für alle Pages
- [ ] **API-Endpoints:** < 500ms für CRUD Operations
- [ ] **Database Queries:** Optimierte CiviCRM APIv4 Calls
- [ ] **Frontend Assets:** CSS/JS Loading optimiert

---

## 🎉 **NACH SUCCESSFUL GO-LIVE:**

### **Monitoring Setup:**
```bash
# Log-Monitoring
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
tail -f /var/www/vhosts/.../api.../httpdocs/api.log

# System-Monitoring  
sudo systemctl status crm-api
sudo systemctl status nginx
sudo systemctl status mysql
```

### **Backup-Automatisierung:**
```bash
# Cron Job für tägliche Backups
crontab -e

# Hinzufügen:
0 2 * * * mysqldump -u mo_crm_user -p mo_civicrm_data > /backups/crm_$(date +\%Y\%m\%d).sql
0 3 * * * tar -czf /backups/website_$(date +\%Y\%m\%d).tar.gz /var/www/vhosts/menschlichkeit-oesterreich.at/
```

---

## 🎯 **EXPECTED RESULTS NACH SETUP:**

### **Status Changes:**
- **CRM:** `403 Forbidden` → ✅ `200 OK` mit Drupal Admin
- **API:** `500 Error` → ✅ `200 OK` mit FastAPI Docs  
- **Website:** ✅ `200 OK` mit funktionaler CRM-Integration

### **Live Features:**
- ✅ **Complete Member Management:** Registration, Login, Profile
- ✅ **CiviCRM Integration:** Contact/Membership CRUD via API
- ✅ **SEPA Payment Processing:** Austrian Banking Integration
- ✅ **Responsive Dashboard:** Member-Area mit Statistics
- ✅ **JWT Security:** Token-based Authentication

---

## 📞 **SUPPORT NACH GO-LIVE:**

### **Bei Problemen:**
1. **Service-Status prüfen:** `systemctl status crm-api`
2. **Logs analysieren:** `tail -f /var/log/nginx/error.log`
3. **Database-Connection:** `mysql -u mo_crm_user -p mo_civicrm_data`
4. **Permission-Issues:** `chown -R www-data:www-data /var/www/vhosts/`

### **Performance-Optimierung:**
1. **PHP-Caching:** OPcache aktivieren
2. **Database-Tuning:** MySQL Query-Cache  
3. **CDN-Setup:** Static-Assets über CDN
4. **Monitoring:** Uptime/Performance Alerts

---

## 🏆 **FINAL RESULT:**

**Nach erfolgreichem Server-Setup haben Sie:**
- 🌐 **Komplettes CRM-System LIVE**
- 👥 **Member-Management** mit CiviCRM Backend  
- 💳 **SEPA-Payment Processing** für Österreich
- 🔐 **Enterprise-Security** mit JWT + SSL
- 📱 **Responsive Web-App** für alle Geräte
- ⚡ **Modern API Architecture** mit FastAPI
- 🛡️ **DSGVO-Compliance** für EU-Datenschutz

**🎉 COMPLETE SUCCESS: ENTERPRISE CRM-SYSTEM LIVE!** 🚀