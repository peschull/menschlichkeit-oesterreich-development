# 🎯 Korrekte Plesk Dokumentenstämme

## 📁 **Plesk Domain-Struktur (Korrekt)**

```
menschlichkeit-oesterreich.at/
├── httpdocs/                                    # Haupt-Website Dokumentenstamm
├── crm.menschlichkeit-oesterreich.at/          # CRM Subdomain Dokumentenstamm  
└── api.menschlichkeit-oesterreich.at/
    └── public/                                  # API Subdomain Dokumentenstamm
```

## 🔄 **Development → Production Mapping**

```
Lokale Entwicklung                              →  Plesk Production
────────────────────────────────────────────────────────────────────────
D:\Arbeitsverzeichniss\website/                →  menschlichkeit-oesterreich.at/httpdocs/
D:\Arbeitsverzeichniss\crm.../httpdocs/        →  menschlichkeit-oesterreich.at/crm.../
D:\Arbeitsverzeichniss\api.../public/          →  menschlichkeit-oesterreich.at/api.../public/
```

## 🏗️ **Angepasste Entwicklungsstruktur**

### **CRM-Entwicklung**
```
crm.menschlichkeit-oesterreich.at/
├── composer.json                    # Drupal + CiviCRM Dependencies
├── web/                            # Drupal Webroot → Plesk Dokumentenstamm
│   ├── index.php
│   ├── core/
│   └── sites/
├── vendor/                         # Composer Packages
└── docker/                        # Lokale Entwicklung
```

### **API-Entwicklung**  
```
api.menschlichkeit-oesterreich.at/
├── public/                         # FastAPI Public → Plesk Dokumentenstamm
│   └── index.php                  # Node.js/PHP Bridge
├── app/                           # FastAPI Source
│   ├── main.py
│   └── requirements.txt
└── docker/                        # Lokale Entwicklung
```

### **Frontend (Bestehend)**
```
website/                            # → menschlichkeit-oesterreich.at/httpdocs/
├── index.html
├── kontakt.html  
├── login.html
└── assets/
```

**Status:** Plesk-Dokumentenstämme korrekt definiert ✅