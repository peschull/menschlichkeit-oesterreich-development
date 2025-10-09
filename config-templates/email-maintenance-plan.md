# Email Infrastructure Maintenance & Rotation Plan

**Dokumentversion**: 1.0 (Phase 7 - Wartung & Langzeitplanung)  
**Erstellt**: 2025-10-07  
**Gültigkeit**: 12 Monate (Review: 2026 Q1)  
**Verantwortlich**: Technical Lead + CiviCRM Admin

---

## 🎯 Wartungsziele

```yaml
Ziele:
  1. DKIM Key Rotation (halbjährlich Q1 + Q3)
  2. DMARC Policy Progression (quarantine → reject → BIMI)
  3. Mailserver Reputation Monitoring (kontinuierlich)
  4. DSGVO-Compliance Audits (quartalsweise)
  5. Performance Optimization (monatlich)
  6. Disaster Recovery Readiness (Backup-Validierung)
  
KPIs:
  - DMARC Pass Rate: ≥ 99%
  - mail-tester Score: ≥ 9/10
  - Spam Complaint Rate: < 0.1%
  - Bounce Rate: < 2%
  - TLS Success Rate: ≥ 98%
  - DSGVO-Compliance: 100%
```

---

## 1. DKIM Key Rotation Schedule

### 1.1 Rotation-Kalender 2025-2026

```yaml
Rotation-Events:
  Q1 2025 (März 2025):
    Datum: 2025-03-15 (Mo-Fr)
    Keys: tx2025q1, news2025q1
    Status: INITIAL DEPLOYMENT (bereits aktiv als tx2025q4, news2025q4)
    
  Q3 2025 (September 2025):
    Datum: 2025-09-15
    Keys: tx2025q3, news2025q3
    Status: ERSTE ROTATION (nach 6 Monaten)
    
  Q1 2026 (März 2026):
    Datum: 2026-03-15
    Keys: tx2026q1, news2026q1
    Status: ZWEITE ROTATION
    
  Q3 2026 (September 2026):
    Datum: 2026-09-15
    Keys: tx2026q3, news2026q3
    Status: DRITTE ROTATION

Naming Convention:
  Pattern: {type}{year}q{quarter}
  Examples:
    - tx2025q3 = Transactional Mail, 2025, Q3
    - news2025q3 = Newsletter/Bulk Mail, 2025, Q3
```

### 1.2 Rotation-Prozedur (Step-by-Step)

**Timeline**: 7 Tage vor Rotation starten

#### **Tag -7 (Vorbereitung)**

```bash
# 1. Neue DKIM Keypairs generieren
cd /workspaces/menschlichkeit-oesterreich-development/secrets/email-dkim/

# Transactional Key (z.B. tx2025q3)
openssl genrsa -out tx2025q3_private.pem 2048
chmod 600 tx2025q3_private.pem
openssl rsa -in tx2025q3_private.pem -pubout -outform DER | base64 -w 0 > tx2025q3_public.txt

# Newsletter Key (z.B. news2025q3)
openssl genrsa -out news2025q3_private.pem 2048
chmod 600 news2025q3_private.pem
openssl rsa -in news2025q3_private.pem -pubout -outform DER | base64 -w 0 > news2025q3_public.txt

# Validierung
ls -lah *2025q3*
# Erwarte: 
# -rw------- 1 user user 1.7K tx2025q3_private.pem
# -rw-r--r-- 1 user user  392 tx2025q3_public.txt
# -rw------- 1 user user 1.7K news2025q3_private.pem
# -rw-r--r-- 1 user user  392 news2025q3_public.txt
```

#### **Tag -5 (DNS Publikation - BEIDE Keys parallel)**

```bash
# 2. DNS TXT Records HINZUFÜGEN (alte Keys bleiben aktiv!)
# Plesk → Domains → menschlichkeit-oesterreich.at → DNS Settings

# NEUER Transactional Selector (tx2025q3):
# Name: tx2025q3._domainkey.menschlichkeit-oesterreich.at
# Type: TXT
# Value: "v=DKIM1; k=rsa; p=[INHALT von tx2025q3_public.txt]"

# NEUER Newsletter Selector (news2025q3):
# Name: news2025q3._domainkey.newsletter.menschlichkeit-oesterreich.at
# Type: TXT
# Value: "v=DKIM1; k=rsa; p=[INHALT von news2025q3_public.txt]"

# WICHTIG: ALTE Keys (tx2025q1, news2025q1) bleiben aktiv!
# Parallelbetrieb ermöglicht Zero-Downtime-Rotation
```

#### **Tag -3 (DNS Propagation Validation)**

```bash
# 3. DNS-Propagation prüfen (weltweit)
dig txt tx2025q3._domainkey.menschlichkeit-oesterreich.at +short
dig txt news2025q3._domainkey.newsletter.menschlichkeit-oesterreich.at +short

# Online-Check (mehrere DNS-Resolver):
# https://mxtoolbox.com/dkim.aspx
# Eingabe: tx2025q3:menschlichkeit-oesterreich.at
# Erwarte: "DKIM record published successfully"

# Google DNS-Check:
dig @8.8.8.8 txt tx2025q3._domainkey.menschlichkeit-oesterreich.at +short
# Erwarte: "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0..."
```

#### **Tag 0 (Rotation Execution - Failover-Window)**

```bash
# 4. Plesk Mail Settings aktualisieren (DKIM Signing)
# Plesk → Mail → Mail Settings → DKIM Spam Protection

# Transactional Domain (menschlichkeit-oesterreich.at):
# - Enable DKIM: ✅
# - Selector: tx2025q3 (ÄNDERN von tx2025q1)
# - Private Key: [INHALT von tx2025q3_private.pem kopieren]
# - Apply → Test (Testmail an check-auth@verifier.port25.com)

# Newsletter Subdomain (newsletter.menschlichkeit-oesterreich.at):
# - Enable DKIM: ✅
# - Selector: news2025q3 (ÄNDERN von news2025q1)
# - Private Key: [INHALT von news2025q3_private.pem kopieren]
# - Apply → Test

# Validierung:
# Sende Testmail via sendmail:
echo "Subject: DKIM Rotation Test
From: civimail@menschlichkeit-oesterreich.at
To: peter.schuller@menschlichkeit-oesterreich.at

DKIM Rotation zu tx2025q3 erfolgreich.
" | sendmail -f civimail@menschlichkeit-oesterreich.at peter.schuller@menschlichkeit-oesterreich.at

# Prüfe Authentication-Results Header:
# dkim=pass header.s=tx2025q3 header.i=@menschlichkeit-oesterreich.at
```

