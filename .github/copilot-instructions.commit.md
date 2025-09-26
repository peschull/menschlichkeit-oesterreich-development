# Commits & PRs - Menschlichkeit Österreich

## Commit Message Format

- **Format:** `<type>(scope): <short summary>`
- **Types:** feat, fix, refactor, docs, test, chore, perf, ci, security
- **Scopes:** auth, sepa, dsgvo, frontend, backend, api, db, deploy
- **Beispiele:**
  - `feat(auth): implement 2FA authentication system`
  - `fix(sepa): correct IBAN validation for Austrian banks`
  - `security(dsgvo): add cookie consent management`

## Pull Request Structure

### PR-Titel

- Kurzer Nutzenfokus, beginnt mit Verb
- **Format:** `Add|Fix|Update|Remove <feature/component>`
- **Beispiele:**
  - `Add SEPA mandate management system`
  - `Fix authentication token expiry handling`
  - `Update privacy center with DSGVO compliance`

### PR-Beschreibung Template

```markdown
## Was wurde geändert?

<!-- Kurze Zusammenfassung der Änderungen -->

## Warum?

<!-- Motivation, Business-Kontext, Problem das gelöst wird -->

## Wie?

<!-- Technische Umsetzung, Architektur-Entscheidungen -->

## Risiken & Breaking Changes

<!-- Potentielle Auswirkungen, Rückwärtskompatibilität -->

## Tests

<!-- Wie wurde getestet? Welche Tests wurden hinzugefügt? -->

- [ ] Unit Tests
- [ ] Integration Tests
- [ ] Manual Testing
- [ ] DSGVO Compliance Check (bei Datenschutz-Änderungen)

## Rollback Plan

<!-- Falls etwas schief geht, wie kann zurückgerollt werden? -->

## Screenshots (optional)

<!-- Bei UI-Änderungen -->
```

## Spezielle Anforderungen

### DSGVO/Datenschutz PRs

- **Label:** `privacy`, `dsgvo-relevant`
- **Review:** Minimum 2 Reviewer, davon 1 mit Datenschutz-Kenntnissen
- **Dokumentation:** Datenschutzerklärung aktualisieren wenn nötig

### Security PRs

- **Label:** `security`
- **Review:** Security-Team Review erforderlich
- **Testing:** Penetration Testing bei kritischen Änderungen

### Financial/SEPA PRs

- **Label:** `financial`, `sepa`
- **Review:** Minimum 2 Reviewer + Compliance Check
- **Testing:** Test mit echten Bankdaten in Staging-Umgebung

## Branch Naming

- **Feature:** `feature/auth-2fa-implementation`
- **Bugfix:** `fix/sepa-iban-validation`
- **Hotfix:** `hotfix/security-vulnerability-patch`
- **Release:** `release/v1.2.0`
