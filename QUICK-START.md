# 🚀 Quick Start - Deployment Scripts

## Status: ✅ PRODUCTION READY

**Alle Scripts sind konfiguriert und getestet.**

---

## 📋 Sofort verwendbar

### 1. Code-Qualität prüfen
```bash
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/quality-check.sh"
```

### 2. Website deployen  
```bash
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/safe-deploy.sh"
```

### 3. Deployment testen
```bash
wsl bash -c "cd /mnt/d/Arbeitsverzeichniss && scripts/test-deployment.sh"
```

---

## 🔐 Konfiguration

- **Alle Passwörter:** Sicher in `config/.env` gespeichert
- **3 Datenbanken:** WordPress, Laravel API, CiviCRM  
- **5 Email-Konten:** Funktionsadressen konfiguriert
- **SSL-Zertifikate:** ✅ Aktiv für alle 3 Domains

---

## 🌐 Live-Domains

1. **menschlichkeit-oesterreich.at** - ✅ SSL gültig bis Nov 2025
2. **api.menschlichkeit-oesterreich.at** - ✅ SSL gültig bis Dez 2025  
3. **crm.menschlichkeit-oesterreich.at** - ✅ SSL gültig bis Nov 2025

---

## ✅ SSH-Umgebung getestet

**Server:** 5.183.217.146  
**User:** dmpl20230054  
**Authentication:** SSH-Key (id_ed25519)  
**Status:** ✅ Verbindung erfolgreich

### Verfügbare Domains:
- **httpdocs/** - Hauptwebsite (WordPress)
- **api.menschlichkeit-oesterreich.at/** - Laravel API  
- **crm.menschlichkeit-oesterreich.at/** - CiviCRM

---

## ⚠️ Vor dem ersten Deployment

**Website-Content vorbereiten:**
```bash
mkdir website
# HTML/CSS/JS Dateien in /website Ordner legen
```

**SFTP ist bereits konfiguriert!**
- SSH-Keys sind eingerichtet
- Plesk-Server erreichbar  
- 3-Domain-Struktur bestätigt

---

## 📞 Bei Fragen

- Vollständige Anleitung: `PRODUCTION-DEPLOYMENT-GUIDE.md`
- Script-Logs: `/quality-reports` Ordner
- Entwicklungsteam kontaktieren

**Ready für Production! 🎉**