#### **Tag +1 (Post-Rotation Validation)**

```bash
# 5. Smoke Tests (siehe email-smoke-tests.md)
# - Authentication Tests (Section 2)
# - mail-tester.com Test (Section 4)
# - CiviMail Integration Test (Section 6)

# Erwartete Ergebnisse:
☐ SPF: pass
☐ DKIM: pass (header.s = tx2025q3 / news2025q3)
☐ DMARC: pass
☐ mail-tester: ≥ 9/10
☐ Keine Delivery-Probleme
```

#### **Tag +7 (Alte Keys deaktivieren)**

```bash
# 6. Alte DNS TXT Records ENTFERNEN (7 Tage nach Rotation)
# Plesk → Domains → menschlichkeit-oesterreich.at → DNS Settings

# LÖSCHEN:
# - tx2025q1._domainkey.menschlichkeit-oesterreich.at (TXT)
# - news2025q1._domainkey.newsletter.menschlichkeit-oesterreich.at (TXT)

# BEHALTEN:
# - tx2025q3._domainkey.menschlichkeit-oesterreich.at (NEU, aktiv)
# - news2025q3._domainkey.newsletter.menschlichkeit-oesterreich.at (NEU, aktiv)
```

#### **Tag +90 (Archivierung)**

```bash
# 7. Alte Private Keys archivieren (90 Tage Retention)
cd /workspaces/menschlichkeit-oesterreich-development/secrets/email-dkim/

# Archiv erstellen
tar -czf archive-2025q1-dkim-keys.tar.gz tx2025q1_*.pem news2025q1_*.pem
gpg --symmetric --cipher-algo AES256 archive-2025q1-dkim-keys.tar.gz
# Passwort: [SICHER SPEICHERN in Password Manager]

# Original-Keys löschen (nur verschlüsseltes Archiv behalten)
rm tx2025q1_private.pem tx2025q1_public.txt
rm news2025q1_private.pem news2025q1_public.txt

# Archiv-Verzeichnis
mkdir -p archive/2025-q1/
mv archive-2025q1-dkim-keys.tar.gz.gpg archive/2025-q1/

# Dokumentation
echo "Rotated 2025-Q1 → 2025-Q3 on $(date)" >> DKIM_ROTATION_LOG.txt
```

### 1.3 Rotation-Checkliste (Template)

```yaml
DKIM Rotation Checklist - {YEAR} Q{QUARTER}:
  
  Pre-Rotation (Tag -7):
    ☐ Neue Keypairs generiert (tx{YEAR}q{QUARTER}, news{YEAR}q{QUARTER})
    ☐ File Permissions korrekt (600 für .pem)
    ☐ Public Keys extrahiert (.txt Dateien)
    
  DNS Publikation (Tag -5):
    ☐ DNS TXT Records hinzugefügt (beide Selektoren)
    ☐ Alte Records NICHT gelöscht (Parallelbetrieb)
    
  Propagation (Tag -3):
    ☐ DNS weltweit propagiert (dig @8.8.8.8)
    ☐ mxtoolbox.com Validation PASS
    
  Rotation (Tag 0):
    ☐ Plesk DKIM Selector aktualisiert (Main Domain)
    ☐ Plesk DKIM Selector aktualisiert (Newsletter Subdomain)
    ☐ Testmail gesendet (Authentication-Results prüfen)
    
  Validation (Tag +1):
    ☐ mail-tester.com ≥ 9/10
    ☐ DKIM pass (neuer Selector)
    ☐ CiviMail Kampagnen funktionieren
    
  Cleanup (Tag +7):
    ☐ Alte DNS TXT Records gelöscht
    ☐ Keine DKIM-Failures in DMARC Reports
    
  Archivierung (Tag +90):
    ☐ Alte Private Keys verschlüsselt archiviert
    ☐ Original-Dateien gelöscht
    ☐ DKIM_ROTATION_LOG.txt aktualisiert
```

---

## 2. DMARC Policy Progression Timeline

### 2.1 Phase 1: Monitoring (p=quarantine) - AKTIV

**Status**: Deployment (Tag 0)  
**Duration**: 30 Tage  
**Policy**: `p=quarantine`

```dns
_dmarc.menschlichkeit-oesterreich.at IN TXT "v=DMARC1; p=quarantine; sp=quarantine; rua=mailto:dmarc@menschlichkeit-oesterreich.at; ruf=mailto:dmarc@menschlichkeit-oesterreich.at; fo=1; adkim=s; aspf=s; pct=100; ri=86400"
```

**Monitoring-Tasks (täglich)**:

```yaml
Tag 1-7:
  ☐ DMARC RUA Reports prüfen (dmarc@)
  ☐ Pass Rate berechnen: (pass / total) * 100
  ☐ Ziel: ≥ 99%
  ☐ Bei Failures: Source-IP analysieren, SPF/DKIM fixen
  
Tag 8-14:
  ☐ Google Postmaster Tools: Domain Reputation = "High"
  ☐ Microsoft SNDS: Green Zone (≥95%)
  ☐ Spam Complaint Rate: < 0.1%
  
Tag 15-21:
  ☐ Trend-Analyse: Pass Rate stabil ≥ 99%?
  ☐ Keine Delivery-Probleme (Gmail/Outlook/GMX)
  ☐ Bounce Rate: < 2%
  
Tag 22-30:
  ☐ Final Review: Alle KPIs grün?
  ☐ Entscheidung: Upgrade zu p=reject (Phase 2)
  ☐ Stakeholder Approval (Technical Lead + Management)
```

