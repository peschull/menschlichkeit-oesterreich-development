# API-Spezifikation: Menschlichkeit Österreich Backend

## Zweck der API

Die **Menschlichkeit Österreich API** dient als zentrale Schnittstelle für die digitale NGO-Plattform und stellt folgende Hauptfunktionalitäten bereit:

- **CRM-Integration**: Verbindung zu CiviCRM für Kontakt- und Mitgliederverwaltung
- **Authentifizierung**: JWT-basierte Benutzeranmeldung mit Token-Rotation
- **DSGVO-Compliance**: Implementation des Rechts auf Vergessenwerden (Art. 17 DSGVO)
- **SEPA-Integration**: Verwaltung von SEPA-Mandaten für österreichische NGO-Spenden
- **Sicherheit**: PII-Sanitization in Logs und umfassende Security-Events

**Zielgruppe**:

- Frontend-Entwickler (React/TypeScript)
- n8n Automation-Workflows
- Externe Integrationen (Gaming Platform, Mobile Apps)
- NGO-Administratoren

## Authentifizierung & Autorisierung

### JWT-Token System

**Authentifizierungsschema**: Bearer Token (JWT)

```http
Authorization: Bearer <access_token>
```

**Token-Typen**:

- **Access Token**: 1 Stunde Gültigkeit, für API-Zugriff
- **Refresh Token**: 7 Tage Gültigkeit, für Token-Erneuerung

**JWT-Payload-Struktur**:

```json
{
  "sub": "user@example.org",
  "type": "access|refresh", 
  "iat": 1696500000,
  "exp": 1696503600,
  "jti": "unique-token-id"
}
```

### Benutzerrollen

- **User**: Standard-Benutzer (Profil, eigene Daten)
- **Admin**: Administratorrechte (alle Endpoints, DSGVO-Verwaltung)

### Umgebungsvariablen

```bash
JWT_SECRET=mindestens_32_zeichen_production_secret
CIVI_BASE_URL=https://crm.menschlichkeit-oesterreich.at
CIVI_SITE_KEY=civicrm_site_key
CIVI_API_KEY=civicrm_api_key
```

## Endpoint-Auflistung

### 1. Authentifizierung

#### POST /auth/login

**Beschreibung**: Benutzeranmeldung mit E-Mail-Adresse  
**Authentifizierung**: Keine  
**Parameter**:

```json
{
  "email": "user@example.org" 
}
```

**Antwort** (200):

```json
{
  "success": true,
  "data": {
    "tokens": {
      "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "expires_in": 3600
    },
    "contact": {
      "id": 123,
      "email": "user@example.org",
      "first_name": "Max",
      "last_name": "Mustermann"
    }
  },
  "message": "Login successful"
}
```

#### POST /auth/register

**Beschreibung**: Kontakt erstellen/aktualisieren und Tokens ausgeben  
**Authentifizierung**: Keine  
**Parameter**:

```json
{
  "email": "user@example.org",
  "first_name": "Max", 
  "last_name": "Mustermann",
  "phone": "+43 1 234567890"
}
```

#### POST /auth/refresh

**Beschreibung**: Access Token mittels Refresh Token erneuern  
**Authentifizierung**: Refresh Token  
**Parameter**:

