#!/bin/bash

################################################################################
# TODO Auto-Update Script
# Aktualisiert TODO.md basierend auf Prompt-Execution-Status
#
# Usage:
#   ./scripts/update-todo-from-prompt.sh <prompt-file>
#   ./scripts/update-todo-from-prompt.sh 01_EmailDNSSetup_DE.prompt.md
#
# Dependencies:
#   - yq (YAML parser) - install via: npm install -g yq
#   - git (für Commits)
################################################################################

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Variablen
PROMPT_FILE="${1:-}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROMPTS_DIR="${REPO_ROOT}/.github/prompts"
TODO_FILE="${REPO_ROOT}/TODO.md"
BACKUP_DIR="${REPO_ROOT}/quality-reports/todo-backups"

################################################################################
# Helper Functions
################################################################################

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat << EOF
Usage: $0 <prompt-file>

Arguments:
  prompt-file   Prompt filename (z.B. 01_EmailDNSSetup_DE.prompt.md)

Examples:
  $0 01_EmailDNSSetup_DE.prompt.md
  $0 02_DatabaseRollout_DE.prompt.md
  
Environment:
  DRY_RUN=1     Zeige Änderungen ohne TODO.md zu modifizieren
  NO_COMMIT=1   Update TODO.md ohne Git-Commit
EOF
    exit 1
}

################################################################################
# Validation
################################################################################

if [[ -z "$PROMPT_FILE" ]]; then
    log_error "Kein Prompt-File angegeben!"
    usage
fi

# Full path konstruieren
if [[ ! "$PROMPT_FILE" =~ ^/ ]]; then
    PROMPT_PATH="${PROMPTS_DIR}/${PROMPT_FILE}"
else
    PROMPT_PATH="$PROMPT_FILE"
fi

if [[ ! -f "$PROMPT_PATH" ]]; then
    log_error "Prompt-File nicht gefunden: $PROMPT_PATH"
    exit 1
fi

if [[ ! -f "$TODO_FILE" ]]; then
    log_error "TODO.md nicht gefunden: $TODO_FILE"
    exit 1
fi

log_info "Verarbeite Prompt: $(basename "$PROMPT_PATH")"

################################################################################
# Backup TODO.md
################################################################################

mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/TODO_${TIMESTAMP}.md"

cp "$TODO_FILE" "$BACKUP_FILE"
log_info "Backup erstellt: $BACKUP_FILE"

################################################################################
# Parse Prompt Metadata (YAML Frontmatter)
################################################################################

# Extrahiere YAML zwischen --- und ---
METADATA=$(awk '/^---$/,/^---$/ {if (NR>1 && !/^---$/) print}' "$PROMPT_PATH")

if [[ -z "$METADATA" ]]; then
    log_warn "Keine YAML Metadata in Prompt gefunden"
    UPDATES_TODO="false"
    EXECUTION_ORDER=""
    DESCRIPTION=""
else
    # Parse YAML (simplified - no yq dependency)
    UPDATES_TODO=$(echo "$METADATA" | grep -E '^updates_todo:' | awk '{print $2}' || echo "false")
    EXECUTION_ORDER=$(echo "$METADATA" | grep -E '^execution_order:' | awk '{print $2}' || echo "")
    DESCRIPTION=$(echo "$METADATA" | grep -E '^description:' | cut -d':' -f2- | xargs || echo "")
fi

log_info "Metadata: updates_todo=$UPDATES_TODO, execution_order=$EXECUTION_ORDER"

if [[ "$UPDATES_TODO" != "true" ]]; then
    log_warn "Prompt hat updates_todo: false - keine TODO-Updates nötig"
    exit 0
fi

################################################################################
# Extrahiere Action Items aus Prompt
################################################################################

# Finde alle Checkboxen im Prompt
# Format: - [x] oder - [ ] oder □ oder ✅
COMPLETED_TASKS=$(grep -E '^\s*-\s*\[[xX✓]\]' "$PROMPT_PATH" | sed 's/^\s*-\s*\[[xX✓]\]\s*//' || true)
PENDING_TASKS=$(grep -E '^\s*-\s*\[\s\]' "$PROMPT_PATH" | sed 's/^\s*-\s*\[\s\]\s*//' || true)

COMPLETED_COUNT=$(echo "$COMPLETED_TASKS" | grep -c . || echo 0)
PENDING_COUNT=$(echo "$PENDING_TASKS" | grep -c . || echo 0)
TOTAL_COUNT=$((COMPLETED_COUNT + PENDING_COUNT))

