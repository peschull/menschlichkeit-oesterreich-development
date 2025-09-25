# 🔐 Plesk Mail-Passwort Abruf-Guide

## Schritt-für-Schritt Anleitung

---

## 🎯 **BENÖTIGTE PASSWÖRTER:**

### 📋 **Mail-Accounts → Environment Mapping:**

```
✅ info@menschlichkeit-oesterreich.at      → WordPress (.env)
✅ logging@menschlichkeit-oesterreich.at   → Laravel API (.env)
✅ civimail@menschlichkeit-oesterreich.at  → CiviCRM (.env)
✅ bounce@menschlichkeit-oesterreich.at    → CiviCRM Bounce (.env)
```

---

## 🔧 **PLESK CONTROL PANEL ZUGANG:**

### **1. Plesk Panel öffnen:**

```
URL: https://menschlichkeit-oesterreich.at:8443
Alternative: https://5.183.217.146:8443
```

### **2. Login:**

```
Benutzer: dmpl20230054
SSH Key: C:\Users\schul\.ssh\id_ed25519
```

### **3. Navigation:**

```
Mail → E-Mail-Adressen → [jeweilige Mail-Adresse auswählen]
```

---

## 📝 **PASSWORT-ABRUF PRO ACCOUNT:**

### **🔸 info@menschlichkeit-oesterreich.at**

```bash
# Plesk: Mail → E-Mail-Adressen → info@...
# Aktion: "Passwort ändern" oder "Passwort anzeigen"
# Eintragen in: menschlichkeit-oesterreich-monorepo/.env
SMTP_PASSWORD=[HIER_EINFÜGEN]
```

### **🔸 logging@menschlichkeit-oesterreich.at**

```bash
# Plesk: Mail → E-Mail-Adressen → logging@...
# Eintragen in: api.menschlichkeit-oesterreich.at/.env
MAIL_PASSWORD=[HIER_EINFÜGEN]
```

### **🔸 civimail@menschlichkeit-oesterreich.at**

```bash
# Plesk: Mail → E-Mail-Adressen → civimail@...
# Eintragen in: crm.menschlichkeit-oesterreich.at/.env
SMTP_PASSWORD=[HIER_EINFÜGEN]
```

### **🔸 bounce@menschlichkeit-oesterreich.at**

```bash
# Plesk: Mail → E-Mail-Adressen → bounce@...
# Eintragen in: crm.menschlichkeit-oesterreich.at/.env
CIVICRM_BOUNCE_PASSWORD=[HIER_EINFÜGEN]
```

---

## 🔄 **UPDATE-PROZESS:**

### **Schritt 1: Passwörter sammeln**

1. Plesk Control Panel öffnen
2. Für jeden der 4 Mail-Accounts das Passwort notieren/ändern
3. Sichere Passwörter verwenden (16+ Zeichen)

### **Schritt 2: .env-Dateien aktualisieren**

```powershell
# Lokal bearbeiten:
d:\Arbeitsverzeichniss\menschlichkeit-oesterreich-monorepo\.env
d:\Arbeitsverzeichniss\menschlichkeit-oesterreich-monorepo\api.menschlichkeit-oesterreich.at\.env
d:\Arbeitsverzeichniss\menschlichkeit-oesterreich-monorepo\crm.menschlichkeit-oesterreich.at\.env
```

### **Schritt 3: SFTP Upload**

```powershell
scp -i "C:\Users\schul\.ssh\id_ed25519" .env dmpl20230054@5.183.217.146:httpdocs/
scp -i "C:\Users\schul\.ssh\id_ed25519" api.menschlichkeit-oesterreich.at/.env dmpl20230054@5.183.217.146:httpdocs/api/
scp -i "C:\Users\schul\.ssh\id_ed25519" crm.menschlichkeit-oesterreich.at/.env dmpl20230054@5.183.217.146:httpdocs/crm/
```

---

## 🧪 **MAIL-FUNKTIONALITÄT TESTEN:**

### **WordPress Test:**

```php
// WordPress Admin → Tools → Site Health → E-Mail-Test
// Oder über WordPress Plugin: WP Mail SMTP Test
```

### **Laravel API Test:**

```php
// SSH/Terminal auf Server (falls möglich):
php artisan tinker
Mail::raw('Test API Mail', function($msg) {
    $msg->to('test@domain.com')->subject('API Test');
});
```

### **CiviCRM Test:**

```
// CiviCRM Admin → Mailings → New Mailing → Test Mailing
// Bounce-Test: CiviCRM → Administer → Mail Accounts → Test Connection
```

---

## 🔒 **SICHERHEITSEMPFEHLUNGEN:**

### **Starke Passwörter verwenden:**

```
Mindestens 16 Zeichen
Groß-/Kleinbuchstaben + Zahlen + Sonderzeichen
Beispiel: K9m$nL7@xQ3vP8uR
```

### **2FA aktivieren** (falls verfügbar in Plesk)

### **Regelmäßige Passwort-Änderungen** (alle 90 Tage)

### **Log-Monitoring** über logging@menschlichkeit-oesterreich.at

---

## ✅ **CHECKLISTE:**

- [ ] **Plesk Panel Zugang** funktioniert
- [ ] **info@** Passwort abgerufen & in WordPress .env eingetragen
- [ ] **logging@** Passwort abgerufen & in Laravel .env eingetragen
- [ ] **civimail@** Passwort abgerufen & in CiviCRM .env eingetragen
- [ ] **bounce@** Passwort abgerufen & in CiviCRM .env eingetragen
- [ ] **Alle .env-Dateien** per SFTP hochgeladen
- [ ] **Mail-Tests** für alle drei Domains durchgeführt

---

**🎯 ZIEL:** Vollständig funktionsfähige Mail-Konfiguration mit bestehender Plesk-Infrastruktur! 📧✅
