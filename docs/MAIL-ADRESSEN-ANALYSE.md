# 📧 Mail-Adressen Analyse - menschlichkeit-oesterreich.at

_Aktualisiert: 22. September 2025_

## 🎯 **AKTUELLE PLESK MAIL-KONTEN (Live-Status):**

### 📊 **Vorhandene E-Mail-Adressen:**

| E-Mail-Adresse                                   | Weiterleitung             | Speicher         | Zweck                   | Status   |
| ------------------------------------------------ | ------------------------- | ---------------- | ----------------------- | -------- |
| **peter.schuller@menschlichkeit-oesterreich.at** | schuller.peter@outlook.at | 913 KB / 250 MB  | Administrator/Owner     | ✅ Aktiv |
| **logging@menschlichkeit-oesterreich.at**        | -                         | 141 MB / 250 MB  | System Logging          | ✅ Aktiv |
| **info@menschlichkeit-oesterreich.at**           | -                         | 26.4 KB / 250 MB | Allgemeine Anfragen     | ✅ Aktiv |
| **civimail@menschlichkeit-oesterreich.at**       | Selbst                    | 18.1 KB / 250 MB | CiviCRM Mail-Versand    | ✅ Aktiv |
| **bounce@menschlichkeit-oesterreich.at**         | Selbst                    | 29.1 KB / 250 MB | CiviCRM Bounce-Handling | ✅ Aktiv |

### 📈 **Speicher-Übersicht:**

- **Gesamtverbrauch:** ~162 MB von 1.25 GB (5×250MB)
- **Größter Verbraucher:** logging@menschlichkeit-oesterreich.at (141 MB)
- **Freier Speicher:** ~1.09 GB verfügbar

---

## ✅ **KONFIGURIERTE MAIL-ADRESSEN (Environment):**

### 🏠 **WordPress Hauptdomain** (menschlichkeit-oesterreich.at)

- **SMTP Username:** `noreply@menschlichkeit-oesterreich.at`
- **From Address:** `noreply@menschlichkeit-oesterreich.at`
- **From Name:** `"Menschlichkeit Österreich"`
- **Status:** ⚠️ **Passwort fehlt** (`your_smtp_password_here`)

### 🔧 **Laravel API** (api.menschlichkeit-oesterreich.at)

- **Mail Username:** `api@menschlichkeit-oesterreich.at`
- **From Address:** `api@menschlichkeit-oesterreich.at`
- **From Name:** `"Menschlichkeit Österreich API"`
- **Status:** ⚠️ **Passwort fehlt** (`your_api_mail_password`)

### 👥 **CiviCRM** (crm.menschlichkeit-oesterreich.at)

- **SMTP Username:** `crm@menschlichkeit-oesterreich.at`
- **From Address:** `crm@menschlichkeit-oesterreich.at`
- **From Name:** `"Menschlichkeit Österreich CRM"`
- **Status:** ⚠️ **Passwort fehlt** (`your_crm_mail_password`)

---

## 🌐 **SMTP-KONFIGURATION (Alle Domains):**

```
SMTP Host: smtp.menschlichkeit-oesterreich.at
SMTP Port: 587
Encryption: TLS
Protocol: STARTTLS
```

---

## 🔍 **STATUS-ÜBERSICHT:**

| Domain          | E-Mail-Adresse                        | Zweck                     | Passwort-Status |
| --------------- | ------------------------------------- | ------------------------- | --------------- |
| **Hauptdomain** | noreply@menschlichkeit-oesterreich.at | WordPress System-Mails    | ❌ Fehlt        |
| **API**         | api@menschlichkeit-oesterreich.at     | Laravel API Notifications | ❌ Fehlt        |
| **CRM**         | crm@menschlichkeit-oesterreich.at     | CiviCRM Kommunikation     | ❌ Fehlt        |

---

## ⚠️ **FEHLENDE KONFIGURATION:**

### **1. Mail-Passwörter benötigt:**

