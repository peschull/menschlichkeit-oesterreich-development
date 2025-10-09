# Secrets Management Helper Scripts

Diese Sammlung von Scripts automatisiert das sichere Management der über 50 Secrets für die 17-Database-Architektur von Menschlichkeit Österreich.

## 📋 Übersicht der Scripts

| Script | Zweck | Verwendung |
| --- | --- | --- |
| `setup-github-secrets.ps1` | Bulk-Upload aller Secrets zu GitHub | PowerShell mit GitHub CLI |
| `generate-production-secrets.py` | Sichere Credential-Generierung | Python3 mit kryptographischen Libraries |
| `validate-secrets.sh` | Verbindungstests für alle Services | Bash mit DB-Clients |
| `rotate-secrets.sh` | Automatische Secret-Rotation | Bash für regelmäßige Wartung |

## 🔐 1. GitHub Secrets Setup (`setup-github-secrets.ps1`)

**Zweck:** Automatischer Upload aller 50+ Secrets zu GitHub Repository Secrets für staging/production Environments.

### Voraussetzungen

```powershell
# GitHub CLI installieren und authentifizieren
gh auth login
```

### Verwendung

```powershell
# Alle verfügbaren Secrets anzeigen
./scripts/setup-github-secrets.ps1 -ShowSecretsList

# SSH-Keys für GitHub Actions generieren
./scripts/setup-github-secrets.ps1 -GenerateKeys

# Dry-Run (keine Änderungen)
./scripts/setup-github-secrets.ps1 -DryRun -Environment staging

# Alle Secrets nach staging deployen
./scripts/setup-github-secrets.ps1 -Environment staging

# Alle Secrets nach production deployen  
./scripts/setup-github-secrets.ps1 -Environment production
```

### Features

- ✅ Bulk-Upload von 50+ Secrets
- ✅ SSH-Key Generierung für Deployments
- ✅ Dry-Run Modus
- ✅ Kategorisierte Secret-Liste
- ✅ Rate-Limiting und Error-Handling

## 🛠️ 2. Production Secrets Generator (`generate-production-secrets.py`)

**Zweck:** Generierung kryptographisch sicherer Credentials für alle Services.

### Voraussetzungen

```bash
python3 -m pip install --user secrets
```

### Verwendung

```bash
# Alle Secrets generieren und exportieren
python3 scripts/generate-production-secrets.py

# Generiert:
# - .env.production.generated (für lokale Entwicklung)
# - secrets.production.json (strukturierte Daten)
```

### Generierte Credentials

- **17 Database-Passwords** (24-32 Zeichen, komplex)
- **JWT & API Keys** (32-64 Zeichen Hex)
- **Admin Passwords** (16-24 Zeichen mit Sonderzeichen)
- **Webhook Secrets** (16-32 Zeichen Hex)
- **SMTP Passwords** (16 Zeichen, Shell-sicher)

### Security Features

- ✅ Kryptographisch sichere Zufallsgenerierung (`secrets` module)
- ✅ Keine mehrdeutigen Zeichen (0O1lI|)
- ✅ Mindestens ein Zeichen aus jeder Kategorie
- ✅ Shell-sichere Sonderzeichen
- ✅ Strukturierte Ausgabe für verschiedene Anwendungsfälle

## ✅ 3. Secrets Validator (`validate-secrets.sh`)

**Zweck:** Umfassende Validation aller Datenbankverbindungen und Service-Endpoints.

### Voraussetzungen

```bash
# Optional: DB-Clients für vollständige Tests
sudo apt-get install mysql-client postgresql-client redis-tools
```

### Verwendung

```bash
# Alle Tests ausführen
./scripts/validate-secrets.sh

# Spezifische Test-Kategorien
./scripts/validate-secrets.sh databases    # Nur Datenbank-Tests
./scripts/validate-secrets.sh services     # Nur HTTP-Endpoint Tests
./scripts/validate-secrets.sh smtp         # Nur SMTP-Tests
./scripts/validate-secrets.sh ssh          # Nur SSH-Tests
./scripts/validate-secrets.sh env          # Nur Environment-Variable Tests
```

### Test-Kategorien

