# Secret Inventory & GitHub Secrets Mapping
**Erstellt:** 2025-10-05
**Status:** ✅ Produktionsreif
**Zweck:** Vollständige Übersicht aller Secrets, ENV-Variablen und deren Quellen für sichere CI/CD-Integration

---

## 🔐 Executive Summary

Dieses Dokument inventarisiert **alle** Secrets aus:
- `.env` (aktuell im Repo; GITHUB_TOKEN erkannt)
- `.env.example` (Template)
- `config-templates/.env.production.template` (neu erstellt)
- Frühere `website/Plesk daten mit passwörter.txt` (jetzt gelöscht, Informationen extrahiert)

**Aktion:** Alle sensiblen Werte müssen als **GitHub Repository Secrets** oder **Environment Secrets** (Production/Staging) hinterlegt werden.

---

## 📋 GitHub Secrets & Variables – Quick Reference

### SSH & Deployment (erforderlich für `.github/workflows/deploy.yml`)

| Secret/Variable Name | Typ | Quelle | Beispiel/Format | Status |
|---------------------|-----|--------|-----------------|--------|
| `SSH_HOST` | Secret | .env.example | `dmpl20230054@<server-ip>` | ⚠️ Zu setzen |
| `SSH_PORT` | Variable | .env.production.template | `22` | ⚠️ Zu setzen |
| `SSH_PRIVATE_KEY` | Secret | .env.example | PEM-Format (mehrzeilig) | ⚠️ Zu setzen |
| `SSH_TARGET_DIR` | Secret | .env.production.template | `/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs` | ⚠️ Zu setzen |

**Systembenutzer (öffentlich):** `dmpl20230054`

### Plesk Server Info (öffentlich, als Variables)

| Variable Name | Typ | Wert | Status |
|--------------|-----|------|--------|
| `BASE_DOMAIN` | Variable | `menschlichkeit-oesterreich.at` | ⚠️ Zu setzen |
| `PLESK_VHOSTS_BASE` | Variable | `/var/www/vhosts/menschlichkeit-oesterreich.at` | ⚠️ Zu setzen |
| `PLESK_SERVER_IP` | Variable | (Server-IP aus Plesk-Daten) | ⚠️ Zu setzen |
| `DB_SERVER_TYPE` | Variable | `MariaDB 10.6.22` | ⚠️ Zu setzen |
| `WEBSERVER` | Variable | `nginx/1.28.0` | ⚠️ Zu setzen |
| `PHP_VERSION` | Variable | `8.4.11` | ⚠️ Zu setzen |

---

## 🗄️ Externe Datenbank-Hosts

### MariaDB (extern)

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `MYSQL_HOST` | Secret | Externer MariaDB Host (IP/Domain) | ⚠️ Zu setzen |
| `MYSQL_PORT` | Variable | `3306` | ⚠️ Zu setzen |
| `MYSQL_ADMIN_USER` | Secret | Admin-Benutzername für Provisioning | ⚠️ Zu setzen |
| `MYSQL_ADMIN_PASS` | Secret | Admin-Passwort (für DB-Provisionierung) | ⚠️ Zu setzen |

### PostgreSQL (extern)

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `PGHOST` | Secret | Externer PostgreSQL Host (IP/Domain) | ⚠️ Zu setzen |
| `PGPORT` | Variable | `5432` | ⚠️ Zu setzen |
| `PGADMIN_USER` | Secret | Admin-Benutzername für Provisioning | ⚠️ Zu setzen |
| `PGADMIN_PASS` | Secret | Admin-Passwort | ⚠️ Zu setzen |

### Redis (extern, optional)

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `REDIS_HOST` | Secret | Redis Server IP/Domain | ⚠️ Optional |
| `REDIS_PORT` | Variable | `6379` | ⚠️ Optional |
| `REDIS_PASS` | Secret | Redis Passwort | ⚠️ Optional |

---

