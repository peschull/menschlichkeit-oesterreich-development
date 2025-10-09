# Email Infrastructure Smoke Tests & Validation

**Dokumentversion**: 1.0 (Phase 6 - Email Infrastructure Setup)  
**Erstellt**: 2025-10-07  
**Für**: Deployment-Validierung nach DNS/Mailserver-Konfiguration

---

## 🎯 Testziele

```yaml
Ziele:
  1. SPF/DKIM/DMARC-Authentifizierung funktioniert (100% Pass-Rate)
  2. Deliverability zu Gmail/Outlook/GMX ≥ 95%
  3. Mail-Tester Score ≥ 9/10
  4. Bounce-Processing funktioniert (VERP)
  5. Autoreplies aktiviert für abuse@, postmaster@, security@, noreply@
  6. CiviMail kann versenden + bounces verarbeiten
  
Akzeptanzkriterien:
  ❌ BLOCKER: DMARC p=quarantine/reject fehlschlägt
  ❌ BLOCKER: Spam-Folder bei Gmail/Outlook
  ⚠️ WARNING: Mail-Tester < 9/10 (Optimierung erforderlich)
  ✅ PASS: Alle Tests grün
```

---

## 1. Pre-Deployment Validation (manuell via Plesk UI)

### 1.1 DNS Records Check

**Voraussetzung**: Alle DNS-Einträge aus `config-templates/email-dns-records.txt` müssen in Plesk eingetragen sein.

```bash
# Test via Terminal (dig commands):

# 1. SPF Record (Main Domain)
dig txt menschlichkeit-oesterreich.at +short | grep "v=spf1"
# Erwarte: "v=spf1 a mx ip4:IP_TX -all"

# 2. SPF Record (Newsletter Subdomain)
dig txt newsletter.menschlichkeit-oesterreich.at +short | grep "v=spf1"
# Erwarte: "v=spf1 a mx ip4:IP_NEWS -all"

# 3. DKIM Record (Transactional - tx2025q4)
dig txt tx2025q4._domainkey.menschlichkeit-oesterreich.at +short
# Erwarte: "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAoyVW3Kq8..."

# 4. DKIM Record (Newsletter - news2025q4)
dig txt news2025q4._domainkey.newsletter.menschlichkeit-oesterreich.at +short
# Erwarte: "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAmQUzWOFaCdxnn..."

# 5. DMARC Record
dig txt _dmarc.menschlichkeit-oesterreich.at +short
# Erwarte: "v=DMARC1; p=quarantine; sp=quarantine; rua=mailto:dmarc@menschlichkeit-oesterreich.at; ruf=mailto:dmarc@menschlichkeit-oesterreich.at; fo=1; adkim=s; aspf=s; pct=100; ri=86400"

# 6. TLSRPT Record
dig txt _smtp._tls.menschlichkeit-oesterreich.at +short
# Erwarte: "v=TLSRPTv1; rua=mailto:tlsrpt@menschlichkeit-oesterreich.at"

# 7. MTA-STS Policy (optional, via HTTPS)
curl https://mta-sts.menschlichkeit-oesterreich.at/.well-known/mta-sts.txt
# Erwarte: "version: STSv1\nmode: enforce\nmax_age: 604800\nmx: mail.menschlichkeit-oesterreich.at"
```

**Checkliste**:

```yaml
☐ SPF Main Domain: PASS (ip4:IP_TX vorhanden)
☐ SPF Newsletter Subdomain: PASS (ip4:IP_NEWS vorhanden)
☐ DKIM tx2025q4: PASS (Public Key stimmt mit /secrets/email-dkim/tx2025q4_public.txt überein)
☐ DKIM news2025q4: PASS (Public Key stimmt mit /secrets/email-dkim/news2025q4_public.txt überein)
☐ DMARC: PASS (p=quarantine, rua/ruf korrekt)
☐ TLSRPT: PASS (rua=tlsrpt@)
☐ MTA-STS: OPTIONAL (nur wenn Web-Server konfiguriert)
```

