# 🏗️ Repository Structure Reorganization

Nach der Submodule-Konfiguration wurde die Repository-Struktur wie folgt reorganisiert:

## 📁 Neue Struktur

```
├── .github/                          # GitHub Actions, Issue Templates, Workflows
│   ├── workflows/
│   │   ├── ci.yml                    # Multi-technology CI/CD pipeline
│   │   └── wordpress.yml             # WordPress-specific integration tests
│   ├── ISSUE_TEMPLATE/               # Structured issue templates
│   └── dependabot.yml                # Automated dependency updates
│
├── mcp-servers-official/             # 🆕 Official MCP Servers (Submodule)
│   └── [Submodule: modelcontextprotocol/servers.git]
│
├── custom-mcp-servers/              # 🔧 Custom MCP Server Development
│   ├── src/everything/              # Everything MCP Server
│   ├── src/filesystem/              # Filesystem MCP Server
│   ├── src/git/                     # Git MCP Server
│   ├── src/memory/                  # Memory MCP Server
│   ├── src/sequentialthinking/      # Sequential Thinking MCP Server
│   └── src/time/                    # Time MCP Server
│
├── wordpress-monorepo/              # 🌐 WordPress Development
│   ├── httpdocs/                    # WordPress Core Installation
│   ├── api.menschlichkeit-oesterreich.at/  # Laravel API Backend
│   └── crm.menschlichkeit-oesterreich.at/  # CRM Integration
│
├── mcp-bridge/                      # 🔗 MCP Bridge Server
├── mcp-search/                      # 🔍 MCP Search Engine
├── mcp-servers/                     # 📦 Legacy MCP Servers (to be reorganized)
└── scripts/                         # 🛠️ Development Scripts
```

## 🚀 Migration Benefits

1. **Modularität:** Klare Trennung zwischen offiziellen und custom MCP Servers
2. **Submodule Integration:** Official MCP servers als Submodule für bessere Versionskontrolle
3. **WordPress Separation:** Saubere Trennung des WordPress Monorepos
4. **CI/CD Ready:** Alle Workflows unterstützen die neue Struktur
5. **Development Workflow:** Bessere Organisation für Team-Entwicklung

## 📋 Next Steps

- [ ] WordPress Monorepo als separates Git Repository extrahieren
- [ ] WordPress Monorepo als Submodule hinzufügen
- [ ] Legacy Verzeichnisse (`servers/`, `menschlichkeit-oesterreich-monorepo/`) entfernen
- [ ] `.gitignore` für neue Struktur anpassen
- [ ] CI/CD Workflows für neue Struktur testen

## 🔄 Submodule Commands

```bash
# Alle Submodules initialisieren
git submodule update --init --recursive

# Submodules auf neueste Version aktualisieren
git submodule update --remote --merge

# Status aller Submodules prüfen
git submodule status
```
