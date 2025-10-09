# E-Mail Infrastructure - Quick Reference Card

## 🚀 Deployment Cheat Sheet

### Schnellstart (Copy-Paste Ready)

#### 1. DNS Records (Plesk DNS oder Domain-Provider)

```dns
# SPF Records
menschlichkeit-oesterreich.at          TXT  "v=spf1 a mx -all"
newsletter.menschlichkeit-oesterreich.at TXT  "v=spf1 a mx -all"

# DKIM Records (Public Keys aus secrets/email-dkim/*/plesk-config.txt)
tx2025q4._domainkey.menschlichkeit-oesterreich.at          TXT  "v=DKIM1; k=rsa; p=MIIBIjANBgk..."
news2025q4._domainkey.newsletter.menschlichkeit-oesterreich.at TXT  "v=DKIM1; k=rsa; p=MIIBIjANBgk..."

# DMARC Record
_dmarc.menschlichkeit-oesterreich.at  TXT  "v=DMARC1; p=none; rua=mailto:dmarc-reports@menschlichkeit-oesterreich.at; ruf=mailto:dmarc-reports@menschlichkeit-oesterreich.at; fo=1; adkim=s; aspf=s; pct=100; ri=86400"

# TLSRPT Record
_smtp._tls.menschlichkeit-oesterreich.at  TXT  "v=TLSRPTv1; rua=mailto:tlsrpt@menschlichkeit-oesterreich.at"

# MTA-STS Record
_mta-sts.menschlichkeit-oesterreich.at  TXT  "v=STSv1; id=20251008"
```

#### 2. Plesk Mail-Konfiguration (Copy-Paste Commands)

```bash
# SSH in Plesk Server
ssh root@your-plesk-server.com

# DKIM Private Key hochladen (Transactional)
cat > /etc/postfix/dkim/tx2025q4.private.pem << 'EOF'
[Private Key aus secrets/email-dkim/tx2025q4_private.pem]
EOF

# Permissions setzen
chmod 600 /etc/postfix/dkim/tx2025q4.private.pem
chown postfix:postfix /etc/postfix/dkim/tx2025q4.private.pem

# Plesk Mail-Einstellungen (GUI oder CLI)
plesk bin mail --update menschlichkeit-oesterreich.at \
  -dkim enable \
  -dkim-selector tx2025q4 \
  -dkim-private-key /etc/postfix/dkim/tx2025q4.private.pem
```

#### 3. E-Mail-Adressen anlegen (Plesk CLI)

```bash
# info@
plesk bin mail --create info@menschlichkeit-oesterreich.at -passwd 'SECURE_PASSWORD' -mailbox true

# support@
plesk bin mail --create support@menschlichkeit-oesterreich.at -passwd 'SECURE_PASSWORD' -mailbox true

# Alle 9 Adressen analog erstellen (siehe Liste unten)
```

#### 4. Autoreplies konfigurieren (Plesk CLI)

```bash
# info@ Autoreply
plesk bin mail --update info@menschlichkeit-oesterreich.at \
  -autoreply true \
  -autoreply-subject "Eingangsbestätigung - Menschlichkeit Österreich" \
  -autoreply-text "$(cat secrets/email-templates/autoreplies/info_autoreply.txt)"

# Für alle anderen analog
```

#### 5. CiviMail DKIM Integration (Drupal CLI)

```bash
# SSH in Drupal Server
ssh root@your-drupal-server.com
cd /var/www/html/crm.menschlichkeit-oesterreich.at

# Modul installieren
composer require drupal/civicrm_mailer_dkim
drush en civicrm_mailer_dkim -y

# CiviMail SMTP konfigurieren (via GUI oder drush config)
drush config:set civicrm.settings mailer_smtp_host 'mail.menschlichkeit-oesterreich.at'
drush config:set civicrm.settings mailer_smtp_port '587'
drush config:set civicrm.settings mailer_smtp_auth 'true'
drush config:set civicrm.settings mailer_dkim_selector 'news2025q4'
drush config:set civicrm.settings mailer_dkim_domain 'newsletter.menschlichkeit-oesterreich.at'

# DKIM Private Key hochladen (via GUI oder File)
cat secrets/email-dkim/news2025q4_private.pem
# → CiviMail → Email Settings → DKIM Private Key
```

---

## 📋 Checklisten

### Pre-Deployment Checklist

- [ ] Plesk-Zugang validiert (SSH + Web-GUI)
- [ ] Domain-Provider-Zugang verfügbar
- [ ] DKIM Keys generiert (`secrets/email-dkim/`)
- [ ] DNS Records vorbereitet (siehe oben)
- [ ] Autoreplies-Texte reviewed
- [ ] Backup-Strategie dokumentiert

### Deployment Checklist

**Tag 1 (DNS Deployment):**
- [ ] SPF Records deployen (beide Domains)
- [ ] DKIM TXT Records deployen (beide Selektoren)
- [ ] DMARC Record deployen
- [ ] TLSRPT Record deployen
- [ ] MTA-STS Record deployen

**Tag 3 (Nach DNS Propagation):**
- [ ] DNS Check: `./scripts/email-monitoring.sh` → Alle PASSED
- [ ] Plesk DKIM aktivieren (tx2025q4)
- [ ] Private Keys hochladen
- [ ] Test-E-Mail senden → mail-tester.com

**Tag 4 (E-Mail-Adressen Setup):**
- [ ] 9 E-Mail-Adressen anlegen
- [ ] Autoreplies konfigurieren
- [ ] Weiterleitungen einrichten (falls benötigt)

**Tag 5 (CiviMail Integration):**
- [ ] Drupal Modul installieren
- [ ] SMTP + DKIM konfigurieren
- [ ] Test-Newsletter senden
- [ ] Bounce Handling validieren

