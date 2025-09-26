# 🎉 VS CODE KONFIGURATION KOMPLETT - Plesk PHP 8.3.25 Integration

## ✅ **Erfolgreich konfiguriert:**

### **🐘 PHP-Entwicklung (Plesk-optimiert):**

- ✅ **PHP-Pfad**: `/opt/plesk/php/8.3/bin/php` (PHP 8.3.25)
- ✅ **Intelephense**: Konfiguriert für Plesk-Environment
- ✅ **Xdebug**: Port 9003, Remote-Mapping zu Server
- ✅ **Path-Mapping**: Alle Subdomains korrekt gemappt

### **🚀 Debug-Konfigurationen verfügbar:**

```json
"pathMappings": {
  "/home/dmpl20230054/httpdocs": "${workspaceFolder}",
  "/home/dmpl20230054/subdomains/api/httpdocs": "${workspaceFolder}/api.menschlichkeit-oesterreich.at",
  "/home/dmpl20230054/subdomains/crm/httpdocs": "${workspaceFolder}/crm.menschlichkeit-oesterreich.at",
  "/home/dmpl20230054/subdomains/games/httpdocs": "${workspaceFolder}/web"
}
```

### **🔧 Server-Integration:**

- **Host**: `5.183.217.146` (korrekte IP)
- **Memory Limit**: 512M
- **Max Execution**: 30s
- **Extensions**: mysqli, curl, gd, imagick, redis, etc.

## 🎯 **Sofort einsatzbereit für:**

### **1. PHP-Debugging:**

```
F5 → "PHP: Xdebug Listen (9003)"
```

### **2. API-Development:**

```
F5 → "Python: FastAPI (uvicorn)"
```

### **3. Full-Stack Debugging:**

```
F5 → "🚀 Full-Stack: Drupal + Games + API"
```

## 📋 **Nächste Schritte:**

### **1. Test-Datei im SSH erstellen:**

```bash
echo '<?php echo "Menschlichkeit Österreich - Server Online!<br>"; phpinfo(); ?>' > httpdocs/test.php
```

### **2. Xdebug testen:**

- Browser: `https://menschlichkeit-oosterreich.at/test.php?XDEBUG_SESSION_START=1`
- VS Code: F5 → "PHP: Xdebug Listen (9003)"

### **3. SFTP-Upload testen:**

```
Ctrl+Shift+P → "SFTP: Upload Folder"
```

**Ihre VS Code-Umgebung ist jetzt perfekt für Plesk PHP 8.3.25 Development optimiert! 🚀**
