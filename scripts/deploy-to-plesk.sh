#!/usr/bin/env bash
# Interactive Plesk Deployment Script
# Fragt SSH-Zugangsdaten ab und führt sicheres Deployment durch

set -euo pipefail

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  🚀 Plesk Deployment - Menschlichkeit Österreich           ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Prüfe ob .env existiert
if [[ -f "$ROOT_DIR/.env" ]]; then
    echo -e "${CYAN}ℹ️  Lade bestehende .env Konfiguration...${NC}"
    # shellcheck disable=SC1090
    source "$ROOT_DIR/.env"
fi

# SSH-Zugangsdaten abfragen oder aus .env verwenden
echo -e "\n${YELLOW}🔐 SSH-Zugangsdaten${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# SSH Host
if [[ -n "${PLESK_HOST:-}" && ! "$PLESK_HOST" =~ "your-" ]]; then
    read -p "SSH Host [$PLESK_HOST]: " INPUT_HOST
    SSH_HOST="${INPUT_HOST:-$PLESK_HOST}"
else
    read -p "SSH Host (Format: user@server-ip oder user@domain.at): " SSH_HOST
fi

# SSH Port
if [[ -n "${SSH_PORT:-}" ]]; then
    read -p "SSH Port [$SSH_PORT]: " INPUT_PORT
    SSH_PORT="${INPUT_PORT:-$SSH_PORT}"
else
    read -p "SSH Port [22]: " SSH_PORT
    SSH_PORT="${SSH_PORT:-22}"
fi

# SSH Key Path
if [[ -n "${SSH_KEY:-}" ]]; then
    read -p "SSH Private Key Path [$SSH_KEY]: " INPUT_KEY
    SSH_KEY="${INPUT_KEY:-$SSH_KEY}"
else
    read -p "SSH Private Key Path [~/.ssh/id_ed25519]: " SSH_KEY
    SSH_KEY="${SSH_KEY:-~/.ssh/id_ed25519}"
fi

# Remote Path
if [[ -n "${PLESK_REMOTE_PATH:-}" && ! "$PLESK_REMOTE_PATH" =~ "your-" ]]; then
    read -p "Remote Path [$PLESK_REMOTE_PATH]: " INPUT_PATH
    REMOTE_PATH="${INPUT_PATH:-$PLESK_REMOTE_PATH}"
else
    read -p "Remote Path [/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs]: " REMOTE_PATH
    REMOTE_PATH="${REMOTE_PATH:-/var/www/vhosts/menschlichkeit-oesterreich.at/httpdocs}"
fi

# Expandiere ~ in SSH_KEY
SSH_KEY="${SSH_KEY/#\~/$HOME}"

# Validierung
echo -e "\n${YELLOW}🔍 Validierung...${NC}"

if [[ ! -f "$SSH_KEY" ]]; then
    echo -e "${RED}❌ SSH Key nicht gefunden: $SSH_KEY${NC}"
    echo -e "${YELLOW}💡 Tipp: Erstelle einen SSH-Key mit: ssh-keygen -t ed25519${NC}"
    exit 1
fi

# Prüfe SSH-Verbindung
echo -e "${CYAN}🔌 Teste SSH-Verbindung...${NC}"
if ssh -i "$SSH_KEY" -p "$SSH_PORT" -o ConnectTimeout=10 -o BatchMode=yes "$SSH_HOST" "echo 'SSH OK'" &>/dev/null; then
    echo -e "${GREEN}✅ SSH-Verbindung erfolgreich${NC}"
else
    echo -e "${RED}❌ SSH-Verbindung fehlgeschlagen${NC}"
    echo -e "${YELLOW}💡 Stelle sicher, dass:${NC}"
    echo "   1. Der SSH-Key auf dem Server hinterlegt ist (authorized_keys)"
    echo "   2. Die Firewall Port $SSH_PORT zulässt"
    echo "   3. Host und Port korrekt sind"
    exit 1
fi

