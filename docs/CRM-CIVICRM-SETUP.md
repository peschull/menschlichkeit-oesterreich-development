# CiviCRM Setup Guide

Dieser Leitfaden beschreibt die vollständige Einrichtung von Drupal 10 + CiviCRM für `crm.menschlichkeit-oesterreich.at`. Die Schritte funktionieren lokal (Docker) wie auch auf dem Plesk-Server, sofern die benötigten Zugänge/Secrets vorhanden sind.

---

## 1. Voraussetzungen

| Komponente | Version / Hinweis |
| --- | --- |
| PHP | ≥ 8.2 (Plesk: 8.3 FPM) |
| Composer | ≥ 2.6 |
| Drush | Wird durch Composer installiert |
| MariaDB | Extern: `external-mysql.menschlichkeit-oesterreich.at:3306` |
| Zugang | SSH/SFTP zum Plesk-Server, DB-Benutzer mit CREATE/ALTER Rechten |

Optional für lokale Entwicklung: Docker (`crm.menschlichkeit-oesterreich.at/docker-compose.yml`).

---

## 2. Datenbank vorbereiten

Der CiviCRM-Stack nutzt eine **externe MariaDB** (Tier 2). Lege Datenbank und Benutzer wie folgt an (IP des Plesk-Servers eintragen):

```sql
CREATE DATABASE mo_crm CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'svc_crm'@'<PLESK_SERVER_IP>' IDENTIFIED BY '<STRONG_PASSWORD>';
GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,ALTER,INDEX,REFERENCES,LOCK TABLES
  ON mo_crm.* TO 'svc_crm'@'<PLESK_SERVER_IP>';
FLUSH PRIVILEGES;
```

Notiere Host, Benutzer und Passwort – sie werden im nächsten Schritt in `.env.deployment` hinterlegt.

---

## 3. Umgebungsvariablen setzen

Führe den Environment-Wizard aus, damit alle benötigten Variablen (u. a. für CRM/CiviCRM) gepflegt werden:

```bash
npm run deploy:setup-env
```

Wichtige Schlüssel im `.env.deployment`:

```env
CRM_DB_HOST="external-mysql.menschlichkeit-oesterreich.at"
CRM_DB_PORT="3306"
CRM_DB_NAME="mo_crm"
CRM_DB_USER="svc_crm"
CRM_DB_PASS="<STRONG_PASSWORD>"
CRM_BASE_URL="https://crm.menschlichkeit-oesterreich.at"
CRM_SITE_NAME="Menschlichkeit Österreich CRM"
CRM_ADMIN_USER="admin"
CRM_ADMIN_PASS="<ADMIN_PW>"
CRM_ADMIN_MAIL="crm@menschlichkeit-oesterreich.at"
CIVICRM_SITE_KEY="<UNIQUE_64_CHAR_KEY>"
```

> 💡 `CIVICRM_SITE_KEY` muss stabil sein (z. B. `openssl rand -hex 32`).

---

## 4. Automatisches Setup ausführen

Das Script `scripts/setup-civicrm.sh` übernimmt Composer-Install, Drush-Site-Install und CiviCRM-Konfiguration.

```bash
chmod +x scripts/setup-civicrm.sh
./scripts/setup-civicrm.sh
```

Was passiert:
1. `.env.deployment` wird geladen und Werte geprüft.
2. `composer install` im Verzeichnis `crm.menschlichkeit-oesterreich.at/httpdocs`.
3. `drush site:install` (nur wenn noch nicht installiert).
4. Grundlegende Drupal Config (`system.site`, Performance).
5. CiviCRM-Site-Key wird in `web/sites/default/civicrm.local.php` abgelegt.
6. `composer civicrm:install` + Cache Clear.

Fehlt eine Variable (z. B. `CRM_DB_PASS`), bricht das Script mit Hinweis ab.

---

## 5. Verifikation

| Check | Befehl | Erwartung |
| --- | --- | --- |
| Drupal Bootstrap | `vendor/bin/drush status` | Bootstrap = Successful |
| CiviCRM Tabelle | `vendor/bin/drush sql:query "SHOW TABLES LIKE 'civicrm_contact';"` | Ergebnis ≠ leer |
| CiviCRM Ping | `vendor/bin/drush civicrm:ping` | `OK` |
| Frontend | `https://crm.menschlichkeit-oesterreich.at` | Loginmaske verfügbar |

Zusätzlich sollten Logs geprüft werden (`sites/default/files/civicrm/ConfigAndLog/`).

---

## 6. Deployment auf Plesk

1. Secrets (`STAGING_REMOTE_HOST`, `STAGING_REMOTE_USER`, `STAGING_DEPLOY_KEY`, `CRM_*`) im GitHub Environment hinterlegen.
2. Workflow `deploy-staging` (oder `safe-deploy.sh`) ausführen.
3. Nach dem Upload `vendor/bin/drush cr` auf dem Server ausführen.
4. Testlogins, CiviCRM-Reports und Mailing-Queue prüfen.

---

## 7. Wartung & Backup

- Nightly DB-Backups via `backup_migrate` (Cron 02:00) – Pfad: `sites/default/files/civicrm/backup/`.
- Sensible Variablen *niemals* im Repository ablegen; stattdessen Secrets oder `.env.deployment`.
- Bei Schema-Updates: `composer update` → `drush updb` → `composer civicrm:install`.

---

## 8. Troubleshooting

| Problem | Lösung |
| --- | --- |
| `Access denied for user` | Firewall/DB Benutzerrechte prüfen; Host/IP freischalten |
| `Integrity constraint violation` | `drush updb` und CiviCRM DB-Schema vergleichen |
| Caches werden nicht geschrieben | Verzeichnis `sites/default/files` auf Schreibrechte (`www-data`) prüfen |
| E-Mails kommen nicht an | SMTP-Variablen (`CRM_SMTP_*`) verifizieren, ggf. Mailhog in Docker testen |

---

Mit diesen Schritten ist das CiviCRM-System betriebsbereit und lässt sich konsistent via CI/CD ausrollen.
