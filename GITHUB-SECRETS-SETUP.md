# GitHub Secrets Setup für Menschlichkeit Österreich

## 🔐 Repository Secrets

### Kritische Produktions-Secrets (REQUIRED)

```
PLESK_HOST=dmpl20230054@5.183.217.146
SSH_PRIVATE_KEY=[Inhalt der ~/.ssh/id_ed25519 Datei]
LARAVEL_DB_USER=laravel_user
LARAVEL_DB_PASS=SECURE_LARAVEL_2025
LARAVEL_DB_NAME=mo_laravel_api
CIVICRM_DB_USER=civicrm_user
CIVICRM_DB_PASS=SECURE_CIVICRM_2025
CIVICRM_DB_NAME=mo_civicrm_data
```

### Quality & Security Tools

```
CODACY_API_TOKEN=[Von Codacy Dashboard]
SNYK_TOKEN=[Von Snyk Settings]
SONAR_TOKEN=[Von SonarCloud/SonarQube]
```

### n8n Automation

```
N8N_USER=[Admin Username für n8n]
N8N_PASSWORD=[Sicheres Passwort für n8n]
N8N_ENCRYPTION_KEY=[32-Zeichen Verschlüsselungsschlüssel]
```

### CiviCRM Integration

```
CIVICRM_SITE_KEY=[CiviCRM Site Key]
CIVICRM_API_KEY=[CiviCRM API v4 Key]
JWT_SECRET=[32-Zeichen JWT Secret]
```

### Optional (Performance & Monitoring)

```
LHCI_TOKEN=[Lighthouse CI Token, falls verwendet]
SENTRY_DSN=[Sentry Error Tracking, falls verwendet]
```

## 🔧 GitHub Actions Environment Variables

### Development Environment

```
NODE_ENV=development
DEBUG=true
ENVIRONMENT=development
```

### Staging Environment

```
NODE_ENV=staging
DEBUG=false
ENVIRONMENT=staging
```

### Production Environment

```
NODE_ENV=production
DEBUG=false
ENVIRONMENT=production
```

## 📋 Setup Anweisungen

### 1. Repository Secrets einrichten

1. Gehe zu GitHub Repository → Settings → Secrets and variables → Actions
2. Klicke "New repository secret"
3. Füge alle Secrets aus der obigen Liste hinzu

### 2. SSH Key Setup

```bash
# SSH Key generieren (falls nicht vorhanden)
ssh-keygen -t ed25519 -C "github-actions@menschlichkeit-oesterreich.at"

# Public Key auf Plesk Server hinzufügen
ssh-copy-id -i ~/.ssh/id_ed25519.pub dmpl20230054@5.183.217.146

# Private Key als GitHub Secret SSH_PRIVATE_KEY hinzufügen:
cat ~/.ssh/id_ed25519
```

### 3. Codacy API Token

1. Gehe zu Codacy Dashboard
2. Settings → API Tokens
3. Erstelle Token mit "Repository Read" Berechtigung
4. Füge als CODACY_API_TOKEN zu GitHub Secrets hinzu

### 4. Snyk Token

1. Gehe zu Snyk Dashboard
2. Settings → General → Auth Token
3. Kopiere Token
4. Füge als SNYK_TOKEN zu GitHub Secrets hinzu

### 5. n8n Setup

1. Generiere sicheres Passwort für N8N_PASSWORD
2. Generiere 32-Zeichen Key für N8N_ENCRYPTION_KEY:

```bash
openssl rand -hex 32
```

### 6. JWT Secret generieren

```bash
openssl rand -hex 32
```

## ⚠️ Sicherheitsrichtlinien

### NIEMALS in Repository committen:

- Echte Passwörter oder API Keys
- SSH Private Keys
- Produktions-Datenbank-Credentials
- Verschlüsselungsschlüssel

### Verwende stattdessen:

- GitHub Secrets für CI/CD
- `.env` (in .gitignore) für lokale Entwicklung
- `.env.example` als sichere Vorlage

### Secret Rotation

- **Monatlich**: API Keys (Codacy, Snyk)
- **Vierteljährlich**: Datenbank-Passwörter
- **Jährlich**: SSH Keys und JWT Secrets
- **Sofort**: Bei Verdacht auf Kompromittierung

## 🔍 Secrets Validation

Teste die Secrets mit GitHub Actions:

```yaml
- name: Validate Secrets
  run: |
    echo "Testing database connection..."
    echo "Testing SSH connection..."
    echo "Testing API tokens..."
  env:
    LARAVEL_DB_PASS: ${{ secrets.LARAVEL_DB_PASS }}
    CODACY_API_TOKEN: ${{ secrets.CODACY_API_TOKEN }}
    SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
```

## 📞 Support

Bei Problemen mit Secrets:

1. Überprüfe GitHub Actions Logs
2. Validiere Secret-Namen (case-sensitive)
3. Teste lokale .env Konfiguration
4. Kontaktiere DevOps Team bei Plesk-Problemen