### 1.2 Mailbox Validation (Plesk UI)

**Login**: Plesk → Mail → Mailboxes

```yaml
Prüfe Existenz & Quota:
  ☐ peter.schuller@menschlichkeit-oesterreich.at (10 GB)
  ☐ info@menschlichkeit-oesterreich.at (5 GB)
  ☐ support@menschlichkeit-oesterreich.at (10 GB)
  ☐ civimail@menschlichkeit-oesterreich.at (5 GB)
  ☐ bounce@newsletter.menschlichkeit-oesterreich.at (2 GB)
  ☐ logging@menschlichkeit-oesterreich.at (5 GB)
  ☐ dmarc@menschlichkeit-oesterreich.at (20 GB)
  ☐ tlsrpt@menschlichkeit-oesterreich.at (5 GB)
  
Prüfe Credentials:
  ☐ Alle Mailboxen haben Passwörter gesetzt
  ☐ Webmail-Zugang funktioniert (Plesk Webmail)
```

### 1.3 Alias Validation (Plesk UI)

**Login**: Plesk → Mail → Mail Settings → Forwarding

```yaml
Prüfe Weiterleitungen (aus email-aliases.yaml):
  ☐ abuse@ → logging@, peter.schuller@
  ☐ postmaster@ → logging@, peter.schuller@
  ☐ hostmaster@ → logging@, peter.schuller@
  ☐ webmaster@ → support@
  ☐ admin@ → peter.schuller@
  ☐ security@ → peter.schuller@
  ☐ privacy@ → support@
  ☐ datenschutz@ → support@
  ☐ newsletter@ → support@
  ☐ spenden@ → support@
  ☐ mitgliedschaft@ → support@
  ☐ events@ → support@
  ☐ presse@ → info@
  ☐ noreply@ → nur Autoreply (keine Weiterleitung)
```

### 1.4 Autoreply Validation (Plesk UI)

**Login**: Plesk → Mail → [Mailbox/Alias] → Autoresponder

```yaml
Prüfe Autoresponder:
  ☐ abuse@ → abuse_autoreply.txt (Subject: "Re: Ihre Meldung an abuse@...")
  ☐ postmaster@ → postmaster_autoreply.txt (Subject: "Re: Ihre Anfrage an postmaster@...")
  ☐ security@ → security_vdp_autoreply.txt (Subject: "Re: Sicherheitsmeldung an security@...")
  ☐ noreply@ → noreply_autoreply.txt (Subject: "Diese E-Mail-Adresse akzeptiert...")
  
Teste Autoresponder:
  Methode: Sende Test-Mail an abuse@ von externer Adresse
  Erwarte: Autoreply innerhalb 60 Sekunden
```

---

## 2. Authentication Tests (SPF/DKIM/DMARC)

### 2.1 Transactional Mail Test (tx2025q4 Selector)

```bash
# Sende Test-Mail via Plesk oder Command Line:
echo "Subject: SPF/DKIM/DMARC Test - Transactional
From: noreply@menschlichkeit-oesterreich.at
To: peter.schuller@menschlichkeit-oesterreich.at

Dies ist ein DKIM-Authentifizierungstest mit Selector tx2025q4.
" | sendmail -f civimail@menschlichkeit-oesterreich.at peter.schuller@menschlichkeit-oesterreich.at
```

**Validation (Gmail)**:

1. Öffne empfangene Mail in Gmail
2. Klicke auf "..." → "Show Original"
3. Prüfe **Authentication-Results** Header:

```
Authentication-Results: mx.google.com;
  spf=pass (google.com: domain of civimail@menschlichkeit-oesterreich.at designates IP_TX as permitted sender) smtp.mailfrom=civimail@menschlichkeit-oesterreich.at;
  dkim=pass header.i=@menschlichkeit-oesterreich.at header.s=tx2025q4 header.b=AbCdEf12;
  dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=menschlichkeit-oesterreich.at
```