```json
{
  "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

### 2. Benutzerprofil

#### GET /user/profile

**Beschreibung**: Aktuelles Benutzerprofil abrufen  
**Authentifizierung**: Bearer Token  
**Parameter**: Keine  
**Antwort** (200):

```json
{
  "success": true,
  "data": {
    "contact": {
      "id": 123,
      "email": "user@example.org",
      "first_name": "Max",
      "last_name": "Mustermann"
    }
  }
}
```

#### PUT /user/profile

**Beschreibung**: Benutzerprofil aktualisieren  
**Authentifizierung**: Bearer Token  
**Parameter**:

```json
{
  "first_name": "Max",
  "last_name": "Mustermann",
  "phone": "+43 1 234567890"
}
```

### 3. Kontakt-Management

#### POST /contacts/create

**Beschreibung**: Neuen Kontakt in CiviCRM erstellen  
**Authentifizierung**: Bearer Token  
**Parameter**: `ContactCreate` Schema (siehe Datenmodelle)

#### GET /contacts/{contact_id}

**Beschreibung**: Kontakt-Details abrufen  
**Authentifizierung**: Bearer Token  
**URL-Parameter**: `contact_id` (integer)

#### PUT /contacts/{contact_id}

**Beschreibung**: Kontakt aktualisieren  
**Authentifizierung**: Bearer Token  
**Parameter**: `ContactUpdate` Schema

### 4. Mitgliedschaften

#### GET /user/memberships

**Beschreibung**: Mitgliedschaften des aktuellen Benutzers  
**Authentifizierung**: Bearer Token

#### POST /memberships/create

**Beschreibung**: Neue Mitgliedschaft erstellen  
**Authentifizierung**: Bearer Token  
**Parameter**: `MembershipCreate` Schema

#### PUT /memberships/{membership_id}

**Beschreibung**: Mitgliedschaft aktualisieren  
**Authentifizierung**: Bearer Token  
**Parameter**: `MembershipUpdate` Schema

### 5. SEPA-Mandate

#### POST /sepa/mandate

**Beschreibung**: SEPA-Mandat erstellen (nur Speicherung)  
**Authentifizierung**: Bearer Token  
**Parameter**:

```json
{
  "contact_id": 123,
  "iban": "AT611904300234573201",
  "bic": "BKAUATWW",
  "mandate_type": "RCUR"
}
```

#### GET /sepa/mandate/{contact_id}

**Beschreibung**: SEPA-Mandat abrufen  
**Authentifizierung**: Bearer Token

### 6. DSGVO Privacy (Recht auf Vergessenwerden)

#### POST /privacy/data-deletion

**Beschreibung**: Löschantrag nach DSGVO Art. 17 stellen  
**Authentifizierung**: Bearer Token  
**Parameter**:

```json
{
  "reason": "no_longer_needed",
  "additional_info": "Freiwilliger Austritt"
}
```

#### GET /privacy/data-deletion

**Beschreibung**: Eigene Löschanträge abrufen  
**Authentifizierung**: Bearer Token

#### POST /privacy/data-deletion/{request_id}/process

**Beschreibung**: Löschantrag bearbeiten (Admin)  
**Authentifizierung**: Bearer Token (Admin)  
**Parameter**:

```json
{
  "action": "approve",
  "admin_notes": "Antrag berechtigt, Löschung eingeleitet"
}
```

#### GET /privacy/data-deletion/admin/all

**Beschreibung**: Alle Löschanträge (Admin)  
**Authentifizierung**: Bearer Token (Admin)

### 7. System

#### GET /health

**Beschreibung**: Health Check für Monitoring  
**Authentifizierung**: Keine  
**Antwort**:

```json
{
  "status": "healthy",
  "timestamp": "2025-10-07T10:30:00Z",
  "version": "1.0.0"
}
```

## Datenmodelle

### ContactCreate

```json
{
  "type": "object",
  "required": ["email", "first_name", "last_name"],
  "properties": {
    "email": {"type": "string", "format": "email"},
    "first_name": {"type": "string"},
    "last_name": {"type": "string"},
    "phone": {"type": "string"},
    "address": {
      "type": "object",
      "properties": {
        "street": {"type": "string"},
        "city": {"type": "string"},
        "postal_code": {"type": "string"},
        "country": {"type": "string", "default": "AT"}
      }
    }
  }
}
```

### MembershipCreate

```json
{
  "type": "object", 
  "required": ["contact_id", "membership_type", "start_date"],
  "properties": {
    "contact_id": {"type": "integer"},
    "membership_type": {"type": "string", "enum": ["standard", "premium", "student"]},
    "start_date": {"type": "string", "format": "date"},
    "auto_renew": {"type": "boolean", "default": true}
  }
}
```

### ApiResponse (Standard)

```json
{
  "type": "object",
  "properties": {
    "success": {"type": "boolean"},
    "data": {"type": "object"},
    "message": {"type": "string"},
    "timestamp": {"type": "string", "format": "date-time"}
  }
}
```

### DataDeletionRequest (DSGVO)

```json
{
  "type": "object",
  "required": ["reason"],
  "properties": {
    "reason": {
      "type": "string",
      "enum": [
        "no_longer_needed",
        "withdraw_consent", 
        "unlawful_processing",
        "legal_obligation",
        "other"
      ]
    },
    "additional_info": {"type": "string", "maxLength": 500}
  }
}
```

## Beispiele

### Kompletter Authentifizierungs-Flow

```bash
# 1. Login
curl -X POST https://api.menschlichkeit-oesterreich.at/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "max@example.org"}'

