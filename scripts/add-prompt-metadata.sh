#!/bin/bash

################################################################################
# Add Metadata to Existing Prompts
# Fügt YAML Frontmatter zu allen Prompts ohne Metadata hinzu
#
# Usage:
#   ./scripts/add-prompt-metadata.sh
#
# Options:
#   DRY_RUN=1    Zeige Änderungen ohne Dateien zu modifizieren
################################################################################

set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_DIR="${REPO_ROOT}/.github/prompts"
BACKUP_DIR="${REPO_ROOT}/quality-reports/prompt-backups"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

################################################################################
# Category & Execution Order Mapping
################################################################################

declare -A PROMPT_CATEGORIES=(
    # Infrastructure (01-09)
    ["01_EmailDNSSetup_DE"]="infrastructure"
    ["02_DatabaseRollout_DE"]="infrastructure"
    ["03_MCPMultiServiceDeployment_DE"]="infrastructure"
    
    # MCP Operations (04-09)
    ["MCPDatabaseMigration_DE"]="database"
    ["MCPFeatureImplementation_DE"]="development"
    ["MCPDSGVOComplianceAudit_DE"]="compliance"
    ["MCPSecurityIncident_DE"]="security"
    
    # Development (10-19)
    ["CodeReview_DE"]="development"
    ["SicherheitsAudit_DE"]="security"
    ["PerformanceOptimierung_DE"]="performance"
    ["APIDesign_DE"]="architecture"
    ["DatenbankSchema_DE"]="database"
    
    # Documentation (20-29)
    ["README_DE"]="documentation"
    ["BenutzerDokumentation_DE"]="documentation"
    ["Onboarding_DE"]="documentation"
    ["DeploymentGuide_DE"]="documentation"
    
    # Planning (30-39)
    ["Roadmap_DE"]="strategy"
    ["FeatureVorschlag_DE"]="product"
    ["Lokalisierungsplan_DE"]="i18n"
    ["Beitragsrichtlinien_DE"]="community"
)

declare -A EXECUTION_ORDERS=(
    ["01_EmailDNSSetup_DE"]=1
    ["02_DatabaseRollout_DE"]=2
    ["03_MCPMultiServiceDeployment_DE"]=3
    ["MCPDatabaseMigration_DE"]=4
    ["MCPFeatureImplementation_DE"]=5
    ["MCPDSGVOComplianceAudit_DE"]=6
    ["MCPSecurityIncident_DE"]=7
    ["CodeReview_DE"]=10
    ["SicherheitsAudit_DE"]=11
    ["PerformanceOptimierung_DE"]=12
    ["APIDesign_DE"]=13
    ["DatenbankSchema_DE"]=14
    ["README_DE"]=20
    ["BenutzerDokumentation_DE"]=21
    ["Onboarding_DE"]=22
    ["DeploymentGuide_DE"]=23
    ["Roadmap_DE"]=30
    ["FeatureVorschlag_DE"]=31
    ["Lokalisierungsplan_DE"]=32
    ["Beitragsrichtlinien_DE"]=33
)

declare -A PRIORITIES=(
    ["01_EmailDNSSetup_DE"]="critical"
    ["02_DatabaseRollout_DE"]="critical"
    ["03_MCPMultiServiceDeployment_DE"]="critical"
    ["MCPSecurityIncident_DE"]="critical"
    ["SicherheitsAudit_DE"]="high"
    ["MCPDSGVOComplianceAudit_DE"]="high"
    ["PerformanceOptimierung_DE"]="high"
    ["CodeReview_DE"]="medium"
    ["README_DE"]="medium"
)

declare -A DEPENDENCIES=(
    ["02_DatabaseRollout_DE"]="01_EmailDNSSetup_DE.prompt.md"
    ["03_MCPMultiServiceDeployment_DE"]="01_EmailDNSSetup_DE.prompt.md,02_DatabaseRollout_DE.prompt.md"
)

################################################################################
# Process Prompts
################################################################################

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