### 2.2 Phase 2: Enforcement (p=reject) - GEPLANT

**Status**: Upgrade nach 30 Tagen Monitoring  
**Duration**: Permanent (bis BIMI-Aktivierung)  
**Policy**: `p=reject`

```dns
# DNS Update (Tag 30):
_dmarc.menschlichkeit-oesterreich.at IN TXT "v=DMARC1; p=reject; sp=reject; rua=mailto:dmarc@menschlichkeit-oesterreich.at; ruf=mailto:dmarc@menschlichkeit-oesterreich.at; fo=1; adkim=s; aspf=s; pct=100; ri=86400"
```

**Upgrade-Prozedur**:

```yaml
Pre-Upgrade Validation (Tag 28-29):
  ☐ DMARC Pass Rate letzte 7 Tage: ≥ 99%
  ☐ Keine SPF/DKIM-Failures in RUA Reports
  ☐ Alle Email-Quellen authentifizieren (kein 3rd-Party ohne SPF)
  ☐ CiviMail funktioniert einwandfrei
  
Upgrade Execution (Tag 30):
  1. Plesk → DNS → TXT Record "_dmarc" editieren
  2. Policy ändern: p=quarantine → p=reject
  3. Subdomain Policy: sp=quarantine → sp=reject
  4. Speichern → 48h DNS Propagation
  
Post-Upgrade Monitoring (Tag 31-37):
  ☐ RUA Reports analysieren (policy_evaluated=reject?)
  ☐ Deliverability-Tests (Gmail/Outlook/GMX - kein Spam-Folder)
  ☐ Spam Complaint Rate unverändert (< 0.1%)
  ☐ Bounce Rate unverändert (< 2%)
  
Rollback-Plan (bei Problemen):
  - Symptom: Emails werden rejected (policy_evaluated=reject in RUA)
  - Action: p=reject → p=quarantine (temporär)
  - Root Cause: SPF/DKIM-Failure analysieren
  - Fix: DNS/Plesk/CiviMail Configuration korrigieren
  - Retry: Nach 7 Tagen stabiler p=quarantine
```

### 2.3 Phase 3: BIMI Activation (Optional) - ZUKUNFT

**Status**: Deferred (benötigt VMC Certificate)  
**Timeline**: Frühestens 2026 Q2  
**Voraussetzungen**:

```yaml
Required:
  ☐ DMARC p=reject aktiv (mind. 30 Tage)
  ☐ Pass Rate ≥ 99.5%
  ☐ VMC (Verified Mark Certificate) von DigiCert/Entrust
    - Kosten: €1000-2000/Jahr
    - Trademark-Nachweis erforderlich
  ☐ Logo optimiert (SVG Tiny-PS Format)
  ☐ BIMI DNS TXT Record publiziert
  
Optional (empfohlen):
  ☐ Logo im Seitenverhältnis 1:1 (Quadrat)
  ☐ Trademark-Registrierung in Österreich (EUIPO)
  ☐ Brand-Monitoring Setup (Phishing-Schutz)
```

**BIMI DNS Record (Beispiel)**:

```dns
default._bimi.menschlichkeit-oesterreich.at IN TXT "v=BIMI1; l=https://menschlichkeit-oesterreich.at/assets/logo-bimi.svg; a=https://menschlichkeit-oesterreich.at/assets/vmc-certificate.pem"
```

**Return on Investment (ROI) - Abwägung**:

```yaml
Pros:
  ✅ Logo-Display in Gmail/Yahoo (Brand Recognition)
  ✅ Trust-Signal für Empfänger (VMC = verified)
  ✅ Phishing-Schutz (nur echte Mails zeigen Logo)
  
Cons:
  ❌ Hohe Kosten (€1000-2000/Jahr für VMC)
  ❌ Trademark-Nachweis erforderlich (Legal-Aufwand)
  ❌ Nur Gmail/Yahoo/Apple Mail (Outlook nicht)
  ❌ ROI fraglich für NGO (kein kommerzieller Vorteil)
  
Empfehlung:
  Postpone BIMI bis:
    - Budget verfügbar (€2000/Jahr)
    - Trademark registriert (EUIPO)
    - p=reject stabil seit 6 Monaten
  Alternative: Fokus auf Content & Engagement (ROI höher)
```

---

## 3. Mailserver Reputation Monitoring

### 3.1 Google Postmaster Tools (Gmail)

**Setup** (einmalig):

```yaml
URL: https://postmaster.google.com/
Domain hinzufügen:
  1. Anmeldung mit Google Account
  2. "Add Domain" → newsletter.menschlichkeit-oesterreich.at
  3. DNS TXT Verification:
     Name: google-site-verification
     Value: [Google-generierter Code]
  4. Verify → Dashboard verfügbar nach 24-48h
```

**Monitoring-KPIs** (wöchentlich):

```yaml
Dashboard Metrics:
  
  IP Reputation:
    Ziel: "High" (grün)
    ⚠️ Warning: "Medium" (gelb) → Spam-Rate prüfen
    ❌ Critical: "Low/Bad" (rot) → Sofortiger Versand-Stopp
    
  Domain Reputation:
    Ziel: "High" (grün)
    Factors: SPF/DKIM/DMARC Alignment, User Engagement
    
  Spam Rate:
    Ziel: < 0.1%
    ⚠️ Warning: 0.1% - 0.3%
    ❌ Critical: > 0.3%
    
  Feedback Loop (Spam Complaints):
    Ziel: < 10 Complaints/Woche
    Action: Bei > 10 → Opt-Out-Prozess prüfen
    
  Encryption (TLS):
    Ziel: 100% TLS 1.2+
    Validation: TLSRPT Reports bestätigen
    
  Authentication (SPF/DKIM/DMARC):
    Ziel: 100% Pass
    Action: Bei Failures → DNS/Plesk Configuration fixen
```

**Alert-Triggers** (automatische Benachrichtigung):

```yaml
Critical Alerts (sofortiger Action Required):
  - IP Reputation: "Low" oder "Bad"
  - Spam Rate: > 0.3%
  - DMARC Fail Rate: > 1%
  
Notifications:
  - Email: peter.schuller@menschlichkeit-oesterreich.at
  - Slack: #email-alerts (falls konfiguriert)
  - Action: Versand pausieren bis Problem gelöst
```