**Erwartete Werte**:

```yaml
☐ SPF: pass (smtp.mailfrom = civimail@menschlichkeit-oesterreich.at)
☐ DKIM: pass (header.s = tx2025q4)
☐ DMARC: pass (p=QUARANTINE)
☐ Alignment: SPF aligned (DMARC aspf=s), DKIM aligned (DMARC adkim=s)
```

### 2.2 Newsletter Mail Test (news2025q4 Selector)

```bash
# Sende Test-Mail von Newsletter-Subdomain:
echo "Subject: SPF/DKIM/DMARC Test - Newsletter
From: newsletter@newsletter.menschlichkeit-oesterreich.at
To: peter.schuller@menschlichkeit-oesterreich.at

Dies ist ein DKIM-Authentifizierungstest mit Selector news2025q4.
" | sendmail -f bounce@newsletter.menschlichkeit-oesterreich.at peter.schuller@menschlichkeit-oesterreich.at
```

**Validation (Gmail)**:

```
Authentication-Results: mx.google.com;
  spf=pass (google.com: domain of bounce@newsletter.menschlichkeit-oesterreich.at designates IP_NEWS as permitted sender) smtp.mailfrom=bounce@newsletter.menschlichkeit-oesterreich.at;
  dkim=pass header.i=@newsletter.menschlichkeit-oesterreich.at header.s=news2025q4 header.b=XyZ789Qw;
  dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=newsletter.menschlichkeit-oesterreich.at
```

**Erwartete Werte**:

```yaml
☐ SPF: pass (smtp.mailfrom = bounce@newsletter....)
☐ DKIM: pass (header.s = news2025q4, header.i = @newsletter.menschlichkeit-oesterreich.at)
☐ DMARC: pass (via Subdomain Policy sp=QUARANTINE)
☐ Alignment: SPF aligned, DKIM aligned
```

---

## 3. Deliverability Tests (Multi-Provider)

### 3.1 Gmail Test

```yaml
Test-Szenario:
  From: newsletter@newsletter.menschlichkeit-oesterreich.at
  To: [persönlicher Gmail-Account]
  Subject: "Deliverability Test - Gmail"
  Body: "HTML + Plain-Text Alternative"
  
Erwartetes Verhalten:
  ☐ Mail landet in INBOX (nicht Spam/Promotions)
  ☐ Authentication-Results: spf=pass, dkim=pass, dmarc=pass
  ☐ Kein "⚠️ Be careful with this message" Warning
  ☐ Bilder werden angezeigt (keine Blockierung)
  
Google Postmaster Tools (nach 24-48h):
  URL: https://postmaster.google.com/
  Domain hinzufügen: newsletter.menschlichkeit-oesterreich.at
  
  Prüfe:
    ☐ IP Reputation: High (grün)
    ☐ Domain Reputation: High
    ☐ Spam Rate: < 0.1%
    ☐ Feedback Loop: Keine Complaints
```

### 3.2 Outlook.com / Office 365 Test

```yaml
Test-Szenario:
  From: newsletter@newsletter.menschlichkeit-oesterreich.at
  To: [persönlicher Outlook.com-Account]
  Subject: "Deliverability Test - Outlook"
  Body: "HTML + Plain-Text Alternative"
  
Erwartetes Verhalten:
  ☐ Mail landet in INBOX (nicht Junk-Ordner)
  ☐ Authentication-Results: spf=pass, dkim=pass, dmarc=pass
  ☐ Sender angezeigt als "Menschlichkeit Österreich <newsletter@...>"
  
Microsoft SNDS (nach Registrierung):
  URL: https://sendersupport.olc.protection.outlook.com/snds/
  IP-Adresse registrieren: IP_NEWS
  
  Prüfe:
    ☐ Status: Green Zone (≥95% Zustellung)
    ☐ Spam Trap Hits: 0
    ☐ Complaint Rate: < 0.1%
```

