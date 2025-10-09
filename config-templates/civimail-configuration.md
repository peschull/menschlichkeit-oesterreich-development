# CiviMail Konfiguration - DSGVO-konform mit SPF/DKIM/DMARC

**Dokumentversion**: 1.0 (Phase 4 - Email Infrastructure Setup)  
**Erstellt**: 2025-10-07  
**Für**: CiviCRM-Administratoren, Newsletter-Manager

---

## 1. Bulk Sender Konfiguration (Newsletter/Kampagnen)

### 1.1 Newsletter-Absender (Subdomain-Strategie)

**Domain**: `newsletter.menschlichkeit-oesterreich.at`  
**Zweck**: Isolierung von Bulk-Mail (bessere Reputation, DMARC-Compliance)

#### Absender-Header (CiviMail Settings)

```yaml
From Header:
  Display Name: "Menschlichkeit Österreich Newsletter"
  Email: newsletter@newsletter.menschlichkeit-oesterreich.at
  
Envelope-From (Return-Path):
  Pattern: bounce+{TOKEN}@newsletter.menschlichkeit-oesterreich.at
  Type: VERP (Variable Envelope Return Path)
  Generiert von: CiviCRM automatisch
  
Reply-To Header:
  Email: support@menschlichkeit-oesterreich.at
  Zweck: Alle Antworten gehen an Support (nicht an noreply)
```

#### CiviCRM-Einstellungen (Pfad: Administer → CiviMail → Mail Accounts)

```yaml
Outbound Mail Server:
  Type: SMTP
  Server: smtp.menschlichkeit-oesterreich.at
  Port: 587 (STARTTLS) oder 465 (SMTPS)
  Authentication: Login
  Username: newsletter@newsletter.menschlichkeit-oesterreich.at
  Password: [aus Plesk/Mailbox]
  
  DKIM Signing: (serverseitig via Plesk)
    Selector: news2025q4
    Private Key: /secrets/email-dkim/news2025q4_private.pem
    
Bounce Processing:
  Mailbox: bounce@newsletter.menschlichkeit-oesterreich.at
  Protocol: IMAP
  Server: mail.menschlichkeit-oesterreich.at
  Port: 993 (IMAPS)
  Username: bounce@newsletter.menschlichkeit-oesterreich.at
  Password: [aus Plesk]
  Folder: INBOX
  Processing: Jeden Tag 02:00 UTC (Cron Job)
```

---

## 2. Transaktionale E-Mails (CiviCRM-System)

**Use Cases**: Spendenbescheinigungen, Event-Bestätigungen, Membership-Notifications

### 2.1 Absender-Header (CiviCRM System Mails)

```yaml
From Header:
  Display Name: "Menschlichkeit Österreich"
  Email: noreply@menschlichkeit-oesterreich.at
  
Envelope-From (Return-Path):
  Email: civimail@menschlichkeit-oesterreich.at
  Zweck: Separater Bounce-Handler für Transaktional
  
Reply-To Header:
  Email: support@menschlichkeit-oesterreich.at
  Zweck: User können auf Systemmails antworten
```

### 2.2 CiviCRM Mail Account (Transaktional)

```yaml
Outbound Mail Server:
  Type: SMTP
  Server: smtp.menschlichkeit-oesterreich.at
  Port: 587 (STARTTLS)
  Username: civimail@menschlichkeit-oesterreich.at
  Password: [aus Plesk]
  
  DKIM Signing: (serverseitig via Plesk)
    Selector: tx2025q4
    Private Key: /secrets/email-dkim/tx2025q4_private.pem
```

---

## 3. Bounce Handling (VERP + Hard/Soft Bounces)

### 3.1 VERP-Pattern (Variable Envelope Return Path)

**CiviMail generiert automatisch**:

```
bounce+b.12345.67890.ABCDEF1234@newsletter.menschlichkeit-oesterreich.at
         ^     ^      ^
         |     |      └─ Hash/Token (Empfänger-ID verschlüsselt)
         |     └─ Mailing-ID
         └─ Bounce-Typ-Marker (b = bounce)
```