### 3.2 Microsoft SNDS (Outlook.com)

**Setup** (einmalig):

```yaml
URL: https://sendersupport.olc.protection.outlook.com/snds/
IP-Registrierung:
  1. Anmeldung mit Microsoft Account
  2. "Request Access" → IP_NEWS eintragen
  3. Email-Verifizierung (an postmaster@menschlichkeit-oesterreich.at)
  4. Dashboard verfügbar nach 24h
```

**Monitoring-KPIs** (wöchentlich):

```yaml
SNDS Data Points:
  
  Data Available:
    Ziel: "Yes" (IP sendet Mails an Outlook)
    Problem: "No" → Zu wenig Traffic (normal bei NGO)
    
  Trap Hits (Spam Traps):
    Ziel: 0 Trap Hits
    ⚠️ Warning: 1-5 Hits/Monat
    ❌ Critical: > 5 Hits/Monat → Listen-Hygiene prüfen
    
  Complaint Rate:
    Ziel: < 0.1% (Green Zone ≥95% Delivery)
    ⚠️ Warning: 0.1% - 0.3% (Yellow Zone)
    ❌ Critical: > 0.3% (Red Zone → Versand blockiert)
    
  Filter Result:
    Ziel: "Green" (≥95% Inbox Delivery)
    Trend: Über 7-Tage-Mittelwert analysieren
```

### 3.3 DMARC Aggregate Reports (RUA)

**Automated Parsing** (via Python-Script):

```python
# /scripts/dmarc-report-analyzer.py
import gzip
import xml.etree.ElementTree as ET
from email import message_from_file

def parse_dmarc_reports(mailbox_path="/var/mail/dmarc"):
    """
    Parst DMARC Aggregate Reports (RUA) aus Mailbox.
    
    Returns:
        dict: {
            'total_emails': int,
            'pass_count': int,
            'fail_count': int,
            'pass_rate': float,
            'sources': [{'ip': str, 'count': int, 'result': str}]
        }
    """
    reports = []
    
    # Mailbox lesen (IMAP oder lokal)
    # XML-Anhänge extrahieren (gzipped)
    # Parsen: <record><row><policy_evaluated><dkim>/<spf></policy_evaluated></row></record>
    
    total = 0
    passed = 0
    failed = 0
    sources = {}
    
    for report_xml in reports:
        tree = ET.fromstring(report_xml)
        for record in tree.findall('.//record'):
            source_ip = record.find('.//source_ip').text
            dkim_result = record.find('.//policy_evaluated/dkim').text
            spf_result = record.find('.//policy_evaluated/spf').text
            count = int(record.find('.//count').text)
            
            total += count
            
            if dkim_result == 'pass' or spf_result == 'pass':
                passed += count
            else:
                failed += count
                
            sources[source_ip] = sources.get(source_ip, 0) + count
    
    return {
        'total_emails': total,
        'pass_count': passed,
        'fail_count': failed,
        'pass_rate': (passed / total * 100) if total > 0 else 0,
        'sources': [{'ip': ip, 'count': count} for ip, count in sources.items()]
    }

# Wöchentlicher Cron-Job:
# 0 9 * * MON python3 /scripts/dmarc-report-analyzer.py | mail -s "DMARC Weekly Report" peter.schuller@menschlichkeit-oesterreich.at
```

**Manual Report Analysis** (für Troubleshooting):

```yaml
DMARC Report Anatomy:
  
  Report Metadata:
    - org_name: gmail.com / outlook.com / gmx.net
    - date_range: begin/end timestamps
    
  Policy Published:
    - domain: menschlichkeit-oesterreich.at
    - p: quarantine / reject
    - sp: quarantine / reject (Subdomain Policy)
    - adkim: s (strict alignment)
    - aspf: s (strict alignment)
    
  Records:
    - source_ip: Absender-IP (z.B. IP_NEWS)
    - count: Anzahl Emails von dieser IP
    - policy_evaluated:
        - dkim: pass / fail
        - spf: pass / fail
        - disposition: none / quarantine / reject
    - auth_results:
        - dkim domain: menschlichkeit-oesterreich.at
        - dkim selector: news2025q4
        - dkim result: pass / fail (+ Fehlergrund)
        - spf domain: newsletter.menschlichkeit-oesterreich.at
        - spf result: pass / fail

Failure Investigation:
  1. Identifiziere Source-IP mit Failures
  2. Prüfe ob IP autorisiert (SPF Record)
  3. Validiere DKIM Signature (Selector korrekt?)
  4. Checke Alignment (From-Domain = SPF/DKIM-Domain?)
  5. Fixe DNS/Plesk Configuration
```

### 3.4 Blacklist Monitoring (automatisiert)

**Tools** (wöchentlich via Cron):

```bash
# /scripts/blacklist-check.sh
#!/bin/bash

IP_TX="[REPLACE_WITH_IP_TX]"
IP_NEWS="[REPLACE_WITH_IP_NEWS]"
DOMAIN="menschlichkeit-oesterreich.at"

echo "=== Blacklist Check $(date) ==="

# IP-basierte Blacklists
for BLACKLIST in zen.spamhaus.org bl.spamcop.net dnsbl.sorbs.net; do
  REVERSE_IP=$(echo $IP_NEWS | awk -F. '{print $4"."$3"."$2"."$1}')
  RESULT=$(dig +short $REVERSE_IP.$BLACKLIST)
  
  if [ -n "$RESULT" ]; then
    echo "❌ LISTED: $IP_NEWS on $BLACKLIST (Result: $RESULT)"
    # Alert senden
  else
    echo "✅ OK: $IP_NEWS not listed on $BLACKLIST"
  fi
done

# Domain-basierte Blacklists (URIBL, SURBL)
for BLACKLIST in multi.uribl.com multi.surbl.org; do
  RESULT=$(dig +short $DOMAIN.$BLACKLIST)
  
  if [ -n "$RESULT" ]; then
    echo "❌ LISTED: $DOMAIN on $BLACKLIST (Result: $RESULT)"
  else
    echo "✅ OK: $DOMAIN not listed on $BLACKLIST"
  fi
done

# Cron: 0 10 * * MON /scripts/blacklist-check.sh | mail -s "Weekly Blacklist Check" peter.schuller@menschlichkeit-oesterreich.at
```