**Tag 6 (Monitoring & Final Testing):**
- [ ] Plesk Cron Job: `./scripts/email-monitoring.sh`
- [ ] n8n Workflow deployen (optional)
- [ ] Postmaster Tools registrieren
- [ ] 24h Monitoring beobachten

### Post-Deployment Validation

- [ ] mail-tester.com Score ≥ 9/10
- [ ] Alle Autoreplies funktionieren
- [ ] CiviMail Newsletter mit DKIM Signature
- [ ] DMARC Reports empfangen (nach 24-48h)
- [ ] Monitoring läuft täglich

---

## 🛠️ Troubleshooting Quick Fixes

### Problem: DKIM Signature Failed

```bash
# Check DNS Record
dig +short TXT tx2025q4._domainkey.menschlichkeit-oesterreich.at

# Check Plesk Config
plesk bin mail --info menschlichkeit-oesterreich.at | grep -i dkim

# Solution: Re-upload Private Key oder DNS Record korrigieren
```

### Problem: SPF Lookup Limit Exceeded

```bash
# Check Lookups
dig +short TXT menschlichkeit-oesterreich.at | grep "v=spf1"

# Solution: SPF Flattening (IP-Adressen hardcoden)
# Siehe MAINTENANCE-ROTATION.md → Troubleshooting
```

### Problem: E-Mails landen in Spam

```bash
# Test mit mail-tester.com
# → Zeigt genaue Fehlerursache

# Häufige Ursachen:
# 1. DKIM Signature fehlt oder ungültig
# 2. SPF Record fehlt oder zu restriktiv
# 3. DMARC Policy zu streng (p=reject)
# 4. Reverse DNS (PTR) fehlt
# 5. IP auf Blacklist (check: mxtoolbox.com/blacklists.aspx)
```

### Problem: CiviMail DKIM nicht aktiv

```bash
# Check Drupal Modul
drush pm:list | grep civicrm_mailer_dkim

# Check DKIM Key Pfad
ls -lh /var/www/html/sites/default/files/civicrm/dkim/

# Solution: Private Key neu hochladen oder Pfad korrigieren
```

---

## 📞 Kontakte & Support

### Bei Problemen während Deployment

1. **Dokumentation nochmal lesen**
   - `secrets/email-dkim/IMPLEMENTATION-GUIDE.md`
   - `quality-reports/email-infrastructure/SETUP-COMPLETE-REPORT.md`

2. **Monitoring ausführen**
   ```bash
   ./scripts/email-monitoring.sh
   ```

3. **Logs prüfen**
   ```bash
   # Plesk Mail-Logs
   tail -f /var/log/maillog
   
   # Postfix Logs
   tail -f /var/log/postfix/smtp.log
   
   # Drupal Watchdog
   drush watchdog:tail
   ```

4. **GitHub Issue erstellen**
   - Label: `email-infrastructure`
   - Template: Deployment Issue
   - Include: Logs, Screenshots, Error Messages

### Emergency Contacts

- **IT Security Lead**: security@menschlichkeit-oesterreich.at
- **DevOps Team**: GitHub Issues (Label: `urgent`)
- **Plesk Support**: support@plesk.com (bei Server-Problemen)

---

## 📊 KPI Targets (Nach 30 Tagen)

```
✅ E-Mail Deliverability:     ≥ 98%
✅ DKIM Signature Success:     100%
✅ SPF Pass Rate:              100%
✅ DMARC Compliance:           0% Failures
✅ TLS Enforcement:            100%
✅ Spam Rate:                  < 0.1%
✅ Bounce Rate:                < 2%
✅ mail-tester.com Score:      10/10
```

---

## 🔄 Quarterly Rotation Reminder

**Nächste DKIM Key Rotation: Januar 2026**

```bash
# Automatisches Script ausführen
./scripts/dkim-rotation.sh --quarter 2026q1

# Oder manuell
# 1. Neue Keys generieren (7 Tage vor Rotation)
# 2. DNS Records deployen (3 Tage vor Rotation)
# 3. Plesk umschalten (Rotation Day)
# 4. Alte Records entfernen (30 Tage nach Rotation)
```

---

## 📁 Wichtige Dateipfade

```
secrets/email-dkim/
├── tx2025q4_private.pem              → Transactional DKIM Private Key
├── tx2025q4_public.txt               → DNS TXT Record
├── news2025q4_private.pem            → Newsletter DKIM Private Key
├── news2025q4_public.txt             → DNS TXT Record
├── IMPLEMENTATION-GUIDE.md           → Schritt-für-Schritt Deployment
└── MAINTENANCE-ROTATION.md           → Key Rotation & Monitoring

secrets/email-templates/autoreplies/
├── info_autoreply.txt                → Allgemeine Anfragen
├── support_autoreply.txt             → Technischer Support
├── contact_autoreply.txt             → Kontaktformular
├── hello_autoreply.txt               → Informell
├── bounces_autoreply.txt             → Bounce Management
├── abuse_autoreply.txt               → Missbrauchsmeldungen
├── security_vdp_autoreply.txt        → Vulnerability Disclosure
├── postmaster_autoreply.txt          → Mail-Infrastruktur
└── noreply_autoreply.txt             → No-Reply

scripts/
├── email-monitoring.sh               → Tägliches DNS Monitoring
└── dkim-rotation.sh                  → Quarterly Key Rotation

quality-reports/email-infrastructure/
├── SETUP-COMPLETE-REPORT.md          → Vollständiger Abschluss-Report
└── email-monitoring-*.json           → Monitoring Reports
```

---

**Letztes Update:** 2025-10-08  
**Version:** 1.0  
**Bereit für Deployment:** ✅ JA

🚀 **Viel Erfolg beim Deployment!** 🇦🇹