```bash
# WordPress Hauptdomain
SMTP_PASSWORD=your_smtp_password_here

# Laravel API
MAIL_PASSWORD=your_api_mail_password

# CiviCRM
SMTP_PASSWORD=your_crm_mail_password
```

### **2. Plesk Mail-Konten erstellen:**

Die folgenden E-Mail-Adressen müssen im **Plesk Control Panel** angelegt werden:

1. **noreply@menschlichkeit-oesterreich.at**
   - Zweck: WordPress System-Mails (Passwort-Reset, Benachrichtigungen)
   - Weiterleitung: Optional an Haupt-E-Mail-Adresse

2. **api@menschlichkeit-oesterreich.at**
   - Zweck: Laravel API Notifications, Webhooks, System-Alerts
   - Weiterleitung: Optional an Administrator

3. **crm@menschlichkeit-oesterreich.at**
   - Zweck: CiviCRM Events, Registrierungen, Spenden-Benachrichtigungen
   - Weiterleitung: An CRM-Manager/Administrator

---

## 🎯 **NÄCHSTE SCHRITTE:**

### **Schritt 1: Plesk Mail-Setup**

1. **Plesk Control Panel öffnen:** https://menschlichkeit-oesterreich.at:8443
2. **Mail → E-Mail-Adressen** aufrufen
3. **Neue E-Mail-Adressen erstellen:**
   - noreply@menschlichkeit-oesterreich.at
   - api@menschlichkeit-oesterreich.at
   - crm@menschlichkeit-oesterreich.at
4. **Starke Passwörter vergeben** und notieren

### **Schritt 2: Environment-Dateien aktualisieren**

```bash
# Nach Erstellung der Mail-Konten die Passwörter in .env-Dateien eintragen:
.env → SMTP_PASSWORD=actual_password_here
api.menschlichkeit-oesterreich.at/.env → MAIL_PASSWORD=actual_password_here
crm.menschlichkeit-oesterreich.at/.env → SMTP_PASSWORD=actual_password_here
```

### **Schritt 3: Mail-Funktionalität testen**

- **WordPress:** Test-Mail über WP-Admin senden
- **Laravel:** Mail-Test via Artisan Command
- **CiviCRM:** Test-Nachricht über CRM-Interface

---

## 📋 **ZUSÄTZLICHE MAIL-KONFIGURATIONEN:**

### **Empfohlene weitere E-Mail-Adressen:**

```
info@menschlichkeit-oesterreich.at       ← Haupt-Kontakt
kontakt@menschlichkeit-oesterreich.at    ← Allgemeine Anfragen
admin@menschlichkeit-oesterreich.at      ← Administrator-Mails
support@menschlichkeit-oesterreich.at    ← Support-Anfragen
```

### **Mail-Aliases/Weiterleitungen:**

```
webmaster@menschlichkeit-oesterreich.at  → admin@...
postmaster@menschlichkeit-oesterreich.at → admin@...
abuse@menschlichkeit-oesterreich.at      → admin@...
```

---

## 🔒 **SICHERHEITSHINWEISE:**

### **1. Sichere Passwörter verwenden:**

- Mindestens 16 Zeichen
- Kombination aus Groß-/Kleinbuchstaben, Zahlen, Sonderzeichen
- Keine Wörterbuch-Wörter

### **2. SPF-Record konfigurieren:**

```txt
v=spf1 a mx ip4:5.183.217.146 ~all
```

### **3. DKIM einrichten:**

- Über Plesk Control Panel aktivieren
- Öffentlichen Key in DNS eintragen

### **4. DMARC-Policy setzen:**

```txt
v=DMARC1; p=quarantine; rua=mailto:dmarc@menschlichkeit-oesterreich.at
```

---

**✅ ZUSAMMENFASSUNG:** Alle Mail-Konfigurationen sind vorbereitet, es fehlen nur die **echten Passwörter** aus dem Plesk Panel! 📧
