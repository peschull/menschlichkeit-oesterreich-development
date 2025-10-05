# 🏗️ Monorepo Setup - Menschlichkeit Österreich

## 📊 **Projekt-Übersicht**

Dieses Projekt ist Teil eines **Monorepo** mit mehreren Services und Deployment-Zielen.

---

## 🗂️ **Monorepo-Struktur**

```
menschlichkeit-oesterreich-monorepo/
├── 📱 frontend/                    # Main SPA (React + Vite)
│   └── → Dieses Repository
│
├── 🌐 website/                     # Static Website (HTML/CSS)
│   └── → Nutzt CSS-Variablen aus Design System
│
├── 🎮 web/                         # Games Subdomain
│   └── → Democracy Games (separates Deployment)
│
├── 🔧 api.menschlichkeit-oesterreich.at/
│   └── → REST API Backend
│
├── 💼 crm.menschlichkeit-oesterreich.at/
│   └── → CiviCRM Integration
│
├── 🤖 automation/n8n/              # Workflow Automation
│   └── → n8n Instance
│
└── 🎨 figma-design-system/         # Design Tokens & Components
    ├── 00_design-tokens.json       # Token Source
    ├── styles/figma-variables.css  # CSS Variables
    ├── components/ui/              # React Components
    └── index.ts                    # Barrel Exports
```

---

## 🌐 **Plesk Deployment-Topologie**

### **Remote-Basis:**
```
/var/www/vhosts/menschlichkeit-oesterreich.at/
```

### **Hauptdomain:**
```
httpdocs/                           → menschlichkeit-oesterreich.at
```

### **Subdomains:**

| Subdomain | Pfad | Service | DB |
|-----------|------|---------|-----|
| **api** | `subdomains/api/httpdocs` | REST API | `mo_main` / `svc_main` |
| **api.stg** | `subdomains/api.stg/httpdocs` | API Staging | `mo_api_stg` / `svc_api_stg` |
| **crm** | `subdomains/crm/httpdocs` | CiviCRM | `mo_crm` / `svc_crm` |
| **games** | `subdomains/games/httpdocs` | Democracy Games | `mo_games` / `svc_games` |
| **forum** | `subdomains/forum/httpdocs` | Forum | `mo_forum` / `svc_forum` |
| **admin.stg** | `subdomains/admin.stg/httpdocs` | Admin Staging | `mo_admin_stg` / `svc_admin_stg` |
| **analytics** | `subdomains/analytics/httpdocs` | Analytics | `mo_analytics` / `svc_analytics` |
| **consent** | `subdomains/consent/httpdocs` | Cookie Consent | `mo_consent` / `svc_consent` |
| **docs** | `subdomains/docs/httpdocs` | Documentation | - |
| **grafana** | `subdomains/grafana/httpdocs` | Monitoring | `mo_grafana` / `svc_grafana` |
| **hooks** | `subdomains/hooks/httpdocs` | Webhooks | `mo_hooks` / `svc_hooks` |
| **idp** | `subdomains/idp/httpdocs` | Identity Provider | `mo_idp` / `svc_idp` |
| **logs** | `subdomains/logs/httpdocs` | Log Viewer | - |
| **media** | `subdomains/media/httpdocs` | Media Storage | - |
| **n8n** | `subdomains/n8n/httpdocs` | Automation | `mo_n8n` / `svc_n8n` |
| **newsletter** | `subdomains/newsletter/httpdocs` | Newsletter | `mo_newsletter` / `svc_newsletter` |
| **s3** | `subdomains/s3/httpdocs` | Object Storage | - |
| **status** | `subdomains/status/httpdocs` | Status Page | `mo_status` / `svc_status` (optional) |
| **support** | `subdomains/support/httpdocs` | Support System | `mo_support` / `svc_support` |
| **votes** | `subdomains/vote/httpdocs` | Voting System | `mo_votes` / `svc_votes` |

---

## 🎨 **Figma Design System Integration**

