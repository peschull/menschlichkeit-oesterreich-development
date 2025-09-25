# SFTP Deployment Configuration Template

Kopieren Sie diese Datei und füllen Sie Ihre Plesk-Server Daten ein.

## Server-Konfiguration (zu ergänzen)

```bash
REMOTE_HOST="ihr-server.hostname.de"     # Ihr Plesk Server Hostname
REMOTE_USER="ihr-username"                # Ihr FTP/SFTP Benutzername  
REMOTE_PORT=22                           # SSH/SFTP Port (meist 22)
```

## Plesk-Verzeichnisstruktur

- Hauptdomain: `/httpdocs`
- Subdomains: `/subdomains/[subdomain-name]/httpdocs`

## Verwendung

1. Server-Daten in `scripts/sftp-sync.sh` eintragen
2. Script ausführen: `./scripts/sftp-sync.sh`
3. Website wird automatisch auf alle drei Domains deployed:
   - menschlichkeit-oesterreich.at (Hauptdomain)
   - api.menschlichkeit-oesterreich.at (API Subdomain)
   - crm.menschlichkeit-oesterreich.at (CRM Subdomain)

## Sicherheitshinweise

- SSH-Key Authentication empfohlen
- FTP-Passwort NICHT im Script speichern
- Backup vor jedem Deployment erstellen

## Test vor Production

1. Zuerst auf Staging-Server testen
2. Domain-DNS korrekt konfiguriert?
3. SSL-Zertifikate eingerichtet?