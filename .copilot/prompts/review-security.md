# name: Security Review

# description: Prüft Code auf DSGVO, SEPA und allgemeine Sicherheitsschwachstellen

Analysiere den markierten/angehängten Code auf folgende **Sicherheitsaspekte**:

## Allgemeine Security-Checks

- **Injection-Schwachstellen:** SQL, NoSQL, Command, LDAP Injection
- **Secrets & Credentials:** Hardcoded Passwörter, API Keys, Tokens
- **Input Validation:** Unvalidierte/unsanitized User Inputs
- **Authentication/Authorization:** Broken Access Control, Session Management
- **Crypto-Probleme:** Schwache Algorithmen, unsichere Zufallszahlen
- **Deserialisierung:** Unsafe Deserialization von User Data

## DSGVO & Privacy-Compliance

- **Personenbezogene Daten:** Werden PII-Daten angemessen geschützt?
- **Datenminimierung:** Werden nur erforderliche Daten verarbeitet?
- **Zweckbindung:** Entspricht die Nutzung dem ursprünglichen Zweck?
- **Speicherdauer:** Sind Aufbewahrungsfristen implementiert?
- **Einwilligung:** Ist Consent-Management korrekt umgesetzt?
- **Betroffenenrechte:** Können Users ihre Daten exportieren/löschen?

## SEPA & Financial Security

- **IBAN/BIC-Schutz:** Sind Bankdaten verschlüsselt gespeichert?
- **PCI-DSS:** Keine Kreditkartendaten im Code oder Logs?
- **Audit-Trails:** Sind Finanztransaktionen vollständig protokolliert?
- **Mandate-Validation:** Korrekte SEPA-Validierung implementiert?

## Austrian Compliance

- **Steuerrecht:** Aufbewahrungsfristen (7-10 Jahre) berücksichtigt?
- **Vereinsrecht:** Entspricht der Code österreichischen Vereinsgesetzen?
- **Meldefristen:** DSGVO-Breach-Meldungen (72h) implementiert?

## Output-Format

Liefere eine **strukturierte Analyse**:

```
## 🔍 Security Findings

### 🔴 Kritisch (sofort beheben)
- **[Vulnerability Type]:** Beschreibung + Codezeile
- **Risiko:** Auswirkung auf Verein/Mitglieder
- **Fix:** Konkreter Lösungsvorschlag

### 🟡 Medium (zeitnah beheben)
- **[Issue]:** Details
- **Empfehlung:** Verbesserungsvorschlag

### 🟢 Info (Best Practices)
- **[Verbesserung]:** Optional, aber empfohlen

## 🛠️ Quick Fixes
[Wenn möglich: Direkte Code-Patches für kritische Issues]

## 📋 Compliance Status
- ✅ DSGVO-konform
- ✅ SEPA-sicher
- ⚠️ Weitere Maßnahmen erforderlich
```

**Fokus:** Praktische, umsetzbare Lösungen für einen österreichischen Verein.
