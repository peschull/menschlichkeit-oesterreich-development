# E-Mail Infrastructure Maintenance Calendar

**Projekt:** Menschlichkeit Österreich  
**Domain:** menschlichkeit-oesterreich.at  
**Letzte Aktualisierung:** 2025-10-08

---

## 🗓️ Quartalsweise Wartung

### Q1 (Januar - März)

**DKIM Key Rotation:**

- [ ] **15. Januar:** Neue DKIM Keys generieren (`./scripts/dkim-rotation.sh 2025q1`)
- [ ] **15. Januar:** DNS Records publizieren (Plesk)
- [ ] **17. Januar:** DNS-Propagation validieren (`dig +short TXT tx2025q1._domainkey...`)
- [ ] **22. Januar:** CiviCRM/CiviMail Selectors aktualisieren
- [ ] **22. Januar:** Tests durchführen (mail-tester.com)
- [ ] **29. Januar:** Alte DKIM Records deaktivieren
- [ ] **15. April:** Alte Keys aus Archiv löschen (90 Tage Retention)

**Monitoring & Reviews:**

- [ ] **31. März:** Q1 E-Mail Deliverability Report generieren
- [ ] **31. März:** DMARC Aggregate Reports analysieren
- [ ] **31. März:** Spam-Beschwerderate prüfen (< 0.1%)
- [ ] **31. März:** Bounce Rate prüfen (< 2%)

---

### Q2 (April - Juni)

**DMARC Policy Review:**

- [ ] **15. April:** DMARC Policy prüfen (nach 30 Tagen Monitoring)
- [ ] **15. April:** Wenn Pass Rate ≥ 99%: DMARC auf `p=reject` umstellen
- [ ] **15. Juni:** BIMI-Record aktivieren (optional, nach DMARC p=reject)

**Monitoring & Reviews:**

- [ ] **30. Juni:** Q2 E-Mail Deliverability Report generieren
- [ ] **30. Juni:** TLS Reports analysieren (tlsrpt@)
- [ ] **30. Juni:** Security Incidents Review (security@, abuse@)

---

### Q3 (Juli - September)

**DKIM Key Rotation:**

- [ ] **15. Juli:** Neue DKIM Keys generieren (`./scripts/dkim-rotation.sh 2025q3`)
- [ ] **15. Juli:** DNS Records publizieren (Plesk)
- [ ] **17. Juli:** DNS-Propagation validieren
- [ ] **22. Juli:** CiviCRM/CiviMail Selectors aktualisieren
- [ ] **22. Juli:** Tests durchführen (mail-tester.com)
- [ ] **29. Juli:** Alte DKIM Records deaktivieren
- [ ] **15. Oktober:** Alte Keys aus Archiv löschen (90 Tage Retention)

**Monitoring & Reviews:**

- [ ] **30. September:** Q3 E-Mail Deliverability Report generieren
- [ ] **30. September:** DMARC Aggregate Reports analysieren
- [ ] **30. September:** Jahresplanung für 2026 (Budget, Tools, Prozesse)

---

### Q4 (Oktober - Dezember)

**Monitoring & Reviews:**

- [ ] **31. Dezember:** Q4 E-Mail Deliverability Report generieren
- [ ] **31. Dezember:** Jahres-Retrospektive: E-Mail Infrastructure
- [ ] **31. Dezember:** Budget-Review: DMARC Monitoring Tools (dmarcian.com, etc.)

**Planning:**

- [ ] **31. Dezember:** Roadmap 2026: BIMI VMC, ARC, etc.
- [ ] **31. Dezember:** Security Audit: E-Mail Infrastructure

---

## 📊 Monatliche Aufgaben

### Jeden 1. des Monats

**DMARC Reports:**

- [ ] <dmarc@menschlichkeit-oesterreich.at> Postfach prüfen
- [ ] RUA Reports parsen (via dmarcian.com oder parsedmarc)
- [ ] Failures analysieren und dokumentieren
- [ ] Bei Pass Rate < 95%: Sofort investigieren

**TLS Reports:**

- [ ] <tlsrpt@menschlichkeit-oesterreich.at> Postfach prüfen
- [ ] TLS Handshake Failures analysieren
- [ ] MTA-STS Policy validieren (falls konfiguriert)

**Bounce Management:**

- [ ] <bounce@menschlichkeit-oesterreich.at> Postfach prüfen
- [ ] Hard Bounces in CiviCRM reviewen
- [ ] Soft Bounces Retry-Pattern validieren

### Jeden 15. des Monats

**Deliverability Monitoring:**

- [ ] Testmail an mail-tester.com (Score ≥ 9/10)
- [ ] Testmail an Gmail/Outlook/GMX (Inbox Placement)
- [ ] Authentication-Results Header validieren (SPF/DKIM/DMARC pass)

**Security Monitoring:**

- [ ] <security@menschlichkeit-oesterreich.at> Response Time prüfen (SLA < 24h)
- [ ] <abuse@menschlichkeit-oesterreich.at> Response Time prüfen (SLA < 24h)
- [ ] Autoreply Funktionsfähigkeit validieren

---

## 🚨 Wöchentliche Aufgaben

### Jeden Montag

**Infrastructure Health Check:**

- [ ] E-Mail Monitoring Script ausführen: `./scripts/email-monitoring.sh`
- [ ] DNS Records validieren (SPF, DKIM, DMARC, TLSRPT)
- [ ] MX Records Erreichbarkeit prüfen

**CiviMail Performance:**

- [ ] Newsletter Bounce Rate prüfen (< 2%)
- [ ] Newsletter Spam-Beschwerderate prüfen (< 0.1%)
- [ ] List-Unsubscribe Funktionsfähigkeit validieren