# Antwort:
{
  "success": true,
  "data": {
    "tokens": {
      "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
      "expires_in": 3600
    }
  }
}

# 2. Geschützten Endpoint aufrufen
curl -X GET https://api.menschlichkeit-oesterreich.at/user/profile \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."

# 3. Token erneuern (nach ~50 Minuten)
curl -X POST https://api.menschlichkeit-oesterreich.at/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."}'
```

### DSGVO Löschantrag

```bash
# Löschantrag stellen
curl -X POST https://api.menschlichkeit-oesterreich.at/privacy/data-deletion \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "no_longer_needed",
    "additional_info": "Austritt aus dem Verein"
  }'

# Antwort:
{
  "success": true,
  "data": {
    "request_id": 12345,
    "status": "pending"
  },
  "message": "Löschantrag wurde erfolgreich eingereicht"
}
```

### SEPA-Mandat erstellen

```bash
curl -X POST https://api.menschlichkeit-oesterreich.at/sepa/mandate \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "contact_id": 123,
    "iban": "AT611904300234573201", 
    "bic": "BKAUATWW",
    "mandate_type": "RCUR"
  }'
```

## Fehlerbehandlung

### Standard HTTP-Statuscodes

| Code | Bedeutung | Verwendung |
|------|-----------|------------|
| 200 | OK | Erfolgreiche Anfrage |
| 201 | Created | Ressource erfolgreich erstellt |
| 400 | Bad Request | Ungültige Anfrage-Parameter |
| 401 | Unauthorized | Fehlende/ungültige Authentifizierung |
| 403 | Forbidden | Unzureichende Berechtigung |
| 404 | Not Found | Ressource nicht gefunden |
| 422 | Unprocessable Entity | Validierungsfehler |
| 429 | Too Many Requests | Rate Limit überschritten |
| 500 | Internal Server Error | Server-Fehler |

### Fehler-Response Format

```json
{
  "success": false,
  "data": null,
  "message": "Beschreibende Fehlermeldung",
  "error": {
    "code": "VALIDATION_ERROR",
    "details": {
      "field": "email", 
      "message": "Ungültiges E-Mail-Format"
    }
  }
}
```

### Spezifische Fehlercodes

| Code | Beschreibung |
|------|--------------|
| `INVALID_CREDENTIALS` | Login-Daten ungültig |
| `TOKEN_EXPIRED` | Access Token abgelaufen |
| `TOKEN_INVALID` | JWT-Token ungültig/manipuliert |
| `REFRESH_TOKEN_REUSED` | Refresh Token bereits verwendet |
| `VALIDATION_ERROR` | Request-Validierung fehlgeschlagen |
| `CIVICRM_ERROR` | CiviCRM-Integration Fehler |
| `RATE_LIMIT_EXCEEDED` | Zu viele Anfragen |
| `ADMIN_REQUIRED` | Admin-Berechtigung erforderlich |

## Rate Limiting

- **Global**: 60 Anfragen pro Minute
- **Pro API-Key**: 10 Anfragen pro Minute
- **Headers**: `X-RateLimit-Remaining`, `X-RateLimit-Reset`

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1696503600
```