## 💾 Bestehende MariaDB-Datenbanken (Plesk, 5 DBs – Limit erreicht)

Diese 5 Datenbanken existieren bereits auf dem Plesk-Server und nutzen das **aktuelle 5-DB-Limit** vollständig aus.

| DB Name | User | Passwort Secret | Zweck | Status |
|---------|------|----------------|-------|--------|
| `mo_main` | `svc_main` | `MO_MAIN_DB_PASS` | Hauptseite | ✅ Produktiv |
| `mo_votes` | `svc_votes` | `MO_VOTES_DB_PASS` | Abstimmungen | ✅ Produktiv |
| `mo_support` | `svc_support` | `MO_SUPPORT_DB_PASS` | Support-Tickets | ✅ Produktiv |
| `mo_newsletter` | `svc_newsletter` | `MO_NEWSLETTER_DB_PASS` | Newsletter-Verwaltung | ✅ Produktiv |
| `mo_forum` | `svc_forum` | `MO_FORUM_DB_PASS` | Forum | ✅ Produktiv |

**Aktion:** Passwörter als GitHub Secrets hinterlegen (siehe Tabelle oben).

---

## 🆕 Neue MariaDB-Datenbanken (extern, 9 DBs)

Werden auf externem MariaDB-Host bereitgestellt (via `scripts/db/provision-mariadb.sh`).

| DB Name | User | Passwort Secret | Service | Status |
|---------|------|----------------|---------|--------|
| `mo_crm` | `svc_crm` | `MO_CRM_DB_PASS` | CiviCRM (Drupal) | ⚠️ Provisioning |
| `mo_n8n` | `svc_n8n` | `MO_N8N_DB_PASS` | n8n Automation | ⚠️ Provisioning |
| `mo_hooks` | `svc_hooks` | `MO_HOOKS_DB_PASS` | Webhook-Handler | ⚠️ Provisioning |
| `mo_consent` | `svc_consent` | `MO_CONSENT_DB_PASS` | DSGVO Consent | ⚠️ Provisioning |
| `mo_games` | `svc_games` | `MO_GAMES_DB_PASS` | Educational Games | ⚠️ Provisioning |
| `mo_analytics` | `svc_analytics` | `MO_ANALYTICS_DB_PASS` | Analytics Engine | ⚠️ Provisioning |
| `mo_api_stg` | `svc_api_stg` | `MO_API_STG_DB_PASS` | API Staging | ⚠️ Provisioning |
| `mo_admin_stg` | `svc_admin_stg` | `MO_ADMIN_STG_DB_PASS` | Admin Staging | ⚠️ Provisioning |
| `mo_nextcloud` | `svc_nextcloud` | `MO_NEXTCLOUD_DB_PASS` | Nextcloud | ⚠️ Provisioning |

---

## 🐘 PostgreSQL-Datenbanken (extern, 3 DBs)

Werden auf externem PostgreSQL-Host bereitgestellt (via `scripts/db/provision-postgres.sh`).

| DB Name | User | Passwort Secret | Service | Status |
|---------|------|----------------|---------|--------|
| `mo_idp` | `svc_idp` | `PG_IDP_DB_PASS` | Keycloak (Identity) | ⚠️ Provisioning |
| `mo_grafana` | `svc_grafana` | `PG_GRAFANA_DB_PASS` | Grafana Monitoring | ⚠️ Provisioning |
| `mo_discourse` | `svc_discourse` | `PG_DISCOURSE_DB_PASS` | Discourse Forum | ⚠️ Provisioning |

---

## ☁️ Nextcloud-Konfiguration

