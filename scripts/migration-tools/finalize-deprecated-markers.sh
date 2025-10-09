#!/bin/bash

# Script zum Aktualisieren der restlichen DEPRECATED-Marker (Markdown-Headers & HTML-Kommentare)

echo "=== Finale DEPRECATED → MIGRATED Aktualisierung ==="
echo ""

total=0

# Finde alle .md Dateien mit verbliebenem DEPRECATED-Text
while IFS= read -r file; do
    if grep -q "⚠️ DEPRECATED – NICHT VERWENDEN" "$file"; then
        ((total++))
        echo "✅ Aktualisiere: $file"
        
        # Ersetze Markdown-Header
        sed -i 's/⚠️ DEPRECATED – NICHT VERWENDEN/✅ MIGRIERT – Neue Version verfügbar/g' "$file"
        
        # Ersetze HTML-Kommentare
        sed -i 's/<!-- DEPRECATED – NICHT VERWENDEN:/<!-- MIGRIERT:/g' "$file"
        
        # Ersetze Beschreibungstext
        sed -i 's/⚠️ DEPRECATED – Diese Legacy-Prompt-Datei wurde ersetzt./✅ MIGRIERT – Diese Legacy-Prompt-Datei wurde zu einem moderneren Format migriert./g' "$file"
    fi
done < <(find .github/prompts -name "*.md" -type f)

echo ""
echo "=== Zusammenfassung ==="
echo "Finalisierte Dateien: $total"
echo ""
echo "✅ Alle DEPRECATED-Marker aktualisiert!"
