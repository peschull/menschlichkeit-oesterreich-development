#!/usr/bin/env bash
# Direct Plesk Deployment (non-interactive)
# Verwendet Credentials aus .env oder übergebene Parameter

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Parameter
ACTION="${1:-dry-run}"  # dry-run oder deploy
SSH_HOST="${2:-dmpl20230054@5.183.217.146}"
SSH_PORT="${3:-22}"
SSH_KEY="${4:-$HOME/.ssh/id_ed25519}"
REMOTE_PATH="${5:-/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs}"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 Plesk Direct Deployment                                ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📋 Konfiguration:${NC}"
echo "  Host:     $SSH_HOST"
echo "  Port:     $SSH_PORT"
echo "  Key:      $SSH_KEY"
echo "  Remote:   $REMOTE_PATH"
echo "  Action:   $ACTION"
echo ""

# Validierung
if [[ ! -f "$SSH_KEY" ]]; then
    echo -e "${RED}❌ SSH Key nicht gefunden: $SSH_KEY${NC}"
    exit 1
fi

# Excludes
EXCLUDES=(
    "--exclude=.git"
    "--exclude=.github"
    "--exclude=.DS_Store"
    "--exclude=node_modules"
    "--exclude=vendor"
    "--exclude=.env"
    "--exclude=.env.*"
    "--exclude=*.decrypted"
    "--exclude=secrets/"
    "--exclude=quality-reports/private/"
    "--exclude=tmp"
    "--exclude=cache"
    "--exclude=logs"
    "--exclude=.turbo"
    "--exclude=dist"
    "--exclude=build"
    "--exclude=*.sqlite"
    "--exclude=test-results"
    "--exclude=playwright-results"
)

if [[ "$ACTION" == "dry-run" ]]; then
    echo -e "${CYAN}🔍 Dry-Run Modus (keine Änderungen)${NC}"
    echo ""
    rsync -azn --delete --partial --info=progress2 --stats \
        -e "ssh -i '$SSH_KEY' -p $SSH_PORT -o StrictHostKeyChecking=no" \
        "${EXCLUDES[@]}" \
        "$ROOT_DIR/" "$SSH_HOST:$REMOTE_PATH/"
    
    echo -e "\n${GREEN}✅ Dry-Run abgeschlossen${NC}"
    echo -e "${YELLOW}💡 Führe './scripts/deploy-to-plesk-direct.sh deploy' aus um tatsächlich zu deployen${NC}"
    
elif [[ "$ACTION" == "deploy" ]]; then
    echo -e "${RED}⚠️  PRODUKTIONS-DEPLOYMENT STARTET${NC}"
    echo -e "${YELLOW}Dateien werden auf den Server übertragen...${NC}"
    echo ""
    
    rsync -az --delete --partial --info=progress2 --stats \
        -e "ssh -i '$SSH_KEY' -p $SSH_PORT -o StrictHostKeyChecking=no" \
        "${EXCLUDES[@]}" \
        "$ROOT_DIR/" "$SSH_HOST:$REMOTE_PATH/"
    
    if [[ $? -eq 0 ]]; then
        echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║              ✅ DEPLOYMENT ERFOLGREICH                      ║${NC}"
        echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${CYAN}🌐 Website: https://menschlichkeit-oesterreich.at${NC}"
        
        # Health Check
        echo -e "\n${CYAN}🏥 Health-Check...${NC}"
        if curl -fsSL --max-time 15 "https://menschlichkeit-oesterreich.at" -o /dev/null 2>/dev/null; then
            echo -e "${GREEN}✅ Website erreichbar und online${NC}"
        else
            echo -e "${YELLOW}⚠️  Website noch nicht erreichbar (DNS-Verzögerung oder Cache)${NC}"
        fi
    else
        echo -e "\n${RED}❌ Deployment fehlgeschlagen${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Ungültiger Action-Parameter: $ACTION${NC}"
    echo "Verwendung: $0 [dry-run|deploy] [ssh-host] [ssh-port] [ssh-key] [remote-path]"
    exit 1
fi