**Delisting-Prozess** (bei Blacklist-Eintrag):

```yaml
Spamhaus ZEN:
  URL: https://www.spamhaus.org/lookup/
  Process:
    1. IP eingeben → Listungsgrund anzeigen
    2. "Request Removal" → Formular ausfüllen
    3. Begründung: False Positive / Compromised Account Fixed / etc.
    4. Warten auf Delisting (24-48h)
  
SORBS:
  URL: http://www.sorbs.net/lookup.shtml
  Process:
    1. IP eingeben
    2. Delisting: $50 Fee ODER 24h automatisch (bei Dynamic-IP-Listing)
    3. Empfehlung: 24h warten, kein Payment
  
SpamCop:
  URL: https://www.spamcop.net/bl.shtml
  Process:
    1. IP eingeben
    2. Auto-Delisting nach 24h ohne neue Spam-Reports
    3. Keine manuelle Delisting-Option

URIBL/SURBL (Domain-Blacklists):
  Process:
    1. Spam-Reports analysieren (woher kamen Complaints?)
    2. Opt-Out-Prozess verbessern (List-Unsubscribe)
    3. Listen-Hygiene (alte/ungültige Emails entfernen)
    4. Delisting-Request via https://admin.uribl.com/
```

---

## 4. DSGVO-Compliance Audits (Quarterly)

### 4.1 Audit-Kalender 2025

```yaml
Q1 2025 (April):
  Datum: 2025-04-15
  Fokus: Initial Deployment Compliance Review
  Checkliste:
    ☐ Consent-Management funktioniert (CiviCRM)
    ☐ List-Unsubscribe One-Click implementiert
    ☐ Datenschutzerklärung aktualisiert (Newsletter-Abschnitt)
    ☐ Impressum in jedem Newsletter-Footer
    ☐ Data Retention Policy dokumentiert (3 Jahre)
    ☐ Betroffenenrechte implementiert (Auskunft, Löschung, Widerruf)
  
Q2 2025 (Juli):
  Datum: 2025-07-15
  Fokus: Bounce Processing & Automated Opt-Outs
  Checkliste:
    ☐ Hard Bounces führen zu automatischem Opt-Out (On Hold)
    ☐ Soft Bounces nach 7 Tagen → On Hold
    ☐ Bounce-Logs enthalten keine PII (nur Hashes)
    ☐ DMARC/TLSRPT Reports analysiert (Privacy-konform)
  
Q3 2025 (Oktober):
  Datum: 2025-10-15
  Fokus: Third-Party Processors (CiviCRM, Plesk)
  Checkliste:
    ☐ Auftragsverarbeitungs-Vertrag (AVV) mit Plesk-Hoster
    ☐ CiviCRM-Extensions DSGVO-konform (keine US-Clouds)
    ☐ Email-Tracking: IP-Adressen anonymisiert (falls aktiviert)
    ☐ Consent für Tracking dokumentiert
  
Q4 2025 (Januar 2026):
  Datum: 2026-01-15
  Fokus: Annual Review & External Audit Preparation
  Checkliste:
    ☐ Verzeichnis von Verarbeitungstätigkeiten (VVT) aktualisiert
    ☐ Datenschutz-Folgenabschätzung (DSFA) für Newsletter-System
    ☐ Technische und organisatorische Maßnahmen (TOM) dokumentiert
    ☐ Externe Audit (falls NGO-Förderung erfordert)
```

### 4.2 Consent Management Validation

**CiviCRM Consent-Felder prüfen**:

```sql
-- Alle Newsletter-Kontakte mit Consent-Status:
SELECT 
  c.id,
  c.display_name,
  e.email,
  g.title AS group_name,
  gs.status AS subscription_status,
  gs.added_by_id AS consent_source,
  gs.date AS consent_date
FROM civicrm_contact c
JOIN civicrm_email e ON c.id = e.contact_id
JOIN civicrm_group_contact gs ON c.id = gs.contact_id
JOIN civicrm_group g ON gs.group_id = g.id
WHERE g.name = 'Newsletter'
  AND gs.status IN ('Added', 'Pending')
ORDER BY gs.date DESC;

-- Erwartung:
-- added_by_id: NULL (Selbst-Opt-In) ODER User-ID (Import mit Consent)
-- status: 'Added' (aktiv) oder 'Pending' (Double-Opt-In ausstehend)

-- Opt-Outs prüfen:
SELECT 
  c.display_name,
  e.email,
  gs.status,
  gs.date AS opt_out_date
FROM civicrm_contact c
JOIN civicrm_email e ON c.id = e.contact_id
JOIN civicrm_group_contact gs ON c.id = gs.contact_id
JOIN civicrm_group g ON gs.group_id = g.id
WHERE g.name = 'Newsletter'
  AND gs.status IN ('Removed', 'Opt-out')
ORDER BY gs.date DESC
LIMIT 50;

-- Validation:
-- ☐ Alle Opt-Outs haben date-Timestamp
-- ☐ Keine Re-Subscription nach Opt-Out (außer erneuter Consent)
```

### 4.3 Data Retention Policy Enforcement

**Automatische Löschung inaktiver Kontakte** (CiviCRM Scheduled Job):

