# Architekturplan: Menschlichkeit Österreich Development Platform

## Übersicht

Die **Menschlichkeit Österreich Development Platform** ist eine **Multi-Service Austrian NGO Platform** mit strikter Service-Trennung und Enterprise-Grade DevOps-Infrastruktur. Das System implementiert eine moderne, DSGVO-konforme Architektur zur Verwaltung von Mitgliedschaften, Spenden und demokratischen Bildungsressourcen für die österreichische Zivilgesellschaft.

### Hauptziele
- **DSGVO-Compliance**: Vollständige Implementation der EU-Datenschutzverordnung mit österreichischen Besonderheiten
- **NGO-Fokus**: Spezialisierte Funktionen für Vereinsverwaltung, Mitgliedermanagement und Spendenabwicklung
- **Educational Gaming**: Interaktive Demokratie-Lernspiele zur politischen Bildung
- **Service-Isolation**: Unabhängige Services für bessere Skalierbarkeit und Wartbarkeit
- **Austrian Compliance**: BAO § 132, DSG und SEPA-Rulebook konforme Implementierung

## Komponenten

### 1. API Service (`api.menschlichkeit-oesterreich.at/`)
**Technologie**: FastAPI (Python 3.11+) + Pydantic + PostgreSQL  
**Port**: 8001 (Development)  
**Zweck**: Zentrale REST-API für alle Frontend- und Service-Integrationen

**Hauptmodule**:
- **Authentication System**: JWT-basierte Anmeldung mit Access/Refresh Token-Rotation
- **CiviCRM Integration**: HTTP-API Verbindung zum CRM-System
- **DSGVO Privacy Routes**: Art. 17 Recht auf Vergessenwerden Implementation
- **SEPA Integration**: Österreichische SEPA-Mandate und Lastschriftverfahren
- **PII Sanitization**: Automatische Anonymisierung in Logs und Fehlermeldungen

**Referenz**: #file:api.menschlichkeit-oesterreich.at/app/main.py

### 2. CRM System (`crm.menschlichkeit-oesterreich.at/`)
**Technologie**: Drupal 10 + CiviCRM 5.x + MariaDB  
**Port**: 8000 (Development)  
**Zweck**: Professionelle Mitglieder- und Spendenverwaltung

**Hauptmodule**:
- **CiviCRM Core**: Kontakt-, Mitgliedschafts- und Beitragsverwaltung
- **Drupal Integration**: Content-Management und Benutzeroberfläche
- **SEPA-Connector**: Direkte SEPA-XML-Generierung für österreichische Banken
- **Reporting Engine**: Finanzberichte und Mitgliederstatistiken
- **Event Management**: Veranstaltungsplanung und Ticketing

**Referenz**: #file:crm.menschlichkeit-oesterreich.at/docker-compose.yml

### 3. Frontend Service (`frontend/`)
**Technologie**: React 18+ + TypeScript 5+ + TailwindCSS + Vite  
**Port**: 3000 (Development)  
**Zweck**: Moderne Hauptwebsite mit Design System Integration

**Hauptmodule**:
- **Design System**: Figma-synchronized Design Tokens und Komponenten
- **User Interface**: Responsive, barrierefreie Benutzeroberfläche (WCAG AA)
- **Authentication UI**: Anmelde- und Registrierungsformulare
- **Member Portal**: Persönlicher Bereich für Mitglieder
- **DSGVO Interface**: Cookie-Consent und Datenschutz-Management

**Referenz**: #file:frontend/src/components/

### 4. Gaming Platform (`web/`)
**Technologie**: Prisma ORM + PostgreSQL + TypeScript  
**Port**: 3000 (Development)  
**Zweck**: Educational Democracy Games für politische Bildung

**Hauptmodule**:
- **Achievement System**: XP-basierte Belohnungen und Abzeichen
- **Game Sessions**: Multiplayer-Demokratiesimulationen
- **Progress Tracking**: Individueller Lernfortschritt
- **Leaderboards**: Gamification-Elemente
- **Analytics**: Lernverhalten und Engagement-Metriken

**Referenz**: #file:schema.prisma (Gaming Models)

### 5. Website Service (`website/`)
**Technologie**: WordPress/Static HTML  
**Zweck**: Statische Inhalte und Landing Pages

**Hauptmodule**:
- **Static Content**: Informationsseiten und Blogbeiträge
- **SEO Optimization**: Suchmaschinenoptimierung
- **Legal Pages**: Impressum, Datenschutz, AGB

**Referenz**: #file:website/