### **MCP Server Setup:**

**Location:** `.vscode/mcp.json`

```json
{
  "mcpServers": {
    "figma": {
      "url": "https://mcp.figma.com/mcp",
      "metadata": {
        "fileKey": "YOUR_FIGMA_FILE_KEY",
        "designTokens": "figma-design-system/00_design-tokens.json",
        "syncCommand": "npm run sync-figma-tokens",
        "rulesPath": ".github/instructions/figma-mcp/stack-rules.md",
        "frameworks": ["react", "typescript", "tailwind"],
        "languages": ["typescript", "css"]
      }
    }
  }
}
```

### **Design Token Workflow:**

```
Figma Design
    ↓ (Export)
00_design-tokens.json
    ↓ (Build)
    ├── figma-design-system/styles/figma-variables.css
    ├── frontend/src/styles/tokens.css
    └── frontend/src/lib/figma-tokens.ts
    ↓ (Import)
Tailwind Config + Components
```

### **Sync-Commands:**

```bash
# Manuell
npm run sync-figma-tokens

# Automatisch (CI)
# → .github/workflows/sync-figma-tokens.yml
```

### **Environment Variables:**

```env
FIGMA_ACCESS_TOKEN=your_token_here
FIGMA_FILE_ID=extracted_from_url
```

---

## 📦 **Deployment-Workflows**

### **1. Frontend (Hauptdomain)**

**Build:**
```bash
npm run build
```

**Deploy:**
```bash
rsync -avz --delete \
  --exclude='.env*' \
  --exclude='node_modules' \
  --exclude='.git' \
  dist/ \
  dmpl20230054@menschlichkeit-oesterreich.at:/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/
```

### **2. Games Subdomain**

**Build:**
```bash
cd web
npm run build
```

**Deploy:**
```bash
rsync -avz --delete \
  dist/ \
  dmpl20230054@menschlichkeit-oesterreich.at:/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/games/httpdocs/
```

### **3. API Backend**

**Build:**
```bash
cd api
npm run build
```

**Deploy:**
```bash
rsync -avz --delete \
  --exclude='node_modules' \
  --exclude='.env*' \
  dist/ \
  dmpl20230054@menschlichkeit-oesterreich.at:/var/www/vhosts/menschlichkeit-oesterreich.at/subdomains/api/httpdocs/
```

---

## 🔑 **SSH & Sicherheit**

### **SSH-Zugang:**

```bash
ssh dmpl20230054@menschlichkeit-oesterreich.at
```

### **Wichtige Regeln:**

- ✅ **Nur SSH-Keys** verwenden (keine Passwörter im Repo)
- ✅ **Secrets in CI/CD** Environment Variables
- ✅ **Nie committen:**
  - `.env*` Dateien
  - `secrets/` Ordner
  - SSH-Keys
  - Zertifikate
  - Passwörter

### **.gitignore Essentials:**

```gitignore
# Secrets
.env
.env.local
.env.production
secrets/
*.key
*.pem

# SSH
id_rsa*
known_hosts

# Databases
*.sql
*.db

# Logs
*.log
```

---

## 🗄️ **Datenbank-Mapping**

| Service | Datenbank | User | Hinweise |
|---------|-----------|------|----------|
| Main API | `mo_main` | `svc_main` | Haupt-Datenbank |
| Votes | `mo_votes` | `svc_votes` | Voting-System |
| Support | `mo_support` | `svc_support` | Tickets |
| Newsletter | `mo_newsletter` | `svc_newsletter` | MailChimp-Sync |
| Forum | `mo_forum` | `svc_forum` | Community |
| Grafana | `mo_grafana` | `svc_grafana` | Metriken |
| IDP | `mo_idp` | `svc_idp` | OAuth/SSO |
| n8n | `mo_n8n` | `svc_n8n` | Workflows |
| Hooks | `mo_hooks` | `svc_hooks` | Webhook-Logs |
| Games | `mo_games` | `svc_games` | Highscores |
| CRM | `mo_crm` | `svc_crm` | CiviCRM |
| Consent | `mo_consent` | `svc_consent` | DSGVO |
| Analytics | `mo_analytics` | `svc_analytics` | Tracking |
| Staging API | `mo_api_stg` | `svc_api_stg` | Test-Daten |
| Staging Admin | `mo_admin_stg` | `svc_admin_stg` | Test-Admin |
| Status | `mo_status` | `svc_status` | Optional |

