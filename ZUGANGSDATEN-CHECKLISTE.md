# 📋 ZUGANGSDATEN CHECKLISTE - Menschlichkeit Österreich

**Stand:** 30. September 2025
**System:** Multi-Service Austrian NGO Platform

## 🚀 QUICK START - Sofort loslegen

### Schritt 1: Generiere Security Keys (2 Minuten)
```bash
# JWT Secret für API
openssl rand -base64 32

# n8n Encryption Key
openssl rand -base64 32
```

### Schritt 2: Kopiere .env Templates
```bash
# API
cp api.menschlichkeit-oesterreich.at/.env.example api.menschlichkeit-oesterreich.at/.env

# CRM
cp crm.menschlichkeit-oesterreich.at/.env.example crm.menschlichkeit-oesterreich.at/.env

# n8n
cp automation/n8n/.env.example automation/n8n/.env
```

### Schritt 3: Trage Secrets ein
1. Öffne die `.env` Dateien
2. Ersetze `DUMMY` Werte mit echten Credentials
3. Verwende generierte Keys aus Schritt 1

### Schritt 4: Starte Services
```bash
npm run dev:all
```

---

## ✅ VERFÜGBARE ZUGANGSDATEN

### 📧 E-Mail Accounts (KOMPLETT)

- ✅ **logging@menschlichkeit-oesterreich.at** | `wa3&3M59m`
- ✅ **info@menschlichkeit-oesterreich.at** | `4%4if15Ao`
- ✅ **peter.schuller@menschlichkeit-oesterreich.at** | `17d3lT8?h`
- ✅ **civimail@menschlichkeit-oesterreich.at** | `69nTdv$16`
- ✅ **bounce@menschlichkeit-oesterreich.at** | `1w8S%8a9k`

### 🌐 Server Zugang (KOMPLETT)

- ✅ **Plesk Host:** `dmpl20230054@5.183.217.146`
- ✅ **SSH Port:** 22
- ✅ **SSH Key:** `~/.ssh/id_ed25519` (verfügbar)
- ✅ **Web Path:** `/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs`

---

## ❌ FEHLENDE ZUGANGSDATEN (KRITISCH)

### 🗄️ Database Credentials

- ❌ **Laravel Database Password**
  - Current: `SECURE_LARAVEL_2025` (DUMMY)
  - Database: `mo_laravel_api`
  - User: `laravel_user`
  - **Aktion:** Echtes Passwort von Plesk holen

- ❌ **CiviCRM Database Password**
  - Current: `SECURE_CIVICRM_2025` (DUMMY)
  - Database: `mo_civicrm_data`
  - User: `civicrm_user`
  - **Aktion:** Echtes Passwort von Plesk holen

### 🔐 Security Keys

- ❌ **JWT Secret (32+ chars)**
  - **Generierung:** `openssl rand -base64 32`
  - **Verwendung:** API Authentication

- ❌ **n8n Encryption Key (32 chars)**
  - **Generierung:** `openssl rand -base64 32`
  - **Verwendung:** Workflow Automation

### 👥 CiviCRM Integration

- ❌ **CiviCRM API Key**
  - **Quelle:** CiviCRM Admin → System Settings → API Keys
  - **Verwendung:** API v4 Integration

- ❌ **CiviCRM Site Key**
  - **Quelle:** CiviCRM Admin → System Settings → Site Key
  - **Verwendung:** API Security

### 🤖 n8n Automation

- ❌ **n8n Admin Username**
  - **Empfehlung:** `moe_admin` oder `admin`

- ❌ **n8n Admin Password**
  - **Generierung:** Starkes Passwort 16+ Zeichen
  - **Pattern:** Mix aus Buchstaben, Zahlen, Sonderzeichen

---

## 🔍 EXTERNAL SERVICES (WICHTIG)

### Code Quality & Security