**Zweck**: Automatisches Bounce-Tracking pro Empfänger + Mailing

### 3.2 Bounce-Kategorien & Schwellenwerte

#### Hard Bounces (sofortige Sperrung)

```yaml
Bounce Type: Hard (5.x.x SMTP Codes)
Beispiele:
  - 550 User unknown (Mailbox existiert nicht)
  - 551 User not local (falsche Domain)
  - 554 Transaction failed (permanenter Fehler)

CiviCRM Aktion:
  Nach 1 Hard Bounce: Email auf "On Hold" setzen
  Status: Permanent (keine weitere Zustellung)
  
Prüfung vor jeder Kampagne:
  SELECT COUNT(*) FROM civicrm_email WHERE on_hold = 1;
```

#### Soft Bounces (temporäre Fehler, Retry-Logik)

```yaml
Bounce Type: Soft (4.x.x SMTP Codes)
Beispiele:
  - 450 Mailbox temporarily unavailable
  - 451 Local error in processing
  - 452 Insufficient system storage
  - 421 Service not available (Greylisting)

CiviCRM Retry-Logik:
  Versuch 1: Sofort
  Versuch 2: +6 Stunden
  Versuch 3: +24 Stunden
  Versuch 4: +48 Stunden
  Versuch 5: +72 Stunden
  
  Nach 5 Soft Bounces innerhalb 30 Tage:
    Email auf "On Hold" setzen
    Status: Temporary (kann manuell reaktiviert werden)
```

#### Spam Complaints (via Feedback Loops)

```yaml
Feedback Loop (FBL):
  Provider: Gmail, Outlook, Yahoo, GMX (automatisch)
  Header: Feedback-Type: abuse
  
CiviCRM Aktion:
  Nach 1 Spam Complaint: Email auf "On Hold" + Opt-Out
  Zusätzlich: Unsubscribe aus ALLEN Mailinglisten
  
  Monitoring:
    Spam Complaint Rate < 0.1% (Google Postmaster Tools)
    Bei > 0.3%: Kampagne pausieren, Ursache prüfen
```

---

## 4. List-Unsubscribe Header (DSGVO + RFC 8058)

### 4.1 One-Click Unsubscribe (RFC 8058, Gmail/Yahoo erforderlich)

**CiviMail fügt automatisch hinzu**:

```
List-Unsubscribe: <https://menschlichkeit-oesterreich.at/civicrm/mailing/unsubscribe?reset=1&jid={JOB_ID}&qid={QUEUE_ID}&h={HASH}>
List-Unsubscribe-Post: List-Unsubscribe=One-Click
```

**Wichtig**: HTTPS erforderlich (HTTP wird von Gmail/Yahoo abgelehnt)

### 4.2 mailto: Fallback (ältere Clients)

```
List-Unsubscribe: <mailto:unsubscribe+{TOKEN}@newsletter.menschlichkeit-oesterreich.at>
```

**Einrichtung in CiviCRM**:

1. Gehe zu **Administer → CiviMail → CiviMail Component Settings**
2. Aktiviere "Include Unsubscribe Link"
3. Setze "Unsubscribe URL" auf HTTPS-Link

### 4.3 DSGVO-Anforderungen

```yaml
Unsubscribe-Link:
  Position: Am Ende JEDER E-Mail (Footer)
  Text: "Newsletter abbestellen" (klar erkennbar)
  Bestätigung: Optional (kann sofort abbestellen)
  Response Time: < 48 Stunden (automatisch via CiviCRM)
  
Betroffenenrechte:
  Auskunft: Via CiviCRM Contact-API
  Löschung: Via CiviCRM "Delete Contact" (inkl. Aktivitäten)
  Widerspruch: Via List-Unsubscribe (automatisch)
```

---

## 5. Email-Templates & Best Practices

### 5.1 Template-Header (ALLE CiviMail-Kampagnen)