### 3.3 GMX.at Test (österreichischer Provider)

```yaml
Test-Szenario:
  From: newsletter@newsletter.menschlichkeit-oesterreich.at
  To: [persönlicher GMX.at-Account]
  Subject: "Deliverability Test - GMX Österreich"
  Body: "HTML + Plain-Text Alternative"
  
Erwartetes Verhalten:
  ☐ Mail landet in INBOX (nicht Spam)
  ☐ Authentication-Results sichtbar (GMX zeigt diese)
  ☐ DKIM-Signatur gültig
```

### 3.4 ProtonMail Test (Privacy-focused)

```yaml
Test-Szenario:
  From: newsletter@newsletter.menschlichkeit-oesterreich.at
  To: [persönlicher ProtonMail-Account]
  Subject: "Deliverability Test - ProtonMail"
  
Erwartetes Verhalten:
  ☐ Mail landet in INBOX
  ☐ ProtonMail zeigt "Verified" Badge (DKIM/SPF validated)
  ☐ Ende-zu-Ende-Verschlüsselung nicht gebrochen (Plain-Text OK)
```

---

## 4. mail-tester.com Comprehensive Test

### 4.1 Test-Durchführung

**Schritt 1**: Generiere eindeutige Test-Adresse

```
URL: https://www.mail-tester.com/
Erhalte Test-Email: test-xyz123@srv1.mail-tester.com
```

**Schritt 2**: Sende Test-Mail via CiviMail oder Kommandozeile

```bash
# Via CiviMail:
CiviMail → New Mailing → "Mail-Tester Validation"
From: newsletter@newsletter.menschlichkeit-oesterreich.at
To: test-xyz123@srv1.mail-tester.com
Subject: "Mail-Tester Comprehensive Validation"
Body: [Verwende Production-ähnliches Template mit Footer/Impressum]

# Oder via sendmail:
cat << EOF | sendmail -f newsletter@newsletter.menschlichkeit-oesterreich.at test-xyz123@srv1.mail-tester.com
Subject: Mail-Tester Comprehensive Validation
From: Menschlichkeit Österreich Newsletter <newsletter@newsletter.menschlichkeit-oesterreich.at>
Reply-To: support@menschlichkeit-oesterreich.at
Content-Type: text/html; charset=UTF-8

<!DOCTYPE html>
<html lang="de-AT">
<body>
  <h1>Test-Mail für mail-tester.com</h1>
  <p>Dies ist eine Test-E-Mail zur Validierung der E-Mail-Infrastruktur.</p>
  
  <footer style="margin-top: 30px; padding: 20px; background: #f5f5f5; font-size: 12px;">
    <strong>Menschlichkeit Österreich</strong><br>
    [Adresse]<br>
    <a href="https://menschlichkeit-oesterreich.at/impressum">Impressum</a> | 
    <a href="https://menschlichkeit-oesterreich.at/datenschutz">Datenschutz</a>
  </footer>
</body>
</html>
EOF
```

**Schritt 3**: Prüfe Score auf mail-tester.com

```
URL: https://www.mail-tester.com/ → "Then check your score"
```

### 4.2 Score-Interpretation

```yaml
Scoring:
  10/10: PERFEKT - Deployment genehmigt ✅
  9/10:  GUT - Kleine Optimierungen empfohlen ✅
  8/10:  AKZEPTABEL - Optimierungen erforderlich ⚠️
  < 8:   BLOCKIERT - Fehler beheben vor Deployment ❌

Häufige Punktabzüge:
  -1: Missing DMARC Record (sollte nicht vorkommen)
  -0.5: DMARC Policy nicht streng genug (p=quarantine statt reject)
  -1: Missing reverse DNS (PTR Record) → Provider-Aufgabe
  -0.5: HTML/Text Ratio ungünstig → Template optimieren
  -1: Broken Links im Footer → Links validieren
  -0.5: Missing List-Unsubscribe Header → CiviMail konfigurieren
```

