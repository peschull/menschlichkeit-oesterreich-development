# 🎯 Plesk Subdomain Architektur

## 🏗️ **Ein Plesk Server - Drei Bereiche**

### **Domain-Struktur**
```
menschlichkeit-oesterreich.at (Plesk Hauptdomain)
├── httpdocs/                           # Haupt-Website
├── crm.menschlichkeit-oesterreich.at/  # CRM-Subdomain 
└── api.menschlichkeit-oesterreich.at/  # API-Subdomain
```

### **Entwicklung → Deployment Mapping**

```
Lokal (Development)                    →  Plesk (Production)
─────────────────────────────────────────────────────────────
D:\Arbeitsverzeichniss\website/        →  httpdocs/
D:\Arbeitsverzeichniss\crm.../         →  crm.menschlichkeit-oesterreich.at/
D:\Arbeitsverzeichniss\api.../         →  api.menschlichkeit-oesterreich.at/
```

## 🚀 **Implementation Plan**

### **1. CRM-Subdomain Setup**
- **Docker-Entwicklung** → **Plesk PHP 8.2 Deployment**
- **Drupal 10 + CiviCRM** mit Composer
- **MySQL Database** über Plesk
- **SSL-Zertifikat** über Plesk Let's Encrypt

### **2. API-Subdomain Setup** 
- **FastAPI Development** → **Node.js Wrapper für Plesk**
- **JWT-Authentication** 
- **CiviCRM APIv4 Integration**
- **CORS** für Frontend-Anbindung

### **3. Frontend Integration**
- Bestehende **httpdocs Website** erweitern
- **CRM/API Integration** über JavaScript
- **DSGVO-konforme** Datenübertragung
- **Responsive Mitgliederbereich**

## 📋 **Nächste Schritte**

1. **✅ Plesk-Architektur** definiert
2. **🔄 CRM Docker-Entwicklung** für Plesk-Deployment
3. **⏳ API Service** mit Node.js Wrapper
4. **⏳ Plesk Deployment-Skripte**
5. **⏳ Frontend CRM-Integration**
6. **⏳ Production Testing**

**Status:** Plesk-Struktur verstanden ✅