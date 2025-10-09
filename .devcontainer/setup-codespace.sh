#!/bin/bash

# Automatisches Setup-Script für GitHub Codespaces
# Installiert uv (Python Package Manager) und andere essenzielle Tools
# Wird automatisch beim Codespace-Start ausgeführt

set -euo pipefail

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Menschlichkeit Österreich - Codespace Setup wird gestartet...${NC}"
echo ""

# 1. uv Installation (Python Package Manager)
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}📦 Installiere uv (Python Package Manager)...${NC}"
    pip install --quiet uv
    echo -e "${GREEN}✅ uv erfolgreich installiert${NC}"
else
    echo -e "${GREEN}✅ uv ist bereits installiert ($(uv --version))${NC}"
fi

# 2. Python-Abhängigkeiten mit uv installieren (schneller als pip)
if [ -f "requirements.txt" ]; then
    echo -e "${YELLOW}📦 Installiere Python-Abhängigkeiten mit uv...${NC}"
    uv pip install -r requirements.txt --quiet
    echo -e "${GREEN}✅ Python-Abhängigkeiten installiert${NC}"
fi

# 3. API-Service Dependencies
if [ -f "api.menschlichkeit-oesterreich.at/requirements.txt" ]; then
    echo -e "${YELLOW}📦 Installiere API-Service Dependencies...${NC}"
    cd api.menschlichkeit-oesterreich.at
    uv pip install -r requirements.txt --quiet
    cd ..
    echo -e "${GREEN}✅ API-Dependencies installiert${NC}"
fi

# 4. Workspace NPM Dependencies
if [ -f "package.json" ]; then
    echo -e "${YELLOW}📦 Installiere npm-Workspaces...${NC}"
    npm install --silent
    echo -e "${GREEN}✅ npm-Workspaces installiert${NC}"
fi

# 5. Composer Dependencies (PHP/Drupal)
if [ -f "composer.json" ] && command -v composer &> /dev/null; then
    echo -e "${YELLOW}📦 Installiere Composer-Dependencies...${NC}"
    composer install --no-dev --optimize-autoloader --quiet
    echo -e "${GREEN}✅ Composer-Dependencies installiert${NC}"
fi

# 6. Prisma Client generieren (Gaming Platform)
if [ -f "schema.prisma" ]; then
    echo -e "${YELLOW}🗄️  Generiere Prisma Client...${NC}"
    npx prisma generate --silent
    echo -e "${GREEN}✅ Prisma Client generiert${NC}"
fi

# 7. Git Konfiguration (für bessere Commits)
echo -e "${YELLOW}🔧 Konfiguriere Git...${NC}"
git config --global core.autocrlf input
git config --global pull.rebase false
git config --global init.defaultBranch main
echo -e "${GREEN}✅ Git konfiguriert${NC}"

# 8. Environment-Check
echo ""
echo -e "${BLUE}📊 System-Übersicht:${NC}"
echo "  Node.js: $(node --version)"
echo "  npm: $(npm --version)"
echo "  Python: $(python3 --version)"
echo "  uv: $(uv --version)"
if command -v php &> /dev/null; then
    echo "  PHP: $(php --version | head -n 1)"
fi
if command -v composer &> /dev/null; then
    echo "  Composer: $(composer --version | head -n 1)"
fi

echo ""
echo -e "${GREEN}✅ Codespace Setup abgeschlossen!${NC}"
echo ""
echo -e "${BLUE}📚 Nächste Schritte:${NC}"
echo "  1. Starte alle Services: ${YELLOW}npm run dev:all${NC}"
echo "  2. Quality Gates prüfen: ${YELLOW}npm run quality:gates${NC}"
echo "  3. Dokumentation lesen: ${YELLOW}cat README.md${NC}"
echo ""
echo -e "${BLUE}🇦🇹 Viel Erfolg beim Entwickeln!${NC}"