```yaml
Job: "Delete Inactive Contacts (GDPR Retention)"

Schedule: Jährlich (z.B. 1. Januar)

Criteria:
  - Newsletter-Status: Opt-Out
  - Letzte Aktivität: > 3 Jahre
  - Keine offenen Spenden/Mitgliedschaften
  - Keine laufenden Kommunikationen

SQL-Preview (NICHT automatisch ausführen):
  DELETE FROM civicrm_contact
  WHERE id IN (
    SELECT c.id
    FROM civicrm_contact c
    JOIN civicrm_group_contact gs ON c.id = gs.contact_id
    WHERE gs.status = 'Opt-out'
      AND gs.date < DATE_SUB(NOW(), INTERVAL 3 YEAR)
      AND NOT EXISTS (
        SELECT 1 FROM civicrm_contribution contrib WHERE contrib.contact_id = c.id
      )
      AND NOT EXISTS (
        SELECT 1 FROM civicrm_membership memb WHERE memb.contact_id = c.id AND memb.status_id IN (1,2)
      )
  );

Manual Review erforderlich:
  ☐ Vor Ausführung: Export der zu löschenden Kontakte (Backup)
  ☐ Legal Approval: Datenschutzbeauftragter bestätigt Retention Policy
  ☐ Execution: Via CiviCRM UI (Administer → Scheduled Jobs)
  ☐ Post-Deletion: Anonymisierte Logs behalten (Statistik-Zwecke)
```

---

## 5. Performance Optimization (Monthly)

### 5.1 CiviMail Queue Optimization

**Bottleneck-Analyse**:

```yaml
Metrics zu messen (via CiviCRM Reports):
  
  Queue Processing Time:
    Ziel: < 1 Minute pro 1000 Emails
    Methode: CiviMail → Reports → Delivery Report → "Queue Start" vs "Queue End"
    
  Bounce Processing Time:
    Ziel: < 5 Minuten (bei 2% Bounce Rate)
    Methode: Cron Logs analysieren (drush cvapi Job.execute job=process_bounces)
    
  SMTP Throughput:
    Ziel: ≥ 100 Emails/Minute
    Limit: Plesk-Hoster Rate Limits prüfen (oft 500/Stunde)
```

**Optimierungen**:

```yaml
1. CiviMail Batch Size erhöhen:
   Administer → CiviMail → CiviMail Component Settings
   - Mailer Batch Limit: 0 (unbegrenzt) ODER 500 (bei Rate Limits)
   - Mailer Job Size: 0 (unbegrenzt)
   
2. Cron Frequenz optimieren:
   - Mailing Scheduler: Alle 5 Minuten (für schnellen Versand)
   - Bounce Processing: Alle 15 Minuten (ausreichend)
   
   # Crontab (Plesk):
   */5 * * * * cd /var/www/vhosts/menschlichkeit-oesterreich.at/crm.menschlichkeit-oesterreich.at && drush cvapi Job.execute job=process_mailings
   */15 * * * * cd /var/www/vhosts/menschlichkeit-oesterreich.at/crm.menschlichkeit-oesterreich.at && drush cvapi Job.execute job=process_bounces

3. SMTP Connection Pooling:
   Plesk → Mail Settings → Advanced
   - Connection Limit: 50 concurrent (statt default 10)
   - Timeout: 60s (statt 30s)
```

### 5.2 Database Query Optimization

**Slow Query Monitoring**:

```sql
-- PostgreSQL Slow Query Log aktivieren:
ALTER SYSTEM SET log_min_duration_statement = 1000; -- Log queries > 1s
SELECT pg_reload_conf();

-- Slow Queries analysieren (nach 1 Woche):
SELECT 
  calls,
  total_time,
  mean_time,
  query
FROM pg_stat_statements
WHERE mean_time > 1000 -- > 1 Sekunde
ORDER BY total_time DESC
LIMIT 20;

-- Häufige Probleme:
-- 1. civicrm_mailing_event_queue: Missing Index auf email_id
-- 2. civicrm_email: Missing Index auf contact_id + on_hold
-- 3. civicrm_group_contact: Missing Index auf group_id + status
```

**Index-Optimierungen**:

```sql
-- Indexe für CiviMail Performance:
CREATE INDEX idx_email_contact_onhold ON civicrm_email(contact_id, on_hold);
CREATE INDEX idx_queue_email ON civicrm_mailing_event_queue(email_id, job_id);
CREATE INDEX idx_group_contact_status ON civicrm_group_contact(group_id, contact_id, status);
CREATE INDEX idx_bounce_email ON civicrm_mailing_event_bounce(email_id, bounce_type_id);

-- Vacuum & Analyze (monatlich):
VACUUM ANALYZE civicrm_mailing_event_queue;
VACUUM ANALYZE civicrm_email;
VACUUM ANALYZE civicrm_group_contact;
```

### 5.3 HTML Template Optimization

**Performance-Checkliste** (für Newsletter-Templates):

```yaml
HTML/CSS:
  ☐ Inline CSS (keine externen Stylesheets)
  ☐ Max. 100 KB HTML-Größe (inkl. Bilder-Inline)
  ☐ Responsive Design (Media Queries für Mobile)
  ☐ Keine JavaScript (wird von Gmail/Outlook blockiert)
  
Images:
  ☐ CDN-Hosting (statt Inline Base64)
  ☐ WebP Format mit JPEG Fallback
  ☐ Max. 200 KB pro Image
  ☐ Alt-Tags für Accessibility
  
Links:
  ☐ HTTPS-Only (keine HTTP-Links)
  ☐ UTM-Tracking-Parameter (für Analytics)
  ☐ Link-Shortener vermeiden (Spam-Signal)
  
Plain-Text Alternative:
  ☐ Automatisch generiert (CiviMail)
  ☐ Manuell optimiert (Lesbarkeit ohne HTML)
```

---

## 6. Disaster Recovery & Backup

### 6.1 Backup-Strategie

**Datenbank-Backups** (PostgreSQL):

```yaml
Frequency: Täglich (3:00 UTC)
Retention: 30 Tage

Script: /scripts/backup-civicrm-db.sh
#!/bin/bash
BACKUP_DIR="/backups/civicrm"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="civicrm"

# Dump erstellen (komprimiert)
pg_dump -Fc -U civicrm -d $DB_NAME > $BACKUP_DIR/civicrm_$DATE.dump

# Alte Backups löschen (> 30 Tage)
find $BACKUP_DIR -name "civicrm_*.dump" -mtime +30 -delete

# Backup-Validierung
pg_restore --list $BACKUP_DIR/civicrm_$DATE.dump > /dev/null
if [ $? -eq 0 ]; then
  echo "✅ Backup OK: $DATE"
else
  echo "❌ Backup FAILED: $DATE" | mail -s "CiviCRM Backup Failure" peter.schuller@menschlichkeit-oesterreich.at
fi

# Crontab:
# 0 3 * * * /scripts/backup-civicrm-db.sh
```

