# 🛠️ Scripts Directory

Hilfs-Skripte für Deployment, Synchronisation und Setup.

## 📋 Verfügbare Skripte

### Security & Setup

#### `generate-secrets.sh`
Generiert alle benötigten Security Keys und Secrets.

```bash
./scripts/generate-secrets.sh
```

**Generiert:**
- JWT Secret für API Authentication
- n8n Encryption Key
- Laravel App Key
- n8n Admin Password

**Output:** `secrets/generated-secrets.env`

### Deployment

#### `safe-deploy.sh`
Sicheres Deployment mit Pre-Checks.

```bash
./scripts/safe-deploy.sh
```

**Features:**
- Pre-deployment Validierung
- Backup vor Deployment
- Rollback bei Fehler

### Synchronisation

#### `plesk-sync.sh`
Synchronisiert Dateien zwischen lokal und Plesk Server.

```bash
# Preview (Dry-Run)
./scripts/plesk-sync.sh pull

# Tatsächliche Ausführung
./scripts/plesk-sync.sh pull --apply
./scripts/plesk-sync.sh push --apply
```

**⚠️ WICHTIG:** Immer erst Dry-Run durchführen!

#### `db-pull.sh`
Lädt Production Database in lokale Entwicklungsumgebung.

```bash
./scripts/db-pull.sh
```

**⚠️ VORSICHT:** Überschreibt lokale Datenbank!

#### `db-push.sh`
Lädt lokale Database auf Production Server.

```bash
./scripts/db-push.sh --apply
```

**🚨 GEFÄHRLICH:** Nur mit `--apply` Flag verwenden, nur wenn sicher!

### MCP Server

#### `start-mcp-servers.ps1`
Startet Model Context Protocol Server (PowerShell).

```powershell
.\scripts\start-mcp-servers.ps1
```

### Secrets Management

#### `secrets-decrypt.ps1`
Entschlüsselt verschlüsselte Secrets (PowerShell).

```powershell
.\scripts\secrets-decrypt.ps1
```

## 🔒 Sicherheit

### Secrets niemals committen!
- `.env` Dateien sind in `.gitignore`
- `secrets/generated-secrets.env` ist excluded
- Immer `.gitignore` prüfen vor commit

### Best Practices
1. Verwende `generate-secrets.sh` für neue Keys
2. Speichere Secrets in Password Manager
3. Rotiere Secrets regelmäßig (alle 90 Tage)
4. Verwende unterschiedliche Secrets für Prod/Dev

## 🚀 Quick Start Workflow

### Erstes Setup
```bash
# 1. Generiere Secrets
./scripts/generate-secrets.sh

# 2. Kopiere in .env Dateien
cat secrets/generated-secrets.env
# Manuell in .env Dateien eintragen

# 3. Füge Database Credentials hinzu (von Plesk)

# 4. Starte Services
npm run dev:all
```

### Deployment Workflow
```bash
# 1. Teste lokal
npm run build
npm run test

# 2. Safe Deploy
./scripts/safe-deploy.sh

# 3. Überprüfe Live
curl https://api.menschlichkeit-oesterreich.at/health
```

### Sync Workflow
```bash
# 1. Backup (Dry-Run)
./scripts/plesk-sync.sh pull

# 2. Tatsächlicher Pull
./scripts/plesk-sync.sh pull --apply

# 3. Lokale Änderungen
# ... mache Änderungen ...

# 4. Push (VORSICHTIG!)
./scripts/plesk-sync.sh push --apply
```

## 📚 Weitere Dokumentation

- [ZUGANGSDATEN-CHECKLISTE.md](../ZUGANGSDATEN-CHECKLISTE.md) - Credentials Guide
- [README.md](../README.md) - Project Documentation
- [deployment-scripts/](../deployment-scripts/) - Plesk Deployment Scripts
