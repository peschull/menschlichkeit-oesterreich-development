# 📁 Submodules Configuration

Diese Repository verwendet Git Submodules für bessere Modularität und Versionskontrolle.

## 🔧 Aktive Submodules

### mcp-servers-official
- **Pfad:** `mcp-servers-official/`
- **Repository:** https://github.com/modelcontextprotocol/servers.git
- **Branch:** main
- **Beschreibung:** Offizielle Model Context Protocol Server von der MCP Community
- **Zweck:** Referenz-Implementierungen und Standard-Server für verschiedene Funktionalitäten

## 🚀 Submodule Management

### Initial Setup
```bash
# Klone das Repository mit allen Submodules
git clone --recursive https://github.com/peschull/menschlichkeit-oesterreich-development.git

# Oder für bestehende Repositories:
git submodule update --init --recursive
```

### Updates
```bash
# Aktualisiere alle Submodules auf neueste Version
git submodule update --remote --merge

# Aktualisiere spezifisches Submodule
git submodule update --remote mcp-servers-official
```

### Development Workflow
```bash
# Arbeite in einem Submodule
cd mcp-servers-official
git checkout -b feature/my-feature
# ... make changes ...
git commit -m "feat: add new feature"
git push origin feature/my-feature

# Zurück zum Haupt-Repository
cd ..
git add mcp-servers-official
git commit -m "chore: update mcp-servers-official submodule"
```

## 📋 Geplante Submodules

### menschlichkeit-oesterreich-wordpress (geplant)
- **Ziel-Pfad:** `wordpress-monorepo/`
- **Beschreibung:** WordPress Monorepo für Österreich non-profit Organisation
- **Status:** Wird als separates Repository extrahiert und dann als Submodule hinzugefügt

## 🔗 Submodule Benefits

1. **Modulare Entwicklung:** Separate Repositories für verschiedene Komponenten
2. **Versionskontrolle:** Spezifische Versionen von Abhängigkeiten fixieren
3. **Team-Collaboration:** Teams können unabhängig an verschiedenen Modulen arbeiten
4. **CI/CD Integration:** Separate Build-Pipelines für verschiedene Komponenten
5. **Code-Wiederverwendung:** Gleiche Module in mehreren Projekten verwenden

## ⚠️ Wichtige Hinweise

- Submodules verweisen auf spezifische Commits, nicht auf Branches
- Änderungen in Submodules müssen explizit committed werden
- `git pull` aktualisiert Submodules nicht automatisch - `git submodule update` verwenden
- Bei CI/CD Pipelines `--recursive` Flag für git clone verwenden