# Passwort-/Secret-Rotationsplan – 2025-10-05

Ziel: Alle bekannten Secrets sicher rotieren und nur noch über GitHub Secrets/Server-ENV verwenden.

## Priorität P0 (sofort)
- Systembenutzer-Passwort (Plesk) – Benutzer: dmpl20230054
- MariaDB Passwörter (5 produktive DBs): mo_main, mo_votes, mo_support, mo_newsletter, mo_forum
- Eventuell weitere Mail-Account-Passwörter, falls im Umlauf

Vorgehen:
1) Neues, starkes Passwort generieren (mind. 20 Zeichen, high-entropy)
2) Auf Plesk/DB-Server ändern
3) GitHub Secrets aktualisieren
4) Dienste/Apps neu deployen, die das Secret verwenden

## Priorität P1 (kurzfristig)
- Externe MariaDB- und PostgreSQL-Admin-User (MYSQL_ADMIN_*, PGADMIN_*)
- Redis-Passwort
- Nextcloud Admin Passwort, OIDC Client Secret

## Priorität P2 (mittelfristig)
- Alle API-Schlüssel (Snyk, Codacy, n8n, etc.)

## Nachweise/Compliance
- Änderungen dokumentieren (Datum, Verantwortliche, Umfang)
- Optional: in secrets/rotation-log/ (gitignored) lokale Notizen führen