**DKIM Key Backups** (verschlüsselt):

```bash
# Quarterly Backup (nach Key-Rotation)
cd /workspaces/menschlichkeit-oesterreich-development/secrets/email-dkim/

tar -czf dkim-backup-$(date +%Y-Q%q).tar.gz *_private.pem *_public.txt
gpg --symmetric --cipher-algo AES256 dkim-backup-$(date +%Y-Q%q).tar.gz
rm dkim-backup-$(date +%Y-Q%q).tar.gz

# Offsite-Backup (via rclone zu Cloud):
rclone copy dkim-backup-$(date +%Y-Q%q).tar.gz.gpg nextcloud:Backups/DKIM/
```

**Plesk Configuration Backup** (via Plesk UI):

```yaml
Plesk → Tools & Settings → Backup Manager:
  - Full Backup: Wöchentlich (Sonntag 1:00 UTC)
  - Retention: 4 Wochen
  - Includes:
      - Mail Settings (DKIM, SPF, DNS)
      - Mailboxen + Passwörter
      - DNS Zones
      - SSL Certificates
  - Storage: Plesk Server + Offsite (FTP/S3)
```

### 6.2 Restore-Prozedur (Notfall)

**Szenario 1: CiviCRM-Datenbank korrupt**

```bash
# 1. Service stoppen
systemctl stop apache2
systemctl stop postgresql

# 2. Letztes gültiges Backup identifizieren
ls -lh /backups/civicrm/ | tail -5

# 3. Restore (PostgreSQL)
dropdb civicrm
createdb civicrm
pg_restore -U civicrm -d civicrm /backups/civicrm/civicrm_20250107_030000.dump

# 4. Validierung
psql -U civicrm -d civicrm -c "SELECT COUNT(*) FROM civicrm_contact;"

# 5. Services starten
systemctl start postgresql
systemctl start apache2

# 6. CiviCRM Cache clearen
cd /var/www/vhosts/.../crm.menschlichkeit-oesterreich.at
drush cache:rebuild
```

**Szenario 2: DKIM Keys kompromittiert**

```yaml
1. Sofortige Deaktivierung (Plesk):
   Plesk → Mail → DKIM Spam Protection → Disable
   
2. Neue Keypairs generieren (siehe Section 1.2)
   
3. DNS Rotation (Tag 0 statt Tag -7):
   - Neue TXT Records sofort publizieren
   - Alte Records sofort löschen
   
4. DMARC RUF Monitoring (48h):
   - Prüfe Failure Reports (dmarc@)
   - Erwarte temporäre DKIM-Failures (alte Mails in Queue)
   
5. Security Incident Report:
   - Dokumentation: Wann, Wie, Was kompromittiert
   - Notification: Datenschutzbeauftragter + Management
   - Post-Mortem: Root Cause Analysis
```

---

## 7. Metrics Dashboard (Template)

### 7.1 KPI-Tracking (Spreadsheet)

```csv
Date,DMARC Pass Rate,mail-tester Score,Spam Complaints,Bounce Rate,TLS Success,Gmail Reputation,Outlook Reputation
2025-01-07,99.5%,9.2/10,0.05%,1.8%,99.2%,High,Green
2025-01-14,99.7%,9.3/10,0.03%,1.5%,99.5%,High,Green
2025-01-21,99.8%,9.5/10,0.02%,1.3%,99.8%,High,Green
...
```

**Automated Collection** (Python-Script):

```python
# /scripts/email-metrics-collector.py
import csv
from datetime import datetime

def collect_weekly_metrics():
    """
    Sammelt Email-Infrastruktur Metriken für Tracking-Dashboard.
    
    Sources:
    - DMARC Pass Rate: Aus dmarc-report-analyzer.py
    - mail-tester: Manuell (wöchentlicher Test)
    - Spam Complaints: Google Postmaster Tools API
    - Bounce Rate: CiviCRM Reports
    - TLS Success: TLSRPT Reports
    - Reputation: Google/Microsoft APIs
    """
    metrics = {
        'date': datetime.now().strftime('%Y-%m-%d'),
        'dmarc_pass_rate': get_dmarc_pass_rate(),  # Via DMARC Reports
        'mail_tester_score': 0,  # Manual input required
        'spam_complaints': get_spam_complaint_rate(),  # Via Postmaster Tools
        'bounce_rate': get_bounce_rate(),  # Via CiviCRM
        'tls_success': get_tls_success_rate(),  # Via TLSRPT
        'gmail_reputation': 'High',  # Manual input
        'outlook_reputation': 'Green'  # Manual input
    }
    
    # CSV updaten
    with open('/var/www/metrics/email-kpis.csv', 'a') as f:
        writer = csv.DictWriter(f, fieldnames=metrics.keys())
        writer.writerow(metrics)
    
    # Alert bei Threshold-Überschreitung
    if float(metrics['dmarc_pass_rate'].rstrip('%')) < 99.0:
        send_alert("DMARC Pass Rate below 99%!")

# Wöchentlicher Cron:
# 0 10 * * MON python3 /scripts/email-metrics-collector.py
```

### 7.2 Trend-Visualisierung (Grafana/Plotly)

**Grafana Dashboard** (optional - Advanced):