### 4.3 Detaillierte Analyse (mail-tester.com Report)

**SPF Check**:

```yaml
Erwarte:
  ✅ SPF Record found
  ✅ Sender IP authorized (ip4:IP_NEWS)
  ✅ Result: pass
```

**DKIM Check**:

```yaml
Erwarte:
  ✅ DKIM signature valid
  ✅ Selector: news2025q4
  ✅ Domain: newsletter.menschlichkeit-oesterreich.at
  ✅ Body hash matches
```

**DMARC Check**:

```yaml
Erwarte:
  ✅ DMARC Record found
  ✅ Policy: quarantine (später reject)
  ✅ Alignment: SPF + DKIM aligned
  ✅ RUA/RUF configured
```

**Content Analysis**:

```yaml
Erwarte:
  ✅ No spam keywords detected
  ✅ HTML/Text ratio balanced (< 3:1)
  ✅ No broken links
  ✅ Unsubscribe link present (List-Unsubscribe header)
  ✅ Physical address in footer (Impressum)
```

**Blacklist Check**:

```yaml
Erwarte:
  ✅ IP not listed on Spamhaus, SORBS, etc.
  ✅ Domain not listed on URIBL, SURBL
```

---

## 5. Bounce Processing Test (VERP)

### 5.1 Simulated Bounce Test

**Schritt 1**: Sende Test-Mail an ungültige Adresse

```bash
# Via CiviMail:
CiviMail → New Mailing → "Bounce Test"
From: newsletter@newsletter.menschlichkeit-oesterreich.at
To: nonexistent-user-12345@menschlichkeit-oesterreich.at
```

**Schritt 2**: Erwarte Bounce an <bounce@newsletter.menschlichkeit-oesterreich.at>

```
Return-Path: bounce+b.12345.67890.ABCDEF1234@newsletter.menschlichkeit-oesterreich.at
SMTP Code: 550 5.1.1 <nonexistent-user-12345@menschlichkeit-oesterreich.at>: User unknown
```

**Schritt 3**: CiviCRM Bounce Processing

```bash
# Manuell triggern:
drush cvapi Job.execute job=process_bounces

# Oder via CiviCRM UI:
Administer → Scheduled Jobs → "Process Bounces" → Execute Now
```

**Schritt 4**: Validiere Bounce-Verarbeitung

```sql
-- Prüfe in CiviCRM-Datenbank:
SELECT 
  e.email,
  e.on_hold,
  e.hold_date,
  b.bounce_type_id,
  bt.name AS bounce_type
FROM civicrm_email e
LEFT JOIN civicrm_mailing_event_bounce b ON e.id = b.email_id
LEFT JOIN civicrm_mailing_bounce_type bt ON b.bounce_type_id = bt.id
WHERE e.email = 'nonexistent-user-12345@menschlichkeit-oesterreich.at';

-- Erwarte:
-- on_hold = 1 (nach Hard Bounce)
-- bounce_type = 'Syntax' oder 'Invalid'
```

### 5.2 Soft Bounce Retry Test

**Schritt 1**: Simuliere temporären Fehler (Greylisting)

```
Methode: Provider mit Greylisting (z.B. GMX) verwenden
Oder: Temporär Mailbox voll machen (Quota überschreiten)
```

**Schritt 2**: Erwarte Retry-Versuche

```yaml
CiviCRM Retry-Logik:
  Versuch 1: Sofort → 450 Mailbox temporarily unavailable
  Versuch 2: +6h → 450 (immer noch temporär)
  Versuch 3: +24h → 250 OK (erfolgreich zugestellt)
```

**Schritt 3**: Validiere in CiviCRM

