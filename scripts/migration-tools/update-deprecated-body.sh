#!/bin/bash

# Script zum Aktualisieren der DEPRECATED-Texte im Body der Legacy-Prompt-Dateien

echo "=== Aktualisiere DEPRECATED-Texte im Body ==="
echo ""

total=0
updated=0

# Finde alle .md Dateien in .github/prompts/
while IFS= read -r file; do
    # Prüfe ob Datei das DEPRECATED Pattern im Body enthält
    if grep -q "⚠️ DEPRECATED - NICHT VERWENDEN" "$file"; then
        ((total++))
        echo "✅ Aktualisiere: $file"
        
        # Ersetze im Body:
        # 1. Titel-Zeile
        sed -i 's/⚠️ DEPRECATED - NICHT VERWENDEN/✅ MIGRIERT - Neue Version verfügbar/' "$file"
        
        # 2. Erste Beschreibungszeile
        sed -i 's/Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt./Diese Datei wurde zu einem moderneren Format migriert./' "$file"
        
        # 3. Status-Zeile im Body
        sed -i 's/- \*\*Status:\*\* DEPRECATED/- **Status:** MIGRATED/' "$file"
        
        # 4. Grund-Zeile (sofern vorhanden)
        sed -i 's/ersetzt durch einheitliches Chatmode\/Instructions-System/migriert zu einheitlichem Chatmode\/Instructions-System/' "$file"
        
        ((updated++))
    fi
done < <(find .github/prompts -name "*.md" -type f)

echo ""
echo "=== Zusammenfassung ==="
echo "Aktualisierte Body-Texte: $updated"
echo ""
echo "✅ Body-Text-Aktualisierung abgeschlossen!"
