# Web Stack MCP Servers Installation and Usage Guide

## Overview

Diese MCP-Server-Suite bietet umfassende Integration für __Plesk__, __WordPress__ und __Laravel__ Entwicklungsumgebungen. Die Server ermöglichen es AI-Agents, direkt mit diesen Systemen zu interagieren und Automatisierungsaufgaben durchzuführen.

## 🚀 Quick Start

### Installation

```powershell
cd d:\Arbeitsverzeichniss\mcp-servers\web-stack
.\install.bat
```

### Alle Server starten

```powershell
npm run start:all
```

## 📦 Verfügbare MCP Server

### 1. Plesk OpenAPI Server (`plesk-openapi`)

__Zweck:__ Automatisierung von Plesk-Hosting-Operationen über die OpenAPI/Swagger-Schnittstelle

__Hauptfunktionen:__

- Domain-Management (erstellen, löschen, konfigurieren)
- Kunden-Verwaltung
- Mail-Konfiguration
- SSL-Zertifikat-Management
- Direkter Zugriff auf alle Plesk REST-API Endpunkte

__Konfiguration:__

```javascript
// Verwende das MCP-Tool: plesk_configure
{
  "host": "ihr-plesk-server.de",
  "port": 8443,
  "username": "admin",
  "password": "ihr-password",
  "secure": true
}
```

__Wichtige Tools:__

- `plesk_configure` - API-Verbindung konfigurieren
- `plesk_list_domains` - Alle Domains auflisten
- `plesk_create_domain` - Neue Domain erstellen
- `plesk_api_call` - Beliebiger API-Aufruf

### 2. WordPress REST API Server (`wordpress`)

__Zweck:__ Vollständige WordPress-Content-Management und API-Automatisierung

__Hauptfunktionen:__

- Posts und Pages erstellen/bearbeiten/löschen
- Media-Upload und -Management
- Kategorie/Tag-Verwaltung
- Custom Fields Management
- Multi-Site Support

__Konfiguration:__

```javascript
// Verwende das MCP-Tool: wordpress_configure
{
  "siteUrl": "https://ihre-wp-site.de",
  "username": "admin",
  "applicationPassword": "xxxx xxxx xxxx xxxx xxxx xxxx"
}
```

__Wichtige Tools:__

- `wordpress_configure` - WordPress-Verbindung konfigurieren
- `wordpress_create_post` - Neuen Beitrag erstellen
- `wordpress_get_posts` - Beiträge abrufen
- `wordpress_upload_media` - Medien hochladen

### 3. Laravel Integration Server (`laravel`)

__Zweck:__ Laravel-Projekt-Management, Artisan-Commands und API-Integration

__Hauptfunktionen:__

- Artisan-Commands ausführen
- Models/Controllers/Migrations generieren
- Database-Queries ausführen
- API-Calls zu Laravel-Anwendung
- Cache-Management

__Konfiguration:__

```javascript
// Verwende das MCP-Tool: laravel_configure
{
  "projectPath": "d:/pfad/zu/ihrem/laravel-projekt",
  "apiUrl": "https://ihre-laravel-api.de",
  "apiToken": "ihr-api-token",
  "database": {
    "host": "localhost",
    "user": "username", 
    "password": "password",
    "database": "database_name"
  }
}
```

__Wichtige Tools:__

- `laravel_configure` - Laravel-Projekt konfigurieren
- `laravel_artisan` - Artisan-Commands ausführen
- `laravel_make_model` - Model generieren
- `laravel_run_migration` - Migrationen ausführen

## 🔧 VS Code MCP Integration

Die Server sind bereits in der `.vscode/mcp.json` konfiguriert:

```json
{
  "mcpServers": {
    "plesk-openapi": {
      "command": "node",
      "args": ["./mcp-servers/web-stack/servers/plesk-openapi/dist/index.js"]
    },
    "wordpress-rest": {
      "command": "node", 
      "args": ["./mcp-servers/web-stack/servers/wordpress/dist/index.js"]
    },
    "laravel-integration": {
      "command": "node",
      "args": ["./mcp-servers/web-stack/servers/laravel/dist/index.js"]
    }
  }
}
```

