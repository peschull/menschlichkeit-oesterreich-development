# 🔧 Mail-Neukonfiguration - Optimierte Zuordnung

## Basierend auf vorhandenen Plesk Mail-Konten

---

## 🎯 **STRATEGIE: Vorhandene Mail-Accounts optimal nutzen**

### 📊 **CURRENT STATE - Vorhandene Plesk Accounts:**

```
✅ peter.schuller@menschlichkeit-oesterreich.at    → Administrator
✅ logging@menschlichkeit-oesterreich.at           → System Logs
✅ info@menschlichkeit-oesterreich.at              → Allgemeine Kommunikation
✅ civimail@menschlichkeit-oesterreich.at          → CiviCRM Mail-Versand
✅ bounce@menschlichkeit-oesterreich.at            → CiviCRM Bounce-Handling
```

### 🎯 **TARGET STATE - Optimale Zuordnung:**

#### **WordPress Hauptdomain** (menschlichkeit-oesterreich.at)

- **Verwende:** `info@menschlichkeit-oesterreich.at` ✅ **Bereits vorhanden!**
- **Zweck:** System-Mails, Kontaktformular, Benachrichtigungen
- **Vorteil:** Professioneller als "noreply", bereits eingerichtet

#### **Laravel API** (api.menschlichkeit-oesterreich.at)

- **Verwende:** `logging@menschlichkeit-oesterreich.at` ✅ **Bereits vorhanden!**
- **Zweck:** API-Logs, System-Alerts, Webhook-Notifications
- **Vorteil:** Perfekt für technische/System-Nachrichten

#### **CiviCRM** (crm.menschlichkeit-oesterreich.at)

- **Verwende:** `civimail@menschlichkeit-oesterreich.at` ✅ **Bereits vorhanden!**
- **Bounce Handling:** `bounce@menschlichkeit-oesterreich.at` ✅ **Bereits vorhanden!**
- **Vorteil:** CiviCRM-spezifische Accounts bereits optimal konfiguriert

---

## 📝 **NEUE ENVIRONMENT-KONFIGURATION:**

### **WordPress (.env)**

```bash
# SMTP Configuration (Plesk Mail) - UPDATED
SMTP_HOST=smtp.menschlichkeit-oesterreich.at
SMTP_PORT=587
SMTP_USERNAME=info@menschlichkeit-oesterreich.at
SMTP_PASSWORD=[PASSWORT_AUS_PLESK]
SMTP_ENCRYPTION=tls
MAIL_FROM_ADDRESS=info@menschlichkeit-oesterreich.at
MAIL_FROM_NAME="Menschlichkeit Österreich"
```

### **Laravel API (.env)**

```bash
# Mail Configuration (Plesk SMTP) - UPDATED
MAIL_MAILER=smtp
MAIL_HOST=smtp.menschlichkeit-oesterreich.at
MAIL_PORT=587
MAIL_USERNAME=logging@menschlichkeit-oesterreich.at
MAIL_PASSWORD=[PASSWORT_AUS_PLESK]
MAIL_ENCRYPTION=tls
MAIL_FROM_ADDRESS=logging@menschlichkeit-oesterreich.at
MAIL_FROM_NAME="Menschlichkeit Österreich API"
```

### **CiviCRM (.env)**

```bash
# Mail Configuration (Plesk SMTP) - UPDATED
SMTP_HOST=smtp.menschlichkeit-oesterreich.at
SMTP_PORT=587
SMTP_USERNAME=civimail@menschlichkeit-oesterreich.at
SMTP_PASSWORD=[PASSWORT_AUS_PLESK]
SMTP_ENCRYPTION=tls
MAIL_FROM_ADDRESS=civimail@menschlichkeit-oesterreich.at
MAIL_FROM_NAME="Menschlichkeit Österreich CRM"

# CiviCRM Bounce Handling
CIVICRM_BOUNCE_EMAIL=bounce@menschlichkeit-oesterreich.at
CIVICRM_BOUNCE_PASSWORD=[PASSWORT_AUS_PLESK]
```

---

## 🔍 **MAIL-PASSWÖRTER ABRUFEN:**

### **Plesk Control Panel Zugang:**

