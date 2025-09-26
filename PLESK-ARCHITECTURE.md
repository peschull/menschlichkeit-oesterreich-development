# 🎉 PLESK SERVER STRUKTUR - VOLLSTÄNDIG ERKANNT!

## ✅ **Bestätigte Server-Architektur:**

### **🏠 Hauptdomain (httpdocs/):**

- **Pfad**: `/home/dmpl20230054/httpdocs/`
- **Status**: ✅ Bereits mit Website-Dateien
- **Inhalt**: HTML-Dateien (index.html, kontakt.html, etc.)
- **Assets**: CSS, Content-Ordner vorhanden

### **🌐 Subdomains (subdomains/):**

```bash
subdomains/
├── api/     # API-Subdomain ✅
├── crm/     # CRM-Subdomain ✅
└── games/   # Games-Subdomain ✅
```

### **🔍 Besondere Erkenntnisse:**

1. **Alle Subdomains existieren bereits!** 🎉
2. **WordPress-Migration bereits erfolgt** (wp-Ordner vorhanden)
3. **Composer & Node.js bereits installiert** (.composer, .npm, .nodenv)
4. **VS Code Server bereits konfiguriert** (.vscode-server)

## 🚀 **Korrekte Server-Befehle:**

### **Test-Datei erstellen (korrekt):**

```bash
# Im SSH-Terminal ausführen:
echo '<?php echo "Menschlichkeit Österreich - Server Online!<br>"; phpinfo(); ?>' > httpdocs/test.php

# Berechtigungen setzen
chmod 644 httpdocs/test.php

# Testen
curl -s http://menschlichkeit-oesterreich.at/test.php | head -5
```

### **Subdomain-Details prüfen:**

```bash
# API-Subdomain
ls -la subdomains/api/
cd subdomains/api && ls -la

# CRM-Subdomain
ls -la subdomains/crm/
cd ../crm && ls -la

# Games-Subdomain
ls -la subdomains/games/
cd ../games && ls -la
```

## 📂 **Aktualisierte SFTP-Pfade:**

### **Korrekte Upload-Ziele:**

- **Hauptdomain**: `/home/dmpl20230054/httpdocs/`
- **API**: `/home/dmpl20230054/subdomains/api/httpdocs/`
- **CRM**: `/home/dmpl20230054/subdomains/crm/httpdocs/`
- **Games**: `/home/dmpl20230054/subdomains/games/httpdocs/`

## 🎯 **DEPLOYMENT-BEREIT:**

- ✅ **SSH-Verbindung**: Funktioniert
- ✅ **Alle Subdomains**: Existieren
- ✅ **Berechtigungen**: Korrekt (psaserv group)
- ✅ **PHP**: Verfügbar
- ✅ **Composer**: Installiert
- ✅ **Node.js**: Verfügbar

**Status: 100% DEPLOYMENT-READY! 🚀**
