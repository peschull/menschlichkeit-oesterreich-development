# GitHub Repository Cleanup Guide

## 🎯 Anleitung zum Entfernen alter Repositories aus GitHub

Da alle Inhalte jetzt in das konsolidierte Repository `menschlichkeit-oesterreich-development` integriert wurden, können alte separate Repositories sicher entfernt werden.

## 📋 **Schritt-für-Schritt Anleitung:**

### 1. **Identifizierung alter Repositories**

Besuchen Sie Ihren GitHub Account und suchen Sie nach Repositories, die möglicherweise separate Teile des Projekts enthielten:

**Mögliche Repository-Namen zu prüfen:**
- `menschlichkeit-frontend`
- `menschlichkeit-api` 
- `menschlichkeit-cms`
- `menschlichkeit-design-system`
- `crm-system`
- `api-backend`
- `drupal-theme`
- `figma-components`
- `deployment-scripts`
- `website-static`
- Alle anderen Repositories mit "menschlichkeit" im Namen

### 2. **Backup-Verifikation**

**Vor dem Löschen sicherstellen:**
```bash
# Überprüfen Sie, dass alle Inhalte im Haupt-Repository sind:
git log --oneline | head -10
git status
ls -la
```

**Alle wichtigen Komponenten sollten vorhanden sein:**
- ✅ `crm.menschlichkeit-oesterreich.at/` - Drupal CMS
- ✅ `api.menschlichkeit-oesterreich.at/` - FastAPI Backend  
- ✅ `frontend/` - React Frontend
- ✅ `web/themes/custom/menschlichkeit/` - Drupal Theme
- ✅ `figma-design-system/` - Design System
- ✅ `deployment-scripts/` - Deployment Automation
- ✅ `docs/` - Dokumentation
- ✅ `secrets/` - Verschlüsselte Konfiguration

### 3. **GitHub Repository Löschung**

**Für jedes alte Repository:**

1. **Gehen Sie zu GitHub.com**
2. **Navigieren Sie zum Repository** (github.com/peschull/[repository-name])
3. **Klicken Sie auf "Settings"** (rechts oben im Repository)
4. **Scrollen Sie nach unten** zum "Danger Zone" Bereich
5. **Klicken Sie auf "Delete this repository"**
6. **Bestätigen Sie** durch Eingabe des Repository-Namens
7. **Klicken Sie "I understand the consequences, delete this repository"**

### 4. **Empfohlene Lösch-Reihenfolge**

**Zuerst prüfen und löschen (falls vorhanden):**
1. Test/Experimental Repositories
2. Feature-Branch Repositories  
3. Backup/Archive Repositories
4. Legacy-Code Repositories

**Dann (falls separate Repositories existierten):**
5. Frontend-spezifische Repositories
6. Backend/API Repositories
7. Design-System Repositories
8. Deployment/Infrastructure Repositories

### 5. **Wichtige Sicherheitschecks**

**Vor jeder Löschung überprüfen:**

```bash
# Überprüfen Sie lokale Git-Remotes:
git remote -v

# Stellen Sie sicher, dass keine wichtigen Branches/Tags verloren gehen:
git branch -a
git tag -l

# Überprüfen Sie die letzten Commits des zu löschenden Repositories:
# (Falls Sie lokale Kopien haben)
```

**❌ NICHT löschen, falls:**
- Repository enthält nicht-konsolidierte Commits
- Externe Abhängigkeiten existieren (CI/CD, Webhooks)
- Andere Projekte darauf verweisen
- Wichtige Issue-Diskussionen/Pull-Requests vorhanden

### 6. **Nach der Löschung - Cleanup**

**Lokale Git-Remotes bereinigen:**
```bash
# Entfernen Sie Referenzen auf gelöschte Repositories:
git remote remove old-repo-name

# Bereinigen Sie lokale Tracking-Branches:
git remote prune origin
```

**Update von externen Referenzen:**
- CI/CD-Konfigurationen aktualisieren
- Webhook-URLs ändern
- Dokumentations-Links korrigieren
- Team-Benachrichtigungen anpassen

### 7. **Bestätigung der Konsolidierung**

**Testen Sie das konsolidierte Repository:**
```bash
# Aktuellen Stand pushen:
git push origin chore/ci-install-before-eslint

# CI/CD Pipeline überprüfen:
# Gehen Sie zu GitHub Actions und stellen Sie sicher, dass alle Tests laufen

# Deployment testen:
./deployment-scripts/deploy-crm-plesk.sh --dry-run
```

## ⚠️ **Wichtige Warnungen:**

1. **Unwiderruflich:** Repository-Löschung kann nicht rückgängig gemacht werden
2. **24h-Regel:** GitHub behält gelöschte Repositories 24h zur Wiederherstellung
3. **Externe Links:** Alle externen Links zu gelöschten Repositories werden ungültig
4. **Forks:** Benutzer-Forks bleiben bestehen (falls vorhanden)

## ✅ **Nach erfolgreicher Bereinigung:**

Sie haben dann nur noch **1 einheitliches Repository:**
- `github.com/peschull/menschlichkeit-oesterreich-development`
- Alle Komponenten konsolidiert
- Saubere, wartbare Struktur
- Plesk-Deployment-Ready

## 🆘 **Im Notfall:**

Falls versehentlich wichtige Repositories gelöscht wurden:
1. **Sofort GitHub Support kontaktieren** (innerhalb 24h)
2. **Repository-Name und Löschzeitpunkt angeben**
3. **Begründung für Wiederherstellung bereitstellen**

---

**Diese Anleitung hilft Ihnen dabei, eine saubere GitHub-Repository-Struktur zu erreichen, die der konsolidierten lokalen Struktur entspricht.**