1. **URL:** https://menschlichkeit-oesterreich.at:8443 oder https://5.183.217.146:8443
2. **Login:** dmpl20230054
3. **Navigation:** Mail → E-Mail-Adressen
4. **Passwörter:** Bei jeder Mail-Adresse → "Passwort ändern" oder anzeigen

### **Benötigte Passwörter:**

- `info@menschlichkeit-oesterreich.at` → WordPress SMTP
- `logging@menschlichkeit-oesterreich.at` → Laravel API
- `civimail@menschlichkeit-oesterreich.at` → CiviCRM Versand
- `bounce@menschlichkeit-oesterreich.at` → CiviCRM Bounce-Handling

---

## ✅ **VORTEILE DIESER KONFIGURATION:**

### **1. Keine neuen Mail-Accounts nötig**

- Nutzt vorhandene, bereits funktionierende Konten
- Kein zusätzlicher Setup-Aufwand
- Sofortige Verfügbarkeit

### **2. Logische Zuordnung**

- `info@` für allgemeine WordPress-Kommunikation
- `logging@` für technische API-Meldungen
- `civimail@` + `bounce@` für CiviCRM (bereits optimal)

### **3. Professionelle Absender**

- Keine "noreply"-Adressen → bessere Zustellbarkeit
- Echte Postfächer → Antworten möglich
- Saubere Trennung der Funktionsbereiche

---

## 🚀 **IMPLEMENTIERUNG:**

### **Schritt 1: Passwörter sammeln**

```bash
# Plesk Control Panel öffnen
# Mail → E-Mail-Adressen
# Für jede Adresse Passwort notieren/ändern:
info@menschlichkeit-oesterreich.at      → [Passwort_1]
logging@menschlichkeit-oesterreich.at   → [Passwort_2]
civimail@menschlichkeit-oesterreich.at  → [Passwort_3]
bounce@menschlichkeit-oesterreich.at    → [Passwort_4]
```

### **Schritt 2: Environment-Dateien aktualisieren**

```bash
# WordPress (.env)
SMTP_USERNAME=info@menschlichkeit-oesterreich.at
SMTP_PASSWORD=[Passwort_1]

# Laravel API (.env)
MAIL_USERNAME=logging@menschlichkeit-oesterreich.at
MAIL_PASSWORD=[Passwort_2]

# CiviCRM (.env)
SMTP_USERNAME=civimail@menschlichkeit-oesterreich.at
SMTP_PASSWORD=[Passwort_3]
CIVICRM_BOUNCE_PASSWORD=[Passwort_4]
```

### **Schritt 3: SFTP Upload der aktualisierten .env-Dateien**

```powershell
scp -i "C:\Users\schul\.ssh\id_ed25519" .env dmpl20230054@5.183.217.146:httpdocs/
scp -i "C:\Users\schul\.ssh\id_ed25519" api.menschlichkeit-oesterreich.at/.env dmpl20230054@5.183.217.146:httpdocs/api/
scp -i "C:\Users\schul\.ssh\id_ed25519" crm.menschlichkeit-oesterreich.at/.env dmpl20230054@5.183.217.146:httpdocs/crm/
```

---

## 🎯 **ZUSÄTZLICHE OPTIMIERUNGEN:**

### **Mail-Weiterleitungen einrichten**

```
info@menschlichkeit-oesterreich.at     → peter.schuller@menschlichkeit-oesterreich.at
logging@menschlichkeit-oesterreich.at  → peter.schuller@menschlichkeit-oesterreich.at
civimail@menschlichkeit-oesterreich.at → [CRM-Verantwortlicher]
bounce@menschlichkeit-oesterreich.at   → [Tech-Admin]
```

### **DNS-Optimierung (für bessere Zustellbarkeit)**

```txt
# SPF Record
v=spf1 a mx ip4:5.183.217.146 ~all

# DKIM (über Plesk aktivieren)
# DMARC
v=DMARC1; p=quarantine; rua=mailto:peter.schuller@menschlichkeit-oesterreich.at
```

---

**🎯 FAZIT:** Optimale Nutzung der vorhandenen Mail-Infrastruktur ohne zusätzliche Accounts! Professionell und sofort einsatzbereit! 📧✨
