# Installation MCP-Server für Menschlichkeit Österreich

Dieses PowerShell-Skript installiert und konfiguriert die optimalen MCP-Server für Ihren Plesk/Laravel/WordPress-Stack.

## Ausführung

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
cd d:\Arbeitsverzeichniss\mcp-servers\web-stack
.\install-mcp-servers.ps1
```

## Was wird installiert

1. __Plesk OpenAPI Server__ - Für Plesk-Hosting-Automatisierung
2. __WordPress REST API Server__ - Für WordPress-Content-Management  
3. __Laravel Integration Server__ - Für Laravel-Entwicklung und Artisan-Commands

## Nach der Installation

Die MCP-Server sind in VS Code verfügbar und können über GitHub Copilot verwendet werden.

Siehe `README.md` für detaillierte Konfiguration und Verwendung.
