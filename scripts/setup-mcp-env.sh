#!/usr/bin/env bash
# ══════════════════════════════════════════════════════════════
# MCP Environment Setup Script (Linux/macOS)
# ══════════════════════════════════════════════════════════════
# 
# Automatisiert:
# - Extraktion von Environment-Variablen aus mcp.json
# - Generierung von .env.example
# - Erstellung von .env.local Template
# - .gitignore Updates
#
# Verwendung: ./scripts/setup-mcp-env.sh
# ══════════════════════════════════════════════════════════════

set -euo pipefail

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Pfade
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MCP_JSON="$PROJECT_ROOT/.vscode/mcp.json"
ENV_DIR="$PROJECT_ROOT/env"
ENV_EXAMPLE="$ENV_DIR/.env.example"
ENV_LOCAL="$ENV_DIR/.env.local"
GITIGNORE="$PROJECT_ROOT/.gitignore"
SANDBOX_DIR="$PROJECT_ROOT/.ai-sandbox"

echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  MCP Environment Setup - Menschlichkeit Österreich        ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# ══════════════════════════════════════════════════════════════
# 1. Prüfe Voraussetzungen
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[1/7] Prüfe Voraussetzungen...${NC}"

if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗ jq nicht gefunden!${NC}"
    echo "Installation:"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  macOS:         brew install jq"
    exit 1
fi

if [ ! -f "$MCP_JSON" ]; then
    echo -e "${RED}✗ mcp.json nicht gefunden: $MCP_JSON${NC}"
    exit 1
fi

echo -e "${GREEN}✓ jq installiert${NC}"
echo -e "${GREEN}✓ mcp.json gefunden${NC}"

# ══════════════════════════════════════════════════════════════
# 2. Erstelle Verzeichnisse
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[2/7] Erstelle Verzeichnisse...${NC}"

mkdir -p "$ENV_DIR"
mkdir -p "$SANDBOX_DIR"
touch "$SANDBOX_DIR/.keep"

echo -e "${GREEN}✓ env/ erstellt${NC}"
echo -e "${GREEN}✓ .ai-sandbox/ erstellt${NC}"

# ══════════════════════════════════════════════════════════════
# 3. Extrahiere Environment-Variablen aus mcp.json
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[3/7] Extrahiere Environment-Variablen...${NC}"

# JSON Syntax prüfen
if ! jq empty "$MCP_JSON" 2>/dev/null; then
    echo -e "${RED}✗ mcp.json hat ungültige JSON-Syntax!${NC}"
    exit 1
fi

# Extrahiere alle ${env:VAR} Patterns (grep ist robuster als jq regex)
ENV_VARS=$(grep -oP '\$\{env:([A-Z0-9_]+)\}' "$MCP_JSON" | sed 's/\${env:\([^}]*\)}/\1/' | sort -u)

if [ -z "$ENV_VARS" ]; then
    echo -e "${RED}✗ Keine Environment-Variablen gefunden!${NC}"
    exit 1
fi

VAR_COUNT=$(echo "$ENV_VARS" | wc -l | tr -d ' ')
echo -e "${GREEN}✓ $VAR_COUNT Environment-Variablen extrahiert${NC}"

# ══════════════════════════════════════════════════════════════
# 4. Generiere .env.example
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[4/7] Generiere .env.example...${NC}"

# Backup falls existiert
if [ -f "$ENV_EXAMPLE" ]; then
    cp "$ENV_EXAMPLE" "$ENV_EXAMPLE.backup.$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}  → Backup erstellt: $ENV_EXAMPLE.backup.*${NC}"
fi

cat > "$ENV_EXAMPLE" <<'HEADER'
# ⚠️ Environment Variables Template for MCP Servers
# 
# WICHTIG: Kopiere diese Datei zu .env.local und fülle die Werte aus!
# .env.local wird NICHT in Git committet (.gitignore)
#
# NIEMALS echte API-Keys hier eintragen - nur in .env.local!

HEADER

echo "# Automatisch extrahiert aus .vscode/mcp.json" >> "$ENV_EXAMPLE"
echo "# Generiert: $(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$ENV_EXAMPLE"
echo "" >> "$ENV_EXAMPLE"