- ❌ **Codacy API Token**
  - **Setup:** https://app.codacy.com → Account → API Tokens
  - **Verwendung:** Code Quality Analysis
  - **Kosten:** Free Tier verfügbar

- ❌ **Snyk Token**
  - **Setup:** https://app.snyk.io → Account Settings → API Token
  - **Verwendung:** Security Vulnerability Scanning
  - **Kosten:** Free Tier verfügbar

- 🟡 **SonarQube Token** (OPTIONAL)
  - **Setup:** SonarCloud oder Self-hosted
  - **Verwendung:** Advanced Code Quality

---

## 💰 PAYMENT INTEGRATION (OPTIONAL)

### SEPA für Österreich (NGO Spenden)

- 🟡 **SEPA Creditor ID**
  - **Quelle:** Österreichische Nationalbank
  - **Format:** AT-XX-ZZZ-YYYYYYYYYYY

- 🟡 **Vereins-IBAN**
  - **Verwendung:** Spenden & Mitgliedsbeiträge
  - **Bank:** Österreichische Bank

- 🟡 **Bank BIC Code**
  - **Format:** 8-11 Zeichen
  - **Verwendung:** SEPA Transfers

### Alternative Payment (OPTIONAL)

- 🟡 **Stripe Public Key** (pk_live_xxx)
- 🟡 **Stripe Secret Key** (sk_live_xxx)

---

## 📊 PRIORITÄTEN-MATRIX

### 🔥 SOFORT (Blockiert Entwicklung)

1. **Database Passwörter** - Plesk Database Access
2. **JWT Secret** - API Security
3. **CiviCRM Keys** - Member Management

### ⚠️ HOCH (Quality Gates)

4. **Codacy Token** - Code Quality CI/CD
5. **Snyk Token** - Security Scanning
6. **n8n Credentials** - Automation Workflows

### 🟡 MITTEL (Features)

7. **SEPA Credentials** - Donation System
8. **SonarQube** - Extended Quality

### 🔵 NIEDRIG (Nice-to-have)

9. **Stripe** - Alternative Payments
10. **Social Media APIs** - Marketing Integration

---

## 🎯 AKTIONSPLAN

### Phase 1: Database & Security (Tag 1) - 🔴 KRITISCH

- [ ] **Plesk Login** → Database Passwörter abrufen
  - Anleitung: Plesk Panel → Datenbanken → Passwort anzeigen
  - Benötigt für: Laravel API, CiviCRM
  
- [ ] **JWT Secret generieren**
  ```bash
  openssl rand -base64 32
  ```
  - Verwendung: API Authentication
  - Speicherort: `.env` → `JWT_SECRET`
  
- [ ] **n8n Admin Credentials definieren**
  - Username: `moe_admin` (empfohlen)
  - Password: Starkes Passwort (16+ Zeichen)
  - Speicherort: `automation/n8n/.env`
  
- [ ] **Alle Secrets in `.env` Dateien eintragen**
  - `api.menschlichkeit-oesterreich.at/.env`
  - `crm.menschlichkeit-oesterreich.at/.env`
  - `automation/n8n/.env`

### Phase 2: External Services (Tag 2-3) - ⚠️ HOCH

- [ ] **Codacy Account erstellen** → API Token holen
  1. https://app.codacy.com registrieren
  2. Repository verbinden
  3. Account → API Tokens → Create Token
  4. In `.env` als `CODACY_PROJECT_TOKEN` speichern
  
- [ ] **Snyk Account erstellen** → API Token holen
  1. https://app.snyk.io registrieren
  2. Account Settings → API Token
  3. In `.env` als `SNYK_TOKEN` speichern
  
- [ ] **CiviCRM installieren** → API & Site Keys generieren
  1. CiviCRM über Drupal installieren
  2. Admin → System Settings → API Keys generieren
  3. Site Key in `civicrm.settings.php` finden
  4. In `.env` speichern: `CIVI_API_KEY`, `CIVI_SITE_KEY`