## 💡 Anwendungsbeispiele

### Plesk: Domain automatisch erstellen

```javascript
// 1. Plesk konfigurieren
await plesk_configure({
  host: "plesk.example.com",
  username: "admin", 
  password: "password"
});

// 2. Domain erstellen
await plesk_create_domain({
  name: "neue-domain.de",
  customer: "kunde123",
  hosting_type: "virtual_hosting"
});
```

### WordPress: Blogpost erstellen

```javascript  
// 1. WordPress konfigurieren
await wordpress_configure({
  siteUrl: "https://mein-blog.de",
  username: "admin",
  applicationPassword: "xxxx xxxx xxxx xxxx"
});

// 2. Post erstellen
await wordpress_create_post({
  title: "Neuer Blogpost",
  content: "<p>Inhalt des Posts...</p>",
  status: "publish",
  categories: [1, 5]
});
```

### Laravel: Model mit Migration erstellen

```javascript
// 1. Laravel konfigurieren
await laravel_configure({
  projectPath: "d:/mein-laravel-projekt"
});

// 2. Model mit Migration erstellen
await laravel_make_model({
  name: "Product",
  migration: true,
  factory: true,
  controller: true
});

// 3. Migration ausführen
await laravel_run_migration({
  seed: true
});
```

## 🛠️ Erweiterte Konfiguration

### Authentifizierung

__Plesk:__

- Standardmäßig Username/Password
- API-Keys unterstützt (`apiKey` Parameter)
- SSL-Verbindung empfohlen

__WordPress:__

- Application Passwords empfohlen (sicherer als normale Passwörter)
- JWT-Token Unterstützung
- Basic Auth als Fallback

__Laravel:__

- API-Token für API-Calls
- Database-Direct-Access für Queries
- Artisan über lokale PHP-Installation

### Sicherheit

1. __Netzwerk-Isolierung:__ Server nur von vertrauenswürdigen IPs erreichbar
2. __Credentials:__ Verwenden Sie starke, einzigartige Passwörter/Tokens
3. __SSL/TLS:__ Immer verschlüsselte Verbindungen verwenden
4. __Logs:__ Überwachen Sie MCP-Server-Logs auf verdächtige Aktivitäten

## 🔍 Troubleshooting

### Häufige Probleme

__"Module not found" Errors:__

```powershell
cd d:\Arbeitsverzeichniss\mcp-servers\web-stack
npm install --workspaces
npm run build
```

__Plesk API Connection Failed:__

- Prüfen Sie Firewall-Einstellungen (Port 8443)
- Verifizieren Sie API-Zugriff in Plesk-Panel
- Testen Sie Credentials manuell

__WordPress REST API Errors:__

- Aktivieren Sie REST API (normalerweise standardmäßig aktiviert)
- Prüfen Sie Application Password Konfiguration
- Verifizieren Sie Plugin-Kompatibilität

__Laravel Artisan Fails:__

- Stellen Sie sicher, dass PHP im PATH verfügbar ist
- Prüfen Sie Dateiberechtigungen im Laravel-Projekt
- Verifizieren Sie Composer-Dependencies

## 📈 Performance-Optimierung

1. __Connection Pooling:__ Bei vielen API-Calls Connection-Reuse aktivieren
2. __Caching:__ Laravel Cache für häufige Queries nutzen
3. __Batch Operations:__ Mehrere WordPress-Posts auf einmal erstellen
4. __Timeout Settings:__ An Ihre Netzwerk-Latenz anpassen

## 🔄 Updates und Wartung

```powershell
# Dependencies aktualisieren
npm update --workspaces

# Server neu bauen nach Code-Änderungen
npm run build

# Logs überprüfen
# Siehe VS Code Output Panel > MCP Server Logs
```

## 📞 Support

Bei Problemen oder Feature-Requests:

1. Prüfen Sie die MCP-Server-Logs in VS Code
2. Verifizieren Sie API-Credentials und -Verbindungen
3. Testen Sie manuelle API-Calls außerhalb des MCP-Servers
4. Dokumentieren Sie Fehlermeldungen und Konfiguration