## CORS-Konfiguration

**Erlaubte Origins** (Development):

- `http://localhost:5173` (Frontend)
- `http://localhost:4180` (Games)

**Erlaubte Methoden**: GET, POST, PUT, PATCH, DELETE, OPTIONS  
**Erlaubte Headers**: Authorization, Content-Type, Accept  
**Credentials**: Erlaubt  

## Versionsstrategie

### Aktuelle Version: v1.0.0

**URL-Schema**: `https://api.menschlichkeit-oesterreich.at/v1/`

**Versionierungs-Ansatz**:

- **Major** (v2.x): Breaking Changes, neue URL-Pfade
- **Minor** (v1.x): Neue Features, abwärtskompatibel  
- **Patch** (v1.0.x): Bugfixes, Sicherheitsupdates

**Deprecation-Policy**:

- 6 Monate Vorankündigung für Breaking Changes
- Alte Versionen werden 12 Monate nach Deprecation unterstützt
- Migration-Guides für Major-Updates

### Geplante Änderungen

**v1.1.0** (Q1 2026):

- `/auth/logout` Endpoint
- `/user/security-logs` für Audit-Trail
- Push-Notification Integration

**v2.0.0** (Q3 2026):

- GraphQL-Support
- Multi-Tenancy für mehrere NGOs
- Advanced RBAC (Role-Based Access Control)

## DSGVO-Compliance

### Implementierte Maßnahmen

- **PII-Sanitization**: Automatische Redaktierung in Logs
- **Consent Management**: Integration mit CiviCRM
- **Right to Erasure**: Vollständiger DSGVO Art. 17 Workflow
- **Data Minimization**: Nur erforderliche Daten sammeln
- **Audit Trail**: Security-Events werden geloggt

### Österreichische Besonderheiten

- **BAO § 132**: 7-Jahres-Aufbewahrungspflicht für Spendendaten beachtet
- **SEPA-Rulebook §4.5**: 14-Monats-Aufbewahrung für SEPA-Mandate
- **DSG**: Österreichisches Datenschutzgesetz-konforme Umsetzung

## Sicherheitsmaßnahmen

### Authentifizierung

- JWT mit 256-bit HMAC Signierung
- Token-Rotation bei Refresh
- Automatische Token-Invalidierung bei Verdacht

### Input-Validierung

- Pydantic Schema-Validierung für alle Endpoints
- SQL-Injection-Schutz durch CiviCRM API
- XSS-Schutz durch Content-Security-Policy

### Logging & Monitoring

- Strukturiertes JSON-Logging
- PII-Sanitization in allen Logs
- Security-Event-Tracking
- Rate-Limiting mit Redis/Memory-Store

### Infrastruktur

- HTTPS-only (TLS 1.3)
- CORS-Policy für bekannte Origins
- Health-Checks für Monitoring
- Automated Security Scanning (Trivy, Gitleaks)

---

**Dokument-Version**: 1.0.0  
**Letzte Aktualisierung**: 7. Oktober 2025  
**Maintainer**: Menschlichkeit Österreich Development Team

**Weiterführende Dokumentation**:

- [#file:openapi.yaml](api.menschlichkeit-oesterreich.at/openapi.yaml) - OpenAPI 3.0 Spezifikation
- [#file:app/main.py](api.menschlichkeit-oesterreich.at/app/main.py) - FastAPI Implementierung  
- [#file:app/routes/privacy.py](api.menschlichkeit-oesterreich.at/app/routes/privacy.py) - DSGVO Endpoints
- [#file:docs/security/AUTHENTICATION-FLOWS.md](docs/security/AUTHENTICATION-FLOWS.md) - Detaillierte Auth-Flows