```html
<!DOCTYPE html>
<html lang="de-AT">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>{mailing.name}</title>
</head>
<body>
  
  <!-- DSGVO: Absender-Informationen (Impressum) -->
  <div style="background: #f5f5f5; padding: 10px; font-size: 12px; color: #666;">
    <strong>Menschlichkeit Österreich</strong><br>
    [Adresse einfügen]<br>
    ZVR: [ZVR-Nummer]<br>
    <a href="https://menschlichkeit-oesterreich.at/impressum">Impressum</a> | 
    <a href="https://menschlichkeit-oesterreich.at/datenschutz">Datenschutz</a>
  </div>
  
  <!-- Personalisierung -->
  <p>Hallo {contact.first_name},</p>
```

### 5.2 Template-Footer (ALLE CiviMail-Kampagnen)

```html
  <!-- DSGVO: Abmelde-Link -->
  <div style="background: #f5f5f5; padding: 20px; margin-top: 30px; font-size: 12px; color: #666;">
    <p>
      Sie erhalten diese E-Mail, weil Sie unseren Newsletter abonniert haben.<br>
      <a href="{action.unsubscribeUrl}">Newsletter abbestellen</a> | 
      <a href="{action.optOutUrl}">Alle E-Mails abbestellen</a> | 
      <a href="{action.forward}">An Freunde weiterleiten</a>
    </p>
    
    <p style="margin-top: 15px;">
      <strong>Kontakt:</strong><br>
      E-Mail: <a href="mailto:support@menschlichkeit-oesterreich.at">support@menschlichkeit-oesterreich.at</a><br>
      Telefon: [Telefonnummer]<br>
      Website: <a href="https://menschlichkeit-oesterreich.at">menschlichkeit-oesterreich.at</a>
    </p>
    
    <!-- Optional: Social Media Links -->
    <p style="margin-top: 15px;">
      <a href="[Facebook-URL]">Facebook</a> | 
      <a href="[Twitter-URL]">Twitter</a> | 
      <a href="[Instagram-URL]">Instagram</a>
    </p>
  </div>
  
</body>
</html>
```

### 5.3 Plain-Text-Alternative (IMMER mitschicken)

```
CiviMail Settings:
  ☑ Always send plain-text version alongside HTML
  
Grund: 
  - Bessere Spam-Scores
  - Barrierefreiheit (Screen Reader)
  - Fallback bei HTML-Blockierung
```

---

## 6. Testing & Validation (vor erster Kampagne)

### 6.1 Test-Checkliste

```yaml
Pre-Launch Tests:
  ☐ Test-Mail an sich selbst senden (CiviMail → "Send Test")
  ☐ Authentication-Results Header prüfen:
      ☐ SPF: pass
      ☐ DKIM: pass
      ☐ DMARC: pass
  ☐ List-Unsubscribe Link funktioniert (One-Click)
  ☐ Reply-To geht an support@
  ☐ Plain-Text-Version vorhanden
  ☐ Impressum & Datenschutz-Links funktionieren
  ☐ Personalisierung korrekt ({contact.first_name})
  
Test-Empfänger:
  ☐ Gmail (Google Workspace)
  ☐ Outlook.com / Office 365
  ☐ GMX.at
  ☐ Proton Mail (Privacy-Check)
  
Spam-Test:
  ☐ mail-tester.com: Score ≥ 9/10
  ☐ Google Postmaster Tools: Reputation "High"
  ☐ Microsoft SNDS: Green Zone
```

### 6.2 Bounce-Processing Test

```bash
# CiviCRM Cron Job manuell ausführen (Test):
drush cvapi Job.execute job=process_bounces

# Oder via CiviCRM UI:
# Administer → System Settings → Scheduled Jobs → "Process Bounces" → Execute Now

# Prüfung:
SELECT email, on_hold, hold_date, reset_date 
FROM civicrm_email 
WHERE on_hold > 0 
ORDER BY hold_date DESC 
LIMIT 10;
```

---

## 7. Monitoring & Metriken

### 7.1 CiviCRM Built-in Reports

