# GitHub Repository Löschen - Berechtigung aktivieren

## 🔐 Problem: HTTP 403 - Must have admin rights to Repository

**Fehler:** `delete_repo` Scope fehlt in der GitHub CLI Authentifizierung

## ✅ Lösung: Berechtigung aktivieren

### Schritt 1: Repository-Lösch-Berechtigung anfordern
```bash
gh auth refresh -h github.com -s delete_repo
```

**Was passiert:**
- Öffnet Browser zur GitHub-Authentifizierung
- Fragt nach zusätzlicher `delete_repo` Berechtigung
- Aktualisiert die lokale GitHub CLI Authentifizierung

### Schritt 2: Berechtigung bestätigen
```bash
gh auth status
```

**Sollte anzeigen:**
```
✓ Logged in to github.com as peschull (...)
✓ Git operations for github.com configured to use https protocol.
✓ Token: ***
✓ Token scopes: delete_repo, gist, read:org, repo
```

### Schritt 3: Repository-Cleanup ausführen

#### **Option A: Automatisiert**
```bash
bash scripts/github-delete-old-repos.sh
```

#### **Option B: Einzeln**  
```bash
gh repo delete peschull/menschlichkeit-oesterreich-monorepo --yes
gh repo delete peschull/menschlichkeit-oesterreich --yes
gh repo delete peschull/crm.menschlichkeit-oesterreich --yes
gh repo delete peschull/api.menschlichkeit-oesterreich --yes
```

## ⚠️ Alternative: Manuelle Löschung über GitHub Web-Interface

Falls CLI-Probleme bestehen bleiben:

1. **Besuchen Sie:** github.com/peschull/[repository-name]
2. **Klicken:** Settings (rechts oben)
3. **Scrollen:** Nach unten zu "Danger Zone"
4. **Klicken:** "Delete this repository" 
5. **Bestätigen:** Repository-Namen eingeben
6. **Klicken:** "I understand the consequences, delete this repository"

## 🎯 Zu löschende Repositories:
- `peschull/menschlichkeit-oesterreich-monorepo`
- `peschull/menschlichkeit-oesterreich` 
- `peschull/crm.menschlichkeit-oesterreich`
- `peschull/api.menschlichkeit-oesterreich`

## ✅ Zu behalten:
- `peschull/menschlichkeit-oesterreich-development` (Haupt-Repository)
- `peschull/webgames` (separates Projekt)