### Phase 3: GitHub Integration (Tag 4) - ⚠️ HOCH

- [ ] **Alle Secrets zu GitHub Secrets migrieren**
  - Repository → Settings → Secrets and variables → Actions
  - Secrets hinzufügen:
    - `JWT_SECRET`
    - `LARAVEL_DB_PASSWORD`
    - `CIVICRM_DB_PASSWORD`
    - `CIVI_API_KEY`
    - `CIVI_SITE_KEY`
    - `N8N_ENCRYPTION_KEY`
    - `CODACY_PROJECT_TOKEN`
    - `SNYK_TOKEN`
    
- [ ] **GitHub Actions testen**
  ```bash
  git push origin main
  # Überprüfe: Actions Tab → Workflow läuft durch
  ```
  
- [ ] **CI/CD Pipeline validieren**
  - Build erfolgreich
  - Tests bestanden
  - Deployment funktioniert

### Phase 4: Payment Integration (Später) - 🔵 NIEDRIG

- [ ] **SEPA Creditor ID beantragen**
  - Österreichische Nationalbank kontaktieren
  - Vereinsdokumente vorbereiten
  - Bearbeitungszeit: 2-4 Wochen
  
- [ ] **Bank Integration setup**
  - IBAN des Vereinskontos in `.env`
  - BIC Code hinzufügen
  
- [ ] **Donation System konfigurieren**
  - CiviCRM SEPA Extension installieren
  - Test-Transaktion durchführen

---

## 🔐 SICHERHEITSHINWEISE

### ✅ SICHERE PRAKTIKEN

- Alle Production Secrets nur in GitHub Secrets
- Lokale `.env` nie in Git committen
- Starke Passwörter (16+ Zeichen)
- Regelmäßige Key Rotation
- 2FA für alle External Services

### ❌ VERMEIDEN

- Secrets in Code oder Kommentaren
- Wiederverwendung von Passwörtern
- Unverschlüsselte Übertragung
- Shared Accounts ohne Audit Trail

---

## 📞 SUPPORT KONTAKTE

### Database/Server Issues

- **Plesk Provider:** digimagical.com
- **Server IP:** 5.183.217.146
- **SSH User:** dmpl20230054

### External Services

- **Codacy Support:** support@codacy.com
- **Snyk Support:** support@snyk.io
- **CiviCRM Community:** https://civicrm.org/support

---

## 🔧 TROUBLESHOOTING

### Problem: "JWT_SECRET not set"
**Lösung:**
```bash
openssl rand -base64 32 > jwt_secret.txt
# Kopiere Inhalt in .env als JWT_SECRET=...
```

### Problem: "Database connection failed"
**Lösung:**
1. Überprüfe Plesk Database Credentials
2. Teste Verbindung: `mysql -u laravel_user -p -h localhost mo_laravel_api`
3. Aktualisiere `.env` mit korrekten Credentials

### Problem: "CiviCRM API not responding"
**Lösung:**
1. Überprüfe `CIVI_BASE_URL` (https://crm.menschlichkeit-oesterreich.at)
2. Teste API: `curl -X GET "https://crm.menschlichkeit-oesterreich.at/civicrm/api/v4"`
3. Verifiziere `CIVI_API_KEY` und `CIVI_SITE_KEY`

### Problem: "n8n won't start"
**Lösung:**
1. Überprüfe Docker: `docker ps`
2. Logs ansehen: `docker logs n8n`
3. Port 5678 frei? `lsof -i :5678`

### Problem: "GitHub Actions failing"
**Lösung:**
1. Überprüfe GitHub Secrets: Repository → Settings → Secrets
2. Alle 26 Secrets vorhanden?
3. Logs prüfen: Actions Tab → Failed Run → Details

---

**Letzte Aktualisierung:** 30. September 2025
**Nächste Review:** Bei System Changes
**Verantwortlich:** Peter Schuller (peter.schuller@menschlichkeit-oesterreich.at)