Verwendet von `scripts/nextcloud/setup-nextcloud.sh`.

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `NC_BASE_URL` | Variable | `https://cloud.menschlichkeit-oesterreich.at` | ⚠️ Zu setzen |
| `NC_TRUSTED_DOMAINS` | Variable | `cloud.menschlichkeit-oesterreich.at` | ⚠️ Zu setzen |
| `NC_DB_HOST` | Secret | Externer MariaDB Host (wie `MYSQL_HOST`) | ⚠️ Zu setzen |
| `NC_DB_NAME` | Variable | `mo_nextcloud` | ⚠️ Zu setzen |
| `NC_DB_USER` | Variable | `svc_nextcloud` | ⚠️ Zu setzen |
| `NC_DB_PASS` | Secret | `MO_NEXTCLOUD_DB_PASS` | ⚠️ Zu setzen |
| `NC_REDIS_HOST` | Secret | Redis Host (optional) | ⚠️ Optional |
| `NC_REDIS_PORT` | Variable | `6379` | ⚠️ Optional |
| `NC_REDIS_PASS` | Secret | `REDIS_PASS` | ⚠️ Optional |
| `NC_ADMIN_USER` | Secret | Nextcloud Admin Username | ⚠️ Zu setzen |
| `NC_ADMIN_PASS` | Secret | Nextcloud Admin Passwort | ⚠️ Zu setzen |
| `NC_OIDC_ISSUER` | Secret | Keycloak URL, z.B. `https://idp.menschlichkeit-oesterreich.at/realms/main` | ⚠️ Zu setzen |
| `NC_OIDC_CLIENT_ID` | Variable | `nextcloud` | ⚠️ Zu setzen |
| `NC_OIDC_CLIENT_SECRET` | Secret | OIDC Client Secret (von Keycloak) | ⚠️ Zu setzen |

---

## 📧 E-Mail-Konfiguration (aus .env.example)

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `MAIL_LOGGING_EMAIL` | Secret | logging@menschlichkeit-oesterreich.at | ⚠️ Zu setzen |
| `MAIL_LOGGING_PASSWORD` | Secret | Passwort | ⚠️ Zu setzen |
| `MAIL_INFO_EMAIL` | Secret | info@… | ⚠️ Zu setzen |
| `MAIL_INFO_PASSWORD` | Secret | Passwort | ⚠️ Zu setzen |
| `MAIL_ADMIN_EMAIL` | Secret | admin@… | ⚠️ Zu setzen |
| `MAIL_ADMIN_PASSWORD` | Secret | Passwort | ⚠️ Zu setzen |
| `MAIL_CIVIMAIL_EMAIL` | Secret | civimail@… | ⚠️ Zu setzen |
| `MAIL_CIVIMAIL_PASSWORD` | Secret | Passwort | ⚠️ Zu setzen |
| `MAIL_BOUNCE_EMAIL` | Secret | bounce@… | ⚠️ Zu setzen |
| `MAIL_BOUNCE_PASSWORD` | Secret | Passwort | ⚠️ Zu setzen |
| `MAIL_HOST` | Variable | `mail.menschlichkeit-oesterreich.at` | ⚠️ Zu setzen |
| `MAIL_PORT` | Variable | `587` | ⚠️ Zu setzen |
| `MAIL_ENCRYPTION` | Variable | `tls` | ⚠️ Zu setzen |

---

## 🔑 API Keys & Tokens

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `GITHUB_TOKEN` | Secret | GitHub PAT (aktuell in .env) | ✅ Vorhanden (lokal) |
| `CODACY_API_TOKEN` | Secret | Codacy API Token | ⚠️ Zu setzen |
| `SNYK_TOKEN` | Secret | Snyk Security Token | ⚠️ Optional |
| `N8N_ENCRYPTION_KEY` | Secret | 32-Zeichen Verschlüsselungs-Key | ⚠️ Zu setzen |
| `CIVICRM_SITE_KEY` | Secret | CiviCRM Site Key | ⚠️ Zu setzen |
| `CIVICRM_API_KEY` | Secret | CiviCRM API Key | ⚠️ Zu setzen |
| `JWT_SECRET` | Secret | JWT Signing Key (32 Zeichen) | ⚠️ Zu setzen |