- **Database Connections:** Alle 17 Datenbanken (5 Plesk MariaDB, 9 External MariaDB, 3 PostgreSQL)
- **HTTP Endpoints:** Website, CRM, API, Games, n8n
- **SMTP Configuration:** Mail-Server und Authentication
- **SSH Access:** Plesk-Server Verbindung
- **Environment Variables:** Kritische Secrets auf Vollständigkeit

### Output

```bash
📊 Test Results:
✅ Passed: 42
❌ Failed: 3
📊 Total: 45
📈 Success Rate: 93%
📄 Log File: validation-20251007_143527.log
```

## 🔄 4. Secret Rotation (`rotate-secrets.sh`)

**Zweck:** Automatische Rotation kritischer Secrets (empfohlen: alle 90 Tage).

### Verwendung

```bash
# Dry-Run (keine Änderungen)
./scripts/rotate-secrets.sh dry-run

# Alle nicht-kritischen Secrets rotieren
./scripts/rotate-secrets.sh

# Nur Application Secrets
./scripts/rotate-secrets.sh app

# Nur Admin Passwords
./scripts/rotate-secrets.sh admin

# Datenbank-Passwörter (KRITISCH - Wartungsfenster erforderlich)
ROTATE_DATABASES=true ./scripts/rotate-secrets.sh database
```

### Rotierte Secrets

- **Application Secrets:** JWT, API Keys, Webhook Secrets
- **Admin Passwords:** CRM, n8n, Grafana
- **Optional:** Database Passwords (mit Maintenance Window)

### Safety Features

- ✅ Automatisches Backup vor Rotation
- ✅ Dry-Run Modus
- ✅ Validation nach Rotation
- ✅ Dokumentation-Updates
- ✅ Rotation-Reports

## 📊 Workflow Integration

### Empfohlener Deployment-Workflow

```bash
# 1. Neue Secrets generieren
python3 scripts/generate-production-secrets.py

# 2. Secrets nach GitHub uploaden
./scripts/setup-github-secrets.ps1 -Environment production

# 3. Konfiguration validieren
./scripts/validate-secrets.sh

# 4. Deployment durchführen  
npm run deploy:production

# 5. Post-Deployment Validation
./scripts/validate-secrets.sh services
```

### Regelmäßige Wartung

```bash
# Alle 90 Tage: Secret Rotation
./scripts/rotate-secrets.sh

# Wöchentlich: Validation
./scripts/validate-secrets.sh

# Bei Bedarf: Neue Secrets generieren
python3 scripts/generate-production-secrets.py
```

## 🔒 Security Best Practices

### DO ✅

- Scripts in sicherer Umgebung ausführen
- Generierte Secret-Dateien nach Upload löschen
- Regelmäßige Rotation (90 Tage)
- Backup vor kritischen Änderungen
- Validation nach jeder Änderung

### DON'T ❌

- Secrets niemals in Git committen
- Keine unverschlüsselten Backups
- Scripts nicht mit Root-Rechten ausführen
- Keine Secrets in Logs/Output

## 📋 Checkliste für neues Environment

- [ ] `python3 scripts/generate-production-secrets.py`
- [ ] `./scripts/setup-github-secrets.ps1 -Environment <env>`
- [ ] GitHub Repository Secrets konfiguriert
- [ ] SSH-Keys für Deployment hochgeladen
- [ ] `./scripts/validate-secrets.sh`
- [ ] Erste Deployment getestet
- [ ] Monitoring & Alerting konfiguriert
- [ ] Backup-Strategie etabliert
- [ ] Rotation-Schedule geplant (90 Tage)

## 🆘 Troubleshooting

### Häufige Probleme

**GitHub CLI Authentifizierung:**

```bash
gh auth status
gh auth login
```

**Missing Database Clients:**

```bash
# Ubuntu/Debian
sudo apt-get install mysql-client postgresql-client redis-tools

# macOS
brew install mysql postgresql redis
```

**Permission Errors:**

```bash
chmod +x scripts/*.sh
```

**Environment Variables nicht geladen:**

```bash
# Prüfe .env-Dateien
ls -la .env*
source .env.deployment
```

---

**🔐 REMEMBER:** Alle Scripts arbeiten mit echten Produktions-Secrets. Sichere Behandlung ist essentiell!