```yaml
Reports (Pfad: Reports → Mailing Reports):
  - Mailing Summary Report
    → Open Rate, Click Rate, Bounce Rate, Unsubscribe Rate
    
  - Mailing Detail Report
    → Pro Empfänger: Delivered, Opened, Clicked, Bounced
    
  - Bounce Report
    → Hard/Soft Bounces, Spam Complaints
```

### 7.2 Externe Monitoring-Tools

```yaml
Google Postmaster Tools:
  Domain: newsletter.menschlichkeit-oesterreich.at
  Metriken:
    - IP Reputation (High/Medium/Low/Bad)
    - Domain Reputation
    - Spam Rate (Ziel: < 0.1%)
    - Feedback Loop (FBL) Complaints
    
Microsoft SNDS (Smart Network Data Services):
  IP-Adresse: [aus Plesk]
  Status: Green Zone (Ziel)
  
MXToolbox:
  Blacklist Check: https://mxtoolbox.com/blacklists.aspx
  Frequency: Wöchentlich
  
mail-tester.com:
  Score: ≥ 9/10 (vor jeder großen Kampagne)
```

### 7.3 Ziel-Metriken (KPIs)

```yaml
Newsletter Performance:
  Open Rate: ≥ 20% (Durchschnitt NGO-Sektor)
  Click Rate: ≥ 3%
  Bounce Rate: < 2%
  Unsubscribe Rate: < 0.5%
  Spam Complaint Rate: < 0.1%
  
Deliverability:
  DMARC Pass Rate: ≥ 99%
  SPF Alignment: 100%
  DKIM Alignment: 100%
  IP Reputation: High (Google Postmaster)
  
Engagement:
  Forward Rate: ≥ 1% (viral coefficient)
  Reply Rate: ≥ 0.5% (zu support@)
```

---

## 8. Troubleshooting

### 8.1 Häufige Probleme

#### Problem: Bounces bei Gmail ("550 5.7.1 Unauthenticated email")

```yaml
Ursache: DMARC-Fehlschlag oder SPF-Alignment-Problem
Lösung:
  1. Prüfe Authentication-Results Header:
     dmarc=fail (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=menschlichkeit-oesterreich.at
  2. Stelle sicher: From-Domain = DKIM-Domain = SPF-Domain
  3. Bei Subdomain (newsletter.): DMARC-Subdomain-Policy prüfen (sp=quarantine)
```

#### Problem: Spam-Folder bei Outlook/Hotmail

```yaml
Ursache: Microsoft SNDS in Yellow/Red Zone
Lösung:
  1. Registriere IP bei Microsoft SNDS: https://sendersupport.olc.protection.outlook.com/snds/
  2. Prüfe Spam Trap Hits (Microsoft meldet diese)
  3. Reduziere Versandvolumen temporär (Warmup)
  4. Implementiere Double-Opt-In (falls noch nicht aktiv)
```

#### Problem: DKIM-Signatur ungültig

```yaml
Ursache: Falsche Schlüssel oder DNS-Eintrag
Lösung:
  1. Prüfe DNS TXT Record:
     dig txt tx2025q4._domainkey.menschlichkeit-oesterreich.at
  2. Vergleiche Public Key mit /secrets/email-dkim/tx2025q4_public.txt
  3. Teste DKIM: https://appmaildev.com/en/dkim
  4. Bei Rotation: 48h warten nach DNS-Änderung
```

---

## 9. DSGVO-Compliance Checklist