---

## 🔧 n8n Automation

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `N8N_USER` | Secret | n8n Admin User | ⚠️ Zu setzen |
| `N8N_PASSWORD` | Secret | n8n Admin Passwort | ⚠️ Zu setzen |
| `N8N_HOST` | Variable | `localhost` oder `n8n.menschlichkeit-oesterreich.at` | ⚠️ Zu setzen |
| `N8N_PORT` | Variable | `5678` | ⚠️ Zu setzen |

---

## 📊 Optional: Performance Monitoring

| Secret Name | Typ | Beschreibung | Status |
|------------|-----|--------------|--------|
| `LHCI_SERVER_BASE_URL` | Variable | Lighthouse CI Server URL | ⚠️ Optional |
| `LHCI_TOKEN` | Secret | Lighthouse CI Token | ⚠️ Optional |
| `HEALTH_URL` | Variable | Post-Deploy Health Check (z.B. `https://menschlichkeit-oesterreich.at/healthz.txt`) | ⚠️ Optional |

---

## ✅ Abnahmekriterien

- [x] Unsichere Datei `website/Plesk daten mit passwörter.txt` gelöscht
- [x] `.gitignore` erweitert: Patterns für `*passwort*.txt`, `*password*.txt`, `*credentials*.txt`, `*zugangsdaten*.txt`
- [x] `.env.production.template` mit allen DB/Service-Secrets erstellt
- [x] Secret-Inventar mit vollständiger Mapping-Tabelle erstellt
- [ ] **Alle** Secrets als GitHub Repository Secrets hinterlegt (siehe Checkliste)
- [ ] GitHub Actions Workflow `.github/workflows/deploy.yml` getestet (Dry-Run)
- [ ] DB-Provisionierungs-Scripts `scripts/db/provision-*.sh` mit echten Admin-Credentials ausgeführt
- [ ] Nextcloud Setup via `scripts/nextcloud/setup-nextcloud.sh` mit echten ENV-Werten getestet
- [ ] Firewall-Regeln auf externen DB-Hosts: Zugriff nur von Plesk-Server-IP

---

## 🚀 Nächste Schritte

1. **GitHub Secrets anlegen:**
   - Repository Settings → Secrets and variables → Actions → New repository secret
   - Für jeden Eintrag mit ⚠️ in den Tabellen oben

2. **Environment Secrets (Production/Staging):**
   - Settings → Environments → Production → Add secret
   - Trennung Production/Staging für DB-Credentials empfohlen

3. **Externe DB-Hosts bereitstellen:**
   ```bash
   # Mit Admin-Credentials als ENV
   export MYSQL_HOST=externe-db.provider.at
   export MYSQL_ADMIN_USER=admin
   export MYSQL_ADMIN_PASS='SecureAdminPass'

   # Dry-Run
   bash scripts/db/provision-mariadb.sh --dry-run

   # Apply
   bash scripts/db/provision-mariadb.sh --apply
   ```

4. **Deployment-Workflow testen:**
   - GitHub Actions → Deploy via SSH (Plesk) → Run workflow
   - Direction: `push`, Apply: `false` (Dry-Run)

5. **Lokale .env pflegen:**
   - Kopiere `config-templates/.env.production.template` → `.env`
   - Fülle Development-Werte (nie committen!)

---

## 🔒 Sicherheitshinweise

- **NIEMALS** Secrets in Git committen
- **NIEMALS** `.env` oder `*.decrypted` Dateien committen
- Verwende **nur** GitHub Secrets für CI/CD
- Rotiere Passwörter regelmäßig (alle 90 Tage)
- Audit-Log für Secret-Zugriffe in GitHub überwachen
- Bei Leak: Sofort rotieren + `git filter-repo` für History-Cleanup

---

**Verantwortlich:** DevOps/SecOps
**Review-Datum:** 2025-10-05
**Nächste Review:** 2026-01-05
