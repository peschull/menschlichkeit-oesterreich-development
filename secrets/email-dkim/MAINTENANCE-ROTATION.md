# E-Mail Infrastructure - Maintenance & Key Rotation Plan

## 🔄 DKIM Key Rotation Schedule

### Warum rotieren?
- **Sicherheit**: Kompromittierte Keys limitieren
- **Best Practice**: Google/Microsoft empfehlen Rotation alle 6-12 Monate
- **Compliance**: PCI-DSS, DSGVO Datensicherheit

### Rotation Timeline

```
Q4 2025 → tx2025q4, news2025q4     (CURRENT - Setup)
Q1 2026 → tx2026q1, news2026q1     (Januar)
Q2 2026 → tx2026q2, news2026q2     (April)
Q3 2026 → tx2026q3, news2026q3     (Juli)
Q4 2026 → tx2026q4, news2026q4     (Oktober)
```

### Automatisierte Rotation

**Script:** `scripts/dkim-rotation.sh`

```bash
# Neue Keys generieren (Safe - alte Keys bleiben aktiv)
./scripts/dkim-rotation.sh --quarter 2026q1

# Output:
# - secrets/email-dkim/tx2026q1/dkim_private.pem
# - secrets/email-dkim/tx2026q1/dkim_public.txt (für DNS)
# - secrets/email-dkim/news2026q1/dkim_private.pem
# - secrets/email-dkim/news2026q1/dkim_public.txt

# Rotation-Report:
# - quality-reports/email-infrastructure/rotation-2026q1-{timestamp}.json
```

### Manuelle Rotation Steps

#### Phase 1: Vorbereitung (T-7 Tage)
```bash
# 1. Neue Keys generieren
./scripts/dkim-rotation.sh --quarter 2026q1

# 2. DNS Records vorbereiten (NICHT deployen!)
cat secrets/email-dkim/tx2026q1/dkim_public.txt
cat secrets/email-dkim/news2026q1/dkim_public.txt

# 3. Plesk vorbereiten
# → Mail-Einstellungen → DKIM → Neue Selektoren hinzufügen (inaktiv)
```

#### Phase 2: DNS Deployment (T-3 Tage)
```bash
# 1. DNS Records deployen (PARALLEL zu alten Records!)
# Plesk DNS → TXT Records:
tx2026q1._domainkey.menschlichkeit-oesterreich.at → [Public Key]
news2026q1._domainkey.newsletter.menschlichkeit-oesterreich.at → [Public Key]

# 2. Propagation warten (48-72h)
# Check:
dig +short TXT tx2026q1._domainkey.menschlichkeit-oesterreich.at
```

#### Phase 3: Plesk Aktivierung (T-Day)
```bash
# 1. Plesk Mail-Einstellungen umschalten
# → DKIM Selektor: tx2025q4 → tx2026q1
# → DKIM Selektor: news2025q4 → news2026q1

# 2. Test-E-Mail senden
# → mail-tester.com Score prüfen

# 3. Monitoring aktivieren
./scripts/email-monitoring.sh
```

#### Phase 4: Cleanup (T+30 Tage)
```bash
# 1. Alte DNS Records entfernen (nach 30 Tagen Grace Period)
# Plesk DNS → Löschen:
# - tx2025q4._domainkey.menschlichkeit-oesterreich.at
# - news2025q4._domainkey.newsletter.menschlichkeit-oesterreich.at

# 2. Alte Keys archivieren
mv secrets/email-dkim/tx2025q4 secrets/email-dkim/archive/tx2025q4-retired-$(date +%Y%m%d)
mv secrets/email-dkim/news2025q4 secrets/email-dkim/archive/news2025q4-retired-$(date +%Y%m%d)

# 3. Rotation dokumentieren
echo "✅ Q4 2025 → Q1 2026 Rotation abgeschlossen" >> secrets/email-dkim/ROTATION-HISTORY.md
```

---

## 📊 Monitoring & Alerting

### Tägliches Monitoring (Cron Job)

**Plesk Cron Setup:**
```bash
# Täglich 06:00 UTC
0 6 * * * /workspaces/menschlichkeit-oesterreich-development/scripts/email-monitoring.sh
```