# Kategorisiere Variablen
while IFS= read -r var; do
    case "$var" in
        GITHUB_*|GITLAB_*|BITBUCKET_*)
            echo "$var=" >> "$ENV_EXAMPLE.github"
            ;;
        POSTGRES_*|MYSQL_*|SQLITE_*|MONGODB_*|REDIS_*)
            echo "$var=" >> "$ENV_EXAMPLE.database"
            ;;
        AWS_*|AZURE_*|GCP_*|GOOGLE_*)
            echo "$var=" >> "$ENV_EXAMPLE.cloud"
            ;;
        STRIPE_*|SENDGRID_*|TWILIO_*)
            echo "$var=" >> "$ENV_EXAMPLE.api"
            ;;
        *)
            echo "$var=" >> "$ENV_EXAMPLE.other"
            ;;
    esac
done <<< "$ENV_VARS"

# Kombiniere Kategorien
for category in github database cloud api other; do
    file="$ENV_EXAMPLE.$category"
    if [ -f "$file" ]; then
        case "$category" in
            github)   echo "# ═══ VERSION CONTROL & CODE HOSTING ═══" >> "$ENV_EXAMPLE" ;;
            database) echo "# ═══ DATABASE CONNECTIONS ═══" >> "$ENV_EXAMPLE" ;;
            cloud)    echo "# ═══ CLOUD PROVIDERS (DSGVO: NUR EU!) ═══" >> "$ENV_EXAMPLE" ;;
            api)      echo "# ═══ API INTEGRATIONS ═══" >> "$ENV_EXAMPLE" ;;
            other)    echo "# ═══ OTHER SERVICES ═══" >> "$ENV_EXAMPLE" ;;
        esac
        cat "$file" >> "$ENV_EXAMPLE"
        echo "" >> "$ENV_EXAMPLE"
        rm "$file"
    fi
done

echo -e "${GREEN}✓ .env.example generiert ($VAR_COUNT Variablen)${NC}"

# ══════════════════════════════════════════════════════════════
# 5. Erstelle .env.local Template
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[5/7] Erstelle .env.local Template...${NC}"

if [ -f "$ENV_LOCAL" ]; then
    echo -e "${YELLOW}  → .env.local existiert bereits - überspringe${NC}"
else
    cp "$ENV_EXAMPLE" "$ENV_LOCAL"
    echo -e "${GREEN}✓ .env.local Template erstellt${NC}"
    echo -e "${YELLOW}  → WICHTIG: Fülle .env.local mit echten API-Keys!${NC}"
fi

# ══════════════════════════════════════════════════════════════
# 6. Aktualisiere .gitignore
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[6/7] Aktualisiere .gitignore...${NC}"

GITIGNORE_ENTRIES=(
    "# MCP Environment Variables (SECURITY: Niemals committen!)"
    "env/.env"
    "env/.env.local"
    "env/.env.development"
    "env/.env.production"
    "env/.env.*.backup.*"
    ""
    "# Filesystem Sandbox (MCP)"
    ".ai-sandbox/*"
    "!.ai-sandbox/.keep"
)

# Prüfe ob schon vorhanden
if grep -q "MCP Environment Variables" "$GITIGNORE" 2>/dev/null; then
    echo -e "${YELLOW}  → .gitignore bereits aktualisiert${NC}"
else
    echo "" >> "$GITIGNORE"
    for entry in "${GITIGNORE_ENTRIES[@]}"; do
        echo "$entry" >> "$GITIGNORE"
    done
    echo -e "${GREEN}✓ .gitignore aktualisiert${NC}"
fi

# ══════════════════════════════════════════════════════════════
# 7. Zusammenfassung & Next Steps
# ══════════════════════════════════════════════════════════════
echo -e "${YELLOW}[7/7] Setup abgeschlossen!${NC}"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  NEXT STEPS                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "1. Konfiguriere API-Keys:"
echo "   nano env/.env.local"
echo ""
echo "2. Lade Environment (für aktuelle Session):"
echo "   source env/.env.local"
echo ""
echo "3. Oder dauerhaft in ~/.bashrc:"
echo "   echo 'set -a; [ -f \"\$PWD/env/.env.local\" ] && . \"\$PWD/env/.env.local\"; set +a' >> ~/.bashrc"
echo ""
echo "4. VS Code neustarten:"
echo "   Cmd/Ctrl+Shift+P → 'Developer: Reload Window'"
echo ""
echo "5. Teste MCP Server in Copilot Chat:"
echo "   @github list repositories"
echo ""
echo -e "${YELLOW}⚠️  SECURITY REMINDER:${NC}"
echo "   - env/.env.local ist in .gitignore"
echo "   - Niemals Production-Keys in Development!"
echo "   - Rotiere Keys alle 90 Tage"
echo ""
echo -e "${GREEN}✓ Setup erfolgreich abgeschlossen!${NC}"
