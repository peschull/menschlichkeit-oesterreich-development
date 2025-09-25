#!/bin/bash

# =============================================================================
# SICHERER KONFIGURATIONS-LOADER
# Lädt Umgebungsvariablen aus .env Datei für Scripts
# =============================================================================

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$CONFIG_DIR/.env"

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Funktion: .env Datei laden
load_env_config() {
    if [ ! -f "$ENV_FILE" ]; then
        echo -e "${RED}❌ Fehler: .env Datei nicht gefunden!${NC}"
        echo -e "${YELLOW}📝 Bitte kopieren Sie .env.example zu .env und tragen Sie Ihre Daten ein:${NC}"
        echo -e "${GREEN}cp config/.env.example config/.env${NC}"
        echo -e "${GREEN}nano config/.env${NC}"
        return 1
    fi

    # .env Datei laden (nur Zeilen mit = und ohne #)
    set -a  # Automatisch alle Variablen exportieren
    source "$ENV_FILE"
    set +a

    echo -e "${GREEN}✅ Konfiguration geladen aus: $ENV_FILE${NC}"
    return 0
}

# Funktion: Überprüfung ob wichtige Variablen gesetzt sind
validate_config() {
    local missing_vars=()
    
    # Kritische Variablen prüfen
    [ -z "$DB_WP_NAME" ] && missing_vars+=("DB_WP_NAME")
    [ -z "$DB_WP_USER" ] && missing_vars+=("DB_WP_USER") 
    [ -z "$DB_WP_PASS" ] && missing_vars+=("DB_WP_PASS")
    [ -z "$SFTP_HOST" ] && missing_vars+=("SFTP_HOST")
    [ -z "$SFTP_USER" ] && missing_vars+=("SFTP_USER")
    
    if [ ${#missing_vars[@]} -ne 0 ]; then
        echo -e "${RED}❌ Fehlende Konfigurationsvariablen:${NC}"
        for var in "${missing_vars[@]}"; do
            echo -e "${RED}   - $var${NC}"
        done
        echo -e "${YELLOW}📝 Bitte überprüfen Sie Ihre .env Datei${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✅ Alle kritischen Konfigurationsvariablen sind gesetzt${NC}"
    return 0
}

# Funktion: Sichere Ausgabe der Konfiguration (ohne Passwörter)
show_config_safe() {
    echo -e "${GREEN}📋 Aktuelle Konfiguration (ohne Passwörter):${NC}"
    echo "   Datenbanken:"
    echo "     WordPress: $DB_WP_NAME (User: $DB_WP_USER)"
    echo "     Laravel API: $DB_API_NAME (User: $DB_API_USER)" 
    echo "     CiviCRM: $DB_CRM_NAME (User: $DB_CRM_USER)"
    echo "   SFTP: $SFTP_HOST (User: $SFTP_USER)"
    echo "   Umgebung: $APP_ENV"
    echo ""
}

# Hauptfunktion für Scripts
initialize_secure_config() {
    echo -e "${GREEN}🔐 Lade sichere Konfiguration...${NC}"
    
    if ! load_env_config; then
        return 1
    fi
    
    if ! validate_config; then
        return 1
    fi
    
    show_config_safe
    return 0
}

# Wenn Script direkt aufgerufen wird, Config laden
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    initialize_secure_config
fi