```sql
-- Prüfe Mailing Event Queue:
SELECT 
  job_id,
  email_id,
  status,
  time_stamp
FROM civicrm_mailing_event_queue
WHERE email_id = (SELECT id FROM civicrm_email WHERE email = 'test-softbounce@gmx.at')
ORDER BY time_stamp DESC;

-- Erwarte: status = 'Success' nach Retries
```

---

## 6. CiviMail Integration Test (End-to-End)

### 6.1 First Newsletter Campaign (Smoke Test)

**Schritt 1**: Erstelle Test-Mailing in CiviCRM

```yaml
CiviMail → New Mailing:
  Name: "SMOKE TEST - First Newsletter"
  From: Menschlichkeit Österreich Newsletter <newsletter@newsletter.menschlichkeit-oesterreich.at>
  Reply-To: support@menschlichkeit-oesterreich.at
  Subject: "Willkommen zu unserem Newsletter (TEST)"
  
  HTML Body:
    [Verwende civimail-configuration.md Template mit Footer/Impressum]
    
  Recipients:
    Group: "Test Group" (max. 10 interne Test-Adressen)
```

**Schritt 2**: Send Test (vor echtem Versand)

```
CiviMail → Send Test
Test-Empfänger: peter.schuller@menschlichkeit-oesterreich.at
```

**Schritt 3**: Validiere Test-Mail

```yaml
☐ Authentication-Results: spf=pass, dkim=pass (news2025q4), dmarc=pass
☐ List-Unsubscribe Header vorhanden (One-Click + mailto)
☐ Reply-To: support@menschlichkeit-oesterreich.at
☐ Personalisierung funktioniert ({contact.first_name})
☐ Footer mit Impressum, Datenschutz, Abmelde-Link
☐ Plain-Text Alternative vorhanden
```

**Schritt 4**: Schedule Mailing (echte Zustellung)

```
CiviMail → Schedule Delivery → Immediate
```

**Schritt 5**: Monitor Delivery (nach 1h)

```yaml
CiviMail → Reports → Mailing Summary Report:
  ☐ Delivered: 100% (10/10)
  ☐ Bounced: 0%
  ☐ Opened: ≥ 50% (Test-Gruppe)
  ☐ Clicked: > 0% (falls Links im Template)
  ☐ Unsubscribed: 0% (Test-Gruppe)
  ☐ Spam Complaints: 0
```

### 6.2 Unsubscribe Flow Test

**Schritt 1**: Empfange Newsletter in Test-Mailbox

**Schritt 2**: Klicke "Newsletter abbestellen" (One-Click Link)

**Schritt 3**: Erwarte Bestätigungsseite

```
URL: https://menschlichkeit-oesterreich.at/civicrm/mailing/unsubscribe?reset=1&jid=XXX&qid=XXX&h=XXX
Nachricht: "Sie wurden erfolgreich abgemeldet."
```

**Schritt 4**: Validiere Unsubscribe in CiviCRM

```sql
SELECT 
  c.id,
  c.email,
  g.title AS group_name,
  gs.status
FROM civicrm_contact c
JOIN civicrm_email e ON c.id = e.contact_id
JOIN civicrm_group_contact gs ON c.id = gs.contact_id
JOIN civicrm_group g ON gs.group_id = g.id
WHERE e.email = 'test@example.com'
  AND g.name = 'Newsletter';

-- Erwarte: status = 'Removed' oder 'Opt-out'
```

### 6.3 Bounce Automation Test (End-to-End)

**Schritt 1**: Füge ungültige Email zu Test-Gruppe hinzu

```sql
INSERT INTO civicrm_email (contact_id, email, is_primary)
VALUES (9999, 'invalid-bounce-test@nonexistent-domain-xyz.com', 1);
```

**Schritt 2**: Sende Mailing an Gruppe (inkl. ungültiger Email)

**Schritt 3**: Warte auf Bounce-Processing (max. 1h)

