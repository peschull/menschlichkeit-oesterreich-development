# Security Guidelines - Menschlichkeit Österreich

## General Security

- Vermeide Hardcoding von Secrets, verwende .env/KeyVault/Azure Key Vault.
- Eingaben validieren/sanitizen; prüfe SQL/Command-Injection besonders bei CRM-Daten.
- Keine eval/dangerous APIs ohne Begründung; wenn nötig, isolieren.
- Logging: keine sensiblen Daten (IBAN, Passwörter, personenbezogene Daten).

## DSGVO & Datenschutz

- **Datenminimierung:** Sammle nur erforderliche Daten für den Vereinszweck.
- **Zweckbindung:** Verwende Mitgliederdaten nur für Vereinsverwaltung, nicht für Marketing ohne Einwilligung.
- **Speicherdauer:** Beachte österreichische Aufbewahrungsfristen (7-10 Jahre für Buchhaltung).
- **Betroffenenrechte:** Implementiere Auskunft, Berichtigung, Löschung nach DSGVO.

## Authentication & Authorization

- **2FA:** Implementiere für Admin- und Moderator-Rollen.
- **Session Management:** Sichere Session-Tokens, automatischer Logout.
- **Rollensystem:** admin > moderator > member > guest (strikt hierarchisch).

## SEPA & Financial Security

- **PCI Compliance:** Keine Kreditkartendaten speichern.
- **IBAN-Validierung:** Verwende MOD-97 Algorithmus, österreichische Bank-Codes.
- **Audit Logs:** Protokolliere alle Finanztransaktionen und Zugriffe.
- **Encryption:** IBAN/BIC verschlüsselt speichern, nur entschlüsselt für Lastschrift.

## Threat Model - Vereinsspezifisch

- **Insider Threats:** Trennung der Rollen, Vier-Augen-Prinzip bei Finanzen.
- **Data Breaches:** Minimiere Datenhaltung, regelmäßige Backups, Incident Response.
- **Social Engineering:** Schulung für Vereinsmitglieder, Multi-Faktor für kritische Aktionen.

## Security Headers & Infrastructure

- **CSP:** Content Security Policy für XSS-Schutz.
- **HTTPS:** Immer HTTPS, HSTS Headers.
- **Rate Limiting:** Besonders bei Login, Registrierung, Passwort-Reset.

## Incident Response

- Bei sicherheitsrelevanten Änderungen: kurze Threat-Notes hinzufügen.
- **DSGVO-Breach:** 72h Meldepflicht an Datenschutzbehörde beachten.
- **Backup & Recovery:** Regelmäßige Tests der Wiederherstellungsverfahren.