PROCESSED=0
SKIPPED=0
UPDATED=0

for PROMPT_FILE in "$PROMPTS_DIR"/*.md; do
    [[ ! -f "$PROMPT_FILE" ]] && continue
    
    BASENAME=$(basename "$PROMPT_FILE" .md)
    PROMPT_NAME=$(basename "$PROMPT_FILE")
    
    # Skip wenn bereits Metadata vorhanden
    if head -n 3 "$PROMPT_FILE" | grep -q '^---$'; then
        log_warn "Überspringe $PROMPT_NAME (hat bereits Metadata)"
        ((SKIPPED++))
        continue
    fi
    
    log_info "Verarbeite: $PROMPT_NAME"
    
    # Backup
    cp "$PROMPT_FILE" "${BACKUP_DIR}/${BASENAME}_${TIMESTAMP}.md"
    
    # Determine metadata
    CATEGORY="${PROMPT_CATEGORIES[$BASENAME]:-development}"
    EXECUTION_ORDER="${EXECUTION_ORDERS[$BASENAME]:-}"
    PRIORITY="${PRIORITIES[$BASENAME]:-medium}"
    REQUIRES="${DEPENDENCIES[$BASENAME]:-}"
    
    # Extrahiere erste Zeile als Description (falls vorhanden)
    FIRST_LINE=$(head -n 1 "$PROMPT_FILE" | sed 's/^#\s*//')
    DESCRIPTION="${FIRST_LINE:-Prompt für $BASENAME}"
    
    # Updates TODO nur für Infrastructure/Critical Prompts
    UPDATES_TODO="false"
    if [[ "$PRIORITY" == "critical" || "$CATEGORY" == "infrastructure" ]]; then
        UPDATES_TODO="true"
    fi
    
    # Build requires array
    REQUIRES_YAML=""
    if [[ -n "$REQUIRES" ]]; then
        REQUIRES_YAML="requires:\n"
        IFS=',' read -ra DEPS <<< "$REQUIRES"
        for DEP in "${DEPS[@]}"; do
            REQUIRES_YAML+="  - \"$DEP\"\n"
        done
    else
        REQUIRES_YAML="requires: []"
    fi
    
    # Build YAML Frontmatter
    METADATA="---
description: $DESCRIPTION
priority: $PRIORITY
category: $CATEGORY"
    
    if [[ -n "$EXECUTION_ORDER" ]]; then
        METADATA+="\nexecution_order: $EXECUTION_ORDER"
    fi
    
    METADATA+="\n$(echo -e "$REQUIRES_YAML")"
    METADATA+="\nupdates_todo: $UPDATES_TODO
---

"
    
    # DRY-RUN Check
    if [[ "${DRY_RUN:-0}" == "1" ]]; then
        echo ""
        echo "=== $PROMPT_NAME ==="
        echo -e "$METADATA"
        echo "--- Original Content Preview ---"
        head -n 5 "$PROMPT_FILE"
        echo ""
        ((PROCESSED++))
        continue
    fi
    
    # Prepend Metadata
    TEMP_FILE="${PROMPT_FILE}.tmp"
    echo -e "$METADATA" > "$TEMP_FILE"
    cat "$PROMPT_FILE" >> "$TEMP_FILE"
    mv "$TEMP_FILE" "$PROMPT_FILE"
    
    log_info "✅ Updated: $PROMPT_NAME"
    ((UPDATED++))
    ((PROCESSED++))
done

################################################################################
# Summary
################################################################################

cat << EOF

${GREEN}═══════════════════════════════════════════════════════════${NC}
Metadata Addition Complete
${GREEN}═══════════════════════════════════════════════════════════${NC}

Processed: $PROCESSED
Updated:   $UPDATED
Skipped:   $SKIPPED (already had metadata)
Backups:   $BACKUP_DIR

EOF

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "${YELLOW}DRY-RUN Mode - keine Dateien wurden modifiziert${NC}"
    echo "Zum Anwenden: Ohne DRY_RUN=1 ausführen"
fi

exit 0