**Hinweis:** Passwörter werden NICHT im Repo gespeichert! Environment Variables verwenden.

---

## 🚀 **CI/CD Pipeline (GitHub Actions)**

### **Deployment-Workflow:**

```yaml
# .github/workflows/deploy.yml
name: Deploy to Plesk

on:
  push:
    branches: [main, production]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Build
        run: npm run build
        env:
          VITE_API_URL: ${{ secrets.API_URL }}
      
      - name: Deploy to Plesk
        uses: easingthemes/ssh-deploy@main
        env:
          SSH_PRIVATE_KEY: ${{ secrets.PLESK_SSH_KEY }}
          REMOTE_HOST: menschlichkeit-oesterreich.at
          REMOTE_USER: dmpl20230054
          TARGET: /var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/
          SOURCE: dist/
          EXCLUDE: ".env*, node_modules, .git"
```

---

## 📁 **Projekt-spezifische Dateiablage**

### **Design System Components:**

```
figma-design-system/components/ui/<Component>.tsx
```

### **App-spezifische Components:**

```
frontend/src/components/<Feature>/<Component>.tsx
```

### **Website (HTML/CSS):**

```
website/
├── index.html
├── assets/
│   ├── css/
│   │   └── design-tokens.css    # Von Figma
│   ├── js/
│   └── images/
└── pages/
```

---

## 🎯 **Code-Generierung aus Figma**

### **Workflow:**

1. **Figma Design** aktualisieren
2. **MCP Tools** verwenden:
   ```
   - get_metadata: Struktur analysieren
   - get_code: React + Tailwind generieren
   - get_screenshot: Visueller Vergleich
   ```
3. **Code ablegen** in:
   - Design System: `figma-design-system/components/ui/`
   - App: `frontend/src/components/`
4. **Barrel-Export** aktualisieren:
   ```typescript
   // figma-design-system/index.ts
   export { NewComponent } from './components/ui/NewComponent';
   ```

### **Prompt-Template:**

```
Generiere React + Tailwind Code aus nodeId=<NODE_ID>
- FileKey: <FILE_KEY> (aus .vscode/mcp.json)
- Nutze Tokens: figma-design-system/00_design-tokens.json
- Ablage: figma-design-system/components/ui/<Name>.tsx
- Barrel-Export: figma-design-system/index.ts aktualisieren
- WCAG 2.1 AA sicherstellen
- Keine Hardcodes, nur CSS-Variablen/Types
```

---

## 🔧 **Lokale Entwicklung**

### **Setup:**

```bash
# 1. Repo klonen
git clone <repo-url>
cd frontend

# 2. Dependencies installieren
npm install

# 3. Environment Variables
cp .env.example .env
# → .env ausfüllen

# 4. Dev-Server starten
npm run dev
```

### **Verfügbare Scripts:**

```bash
npm run dev              # Dev-Server (Port 3000)
npm run build            # Production Build
npm run preview          # Build-Preview
npm run type-check       # TypeScript prüfen
npm run lint             # ESLint
npm run test             # Vitest Tests
npm run test:e2e         # Playwright E2E
npm run test:a11y        # Accessibility
npm run sync-figma-tokens # Figma-Sync (manuell)
```

---

## 📊 **Monitoring & Logging**

### **Services:**

| Service | URL | Zweck |
|---------|-----|-------|
| **Grafana** | grafana.menschlichkeit-oesterreich.at | Monitoring-Dashboards |
| **Logs** | logs.menschlichkeit-oesterreich.at | Log-Aggregation |
| **Status** | status.menschlichkeit-oesterreich.at | Uptime-Status |
| **Analytics** | analytics.menschlichkeit-oesterreich.at | Web-Analytics |