```bash
# Manuell triggern wenn Cron nicht aktiv:
drush cvapi Job.execute job=fetch_bounces
drush cvapi Job.execute job=process_bounces
```

**Schritt 4**: Validiere Bounce wurde verarbeitet

```sql
SELECT 
  e.email,
  e.on_hold,
  e.hold_date,
  b.bounce_reason
FROM civicrm_email e
LEFT JOIN civicrm_mailing_event_bounce b ON e.id = b.email_id
WHERE e.email = 'invalid-bounce-test@nonexistent-domain-xyz.com';

-- Erwarte:
-- on_hold = 1
-- bounce_reason = 'Host or domain name not found'
```

---

## 7. Monitoring & Alerting Setup

### 7.1 DMARC Report Monitoring (dmarc@ Mailbox)

**Erwartung**: Innerhalb 24-48h nach ersten Versandaktivitäten

```yaml
DMARC Reports (RUA - Aggregate):
  Empfänger: dmarc@menschlichkeit-oesterreich.at
  Frequenz: Täglich (von Gmail, Outlook, Yahoo, GMX)
  Format: XML (gzipped)
  
Validierung:
  ☐ RUA Reports empfangen (prüfe dmarc@ Mailbox)
  ☐ Reports parsen (via dmarc-analyzer Tool oder manuell)
  ☐ Pass-Rate ≥ 99%
  ☐ Keine "policy_evaluated=reject" Einträge (vor DMARC p=reject Upgrade)
  
Tools für Report-Analyse:
  - Postmark DMARC Digests (https://dmarc.postmarkapp.com/)
  - dmarcian (https://dmarcian.com/)
  - Manuell: Python-Script zum XML-Parsing
```

### 7.2 TLSRPT Monitoring (tlsrpt@ Mailbox)

```yaml
TLS Reports:
  Empfänger: tlsrpt@menschlichkeit-oesterreich.at
  Frequenz: Täglich (bei TLS-Problemen)
  Format: JSON
  
Validierung:
  ☐ TLSRPT Reports empfangen (bei TLS-Fehlern)
  ☐ Keine "failure-details" Einträge
  ☐ Alle Verbindungen: policy_string="tlsv1.2" oder höher
  
Erwartetes Verhalten:
  - Keine Reports = Gut (TLS funktioniert überall)
  - Reports mit failure-details = Problem bei spezifischen Providern
```

### 7.3 Spam Complaint Monitoring (via Feedback Loops)

```yaml
Provider Feedback Loops (FBL):
  Gmail: Automatisch (via ARF - Abuse Reporting Format)
  Outlook: Registrierung erforderlich (JMRP/SNDS)
  Yahoo: Complaint Feedback Loop (CFL) - Registrierung erforderlich
  
Setup:
  1. Gmail: Automatisch aktiv (keine Aktion erforderlich)
  2. Outlook: https://sendersupport.olc.protection.outlook.com/snds/JMRP.aspx
  3. Yahoo: https://senders.yahooinc.com/complaint-feedback-loop/
  
Validierung:
  ☐ FBL-Mails werden an abuse@ weitergeleitet
  ☐ Spam Complaint Rate < 0.1% (via Google Postmaster Tools)
  ☐ Bei Complaints: Sofortiges Opt-Out in CiviCRM
```

---

## 8. Success Criteria & Sign-Off

### 8.1 Deployment Approval Checklist