**Alternative: n8n Workflow**
```json
{
  "name": "E-Mail Infrastructure Daily Check",
  "nodes": [
    {
      "type": "n8n-nodes-base.schedule",
      "parameters": {
        "rule": {
          "interval": [{"field": "hours", "value": 24}]
        }
      }
    },
    {
      "type": "n8n-nodes-base.executeCommand",
      "parameters": {
        "command": "./scripts/email-monitoring.sh"
      }
    },
    {
      "type": "n8n-nodes-base.emailSend",
      "parameters": {
        "subject": "E-Mail Infrastructure Status",
        "attachments": "quality-reports/email-infrastructure/*.json"
      }
    }
  ]
}
```

### Alert-Bedingungen

**CRITICAL (sofort Alarm):**
- ❌ SPF Record nicht auflösbar
- ❌ DKIM Signature Verification fehlgeschlagen
- ❌ DMARC Policy = quarantine/reject ohne funktionierende SPF/DKIM
- ❌ TLSRPT zeigt TLS Failures > 10%

**WARNING (24h Review):**
- ⚠️ DKIM Key läuft in < 30 Tagen ab
- ⚠️ SPF Record enthält > 10 DNS Lookups
- ⚠️ DMARC Aggregate Reports zeigen Failures > 5%

**INFO (wöchentlich Review):**
- ℹ️ Neue DMARC Reports verfügbar
- ℹ️ TLSRPT zeigt Cipher-Downgrade-Versuche

---

## 🔐 Key Storage & Backup

### Lokale Keys (Development)
```
secrets/email-dkim/
├── tx2025q4/
│   ├── dkim_private.pem          (NIEMALS committen!)
│   ├── dkim_public.txt
│   └── plesk-config.txt
├── news2025q4/
│   ├── dkim_private.pem
│   ├── dkim_public.txt
│   └── plesk-config.txt
└── archive/                       (retired keys)
```

### GitHub Secrets (CI/CD)
```bash
# Encrypted Secrets für Deployment-Automation
DKIM_PRIVATE_TX_CURRENT=<base64-encoded>
DKIM_PRIVATE_NEWS_CURRENT=<base64-encoded>
```

### Plesk Backup
```bash
# Automatisches Backup via Plesk Extensions → Backup Manager
# Schedule: Täglich 02:00 UTC
# Retention: 30 Tage
# Includes: Mail-Konfiguration, DNS Records, DKIM Keys
```

### Disaster Recovery
```bash
# Wenn Plesk-Server komplett verloren:
# 1. Private Keys aus lokalem Backup wiederherstellen
cp secrets/email-dkim/tx2025q4/dkim_private.pem /tmp/

# 2. Plesk neu konfigurieren (siehe IMPLEMENTATION-GUIDE.md)

# 3. DNS Records neu deployen
cat secrets/email-dkim/tx2025q4/dkim_public.txt
# → Plesk DNS → TXT Record

# 4. Mail-Tester validieren
# → mail-tester.com (Ziel: 10/10 Score)
```

---

## 📈 Performance Metrics

### Key Performance Indicators (KPIs)

**E-Mail Deliverability:**
- Target: ≥ 98% Zustellrate (Inbox, nicht Spam)
- Measurement: DMARC Aggregate Reports

**DKIM Signature Success:**
- Target: 100% valide Signaturen
- Measurement: DMARC Reports + mail-tester.com

**SPF Pass Rate:**
- Target: 100% (alle legitimen Sender in SPF)
- Measurement: DMARC Reports

**DMARC Policy Compliance:**
- Target: p=reject mit 0% False Positives
- Timeline: 
  - Q4 2025: p=none (monitoring)
  - Q1 2026: p=quarantine
  - Q2 2026: p=reject

### Monitoring Dashboard

**Tools:**
1. **Postmaster Tools** (Google, Microsoft, Yahoo)
   - Domain Reputation
   - Spam Rate
   - Feedback Loop Reports

2. **DMARC Analyzer** (z.B. dmarcian.com)
   - Aggregate Reports Parsing
   - Forensic Reports
   - Policy Recommendations

3. **Custom Dashboard** (n8n + Grafana)
   - Real-time SPF/DKIM/DMARC Status
   - Historical Deliverability Trends
   - Alert Notifications

---

## 🛠️ Troubleshooting

### DKIM Signature Failures