### **Alerts:**

- Server-Down → Email + SMS
- High-Error-Rate → Email
- DB-Performance → Grafana-Alerts

---

## 🔐 **Sicherheit & Compliance**

### **DSGVO:**

- ✅ Cookie-Consent: `consent.menschlichkeit-oesterreich.at`
- ✅ Privacy-Center: In Frontend integriert
- ✅ Daten-Export: CRM + API
- ✅ Daten-Löschung: CRM + API

### **Security-Headers (Plesk):**

```nginx
# In .htaccess oder Plesk-Config
Header set X-Frame-Options "SAMEORIGIN"
Header set X-Content-Type-Options "nosniff"
Header set X-XSS-Protection "1; mode=block"
Header set Referrer-Policy "strict-origin-when-cross-origin"
Header set Permissions-Policy "geolocation=(), microphone=(), camera=()"
```

### **SSL/TLS:**

- ✅ Let's Encrypt für alle Domains
- ✅ HTTPS erzwingen
- ✅ HSTS aktivieren

---

## 📝 **Nächste Schritte**

### **Sofort:**

1. ✅ **LICENSE-Ordner beheben**
   ```bash
   rm -rf LICENSE/
   # LICENSE-Datei sollte dann vorhanden sein
   ```

2. ✅ **Figma MCP konfigurieren**
   - `.vscode/mcp.json` mit FileKey füllen
   - `.github/instructions/figma-mcp/stack-rules.md` erstellen
   - Figma Access Token in CI-Secrets

3. ✅ **Environment Variables**
   - Production `.env` erstellen
   - Secrets in GitHub Actions hinterlegen

### **Diese Woche:**

1. ✅ **Staging-Deployment testen**
   - Build zu `api.stg` deployen
   - UAT durchführen

2. ✅ **Figma-Token-Sync**
   - Manuell testen: `npm run sync-figma-tokens`
   - CI-Workflow prüfen

3. ✅ **Subdomains einrichten**
   - DNS-Einträge prüfen
   - SSL-Zertifikate für alle Subdomains

---

## 🆘 **Troubleshooting**

### **Problem: Build schlägt fehl**

```bash
# 1. Cache löschen
rm -rf node_modules package-lock.json
npm install

# 2. Type-Check
npm run type-check

# 3. Dependencies audit
npm audit fix
```

### **Problem: Deployment-Fehler**

```bash
# SSH-Verbindung testen
ssh dmpl20230054@menschlichkeit-oesterreich.at

# Rechte prüfen
ls -la /var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs/

# Logs prüfen
tail -f /var/www/vhosts/menschlichkeit-oesterreich.at/logs/error_log
```

### **Problem: Figma-Sync funktioniert nicht**

```bash
# 1. Token prüfen
echo $FIGMA_ACCESS_TOKEN

# 2. Manuell testen
curl -H "X-Figma-Token: $FIGMA_ACCESS_TOKEN" \
  https://api.figma.com/v1/files/$FIGMA_FILE_ID

# 3. Logs prüfen
cat scripts/sync-figma-tokens.sh
```

---

## 📚 **Weitere Dokumentation**

- [README.md](README.md) - Projekt-Übersicht
- [ROADMAP.md](ROADMAP.md) - Feature-Roadmap
- [ARCHITECTURE.md](ARCHITECTURE.md) - Code-Architektur
- [NEXT_STEPS.md](NEXT_STEPS.md) - Deployment-Guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution-Guide

---

**Version:** 1.0  
**Erstellt:** 2025-10-02  
**Zuletzt aktualisiert:** 2025-10-02  
**Status:** 🟢 **AKTIV**

---

<div align="center">

**Monorepo Setup komplett!** 🏗️

_Ein Projekt, viele Services, eine Vision_ ✨

</div>