---

## 🔔 Ad-hoc Trigger (Event-basiert)

### Bei neuer CiviMail Campaign

- [ ] From-Adresse validieren: `newsletter@newsletter.menschlichkeit-oesterreich.at`
- [ ] Reply-To validieren: `support@menschlichkeit-oesterreich.at`
- [ ] List-Unsubscribe Header aktiviert
- [ ] VERP Bounce-Handling aktiviert
- [ ] Test-Mailing an interne Adressen (Gmail/Outlook/GMX)
- [ ] Spam-Check via mail-tester.com (Score ≥ 9/10)

### Bei DMARC Policy Change

- [ ] **Tag 0:** Policy auf `p=quarantine` oder `p=reject` umstellen
- [ ] **Tag 1-7:** Täglich DMARC RUA Reports prüfen
- [ ] **Tag 7:** Wenn Pass Rate ≥ 99%: Policy beibehalten
- [ ] **Tag 7:** Wenn Pass Rate < 95%: Policy zurückrollen und investigieren

### Bei Security Incident

- [ ] **< 1 Stunde:** Incident Response Team benachrichtigen
- [ ] **< 4 Stunden:** Betroffene E-Mail-Accounts sperren
- [ ] **< 24 Stunden:** Root Cause Analysis
- [ ] **< 48 Stunden:** DKIM Keys rotieren (falls kompromittiert)
- [ ] **< 72 Stunden:** Post-Mortem Report

### Bei DSGVO Data Subject Request

- [ ] **< 24 Stunden:** Eingangsbestätigung senden
- [ ] **< 30 Tage:** Anfrage bearbeiten (Art. 15 DSGVO - Auskunft)
- [ ] **< 30 Tage:** Anfrage bearbeiten (Art. 17 DSGVO - Löschung)
- [ ] **< 30 Tage:** Anfrage bearbeiten (Art. 20 DSGVO - Datenportabilität)
- [ ] **< 30 Tage:** Anfrage bearbeiten (Art. 21 DSGVO - Widerspruch)

---

## 📈 KPIs & Zielwerte

| Metrik | Zielwert | Frequenz | Alarm bei |
|--------|----------|----------|-----------|
| **DMARC Pass Rate** | ≥ 99% | Monatlich | < 95% |
| **Mail-Tester Score** | ≥ 9/10 | Wöchentlich | < 8/10 |
| **Spam-Beschwerderate** | < 0.1% | Monatlich | ≥ 0.2% |
| **Bounce Rate** | < 2% | Wöchentlich | ≥ 5% |
| **Security Response Time** | < 24h | Monatlich | ≥ 48h |
| **DSGVO Response Time** | < 30 Tage | Quartalsweise | ≥ 35 Tage |
| **DKIM Key Age** | < 180 Tage | Quartalsweise | ≥ 200 Tage |

---

## 🔗 Wichtige Links & Tools

**DNS Validation:**

- [MXToolbox DMARC Checker](https://mxtoolbox.com/dmarc.aspx)
- [DKIM Core Tools](https://dkimcore.org/tools/)
- [Google Admin Toolbox](https://toolbox.googleapps.com/apps/checkmx/)

**Deliverability Testing:**

- [mail-tester.com](https://www.mail-tester.com/)
- [GlockApps](https://glockapps.com/)
- [Litmus](https://www.litmus.com/)

**DMARC Monitoring:**

- [dmarcian.com](https://dmarcian.com/)
- [parsedmarc](https://domainaware.github.io/parsedmarc/)
- [Postmark DMARC Digests](https://dmarc.postmarkapp.com/)

**Security:**

- [Have I Been Pwned](https://haveibeenpwned.com/)
- [SSL Labs](https://www.ssllabs.com/)
- [Hardenize](https://www.hardenize.com/)

---

## 📝 Change Log

| Datum | Änderung | Verantwortlich |
|-------|----------|----------------|
| 2025-10-08 | Initial Setup: DKIM tx2025q4 + news2025q4 | GitHub Copilot |
| 2025-10-08 | E-Mail Infrastructure Baseline etabliert | GitHub Copilot |
| TBD | DMARC Policy auf `p=reject` umgestellt | Pending (nach 30 Tagen) |
| TBD | BIMI Record aktiviert | Pending (nach 60 Tagen) |

---

## 🤖 Automatisierung

**Cron Jobs (empfohlen):**

```bash
# E-Mail Monitoring (täglich 6:00 UTC)
0 6 * * * /workspaces/menschlichkeit-oesterreich-development/scripts/email-monitoring.sh

# DMARC Report Reminder (monatlich 1. des Monats 9:00 UTC)
0 9 1 * * echo "⏰ DMARC Reports prüfen: dmarc@menschlichkeit-oesterreich.at" | mail -s "DMARC Monthly Review" peter.schuller@menschlichkeit-oesterreich.at

# DKIM Rotation Reminder (quartalsweise 15. Tag 9:00 UTC)
0 9 15 1,7 * echo "🔑 DKIM Rotation fällig: ./scripts/dkim-rotation.sh $(date +%Yq%q)" | mail -s "DKIM Quarterly Rotation" peter.schuller@menschlichkeit-oesterreich.at
```

**GitHub Actions (optional):**

- `.github/workflows/email-monitoring.yml` (täglich)
- `.github/workflows/dkim-rotation-reminder.yml` (quartalsweise)

---

**Maintained by:** IT-Team Menschlichkeit Österreich  
**Review Cycle:** Quartalsweise (am Ende jedes Quartals)  
**Next Review:** 2025-12-31