### 6. Automation Service (`automation/n8n/`)
**Technologie**: n8n (Docker) + Webhook-Integration  
**Port**: 5678 (Development)  
**Zweck**: Workflow-Automatisierung und Service-Integration

**Hauptmodule**:
- **Build Notifications**: CI/CD Pipeline Benachrichtigungen
- **Email Automation**: Newsletter und Transaktions-E-Mails
- **External API Integration**: Drittanbieter-Services
- **Data Synchronization**: Service-übergreifende Datenabgleiche
- **Monitoring Alerts**: System-Health und Error-Notifications

**Referenz**: #file:automation/n8n/

### 7. Shared Infrastructure
**Design System**: Figma Design Tokens in #file:figma-design-system/00_design-tokens.json  
**Database Schema**: Prisma Schema in #file:schema.prisma  
**Build Pipeline**: Multi-Service Build in #file:build-pipeline.sh  
**MCP Servers**: AI-Integration in #file:mcp-servers/  

## Datenfluss

### 1. User Authentication Flow
```
Frontend → API Service → JWT Token Generation → User Session
    ↓
API Service → CiviCRM → User Validation → Contact Retrieval
    ↓
Gaming Platform → API Service → Achievement Updates → XP Tracking
```

### 2. Membership Management Flow
```
Frontend → API Service → CiviCRM Integration → Member Creation
    ↓
n8n Automation → Welcome Email → External Services
    ↓
SEPA Processing → Austrian Banking → Payment Confirmation
```

### 3. DSGVO Compliance Flow
```
User Request → API Privacy Endpoint → Data Deletion Request
    ↓
Admin Review → CiviCRM Data Removal → Gaming Platform Anonymization
    ↓
Audit Log → Compliance Report → Legal Documentation
```

### 4. Design System Synchronization Flow
```
Figma Design Updates → MCP Figma Server → Token Extraction
    ↓
GitHub Repository → Build Pipeline → Token Distribution
    ↓
Frontend Build → TailwindCSS Generation → UI Updates
```

## Schnittstellen und APIs

### 1. REST API Endpoints
**Base URL**: `https://api.menschlichkeit-oesterreich.at/v1/`

**Authentifizierung**:
- `POST /auth/login` - JWT Token Generation
- `POST /auth/refresh` - Token-Erneuerung
- `POST /auth/register` - Benutzerregistrierung

**Mitgliederverwaltung**:
- `GET /user/profile` - Benutzerprofil
- `PUT /user/profile` - Profil-Update
- `GET /user/memberships` - Mitgliedschaften

**DSGVO Compliance**:
- `POST /privacy/data-deletion` - Löschantrag
- `GET /privacy/data-deletion` - Antragsstatus

**CiviCRM Integration**:
- `GET /contacts/{id}` - Kontakt-Details
- `POST /contacts/create` - Kontakt erstellen
- `POST /sepa/mandate` - SEPA-Mandat

**Referenz**: #file:docs/API-SPEZIFIKATION-DE.md

### 2. GraphQL Schema (geplant v2.0)
```graphql
type User {
  id: ID!
  email: String!
  memberships: [Membership!]!
  achievements: [Achievement!]!
  gdprConsent: GDPRConsent
}

type Mutation {
  requestDataDeletion(reason: DeletionReason!): DeletionRequest!
  createSEPAMandate(iban: String!, bic: String!): SEPAMandate!
}
```

### 3. Webhook Integration
**n8n Webhooks**:
- `POST /webhook/build-notification` - Build Status
- `POST /webhook/member-registration` - Neue Mitglieder
- `POST /webhook/payment-confirmation` - SEPA Bestätigungen

### 4. Inter-Service Communication
**Service Mesh**:
```
API ↔ CRM: HTTP REST (CiviCRM API)
API ↔ Gaming: Direct Database (Prisma)
Frontend ↔ API: REST + WebSocket (geplant)
n8n ↔ All Services: Webhook + HTTP
```

## Abhängigkeiten

### 1. Externe Services
**Datenbank**:
- **PostgreSQL 16+**: Haupt-Datenbank für Gaming und API
- **MariaDB 10.11**: CiviCRM-Datenbank

**Authentifizierung**:
- **JWT**: PyJWT 2.8.0+ für Token-Management
- **OAuth2**: Geplante Integration für Social Login

**Payment Processing**:
- **SEPA-Clearing**: Österreichische Bankenintegration
- **Stripe**: Alternative Payment-Processor (geplant)

**Email Services**:
- **SMTP Provider**: Transaktions-E-Mails
- **Newsletter Service**: Mailchimp/SendGrid Integration