**Symptom:** E-Mails haben ungültige DKIM Signaturen

**Diagnose:**
```bash
# 1. DNS Record prüfen
dig +short TXT tx2025q4._domainkey.menschlichkeit-oesterreich.at

# 2. Public Key aus Plesk exportieren
# Plesk → Mail → DKIM → Public Key anzeigen

# 3. Vergleichen
# → Müssen identisch sein!
```

**Lösung:**
```bash
# Falls DNS != Plesk:
# → DNS Record aktualisieren (Plesk DNS oder Domain-Provider)

# Falls Plesk Private Key fehlt:
# → Aus secrets/email-dkim/ Backup wiederherstellen
```

### SPF Lookup Limit Exceeded

**Symptom:** SPF Record überschreitet 10 DNS Lookups

**Diagnose:**
```bash
# SPF Flattening Tool verwenden
# https://www.spf-record.com/flatten

# Aktueller Record:
dig +short TXT menschlichkeit-oesterreich.at | grep "v=spf1"
```

**Lösung:**
```bash
# Option 1: SPF Flattening (IP-Adressen hardcoden)
v=spf1 ip4:195.201.XXX.XXX ip4:... -all

# Option 2: Subdomain Delegation
# newsletter.menschlichkeit-oesterreich.at → eigener SPF Record
```

### DMARC False Positives

**Symptom:** Legitime E-Mails werden quarantined/rejected

**Diagnose:**
```bash
# DMARC Aggregate Reports analysieren
# → Welche Sender (Source IP) schlagen fehl?
# → SPF oder DKIM fehlgeschlagen?
```

**Lösung:**
```bash
# Falls SPF Fehler:
# → Sender-IP zu SPF Record hinzufügen

# Falls DKIM Fehler:
# → Prüfen ob Sender DKIM überhaupt unterstützt
# → Ggf. Whitelist in DMARC Policy

# Falls beide fehlschlagen:
# → Prüfen ob Spoofing-Versuch oder legitimer Sender
```

---

## 📅 Maintenance Calendar 2026

### Q1 2026 (Januar - März)
- ✅ **01.01.2026**: DKIM Key Rotation → tx2026q1, news2026q1
- ✅ **15.01.2026**: DMARC Policy Evaluation (p=none → p=quarantine?)
- ✅ **01.03.2026**: Quarterly Security Audit

### Q2 2026 (April - Juni)
- ✅ **01.04.2026**: DKIM Key Rotation → tx2026q2, news2026q2
- ✅ **15.04.2026**: DMARC Policy Review
- ✅ **01.06.2026**: Mid-Year Infrastructure Review

### Q3 2026 (Juli - September)
- ✅ **01.07.2026**: DKIM Key Rotation → tx2026q3, news2026q3
- ✅ **15.07.2026**: DMARC Policy Evaluation (p=quarantine → p=reject?)
- ✅ **01.09.2026**: Quarterly Security Audit

### Q4 2026 (Oktober - Dezember)
- ✅ **01.10.2026**: DKIM Key Rotation → tx2026q4, news2026q4
- ✅ **15.10.2026**: Annual Infrastructure Review
- ✅ **01.12.2026**: Year-End Compliance Check

---

## 🇦🇹 DSGVO Compliance

### Datenverarbeitung
- **PII in E-Mails**: Automatische Sanitization (siehe PII-SANITIZATION-README.md)
- **DKIM Keys**: Nicht personenbezogen (technische Keys)
- **DMARC Reports**: Enthalten IP-Adressen → 30 Tage Retention

### Aufbewahrungspflichten
```bash
# DMARC Aggregate Reports: 90 Tage
# TLSRPT Reports: 90 Tage
# DKIM Keys (retired): 1 Jahr (für Forensics)
# Monitoring Logs: 90 Tage
```

### Incident Response
Falls DKIM Key kompromittiert:
1. **Sofort**: DKIM Key deaktivieren (Plesk)
2. **< 1h**: Neue Keys generieren & deployen
3. **< 24h**: DNS Records aktualisiert
4. **< 72h**: Incident Report dokumentieren

---

**Letztes Update:** 2025-10-08  
**Nächste Review:** 2026-01-01  
**Maintainer:** IT Security Team, Menschlichkeit Österreich
