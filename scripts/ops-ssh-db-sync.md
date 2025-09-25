# SSH & DB Sync Leitfaden

## Sicherheits-Hinweis
- Niemals `config/.env` in Git committen (siehe `.gitignore_sensitive`)
- Stattdessen `config/.env.example` pflegen und echte `.env` via SSH/SCP verteilen

## .env verteilen (SCP)

Beispiel (Plesk, private Pfade anpassen):

```
# PowerShell
./scripts/ssh-env-sync.ps1 -LocalEnvPath config/.env \
  -RemoteHost your.host \
  -RemoteUser your_user \
  -RemotePath /var/www/vhosts/your-domain/private/.env
```

## DB Sync (Pull/Push)

Voraussetzungen: `ssh`, `mysqldump`, `mysql` im PATH.

- Pull (Prod → Lokal):
```
./scripts/db-sync.ps1 -Direction pull \
  -RemoteHost your.host -RemoteUser your_user -DbHost localhost \
  -DbName prod_db -DbUser prod_user -DbPass "*****" \
  -LocalDbName local_db -LocalDbUser root -LocalDbPass "*****"
```

- Push (Lokal → Prod):
```
./scripts/db-sync.ps1 -Direction push \
  -RemoteHost your.host -RemoteUser your_user -DbHost localhost \
  -DbName prod_db -DbUser prod_user -DbPass "*****" \
  -LocalDbName local_db -LocalDbUser root -LocalDbPass "*****"
```

## Git: Richtig mit .env umgehen
- Committe nur `config/.env.example`:
```
git add config/.env.example
git commit -m "chore(config): add sanitized .env example"
```
- Falls du GEGEN Empfehlung `config/.env` committen willst (nicht empfohlen):
```
# Force-Add überschreibt Ignore-Regeln – hohes Risiko!
git add -f config/.env
git commit -m "feat(config): commit real .env (NOT RECOMMENDED)"
# Danach pushen:
git push origin <branch>
```

Empfehlung: Alternativ SOPS/git-crypt zum Verschlüsseln nutzen.