```yaml
Infrastructure (Phase 1-3):
  ☐ Alle 8 Mailboxen erstellt (Plesk)
  ☐ Alle 14 Aliases konfiguriert (Plesk)
  ☐ DNS Records aktiv (SPF, DKIM, DMARC, TLSRPT)
  ☐ DKIM Keys deployed (tx2025q4, news2025q4)
  ☐ Autoreplies aktiviert (abuse@, postmaster@, security@, noreply@)
  
Authentication (Phase 6):
  ☐ SPF pass (Main Domain + Subdomain)
  ☐ DKIM pass (beide Selektoren tx2025q4, news2025q4)
  ☐ DMARC pass (p=quarantine)
  ☐ Alignment: strict (adkim=s, aspf=s)
  
Deliverability:
  ☐ Gmail: INBOX (kein Spam-Folder)
  ☐ Outlook: INBOX (kein Junk)
  ☐ GMX.at: INBOX
  ☐ mail-tester.com: Score ≥ 9/10
  ☐ Google Postmaster Tools: IP/Domain Reputation "High"
  
CiviMail:
  ☐ Test-Kampagne erfolgreich versendet
  ☐ Bounce Processing funktioniert (VERP)
  ☐ Unsubscribe Flow funktioniert (One-Click)
  ☐ Reports generiert (Delivery, Bounces, Opens, Clicks)
  
Monitoring:
  ☐ DMARC Reports empfangen (dmarc@)
  ☐ TLSRPT Reports aktiviert (tlsrpt@)
  ☐ Spam Complaint Monitoring setup (FBL)
  
Documentation:
  ☐ email-aliases.yaml vollständig
  ☐ email-dns-records.txt aktuell
  ☐ civimail-configuration.md deployment-ready
  ☐ Autoreply-Templates deployed
  ☐ Maintenance-Plan dokumentiert (Phase 7)
```

### 8.2 Rollback-Plan (bei BLOCKERN)

```yaml
Blocker-Szenarien:
  
  1. DMARC Fail (SPF/DKIM nicht aligned):
     Action: DNS-Einträge prüfen, 48h warten, nochmal testen
     Rollback: DMARC Policy temporär auf p=none setzen (Monitoring-Modus)
     
  2. Spam-Folder bei Gmail/Outlook:
     Action: mail-tester.com Report analysieren, Fixes implementieren
     Rollback: Keine Kampagnen versenden bis Score ≥ 9/10
     
  3. Bounce Processing fehlschlägt:
     Action: CiviCRM Cron Jobs prüfen, IMAP-Credentials validieren
     Rollback: Manuelle Bounce-Verarbeitung bis Automation funktioniert
     
  4. IP/Domain auf Blacklist:
     Action: Delisting-Request bei Blacklist-Provider
     Rollback: Alternative IP verwenden (falls verfügbar)
```

### 8.3 Go-Live Approval

```yaml
Approval erforderlich von:
  ☐ Technical Lead: Email-Infrastruktur funktioniert (SPF/DKIM/DMARC)
  ☐ CiviCRM Admin: CiviMail kann Newsletter versenden + Bounces verarbeiten
  ☐ DSGVO Officer: Consent-Management, List-Unsubscribe, Datenschutz-Footer
  ☐ Project Manager: Alle Smoke Tests PASS, keine BLOCKER
  
Deployment-Timeline:
  Tag 1: DNS-Einträge publizieren → 48h Propagation
  Tag 3: Mailboxen + Aliases konfigurieren (Plesk)
  Tag 4: Authentication Tests (SPF/DKIM/DMARC)
  Tag 5: Deliverability Tests (Gmail/Outlook/GMX)
  Tag 6: CiviMail Integration Tests
  Tag 7: First Production Newsletter (max. 100 Empfänger)
  Tag 14: Full Production (alle Newsletter-Abonnenten)
  Tag 30: DMARC Policy Upgrade (quarantine → reject)
```

---

**Ende Smoke Tests & Validation**

**Status**: Bereit für Deployment-Validierung  
**Abhängigkeiten**:

- Phase 1-5 müssen vollständig sein (Mailboxen, Aliases, DNS, CiviMail, Autoreplies)
- Plesk-Zugang erforderlich für manuelle Validierungen
- Test-Mailboxen bei Gmail, Outlook, GMX für Deliverability-Tests

**Next Steps**: Phase 7 - Maintenance & Rotation Planning