```yaml
Data Source: PostgreSQL (CiviCRM Datenbank + Metrics-Tabelle)

Panels:
  1. DMARC Pass Rate (Line Chart):
     Query: SELECT date, dmarc_pass_rate FROM email_metrics ORDER BY date DESC LIMIT 30
     Threshold: Red Zone < 99%, Yellow 99-99.5%, Green ≥99.5%
     
  2. Deliverability Overview (Gauge):
     Metrics: Gmail Reputation, Outlook SNDS, mail-tester Score
     Combined Score: (Gmail + Outlook + mail-tester) / 3
     
  3. Engagement Metrics (Bar Chart):
     CiviCRM Query: SELECT mailing_name, opened_count, clicked_count FROM civicrm_mailing_stats
     
  4. Bounce Rate Trend (Area Chart):
     Query: Hard Bounces vs Soft Bounces over Time
     
  5. Spam Complaint Heatmap:
     Dimensions: Date, Email-Provider (Gmail/Outlook/GMX)

Alerts:
  - Slack Notification: DMARC Pass < 99%
  - Email Alert: Spam Complaints > 0.1%
  - PagerDuty: IP Blacklist detected
```

---

## 8. Emergency Procedures

### 8.1 IP Blacklist Response

**Detection**:

```yaml
Symptom: Bounce-Rate plötzlich > 10%, Fehler "550 Blocked by Spamhaus ZEN"
Source: Bounce-Logs (civimail@)
Validation: https://www.spamhaus.org/lookup/ → IP_NEWS eingeben
```

**Immediate Actions** (innerhalb 1h):

```yaml
1. Versand pausieren:
   CiviCRM → Administer → CiviMail → Pause All Scheduled Mailings
   
2. Blacklist-Grund identifizieren:
   - Spamhaus Listing Reason: "Spam Trap Hit" / "Compromised Account" / etc.
   - RBL-Check: https://mxtoolbox.com/blacklists.aspx → IP_NEWS
   
3. Root Cause fixen:
   - Spam Trap Hit → Listen-Hygiene (alte Emails entfernen)
   - Compromised Account → Passwort-Reset, SMTP Auth prüfen
   - High Complaint Rate → Opt-Out-Prozess verbessern
   
4. Delisting-Request:
   - Spamhaus: https://www.spamhaus.org/lookup/ → "Request Removal"
   - Warten: 24-48h
   
5. Post-Delisting Validation:
   - mail-tester.com Test (Score ≥ 9/10?)
   - Test-Mails an Gmail/Outlook (Inbox-Delivery?)
   - Versand vorsichtig wieder aufnehmen (max. 100 Emails/Stunde initial)
```

### 8.2 DMARC Enforcement Failure

**Detection**:

```yaml
Symptom: DMARC RUA Reports zeigen policy_evaluated=reject
Source: dmarc@ Mailbox
Impact: Emails werden abgelehnt (nicht zugestellt)
```

**Immediate Actions**:

```yaml
1. DMARC Policy downgrade (Rollback):
   Plesk → DNS → _dmarc TXT Record
   Change: p=reject → p=quarantine (temporär)
   
2. Root Cause analysieren:
   - RUA Report parsen: Welche Source-IP hat Failure?
   - SPF Check: Ist IP autorisiert (ip4:IP_NEWS)?
   - DKIM Check: Selector korrekt (news2025q4)?
   - Alignment: From-Domain = SPF/DKIM-Domain?
   
3. Fix implementieren:
   - SPF: DNS TXT Record updaten (IP hinzufügen)
   - DKIM: Plesk Selector-Konfiguration prüfen
   - Alignment: From-Header in CiviMail korrekt setzen
   
4. Validation (48h):
   - Neue RUA Reports prüfen (Pass-Rate ≥ 99%?)
   - Test-Mails (Authentication-Results Header)
   
5. DMARC Policy re-enforce:
   p=quarantine → p=reject (nach stabiler Phase)
```

### 8.3 CiviMail Total Failure

**Detection**:

```yaml
Symptom: Keine Emails werden versendet, Queue bleibt bei "Pending"
Source: CiviMail → Reports → Delivery Report (0% Delivered)
```

**Debugging**:

```bash
# 1. Cron-Job Status
drush cvapi Job.execute job=process_mailings --debug

# Erwarte: JSON Response mit "values": [...] (Mailing Jobs)
# Fehler: "SMTP connection failed" / "Mailbox quota exceeded" / etc.

# 2. SMTP Connectivity
telnet mail.menschlichkeit-oesterreich.at 25
# Erwarte: 220 mail.menschlichkeit-oesterreich.at ESMTP

# 3. Plesk Mail Queue
qshape active
# Erwarte: Keine gestoppten Mails

# 4. CiviCRM Error Logs
tail -f /var/www/vhosts/.../crm.menschlichkeit-oesterreich.at/sites/default/files/civicrm/ConfigAndLog/CiviCRM.*.log
```

**Fixes** (häufige Ursachen):

```yaml
Problem 1: SMTP Auth Failure
  Symptom: "535 Authentication Failed"
  Fix: CiviCRM → Administer → System Settings → Outbound Email
       - Username: civimail@menschlichkeit-oesterreich.at
       - Password: [KORREKT EINGEBEN]
       
Problem 2: Mailbox Quota Exceeded (civimail@)
  Symptom: "552 Mailbox full"
  Fix: Plesk → Mail → civimail@ → Quota erhöhen (5GB → 10GB)
  
Problem 3: DKIM Signing Error
  Symptom: "DKIM signature generation failed"
  Fix: Plesk → Mail → DKIM → Private Key neu eingeben
       - Validate: Testmail senden → Authentication-Results prüfen
       
Problem 4: Rate Limit überschritten
  Symptom: "450 Too many emails sent"
  Fix: Plesk → Mail → Advanced → Rate Limit erhöhen (500/h → 1000/h)
       ODER: CiviMail Batch Size reduzieren (0 → 100)
```

---

**Ende Maintenance & Rotation Plan**

**Status**: Bereit für 12-Monate-Wartungszyklus  
**Next Review**: 2026 Q1 (März 2026)  
**Abhängigkeiten**:

- Phase 1-6 vollständig implementiert
- DKIM Key Rotation Q3 2025 (September) eingeplant
- DMARC Policy Upgrade nach 30 Tagen Monitoring
- KPI-Tracking etabliert (wöchentlich)

**Dokumentations-Updates**:

- Rotation-Log pflegen (`DKIM_ROTATION_LOG.txt`)
- Metrics-Dashboard aktuell halten (`email-kpis.csv`)
- Incident-Reports dokumentieren (bei Blacklist/Failures)
