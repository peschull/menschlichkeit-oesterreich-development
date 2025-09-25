# Secrets mit SOPS (age)

Sichere Verwaltung von `.env` ohne Klartext im Git‑Repo.

## Voraussetzungen
- `sops` (https://github.com/getsops/sops)
- `age` (https://github.com/FiloSottile/age)

## Age Schlüssel erzeugen (lokal)
```
age-keygen -o ~/.config/sops/age/keys.txt
# Public Recipient anzeigen
cat ~/.config/sops/age/keys.txt | grep public
```
- Empfänger (`age1...`) in `.sops.yaml` eintragen: `REPLACE_WITH_AGE_RECIPIENT`
- Alternativ via ENV: `setx SOPS_AGE_RECIPIENTS age1...` (Windows PowerShell)

## Dateien
- Klartext (nicht im Repo): `config/.env`
- Verschlüsselt (im Repo): `config/.env.enc`
- SOPS Konfig: `.sops.yaml` (mit Recipient)

## Verschlüsseln
```
# PowerShell
./scripts/secrets-encrypt.ps1
```
Erzeugt/aktualisiert `config/.env.enc` aus `config/.env`.

## Entschlüsseln
```
# PowerShell
# Schlüsseldatei bekannt geben
$env:SOPS_AGE_KEY_FILE = "$HOME/.config/sops/age/keys.txt"
./scripts/secrets-decrypt.ps1
```
Schreibt Klartext nach `config/.env`.

## Tipps
- Achtung: `config/.env` bleibt per `.gitignore_sensitive` ignoriert.
- CI/CD kann mit `SOPS_AGE_KEY` (Inhalt der privaten Schlüsseldatei) arbeiten, um zu entschlüsseln.
- Mehrere Empfänger? Füge sie in `.sops.yaml` unter `age: [...]` hinzu.

