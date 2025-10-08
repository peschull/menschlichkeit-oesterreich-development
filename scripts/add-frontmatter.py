#!/usr/bin/env python3
"""
Add Frontmatter to .github Files

Fügt YAML Frontmatter mit Versioning zu allen aktiven .github Dateien hinzu.
"""

import os
import re
from pathlib import Path
from datetime import datetime

# Konfiguration
GITHUB_DIR = Path(".github")
TARGET_DIRS = {
    "instructions": GITHUB_DIR / "instructions",
    "chatmodes": GITHUB_DIR / "chatmodes",
}

# Kategorisierung
CATEGORIES = {
    "instructions": {
        "core": ["project-development", "mcp-integration", "quality-gates", "codacy"],
        "compliance": ["dsgvo-compliance", "verein-statuten", "mitgliedsbeitraege"],
        "deployment": ["plesk-deployment", "n8n-automation", "database-operations-mcp", "civicrm-n8n-automation"],
        "quality": ["documentation", "markdown-best-practices", "markdown-documentation"],
        "domain": ["civicrm-vereinsbuchhaltung", "figma-mcp"],
    },
    "chatmodes": {
        "development": ["CodeReview", "APIDesign", "TestGeneration", "DatenbankSchema"],
        "operations": ["DeploymentGuide", "CIPipeline", "PerformanceOptimierung", "Dockerisierung"],
        "compliance": ["SicherheitsAudit", "BarrierefreiheitAudit"],
        "content": ["BenutzerDokumentation", "MarketingContent", "Onboarding", "Roadmap"],
    }
}

# Priority Mapping
PRIORITY_MAP = {
    "project-development": "critical",
    "mcp-integration": "critical",
    "dsgvo-compliance": "critical",
    "quality-gates": "critical",
    "verein-statuten": "high",
    "plesk-deployment": "high",
    "CodeReview": "high",
    "SicherheitsAudit": "critical",
}

FRONTMATTER_TEMPLATE = """---
title: {title}
version: {version}
created: {created}
lastUpdated: {last_updated}
status: ACTIVE
priority: {priority}
category: {category}
applyTo: {apply_to}
---

"""


def extract_title_from_content(content: str, filename: str) -> str:
    """Extrahiert Titel aus der ersten Überschrift oder Dateiname"""
    # Suche nach erster H1
    match = re.search(r'^#\s+(.+)$', content, re.MULTILINE)
    if match:
        return match.group(1).strip()
    
    # Fallback: Dateiname formatieren
    title = filename.replace("_DE.chatmode.md", "").replace(".instructions.md", "")
    title = title.replace("_", " ").replace("-", " ").title()
    return title


def determine_category(filename: str, file_type: str) -> str:
    """Bestimmt Kategorie basierend auf Dateiname"""
    base_name = filename.replace("_DE.chatmode.md", "").replace(".instructions.md", "")
    
    for category, files in CATEGORIES.get(file_type, {}).items():
        for pattern in files:
            if pattern.lower() in base_name.lower():
                return category
    
    return "general"


def determine_priority(filename: str) -> str:
    """Bestimmt Priorität basierend auf Dateiname"""
    base_name = filename.replace("_DE.chatmode.md", "").replace(".instructions.md", "")
    
    for pattern, priority in PRIORITY_MAP.items():
        if pattern.lower() in base_name.lower():
            return priority
    
    return "medium"


def determine_apply_to(filename: str, file_type: str) -> str:
    """Bestimmt applyTo Pattern"""
    base_name = filename.replace("_DE.chatmode.md", "").replace(".instructions.md", "")
    
    # Spezifische Mappings
    patterns = {
        "dsgvo": "**",
        "verein": "**",
        "codacy": "**",
        "quality-gates": "**/*",
        "civicrm": "crm.menschlichkeit-oesterreich.at/**",
        "n8n": "automation/n8n/**",
        "figma": "figma-design-system/**,frontend/**",
        "database": "**/*.{sql,prisma,js,ts,py,php}",
        "plesk": "deployment-scripts/**,scripts/**",
        "api": "api.menschlichkeit-oesterreich.at/**",
        "frontend": "frontend/**",
        "markdown": "**/*.md",
    }
    
    for pattern, apply in patterns.items():
        if pattern in base_name.lower():
            return apply
    
    return "**/*"


def has_frontmatter(content: str) -> bool:
    """Prüft ob Datei bereits Frontmatter hat"""
    return content.strip().startswith("---")


def add_frontmatter(file_path: Path, file_type: str):
    """Fügt Frontmatter zu Datei hinzu"""
    try:
        # Lese existierenden Inhalt
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Prüfe ob bereits Frontmatter vorhanden
        if has_frontmatter(content):
            # Extrahiere und aktualisiere
            match = re.match(r'^---\n(.+?)\n---\n', content, re.DOTALL)
            if match:
                print(f"   ⏭️  Hat bereits Frontmatter: {file_path.name}")
                return False
        
        # Bestimme Metadaten
        filename = file_path.name
        title = extract_title_from_content(content, filename)
        category = determine_category(filename, file_type)
        priority = determine_priority(filename)
        apply_to = determine_apply_to(filename, file_type)
        
        # Erstelle Frontmatter
        frontmatter = FRONTMATTER_TEMPLATE.format(
            title=title,
            version="1.0.0",
            created=datetime.now().strftime("%Y-%m-%d"),
            last_updated=datetime.now().strftime("%Y-%m-%d"),
            priority=priority,
            category=category,
            apply_to=apply_to
        )
        
        # Füge Frontmatter ein
        new_content = frontmatter + content
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        
        print(f"   ✅ Hinzugefügt: {file_path.name} (v1.0.0, {category}, {priority})")
        return True
        
    except Exception as e:
        print(f"   ❌ Fehler bei {file_path.name}: {e}")
        return False


def main():
    print("=" * 80)
    print("ADD FRONTMATTER TO .GITHUB FILES - Phase 2")
    print("=" * 80)
    
    stats = {
        "total": 0,
        "added": 0,
        "skipped": 0,
        "errors": 0
    }
    
    # Verarbeite jedes Verzeichnis
    for file_type, directory in TARGET_DIRS.items():
        if not directory.exists():
            print(f"\n⚠️  Verzeichnis nicht gefunden: {directory}")
            continue
        
        print(f"\n📁 Verarbeite {file_type}: {directory.relative_to(GITHUB_DIR)}")
        
        # Durchlaufe alle Dateien
        for file_path in sorted(directory.glob("*.md")):
            if file_path.is_file():
                stats["total"] += 1
                
                if add_frontmatter(file_path, file_type):
                    stats["added"] += 1
                else:
                    stats["skipped"] += 1
    
    # Zusammenfassung
    print("\n" + "=" * 80)
    print("ZUSAMMENFASSUNG")
    print("=" * 80)
    print(f"\n📊 Statistiken:")
    print(f"   Gesamt: {stats['total']}")
    print(f"   ✅ Hinzugefügt: {stats['added']}")
    print(f"   ⏭️  Übersprungen: {stats['skipped']}")
    print(f"   ❌ Fehler: {stats['errors']}")
    
    print("\n✅ Phase 2 abgeschlossen!")
    print("\n📋 Nächste Schritte:")
    print("   1. Review Frontmatter: git diff .github/")
    print("   2. Kategorien prüfen und ggf. anpassen")
    print("   3. Phase 3 starten (Reorganisation)")
    print("=" * 80)


if __name__ == "__main__":
    main()
