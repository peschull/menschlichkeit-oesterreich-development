# 🔒 SSH/SFTP Zugriffsbeschränkungen - Plesk Server

## Server: 5.183.217.146 / menschlichkeit-oesterreich.at

### ⚠️ WICHTIGE ERKENNTNIS: CHROOT SFTP Only

**Status:** Der Plesk-Server ist mit **chroot SFTP**-Beschränkungen konfiguriert.

---

## 🔍 Aktuelle Zugriffsbeschränkungen:

### ❌ NICHT VERFÜGBAR:

- **SSH Shell-Zugriff** - Exit Code 255
- **Remote Command Execution** - Keine interaktive Shell
- **Direct Server Management** über SSH-Befehle

### ✅ VERFÜGBAR:

- **SFTP File Transfer** - SCP/SFTP funktioniert
- **File Upload/Download** - Vollzugriff auf httpdocs/
- **Web-basierte Verwaltung** - Plesk Control Panel
- **PHP-Skript Ausführung** - Über Web-Interface

---

## 📁 SFTP Chroot Environment:

```
/httpdocs/          <- Web-Root (zugänglich)
├── index.html      <- Hauptseite
├── wp/             <- WordPress Installation
├── api/            <- Laravel API (Subdomain)
├── crm/            <- CiviCRM (Subdomain)
└── [uploaded files] <- Setup-Skripte (wurden entfernt)
```

**Chroot Jail:** Benutzer dmpl20230054 ist auf das httpdocs-Verzeichnis beschränkt

---

## 🛠️ ALTERNATIVE VERWALTUNGSMETHODEN:

### 1. Plesk Control Panel

- **URL:** https://5.183.217.146:8443 oder https://menschlichkeit-oesterreich.at:8443
- **Benutzer:** dmpl20230054
- **Funktionen:**
  - Datenbankverwaltung (phpMyAdmin)
  - Dateimanager
  - DNS-Einstellungen
  - SSL-Zertifikate
  - Cron-Jobs
  - Log-Dateien

### 2. Web-basierte PHP-Skripte

- Upload via SCP/SFTP
- Ausführung über HTTPS
- Automatische Bereinigung nach Ausführung
- Sichere Key-basierte Authentifizierung

### 3. FTP/SFTP File Operations

- **Upload:** `scp -i key file user@server:path`
- **Download:** `scp -i key user@server:path localpath`
- **Batch Operations:** PowerShell/Bash-Skripte

---

## 🎯 AUSWIRKUNGEN AUF UNSER PROJEKT:

### ✅ ERFOLGREICH ABGESCHLOSSEN:

- Database Setup (über Web-Skripte)
- File Synchronization (SFTP funktioniert)
- Configuration Updates (lokal)
- Script Cleanup (über Web-Interface)

### 🔄 ANGEPASSTE WORKFLOWS:

- **Server-Konfiguration:** Nur über Plesk Panel
- **Datenbank-Management:** phpMyAdmin/Plesk
- **File-Management:** SFTP + Plesk File Manager
- **Maintenance:** Web-basierte Skripte

---

## 🚀 NÄCHSTE SCHRITTE (angepasst):

### 1. Security Keys Generation

- **Lokal generieren** und per SFTP hochladen
- **Web-Skript** für WordPress Salts
- **Plesk Panel** für SSL-Zertifikate

### 2. Live-Presentation Setup

- **Laravel Artisan Commands:** Über Plesk Terminal (falls verfügbar)
- **WordPress Plugin Installation:** Über WP-Admin
- **Configuration:** Via SFTP .env Updates

### 3. Deployment Strategy

- **Git Deployment:** Über Plesk Git-Integration
- **CI/CD:** GitHub Actions mit SFTP-Deploy
- **Updates:** Automatisierte SFTP-Workflows

---

## 🔐 SICHERHEITSVORTEILE:

### ✅ ERHÖHTE SICHERHEIT:

- **Kein Root-Zugriff** - Reduzierte Angriffsfläche
- **Chroot Isolation** - Beschränkt auf Web-Directory
- **SFTP Only** - Keine Shell-Injection möglich
- **Plesk Management** - Professionelle Admin-Oberfläche

### ⚠️ BERÜCKSICHTIGUNGEN:

- **Begrenzte CLI-Tools** - Nur über Plesk verfügbar
- **Web-basierte Verwaltung** - Längere Workflows
- **File-Transfer fokussiert** - SFTP als Hauptschnittstelle

---

**FAZIT:** Die chroot SFTP-Beschränkung ist ein **Sicherheitsfeature**, nicht ein Problem.
Alle geplanten Funktionen sind über alternative Wege realisierbar! 🎯
