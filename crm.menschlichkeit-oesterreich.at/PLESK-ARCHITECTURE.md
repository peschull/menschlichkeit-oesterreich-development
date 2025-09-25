# 🏗️ Plesk-kompatible CRM Entwicklung

## 📋 **Plesk Server Architektur**

### **Production Domains (Plesk)**
- `menschlichkeit-oesterreich.at/httpdocs` → Dokumentenstamm
- `menschlichkeit-oesterreich.at/crm.menschlichkeit-oesterreich.at` → Dokumentenstamm
- `menschlichkeit-oesterreich.at/api.menschlichkeit-oesterreich.at/public` → Dokumentenstamm

### **Lokale Entwicklung → Plesk Deployment**

```bash
# 1. Lokale Entwicklung (Docker)
docker-compose up -d

# 2. Plesk Deployment
./deploy-to-plesk.sh

# 3. Plesk Subdomain Setup
# - CRM: Drupal 10 + CiviCRM
# - API: FastAPI (Node.js wrapper oder Docker)
# - SSL: Let's Encrypt über Plesk
```

## 🔧 **Plesk-spezifische Anpassungen**

### **CRM (Drupal + CiviCRM)**
- **Plesk PHP 8.2** Kompatibilität
- **Composer** Abhängigkeiten für Plesk
- **Database** über Plesk MySQL/MariaDB
- **SSL** über Plesk Interface
- **Cron Jobs** über Plesk Scheduler

### **API (FastAPI)**
- **Node.js** wrapper für Plesk-Kompatibilität
- **PM2** Process Manager
- **Nginx** Reverse Proxy (Plesk)
- **Environment Variables** über Plesk

### **Frontend Integration**
- **httpdocs** kompatible Struktur
- **CORS** zwischen Subdomains
- **JWT** Token handling
- **DSGVO** Compliance maintained

## 📁 **Deployment-Ready Structure**

```
crm.menschlichkeit-oesterreich.at/
├── httpdocs/                   # → Plesk httpdocs
│   ├── web/                   # Drupal webroot
│   ├── vendor/                # Composer dependencies  
│   └── composer.json          # Plesk-compatible
├── docker/                    # Lokale Entwicklung
├── deploy/                    # Plesk Deployment Scripts
└── README-PLESK.md           # Plesk Setup Guide
```

**Status:** Plesk-Architektur berücksichtigt ✅