log_info "Gefunden: $COMPLETED_COUNT completed, $PENDING_COUNT pending (Total: $TOTAL_COUNT)"

if [[ $TOTAL_COUNT -eq 0 ]]; then
    log_warn "Keine Action Items in Prompt gefunden"
    exit 0
fi

COMPLETION_PERCENT=$((COMPLETED_COUNT * 100 / TOTAL_COUNT))
log_info "Completion: ${COMPLETION_PERCENT}%"

################################################################################
# Update TODO.md
################################################################################

TEMP_TODO="${TODO_FILE}.tmp"
cp "$TODO_FILE" "$TEMP_TODO"

# Erstelle Section für diesen Prompt (falls nicht existiert)
SECTION_HEADER="## Prompt: $(basename "$PROMPT_PATH" .md)"

if ! grep -q "$SECTION_HEADER" "$TEMP_TODO"; then
    log_info "Erstelle neue TODO-Section für Prompt"
    cat >> "$TEMP_TODO" << EOF

---

$SECTION_HEADER

**Beschreibung:** $DESCRIPTION
**Execution Order:** $EXECUTION_ORDER
**Status:** ${COMPLETION_PERCENT}% Complete ($COMPLETED_COUNT/$TOTAL_COUNT)

### Completed ✅
$COMPLETED_TASKS

### Pending ⏳
$PENDING_TASKS

EOF
else
    log_info "Aktualisiere existierende TODO-Section"
    
    # Update Status-Line
    sed -i "s/^\*\*Status:\*\* .*%.*$/\*\*Status:\*\* ${COMPLETION_PERCENT}% Complete ($COMPLETED_COUNT\/$TOTAL_COUNT)/" "$TEMP_TODO"
    
    # Update Completed Tasks (simplified - replace entire section)
    # In production, würde hier intelligenteres Merging erfolgen
    log_warn "Section-Update noch nicht vollständig implementiert - manuelle Review nötig"
fi

################################################################################
# Dry-Run Check
################################################################################

if [[ "${DRY_RUN:-0}" == "1" ]]; then
    log_warn "DRY-RUN Mode: Zeige Änderungen ohne zu speichern"
    echo ""
    echo "=== TODO.md Diff ==="
    diff -u "$TODO_FILE" "$TEMP_TODO" || true
    echo ""
    rm "$TEMP_TODO"
    exit 0
fi

################################################################################
# Apply Changes
################################################################################

mv "$TEMP_TODO" "$TODO_FILE"
log_info "TODO.md aktualisiert"

# Zeige Diff
if command -v git &> /dev/null; then
    echo ""
    echo "=== Git Diff ==="
    git diff "$TODO_FILE" || true
fi

################################################################################
# Git Commit (optional)
################################################################################

if [[ "${NO_COMMIT:-0}" != "1" ]] && command -v git &> /dev/null; then
    if [[ -n "$(git status --porcelain "$TODO_FILE")" ]]; then
        PROMPT_NAME=$(basename "$PROMPT_PATH" .md)
        COMMIT_MSG="chore(todo): Update from ${PROMPT_NAME} (${COMPLETION_PERCENT}% complete)"
        
        git add "$TODO_FILE"
        git commit -m "$COMMIT_MSG"
        
        log_info "Git Commit erstellt: $COMMIT_MSG"
    else
        log_warn "Keine Änderungen für Git-Commit"
    fi
else
    log_warn "Git-Commit übersprungen (NO_COMMIT=1 oder git nicht verfügbar)"
fi

################################################################################
# Summary
################################################################################

cat << EOF

${GREEN}═══════════════════════════════════════════════════════════${NC}
${GREEN}TODO Update Complete${NC}
${GREEN}═══════════════════════════════════════════════════════════${NC}

Prompt:       $(basename "$PROMPT_PATH")
Completion:   ${COMPLETION_PERCENT}% (${COMPLETED_COUNT}/${TOTAL_COUNT})
Backup:       $BACKUP_FILE
TODO Updated: $TODO_FILE

${YELLOW}Next Steps:${NC}
1. Review TODO.md für Accuracy
2. Commit falls NO_COMMIT=1 gesetzt war
3. Update GitHub Project Board (optional)
4. Trigger next Prompt in execution_order

EOF

exit 0