```yaml
Rechtsgrundlage:
  ☐ Art. 6 Abs. 1 lit. a DSGVO (Einwilligung)
  ☐ Double-Opt-In implementiert (CiviCRM: Confirmation Page)
  ☐ Opt-In-Zeitstempel gespeichert (civicrm_subscription_history)
  
Betroffenenrechte:
  ☐ Auskunftsrecht: Via CiviCRM Contact-API
  ☐ Löschungsrecht: Via CiviCRM "Delete Contact" (inkl. Aktivitäten)
  ☐ Widerspruchsrecht: Via List-Unsubscribe (One-Click)
  ☐ Datenportabilität: Via CiviCRM Export (CSV/JSON)
  
Datensparsamkeit:
  ☐ Nur notwendige Felder: Email, Name (optional: Anrede)
  ☐ KEINE Tracking-Pixel ohne Consent
  ☐ Click-Tracking: Nur mit Consent (CiviCRM Setting)
  
Speicherdauer:
  ☐ Aktive Newsletter-Abonnenten: Unbegrenzt (mit Consent)
  ☐ Unsubscribed: 90 Tage Retention (Bounce-History)
  ☐ Bounced (Hard): 90 Tage, dann Anonymisierung
  
Auftragsverarbeitung:
  ☐ AVV mit Mailserver-Provider (Plesk-Hoster)
  ☐ AVV mit CiviCRM-Cloud (falls gehostet)
  ☐ Server-Standort: EU (DSGVO Art. 44-50)
```

---

## 10. Nächste Schritte (Deployment)

### 10.1 CiviCRM Konfiguration (manuell via UI)

```yaml
1. Mail Accounts einrichten:
   Pfad: Administer → CiviMail → Mail Accounts
   
   Account 1: Newsletter (Bulk)
     Name: "Newsletter Bulk Sender"
     Server: smtp.menschlichkeit-oesterreich.at:587
     Username: newsletter@newsletter.menschlichkeit-oesterreich.at
     Password: [aus Plesk]
     Is Default: Yes
     
   Account 2: Transactional
     Name: "System Transactional"
     Server: smtp.menschlichkeit-oesterreich.at:587
     Username: civimail@menschlichkeit-oesterreich.at
     Password: [aus Plesk]
     Is Default: No (nur für System Mails)

2. Bounce Processing:
   Pfad: Administer → CiviMail → Mail Accounts → Edit Bounce Account
   
   Server: mail.menschlichkeit-oesterreich.at:993 (IMAPS)
   Username: bounce@newsletter.menschlichkeit-oesterreich.at
   Password: [aus Plesk]
   Polling Frequency: Every hour (Cron Job)

3. Scheduled Jobs aktivieren:
   Pfad: Administer → System Settings → Scheduled Jobs
   
   ☐ Process Bounces (Hourly)
   ☐ Fetch Bounces (Every 15 min)
   ☐ Send Scheduled Mailings (Every 15 min)

4. Component Settings:
   Pfad: Administer → CiviMail → CiviMail Component Settings
   
   ☐ Enable CiviMail
   ☐ Track Replies: Yes (via support@)
   ☐ Include Unsubscribe Link: Yes
   ☐ Click-through Tracking: Yes (mit DSGVO-Consent!)
```

### 10.2 First Campaign Test (Smoke Test)

```yaml
1. Erstelle Test-Mailing:
   Mailings → New Mailing
   Name: "TEST - Infrastructure Validation"
   From: newsletter@newsletter.menschlichkeit-oesterreich.at
   Reply-To: support@menschlichkeit-oesterreich.at
   
2. Test-Empfänger:
   - peter.schuller@menschlichkeit-oesterreich.at
   - [Externe Gmail/Outlook Accounts für Deliverability-Test]
   
3. Versende Test:
   CiviMail → Send Test → Prüfe Inbox + Spam-Folder
   
4. Validiere Authentication:
   Gmail: "Show Original" → Authentication-Results
   Erwarte: spf=pass dkim=pass dmarc=pass
   
5. Bounce-Processing:
   48h warten → Prüfe bounce@ Mailbox (sollte leer sein)
```

---

**Ende CiviMail Konfigurationsdokumentation**

**Status**: Bereit für Deployment (nach DNS-Konfiguration in Phase 3)  
**Abhängigkeiten**:

- DNS Records (email-dns-records.txt) müssen in Plesk eingetragen sein
- Mailboxen (newsletter@, civimail@, bounce@, support@) müssen in Plesk existieren
- DKIM Keys (tx2025q4, news2025q4) müssen im Mailserver konfiguriert sein

**Validierung**: Via Phase 6 Smoke Tests (siehe nächste Dokumentation)
