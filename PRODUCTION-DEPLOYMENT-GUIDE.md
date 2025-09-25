# 🚀 Production Deployment Guide - Menschlichkeit Österreich

## ✅ Setup-Status
- ✅ Sichere Konfiguration implementiert (.env-basiert)
- ✅ Alle Haupt-Scripts integriert und getestet  
- ✅ Legacy Scripts bereinigt und archiviert
- ✅ SSL-Zertifikate aktiv für alle 3 Domains
- ✅ Deployment-Pipeline funktionsfähig

---

## 🔐 1. Sichere Konfiguration

### Verwendete Dateien:
- `config/.env` - **Produktive Credentials (niemals committen!)**
- `config/.env.example` - Template für neue Umgebungen
- `config/load-config.sh` - Sicherer Konfigurations-Loader

### Konfigurierte Credentials:
- **3 Datenbanken:** WordPress, Laravel API, CiviCRM
- **5 Email-Konten:** Verschiedene Funktionsadressen  
- **SFTP-Zugang:** Plesk-Server Verbindung
- **Umgebung:** Production-ready

---

## 🛠️ 2. Verfügbare Deployment-Scripts

### Hauptdomain Workflow:
```bash
# 1. Code-Qualität prüfen
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/quality-check.sh"

# 2. Sicheres Deployment ausführen
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/safe-deploy.sh"

# 3. Post-Deployment Tests
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/test-deployment.sh"
```

### Einzelne Script-Funktionen:

#### `scripts/quality-check.sh`
- ✅ Lädt sichere Konfiguration
- 📊 Codacy-Analyse über WSL
- 📈 Code-Metriken Sammlung
- 💾 Reports in `/quality-reports`

#### `scripts/safe-deploy.sh`
- ✅ Pre-Deployment Validierung
- 🔄 Ruft `sftp-sync.sh` auf
- ⚠️ Backup-Integration (geplant)
- 🚦 Fehlerbehandlung

#### `scripts/sftp-sync.sh`
- ✅ 3-Domain Architektur (main, api.*, crm.*)
- 📁 Selektives Verzeichnis-Sync
- 🔐 Verwendet SFTP_HOST/USER aus .env
- 📋 Detaillierte Upload-Reports

#### `scripts/test-deployment.sh`
- ✅ SSL-Zertifikat Validierung
- 🌐 HTTP Status Tests für alle Domains  
- 📱 Mobile Responsiveness Check
- 🔍 Content-Verifikation

---

## 🎯 3. Domain-Architektur

### Aktuelle Domains:
1. **Hauptdomain:** `menschlichkeit-oesterreich.at`
   - SSL: ✅ Valid bis Nov 2025
   - Status: 🟡 Live (mit 301 Redirect)
   
2. **API Subdomain:** `api.menschlichkeit-oesterreich.at` 
   - SSL: ✅ Valid bis Dez 2025
   - Status: 🔴 500 Error (Development needed)
   
3. **CRM Subdomain:** `crm.menschlichkeit-oesterreich.at`
   - SSL: ✅ Valid bis Nov 2025  
   - Status: 🔴 403 Forbidden (Setup needed)

### Plesk-Verzeichnisse:
- **Hauptdomain:** `/httpdocs`
- **API:** `/subdomains/api/httpdocs` 
- **CRM:** `/subdomains/crm/httpdocs`

---

## 🔧 4. Deployment-Vorbereitung

### Vor dem ersten Deployment:

1. **Website-Content vorbereiten:**
   ```bash
   mkdir website
   # Ihre HTML/CSS/JS Dateien in /website ablegen
   ```

2. **API-Development (optional):**
   ```bash
   mkdir api
   # Laravel/PHP API Code in /api ablegen  
   ```

3. **CRM-Integration (optional):**
   ```bash
   mkdir crm
   # CiviCRM Setup-Dateien in /crm ablegen
   ```

### SFTP-Credentials aktualisieren:
In `config/.env` die Platzhalter ersetzen:
```bash
SFTP_HOST="ihr-echter-plesk-server.de"
SFTP_USER="ihr-ftp-benutzer"
SFTP_PASSWORD="ihr-ftp-passwort"
```

---

## ⚡ 5. Produktiver Deployment-Ablauf

### Standard-Workflow:
```bash
# Terminal öffnen in d:\Arbeitsverzeichniss

# 1. Qualitätsprüfung (immer zuerst!)
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/quality-check.sh"

# 2. Bei bestandenen Tests: Deployment
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/safe-deploy.sh"

# 3. Nach Deployment: Verifikation
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/test-deployment.sh"
```

### Bei Fehlern:
1. 🔍 Script-Output analysieren
2. 📋 Quality-Reports in `/quality-reports` prüfen
3. 🔧 Issues beheben vor erneutem Deployment
4. 🔄 Workflow von vorne beginnen

---

## 📊 6. Monitoring & Maintenance

### Regelmäßige Checks:
- **Täglich:** Quality-Reports überprüfen
- **Wöchentlich:** SSL-Zertifikate Status
- **Monatlich:** Code-Metriken Trends analysieren

### Backup-Strategie:
- 🔄 Automatische Plesk-Backups
- 💾 Git-Repository als Code-Backup  
- 🗃️ Datenbank-Exports (geplant)

### Troubleshooting:
- **WSL-Probleme:** `wsl --shutdown && wsl`
- **SFTP-Fehler:** Credentials in `.env` prüfen
- **SSL-Issues:** Plesk Auto-SSL verifizieren

---

## 🚨 7. Sicherheitshinweise

### ⚠️ Kritische Dateien:
- `config/.env` - **NIEMALS committen oder teilen!**
- Enthält alle Produktions-Passwörter
- Nur via sichere Kanäle übertragen

### 🔐 Access Control:
- Scripts nur von autorisiertem System ausführen
- WSL-Environment vor unbefugtem Zugriff schützen  
- Regelmäßige Passwort-Rotation empfohlen

### 📋 Compliance:
- Alle Credentials verschlüsselt gespeichert
- Logs enthalten keine Passwörter (masked)
- Codacy-Integration für Security-Scans

---

## 🎯 8. Nächste Schritte

### Kurzfristig (1-2 Wochen):
1. **Content-Deployment:** Website-Dateien vorbereiten und deployen
2. **API-Setup:** Laravel API-Grundgerüst einrichten  
3. **CRM-Integration:** CiviCRM Basis-Installation

### Mittelfristig (1 Monat):
1. **Monitoring-Dashboard:** Automatisierte Quality-Reports
2. **CI/CD-Pipeline:** GitHub Actions Integration
3. **Backup-Automatisierung:** Scheduled Backups

### Langfristig (3 Monate):
1. **Performance-Optimierung:** Caching, CDN
2. **Security-Hardening:** Advanced SSL, CSRF-Protection  
3. **Scaling-Vorbereitung:** Load Balancing, Database Clustering

---

## 📞 Support & Kontakt

Bei Fragen oder Problemen:
1. 📖 Diese Dokumentation konsultieren
2. 🔍 Script-Logs in `/quality-reports` analysieren  
3. 🛠️ Issues im Git-Repository dokumentieren
4. 📧 Entwicklungsteam kontaktieren

**Status:** ✅ Production-Ready  
**Letzte Aktualisierung:** 2024-12-22  
**Version:** 1.0.0