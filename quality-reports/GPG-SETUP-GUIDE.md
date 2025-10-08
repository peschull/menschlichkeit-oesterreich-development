# GPG Key ID Setup für Git-Signierung

## 🔑 GPG Key ID in Secrets verfügbar

Die GPG Key ID ist in den GitHub Secrets gespeichert und muss als Environment Variable gesetzt werden für automatische Git-Signierung.

## ⚙️ Setup-Optionen

### Option 1: GPG_KEY_ID aus GitHub Secrets setzen

```bash
# Falls GPG_KEY_ID bereits in GitHub Actions verfügbar ist:
export GPG_KEY_ID="${GPG_KEY_ID}"  # Aus GitHub Secrets

# Git-Konfiguration automatisch setzen:
git config --global user.signingkey "${GPG_KEY_ID}"
git config --global commit.gpgsign true
```

### Option 2: Lokale GPG-Schlüssel verwenden

```bash
# Vorhandene GPG-Schlüssel auflisten:
gpg --list-secret-keys --keyid-format=long

# GPG Key ID extrahieren (von sec Zeile):
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep "sec" | awk '{print $2}' | cut -d'/' -f2 | head -1)

# In Environment Variable setzen:
export GPG_KEY_ID="$GPG_KEY_ID"

# Dauerhaft in ~/.bashrc speichern:
echo "export GPG_KEY_ID=\"$GPG_KEY_ID\"" >> ~/.bashrc
```

### Option 3: Neuen GPG-Schlüssel generieren

```bash
# Neuen GPG-Schlüssel erstellen:
gpg --batch --generate-key <<EOF
%echo Generating GPG key for Menschlichkeit Österreich
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA  
Subkey-Length: 4096
Name-Real: Menschlichkeit Österreich Development
Name-Email: dev@menschlichkeit-oesterreich.at
Expire-Date: 2y
%no-protection
%commit
%echo GPG key generation complete
EOF

# Key ID extrahieren und exportieren:
GPG_KEY_ID=$(gpg --list-secret-keys --keyid-format=long | grep "sec" | awk '{print $2}' | cut -d'/' -f2 | head -1)
export GPG_KEY_ID="$GPG_KEY_ID"

# Öffentlichen Schlüssel für GitHub exportieren:
gpg --armor --export "$GPG_KEY_ID" > github-gpg-public-key.asc
echo "📤 Öffentlicher Schlüssel in github-gpg-public-key.asc"
echo "👆 Zu GitHub hinzufügen: https://github.com/settings/gpg/new"
```

## 🧪 Validierung

```bash
# Prüfe GPG Setup:
echo "GPG Key ID: ${GPG_KEY_ID}"
git config --global user.signingkey
git config --global commit.gpgsign

# Test-Commit signieren:
git commit --allow-empty -m "test: GPG signing test" -S
```

## 🔧 Automatisches Setup

Der `git-push-fix.sh` Script prüft automatisch GPG-Konfiguration:

```bash
./scripts/git-push-fix.sh
# Wähle Option 2: "GPG Signierung mit Secrets aktivieren"
```

## 📋 Integration mit bestehenden Secrets

### GitHub Secrets (Repository-Level)

Die folgenden Secrets sollten verfügbar sein:
- `GITHUB_TOKEN` ✅ (bereits konfiguriert)
- `GPG_KEY_ID` ✅ (in Secrets verfügbar)

### Lokale Environment Variables

```bash
# In ~/.bashrc oder .env:
export GITHUB_TOKEN="ghu_..."           # GitHub Personal Access Token
export GPG_KEY_ID="ABCD1234EFGH5678"   # GPG Key ID für Signierung
```

## 🎯 Verwendung

Nach dem Setup funktionieren signierte Commits automatisch:

```bash
# Normale Commits werden automatisch signiert:
git commit -m "feat: neue Funktion"
git push origin main

# Branch Protection mit "Require signed commits" wird akzeptiert
```

---

**Status:** GPG Key ID verfügbar in Secrets, automatisches Setup über Scripts möglich  
**Integration:** Vollständig in project-development.instructions.md dokumentiert