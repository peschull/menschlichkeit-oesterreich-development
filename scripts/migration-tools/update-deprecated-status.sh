#!/bin/bash

# Script zum Aktualisieren des DEPRECATED Status in allen Legacy-Prompt-Dateien
# Ersetzt "status: DEPRECATED" durch "status: MIGRATED"

echo "=== Aktualisiere DEPRECATED Status in Legacy-Prompts ==="
echo ""

# Zähler
total=0
updated=0
skipped=0

# Finde alle .md Dateien in .github/prompts/ mit "status: DEPRECATED"
while IFS= read -r file; do
    ((total++))
    
    # Prüfe ob Datei das DEPRECATED Pattern enthält
    if grep -q "^status: DEPRECATED" "$file"; then
        echo "✅ Aktualisiere: $file"
        
        # Erstelle Backup
        cp "$file" "${file}.backup-deprecated-$(date +%s)"
        
        # Ersetze DEPRECATED durch MIGRATED
        sed -i 's/^status: DEPRECATED$/status: MIGRATED/' "$file"
        
        ((updated++))
    else
        echo "⏭️  Überspringe: $file (kein DEPRECATED Status)"
        ((skipped++))
    fi
done < <(find .github/prompts -name "*.md" -type f)

echo ""
echo "=== Zusammenfassung ==="
echo "Geprüfte Dateien: $total"
echo "Aktualisiert: $updated"
echo "Übersprungen: $skipped"
echo ""
echo "✅ Status-Aktualisierung abgeschlossen!"
echo ""
echo "Hinweis: Backup-Dateien wurden erstellt (*.backup-deprecated-*)"