# Zeige Deployment-Plan
echo -e "\n${BLUE}📋 Deployment-Plan${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "  SSH Host:     ${CYAN}$SSH_HOST${NC}"
echo -e "  SSH Port:     ${CYAN}$SSH_PORT${NC}"
echo -e "  SSH Key:      ${CYAN}$SSH_KEY${NC}"
echo -e "  Remote Path:  ${CYAN}$REMOTE_PATH${NC}"
echo -e "  Local Path:   ${CYAN}$ROOT_DIR${NC}"
echo ""

# Zeige welche Dateien übertragen werden (Dry-Run)
echo -e "${YELLOW}📦 Vorschau der zu übertragenden Dateien...${NC}"
echo ""

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
)

# Dry-Run
rsync -azn --delete --stats \
    -e "ssh -i '$SSH_KEY' -p $SSH_PORT" \
    "${EXCLUDES[@]}" \
    "$ROOT_DIR/" "$SSH_HOST:$REMOTE_PATH/" \
    | tail -20

echo ""
echo -e "${YELLOW}⚠️  ACHTUNG: Deployment-Modus${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Bitte wähle:"
echo "  1) 🔍 Nur Vorschau (Dry-Run, sicher)"
echo "  2) 🚀 Vollständiges Deployment (schreibt auf Server!)"
echo "  3) ❌ Abbrechen"
echo ""
read -p "Deine Wahl [1]: " CHOICE
CHOICE="${CHOICE:-1}"

case "$CHOICE" in
    1)
        echo -e "\n${CYAN}🔍 Führe Dry-Run durch...${NC}"
        rsync -azn --delete --partial --info=progress2 \
            -e "ssh -i '$SSH_KEY' -p $SSH_PORT" \
            "${EXCLUDES[@]}" \
            "$ROOT_DIR/" "$SSH_HOST:$REMOTE_PATH/"

        echo -e "\n${GREEN}✅ Dry-Run abgeschlossen${NC}"
        echo -e "${YELLOW}💡 Keine Änderungen wurden auf dem Server vorgenommen${NC}"
        ;;

    2)
        echo -e "\n${RED}⚠️  LETZTE WARNUNG${NC}"
        echo "Dies wird Dateien auf dem Produktionsserver ÜBERSCHREIBEN!"
        read -p "Wirklich fortfahren? (yes zum Bestätigen): " CONFIRM

        if [[ "$CONFIRM" != "yes" ]]; then
            echo -e "${YELLOW}❌ Deployment abgebrochen${NC}"
            exit 0
        fi

        echo -e "\n${GREEN}🚀 Starte Deployment...${NC}"
        echo ""

        rsync -az --delete --partial --info=progress2 \
            -e "ssh -i '$SSH_KEY' -p $SSH_PORT" \
            "${EXCLUDES[@]}" \
            "$ROOT_DIR/" "$SSH_HOST:$REMOTE_PATH/"

        if [[ $? -eq 0 ]]; then
            echo -e "\n${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║              ✅ DEPLOYMENT ERFOLGREICH                      ║${NC}"
            echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${CYAN}🌐 Überprüfe deine Website:${NC}"
            echo "   https://menschlichkeit-oesterreich.at"

            # Optional: Health Check
            echo ""
            echo -e "${CYAN}🏥 Führe Health-Check durch...${NC}"
            if curl -fsSL --max-time 10 "https://menschlichkeit-oesterreich.at" -o /dev/null; then
                echo -e "${GREEN}✅ Website erreichbar${NC}"
            else
                echo -e "${YELLOW}⚠️  Website nicht erreichbar (möglicherweise DNS-Verzögerung)${NC}"
            fi
        else
            echo -e "\n${RED}❌ Deployment fehlgeschlagen${NC}"
            exit 1
        fi
        ;;

    3)
        echo -e "${YELLOW}❌ Deployment abgebrochen${NC}"
        exit 0
        ;;

    *)
        echo -e "${RED}❌ Ungültige Auswahl${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Deployment-Prozess abgeschlossen!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
