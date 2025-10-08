#!/usr/bin/env python3
"""
Legacy Files Marker

Markiert veraltete .github Dateien mit DEPRECATED Status
und bereitet Migration vor.
"""

import os
import json
from pathlib import Path
from datetime import datetime

# Konfiguration
GITHUB_DIR = Path(".github")
LEGACY_DIRS = [
    GITHUB_DIR / "prompts",
    GITHUB_DIR / "prompts" / "chatmodes",
]

DEPRECATION_TEMPLATE = """---
status: DEPRECATED
deprecated_date: {date}
migration_target: {target}
reason: {reason}
---

**⚠️ DEPRECATED - NICHT VERWENDEN**

Diese Datei ist veraltet und wird in einer zukünftigen Version entfernt.

- **Status:** DEPRECATED
- **Datum:** {date}
- **Migration:** {target}
- **Grund:** {reason}

**Aktuelle Version verwenden:** {target}

---

"""


def get_migration_target(file_path: Path) -> str:
    """Bestimmt Migrations-Ziel basierend auf Dateiname"""
    name = file_path.stem
    
    # .yaml.json → .yaml (redundant)
    if file_path.suffix == ".json" and ".yaml" in file_path.name:
        return f".github/prompts/chatmodes/{name.replace('.yaml', '')}.yaml"
    
    # _examples.md → Integration in Haupt-Datei
    if "_examples" in name:
        return f".github/chatmodes/{name.replace('_examples', '')}_DE.chatmode.md"
    
    # Legacy prompts → Neue chatmodes
    if file_path.parent.name == "prompts" and file_path.suffix == ".md":
        # CiviCRM_n8n_Automation_DE.prompt.md → civicrm-n8n-automation.instructions.md
        if "CiviCRM" in name or "n8n" in name or "Vereinsbuchhaltung" in name:
            normalized = name.replace("_DE.prompt", "").replace("_", "-").lower()
            return f".github/instructions/{normalized}.instructions.md"
        else:
            normalized = name.replace("_DE.prompt", "")
            return f".github/chatmodes/{normalized}_DE.chatmode.md"
    
    # prompts/chatmodes/*.yaml → chatmodes/*.chatmode.md
    if file_path.parent.name == "chatmodes" and file_path.suffix in [".yaml", ".json"]:
        return f".github/chatmodes/{name.replace('-', '_').title()}_DE.chatmode.md"
    
    return "TBD - Siehe Migration Guide"


def get_deprecation_reason(file_path: Path) -> str:
    """Bestimmt Grund für Deprecation"""
    if ".yaml.json" in file_path.name:
        return "JSON-Duplikat von YAML - redundant, wird nicht verwendet"
    elif "_examples" in file_path.stem:
        return "Examples wurden in Hauptdatei integriert - separate Datei nicht mehr nötig"
    elif file_path.parent.name == "prompts" and file_path.suffix == ".md":
        return "Legacy Prompt-Format - ersetzt durch einheitliches Chatmode/Instructions-System"
    elif file_path.suffix == ".yaml" and file_path.parent.name == "chatmodes":
        return "YAML-Format deprecated - ersetzt durch strukturierte .chatmode.md Dateien"
    else:
        return "Konsolidierung der .github Struktur - siehe VERSIONING-AND-CONSOLIDATION-PLAN.md"


def mark_file_deprecated(file_path: Path):
    """Fügt Deprecation-Warnung am Anfang der Datei ein"""
    target = get_migration_target(file_path)
    reason = get_deprecation_reason(file_path)
    date = datetime.now().strftime("%Y-%m-%d")
    
    deprecation_notice = DEPRECATION_TEMPLATE.format(
        date=date,
        target=target,
        reason=reason
    )
    
    try:
        # Lese existierenden Inhalt
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Prüfe ob schon deprecated
        if "status: DEPRECATED" in content:
            print(f"   ⏭️  Bereits deprecated: {file_path.relative_to(GITHUB_DIR)}")
            return False
        
        # Füge Deprecation Notice ein
        new_content = deprecation_notice + content
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"   ✅ Markiert: {file_path.relative_to(GITHUB_DIR)} → {target}")
        return True
        
    except Exception as e:
        print(f"   ❌ Fehler bei {file_path}: {e}")
        return False


def main():
    print("=" * 80)
    print("LEGACY FILES MARKER - Phase 1")
    print("=" * 80)
    
    stats = {
        "total": 0,
        "marked": 0,
        "skipped": 0,
        "errors": 0
    }
    
    migration_map = {}
    
    # Durchlaufe alle Legacy-Verzeichnisse
    for legacy_dir in LEGACY_DIRS:
        if not legacy_dir.exists():
            print(f"\n⚠️  Verzeichnis nicht gefunden: {legacy_dir}")
            continue
        
        print(f"\n📁 Verarbeite: {legacy_dir.relative_to(GITHUB_DIR)}")
        
        for file_path in legacy_dir.rglob("*"):
            if not file_path.is_file():
                continue
            
            # Skip bereits deprecated
            if file_path.suffix not in [".md", ".yaml", ".json"]:
                continue
            
            # Skip _schema.json (wird separat behandelt)
            if file_path.name == "_schema.json":
                continue
            
            stats["total"] += 1
            
            # Markiere als deprecated
            if mark_file_deprecated(file_path):
                stats["marked"] += 1
                # Speichere Migration-Mapping
                migration_map[str(file_path.relative_to(GITHUB_DIR))] = get_migration_target(file_path)
            else:
                stats["skipped"] += 1
    
    # Zusammenfassung
    print("\n" + "=" * 80)
    print("ZUSAMMENFASSUNG")
    print("=" * 80)
    print(f"\n📊 Statistiken:")
    print(f"   Gesamt: {stats['total']}")
    print(f"   ✅ Markiert: {stats['marked']}")
    print(f"   ⏭️  Übersprungen: {stats['skipped']}")
    print(f"   ❌ Fehler: {stats['errors']}")
    
    # Export Migration Map
    migration_file = GITHUB_DIR / "prompts" / "MIGRATION_MAP.json"
    print(f"\n💾 Exportiere Migration Map: {migration_file}")
    
    with open(migration_file, 'w', encoding='utf-8') as f:
        json.dump({
            "generated": datetime.now().isoformat(),
            "deprecated_count": stats["marked"],
            "mappings": migration_map
        }, f, indent=2, ensure_ascii=False)
    
    print("\n✅ Phase 1 abgeschlossen!")
    print("\n📋 Nächste Schritte:")
    print("   1. Review deprecated files: git status")
    print("   2. Migration testen (Phase 2)")
    print("   3. Cleanup durchführen (Phase 3)")
    print("=" * 80)


if __name__ == "__main__":
    main()