### 2. Development Dependencies
**Frontend**:
```json
{
  "react": "^18.2.0",
  "typescript": "^5.0.0",
  "tailwindcss": "^3.3.0",
  "vite": "^4.4.0"
}
```

**API Service**:
```python
fastapi==0.104.1
pydantic==2.5.0
PyJWT==2.8.0
prisma==0.11.0
httpx==0.25.2
```

**CRM Service**:
```json
{
  "drupal/core": "^10.1",
  "civicrm/civicrm-core": "^5.65",
  "composer/composer": "^2.0"
}
```

### 3. Infrastructure Dependencies
**Container Runtime**:
- **Docker 24.0+**: Service-Containerisierung
- **Docker Compose**: Development Environment

**Monitoring & Logging**:
- **ELK Stack**: Elasticsearch, Logstash, Kibana (geplant)
- **Prometheus**: Metriken-Sammlung (geplant)

**CI/CD Pipeline**:
- **GitHub Actions**: Automatisierte Builds und Deployments
- **Codacy**: Code Quality Analysis
- **Trivy**: Security Scanning

**Referenz**: #file:build-pipeline.sh

### 4. Austrian/EU Compliance Dependencies
**DSGVO**:
- **Cookie Consent**: GDPR-konforme Cookie-Banner
- **Data Retention**: Automatisierte Löschprozesse
- **Audit Logging**: Compliance-Nachweise

**Österreichische Standards**:
- **BAO § 132**: 7-Jahres-Aufbewahrung für Spendendaten
- **SEPA-Rulebook**: EU-weite Lastschriftverfahren
- **DSG**: Österreichisches Datenschutzgesetz

## Deployment

### 1. Development Environment
**Lokale Entwicklung**:
```bash
npm run dev:all         # Alle Services starten
# - CRM: http://localhost:8000
# - API: http://localhost:8001  
# - Frontend: http://localhost:3000
# - Gaming: http://localhost:3000
# - n8n: http://localhost:5678
```

**Docker Compose**:
```yaml
services:
  drupal:      # CRM Service
  mariadb:     # CRM Database
  postgres:    # API/Gaming Database
  redis:       # Session Storage
  n8n:         # Automation
```

**Referenz**: #file:crm.menschlichkeit-oesterreich.at/docker-compose.yml

### 2. Production Deployment
**Hosting-Provider**: Plesk Shared Hosting (Austrian Provider)

**Service-Mapping**:
```
menschlichkeit-oesterreich.at       → Website Service
api.menschlichkeit-oesterreich.at   → API Service  
crm.menschlichkeit-oesterreich.at   → CRM Service
```

**Deployment Pipeline**:
```bash
./build-pipeline.sh production
# 1. Quality Gates (Security, DSGVO, Performance)
# 2. Multi-Service Build
# 3. Database Migrations
# 4. SFTP Upload via Plesk
# 5. Health Checks
# 6. Rollback on Failure
```

**Referenz**: #file:deployment-scripts/multi-service-deploy.sh

### 3. Skalierung & High Availability
**Load Balancing**: Nginx Reverse Proxy (geplant)
**Database Replication**: PostgreSQL Streaming Replication
**CDN Integration**: Static Asset Delivery
**Backup Strategy**: Automatisierte tägliche Backups

### 4. Monitoring & Observability
**Health Checks**:
```bash
GET /health              # API Service
GET /admin/reports/status  # CRM Service  
GET /            # Frontend Availability
```

**Metrics Collection**:
- **Application Metrics**: Response Times, Error Rates
- **Infrastructure Metrics**: CPU, Memory, Disk Usage
- **Business Metrics**: Membership Growth, Donation Volumes

**Alerting**:
- **n8n Webhook Integration**: Slack/Email Notifications
- **DSGVO Compliance Alerts**: Data Breach Detection
- **Financial Alerts**: SEPA Processing Failures

**Log Aggregation**:
```
All Services → Filebeat → Logstash → Elasticsearch → Kibana
```

**Referenz**: #file:docs/security/F-03-PHASE-4-ARCHITECTURE.md

---

**Architektur-Version**: 1.0.0  
**Letzte Aktualisierung**: 7. Oktober 2025  
**Maintainer**: Menschlichkeit Österreich Development Team

**Ergänzende Dokumentation**:
- **API-Spezifikation**: #file:docs/API-SPEZIFIKATION-DE.md
- **DSGVO Compliance**: #file:analysis/phase-0/threat-model/STRIDE-LINDDUN-ANALYSIS.md
- **Quality Gates**: #file:.github/instructions/quality-gates.instructions.md
- **MCP Integration**: #file:.github/instructions/mcp-integration.instructions.md