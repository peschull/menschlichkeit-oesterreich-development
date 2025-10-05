# Datenbank-Status Report - Menschlichkeit Österreich
**Erstellt:** 5. Oktober 2025
**Status:** Deployment abgeschlossen, DB-Provisioning ausstehend

---

## 📊 Executive Summary

### Aktuelle Situation
- ✅ **Website deployed** und online (https://www.menschlichkeit-oesterreich.at)
- ⚠️ **CRM deployed** aber HTTP 403 (DB-Verbindung fehlt)
- ⚠️ **API deployed** aber nicht gestartet (DB-Verbindung fehlt)
- ❌ **Keine Datenbanken** auf Plesk-Server provisioniert
- ❌ **Externe DB-Hosts** noch nicht eingerichtet

### Kritische Blocker
1. **CiviCRM (Drupal)**: Benötigt MariaDB-Verbindung zu `mo_crm`
2. **Educational Games**: Benötigt PostgreSQL-Verbindung zu `mo_games`
3. **API-Service**: Benötigt Datenbank für Sessions/Cache
4. **n8n Automation**: Benötigt MariaDB für Workflow-Daten

---

## 🗄️ Datenbank-Architektur

### Plesk Server (5 DB Limit - ERREICHT)

Laut Secret-Inventory existieren bereits **5 produktive MariaDB-Datenbanken** auf dem Plesk-Server:

| DB Name | Service | User | Status | Priorität |
|---------|---------|------|--------|-----------|
| `mo_main` | Hauptseite | `svc_main` | ✅ Produktiv | HIGH |
| `mo_votes` | Abstimmungen | `svc_votes` | ✅ Produktiv | HIGH |
| `mo_support` | Support-Tickets | `svc_support` | ✅ Produktiv | MEDIUM |
| `mo_newsletter` | Newsletter | `svc_newsletter` | ✅ Produktiv | MEDIUM |
| `mo_forum` | Forum | `svc_forum` | ✅ Produktiv | LOW |

**Problem:** Plesk-Plan erlaubt maximal 5 Datenbanken - **Limit erreicht**!

### Externe MariaDB (9 neue Datenbanken)

**Status:** ❌ Nicht provisioniert
**Host:** Noch nicht bekannt (muss extern bereitgestellt werden)

| DB Name | Service | User | Priorität | Anmerkung |
|---------|---------|------|-----------|-----------|
| `mo_crm` | CiviCRM (Drupal) | `svc_crm` | **CRITICAL** | CRM läuft nicht ohne DB |
| `mo_games` | Educational Games | `svc_games` | **HIGH** | Siehe `schema.prisma` |
| `mo_n8n` | n8n Automation | `svc_n8n` | **HIGH** | Workflow-Speicher |
| `mo_consent` | DSGVO Consent | `svc_consent` | **HIGH** | Compliance |
| `mo_hooks` | Webhook-Handler | `svc_hooks` | MEDIUM | Event-Verarbeitung |
| `mo_analytics` | Analytics Engine | `svc_analytics` | MEDIUM | Tracking |
| `mo_nextcloud` | Nextcloud | `svc_nextcloud` | MEDIUM | Cloud-Storage |
| `mo_api_stg` | API Staging | `svc_api_stg` | LOW | Development |
| `mo_admin_stg` | Admin Staging | `svc_admin_stg` | LOW | Development |

### Externe PostgreSQL (3 Datenbanken)

**Status:** ❌ Nicht provisioniert
**Host:** Noch nicht bekannt

| DB Name | Service | User | Priorität | Anmerkung |
|---------|---------|------|-----------|-----------|
| `mo_idp` | Keycloak (Identity) | `svc_idp` | HIGH | Single Sign-On |
| `mo_grafana` | Grafana Monitoring | `svc_grafana` | MEDIUM | Observability |
| `mo_discourse` | Discourse Forum | `svc_discourse` | LOW | Community |

---

## 🚨 Kritische Abhängigkeiten

### 1. CiviCRM (BLOCKIERT)
**Problem:** Drupal + CiviCRM deployed, aber:
- ❌ Keine `mo_crm` Datenbank vorhanden
- ❌ `sites/default/settings.php` fehlt (DB-Credentials)
- ❌ CiviCRM Installation nicht abgeschlossen

**Lösung:**
```bash
# 1. Externen MariaDB-Host bereitstellen
export MYSQL_HOST=externe-db.provider.com
export MYSQL_ADMIN_USER=admin
export MYSQL_ADMIN_PASS='SecurePassword'

# 2. Datenbank provisionieren
bash scripts/db/provision-mariadb.sh --apply --db mo_crm --user svc_crm

# 3. CRM-Settings generieren
bash deployment-scripts/drupal/setup-civicrm-settings.sh

# 4. CiviCRM-Installation durchführen
ssh plesk "cd crm.menschlichkeit-oesterreich.at/httpdocs && \
  vendor/bin/drush civicrm:install --db-url='mysql://svc_crm:PASS@HOST/mo_crm'"
```

### 2. Educational Games (Prisma + PostgreSQL)
**Problem:**
- `schema.prisma` definiert Game-Models (User, Achievement, GameSession)
- ❌ Keine PostgreSQL-Datenbank `mo_games` vorhanden
- ❌ Prisma Migrations nicht ausgeführt

**Lösung:**
```bash
# 1. PostgreSQL extern bereitstellen
export PG_HOST=postgres.provider.com
export PG_ADMIN_USER=postgres
export PG_ADMIN_PASS='SecurePassword'

# 2. Datenbank provisionieren
bash scripts/db/provision-postgres.sh --apply --db mo_games --user svc_games

# 3. Prisma Migrations ausführen
cd web/
DATABASE_URL="postgresql://svc_games:PASS@HOST:5432/mo_games" \
  npx prisma migrate deploy

# 4. Prisma Client generieren
npx prisma generate
```

### 3. API-Service (FastAPI)
**Problem:**
- FastAPI deployed, aber nicht gestartet
- ❌ Keine DB für Sessions/Cache
- ❌ Kein Systemd-Service konfiguriert

**Lösung:**
```bash
# 1. Datenbank für API (kann mo_main nutzen oder eigene mo_api)
# Wenn neue DB gewünscht:
bash scripts/db/provision-mariadb.sh --apply --db mo_api --user svc_api

# 2. Systemd-Service erstellen (auf Plesk-Server)
# Oder via Plesk Control Panel:
# - Python-Anwendung konfigurieren
# - Document Root: api.menschlichkeit-oesterreich.at/httpdocs
# - Startup File: app/main.py
# - Environment Variables: DATABASE_URL, etc.
```

### 4. n8n Automation
**Problem:**
- Docker-basiert, lokal getestet
- ❌ Keine `mo_n8n` Datenbank für Workflow-Persistenz
- ❌ Nicht auf Plesk-Server deployt (Docker nicht verfügbar)

**Lösung:**
- **Option A:** n8n auf separatem VPS mit Docker
- **Option B:** n8n SQLite (ohne externe DB)
- **Option C:** n8n als Node.js-Prozess auf Plesk mit `mo_n8n` MariaDB

---

## 📋 Provisioning-Checkliste

### Phase 1: Kritische DBs (ASAP)
- [ ] **Externe MariaDB Host bereitstellen** (z.B. DigitalOcean Managed DB, AWS RDS)
- [ ] **`mo_crm` provisionieren** (User: `svc_crm`)
- [ ] **`mo_games` provisionieren** (PostgreSQL, User: `svc_games`)
- [ ] **CiviCRM-Settings** generieren und deployen
- [ ] **Prisma Migrations** auf `mo_games` ausführen

### Phase 2: Services aktivieren
- [ ] **API-Service starten** (Plesk Python App oder Systemd)
- [ ] **CRM testen** (https://crm.menschlichkeit-oesterreich.at/user/login)
- [ ] **Games testen** (DB-Verbindung prüfen)
- [ ] **n8n entscheiden**: VPS vs. Plesk vs. SQLite

### Phase 3: Weitere DBs (optional)
- [ ] `mo_n8n` (wenn n8n auf Plesk)
- [ ] `mo_consent` (DSGVO-Compliance)
- [ ] `mo_hooks` (Webhook-Event-Log)
- [ ] `mo_analytics` (Custom Analytics)
- [ ] `mo_nextcloud` (wenn Nextcloud gewünscht)

### Phase 4: Identity & Monitoring
- [ ] `mo_idp` (Keycloak PostgreSQL)
- [ ] `mo_grafana` (Monitoring PostgreSQL)
- [ ] `mo_discourse` (Forum PostgreSQL)

---

## 🔧 Provisioning-Scripts

### Bereits vorhanden:
- ✅ `scripts/db/provision-mariadb.sh` - MariaDB DB+User erstellen
- ✅ `scripts/db/provision-postgres.sh` - PostgreSQL DB+User erstellen
- ✅ `deployment-scripts/drupal/setup-civicrm-settings.sh` - CiviCRM Config

### Fehlend:
- ❌ Script für **Plesk DB-Verwaltung** (falls Limit erhöht wird)
- ❌ **DB-Migration-Scripts** (Produktions-Daten importieren)
- ❌ **Backup-Scripts** (automatisierte DB-Backups)

---

## 💡 Empfohlene DB-Provider

### MariaDB (9 Datenbanken)
**Option 1: DigitalOcean Managed Database**
- Kosten: ~$15/Monat (Basic Plan)
- Bis zu 10 Datenbanken pro Cluster
- Automatische Backups
- Hohe Verfügbarkeit

**Option 2: AWS RDS MariaDB**
- Kosten: ~$12/Monat (db.t3.micro)
- Unbegrenzte Datenbanken
- Point-in-time Recovery
- Skalierbar

**Option 3: Hetzner Cloud + Self-Managed**
- Kosten: ~$5/Monat (CX21)
- Volle Kontrolle
- Mehr Wartungsaufwand

### PostgreSQL (3 Datenbanken)
**Option 1: DigitalOcean PostgreSQL**
- Kosten: ~$15/Monat
- Bis zu 10 Datenbanken
- PostgreSQL 15+

**Option 2: AWS RDS PostgreSQL**
- Kosten: ~$13/Monat (db.t3.micro)
- High-Performance

**Option 3: Supabase (für mo_games)**
- Kosten: Free Tier verfügbar
- PostgreSQL + REST API
- Ideal für Prisma

---

## 🚀 Nächste Schritte (Priorität)

### Sofort (Heute):
1. **Externe DB-Hosts auswählen und bereitstellen**
   - MariaDB Host für 9 Datenbanken
   - PostgreSQL Host für 3 Datenbanken

2. **Credentials als GitHub Secrets speichern:**
   - `MYSQL_HOST`, `MYSQL_ADMIN_USER`, `MYSQL_ADMIN_PASS`
   - `PG_HOST`, `PG_ADMIN_USER`, `PG_ADMIN_PASS`
   - Alle `*_DB_PASS` Secrets aus Secret-Inventory

3. **Kritische DBs provisionieren:**
   ```bash
   # mo_crm (CiviCRM)
   bash scripts/db/provision-mariadb.sh --apply --db mo_crm --user svc_crm

   # mo_games (Educational Games)
   bash scripts/db/provision-postgres.sh --apply --db mo_games --user svc_games
   ```

### Diese Woche:
4. **CiviCRM konfigurieren:**
   ```bash
   bash deployment-scripts/drupal/setup-civicrm-settings.sh
   rsync -avz crm.menschlichkeit-oesterreich.at/web/sites/ \
     plesk:crm.menschlichkeit-oesterreich.at/httpdocs/sites/
   ```

5. **Prisma Migrations deployen:**
   ```bash
   cd web/
   DATABASE_URL="postgresql://svc_games:$PASSWORD@$PG_HOST:5432/mo_games" \
     npx prisma migrate deploy
   ```

6. **API-Service starten** (Plesk Python App)

### Nächste 2 Wochen:
7. n8n-Strategie finalisieren
8. Weitere DBs nach Bedarf provisionieren
9. Backup-Strategie implementieren
10. Monitoring (Grafana) aufsetzen

---

## 📊 Kosten-Schätzung

| Service | Provider | Monatliche Kosten |
|---------|----------|-------------------|
| MariaDB (9 DBs) | DigitalOcean Managed | $15 |
| PostgreSQL (3 DBs) | DigitalOcean Managed | $15 |
| **Gesamt** | | **$30/Monat** |

**Alternative (Günstiger):**
- Hetzner Cloud CX21: $5/Monat
- Self-Managed MariaDB + PostgreSQL
- **Gesamt:** $5/Monat (+ Wartungsaufwand)

---

## ✅ Erfolgs-Kriterien

- [ ] CRM läuft und zeigt Login-Seite (nicht 403)
- [ ] Educational Games können Daten in DB speichern
- [ ] API-Service antwortet auf https://api.menschlichkeit-oesterreich.at/docs
- [ ] Alle Passwörter als GitHub Secrets hinterlegt
- [ ] DB-Backups laufen täglich automatisch
- [ ] Monitoring zeigt DB-Health-Status

---

**Stand:** 5. Oktober 2025, 14:02 Uhr
**Deployment:** ✅ Erfolgreich (Website online)
**Datenbanken:** ⚠️ Provisioning ausstehend (kritischer Blocker)
