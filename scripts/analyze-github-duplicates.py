#!/usr/bin/env python3
"""
GitHub Files Duplicate Analyzer

Identifiziert Duplikate in .github/ Verzeichnissen basierend auf:
- Dateinamen-Ähnlichkeit
- Inhalts-Hashing
- Strukturelle Ähnlichkeit
"""

import os
import hashlib
import json
import csv
from pathlib import Path
from collections import defaultdict
from typing import Dict, List, Tuple
import difflib

# Konfiguration
GITHUB_DIR = Path(".github")
REPORT_DIR = Path("quality-reports")
REPORT_FILE = REPORT_DIR / "github-duplicates.csv"
JSON_FILE = REPORT_DIR / "github-duplicates.json"

# Kategorien
CATEGORIES = {
    "chatmodes": GITHUB_DIR / "chatmodes",
    "prompts": GITHUB_DIR / "prompts",
    "prompts_chatmodes": GITHUB_DIR / "prompts" / "chatmodes",
    "instructions": GITHUB_DIR / "instructions",
}


def calculate_file_hash(file_path: Path) -> str:
    """Berechnet SHA256-Hash einer Datei"""
    sha256 = hashlib.sha256()
    try:
        with open(file_path, 'rb') as f:
            for chunk in iter(lambda: f.read(4096), b""):
                sha256.update(chunk)
        return sha256.hexdigest()
    except Exception as e:
        print(f"⚠️  Fehler beim Hashen von {file_path}: {e}")
        return ""


def normalize_filename(filename: str) -> str:
    """
    Normalisiert Dateinamen für Vergleich
    Beispiel: code-review_DE.chatmode.md → code-review
    """
    # Entferne Suffixe
    name = filename
    for suffix in [".chatmode.md", ".prompt.md", ".instructions.md", "_DE", "_EN", 
                   ".yaml", ".yaml.json", ".json", "_examples.md", ".md"]:
        name = name.replace(suffix, "")
    
    # Normalisiere Separatoren
    name = name.replace("_", "-").replace(" ", "-").lower()
    
    return name


def find_duplicates_by_name() -> Dict[str, List[Path]]:
    """Findet Duplikate basierend auf normalisierten Dateinamen"""
    name_map = defaultdict(list)
    
    for category, directory in CATEGORIES.items():
        if not directory.exists():
            continue
            
        for file_path in directory.rglob("*"):
            if file_path.is_file() and file_path.suffix in [".md", ".yaml", ".json"]:
                normalized = normalize_filename(file_path.name)
                name_map[normalized].append(file_path)
    
    # Filtere nur Duplikate (>1 Datei)
    duplicates = {name: files for name, files in name_map.items() if len(files) > 1}
    
    return duplicates


def find_duplicates_by_content() -> Dict[str, List[Path]]:
    """Findet Duplikate basierend auf Datei-Inhalt (Hash)"""
    hash_map = defaultdict(list)
    
    for category, directory in CATEGORIES.items():
        if not directory.exists():
            continue
            
        for file_path in directory.rglob("*"):
            if file_path.is_file() and file_path.suffix in [".md", ".yaml", ".json"]:
                file_hash = calculate_file_hash(file_path)
                if file_hash:
                    hash_map[file_hash].append(file_path)
    
    # Filtere nur Duplikate
    duplicates = {hash_val: files for hash_val, files in hash_map.items() if len(files) > 1}
    
    return duplicates


def calculate_content_similarity(file1: Path, file2: Path) -> float:
    """Berechnet Inhalts-Ähnlichkeit zwischen zwei Dateien (0.0 - 1.0)"""
    try:
        with open(file1, 'r', encoding='utf-8') as f1, \
             open(file2, 'r', encoding='utf-8') as f2:
            content1 = f1.read()
            content2 = f2.read()
            
        # SequenceMatcher für Ähnlichkeits-Score
        similarity = difflib.SequenceMatcher(None, content1, content2).ratio()
        return similarity
    except Exception as e:
        print(f"⚠️  Fehler beim Vergleich {file1} <-> {file2}: {e}")
        return 0.0


def analyze_duplicates():
    """Hauptanalyse-Funktion"""
    print("=" * 80)
    print("GITHUB FILES DUPLICATE ANALYZER")
    print("=" * 80)
    
    # 1. Duplikate nach Namen
    print("\n📝 Analysiere Duplikate nach Dateinamen...")
    name_duplicates = find_duplicates_by_name()
    print(f"   Gefunden: {len(name_duplicates)} Duplikat-Gruppen (Namen)")
    
    # 2. Duplikate nach Inhalt
    print("\n🔍 Analysiere Duplikate nach Inhalt (Hash)...")
    content_duplicates = find_duplicates_by_content()
    print(f"   Gefunden: {len(content_duplicates)} Duplikat-Gruppen (Inhalt)")
    
    # 3. Detaillierte Analyse
    print("\n📊 Erstelle Detailbericht...")
    
    results = []
    
    # Analyse Name-Duplikate
    for normalized_name, files in name_duplicates.items():
        # Prüfe ob auch Inhalts-Duplikate
        file_hashes = {f: calculate_file_hash(f) for f in files}
        unique_hashes = len(set(file_hashes.values()))
        
        # Berechne paarweise Ähnlichkeiten
        similarities = []
        if len(files) == 2:
            similarity = calculate_content_similarity(files[0], files[1])
            similarities.append(similarity)
        
        avg_similarity = sum(similarities) / len(similarities) if similarities else 0.0
        
        result = {
            "type": "name_duplicate",
            "normalized_name": normalized_name,
            "file_count": len(files),
            "files": [str(f.relative_to(GITHUB_DIR)) for f in files],
            "unique_content_hashes": unique_hashes,
            "average_similarity": round(avg_similarity, 2),
            "identical_content": unique_hashes == 1,
            "recommendation": ""
        }
        
        # Empfehlung
        if result["identical_content"]:
            result["recommendation"] = "DELETE_DUPLICATES - Identischer Inhalt, eine Datei behalten"
        elif avg_similarity > 0.9:
            result["recommendation"] = "MERGE - Sehr ähnlich, konsolidieren"
        elif avg_similarity > 0.5:
            result["recommendation"] = "REVIEW - Ähnlich, manuelle Prüfung nötig"
        else:
            result["recommendation"] = "KEEP_SEPARATE - Unterschiedliche Inhalte trotz ähnlicher Namen"
        
        results.append(result)
    
    # 4. Statistiken
    print("\n" + "=" * 80)
    print("ZUSAMMENFASSUNG")
    print("=" * 80)
    
    identical_count = sum(1 for r in results if r["identical_content"])
    merge_count = sum(1 for r in results if "MERGE" in r["recommendation"])
    review_count = sum(1 for r in results if "REVIEW" in r["recommendation"])
    
    print(f"\n📌 Identische Duplikate (DELETE): {identical_count}")
    print(f"📌 Ähnliche Dateien (MERGE): {merge_count}")
    print(f"📌 Zu prüfen (REVIEW): {review_count}")
    print(f"📌 Unterschiedlich (KEEP): {len(results) - identical_count - merge_count - review_count}")
    
    # Top Duplikate
    print("\n🔥 TOP 10 DUPLIKATE (nach Dateianzahl):")
    top_duplicates = sorted(results, key=lambda x: x["file_count"], reverse=True)[:10]
    for idx, dup in enumerate(top_duplicates, 1):
        print(f"\n{idx}. {dup['normalized_name']}")
        print(f"   Dateien: {dup['file_count']}")
        print(f"   Ähnlichkeit: {dup['average_similarity'] * 100:.1f}%")
        print(f"   Empfehlung: {dup['recommendation']}")
        for file in dup['files']:
            print(f"     - {file}")
    
    # 5. CSV-Export
    print(f"\n💾 Exportiere CSV-Report: {REPORT_FILE}")
    REPORT_DIR.mkdir(exist_ok=True)
    
    with open(REPORT_FILE, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = ['normalized_name', 'file_count', 'unique_content_hashes', 
                     'identical_content', 'average_similarity', 'recommendation', 'files']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        
        writer.writeheader()
        for result in results:
            row = {
                'normalized_name': result['normalized_name'],
                'file_count': result['file_count'],
                'unique_content_hashes': result['unique_content_hashes'],
                'identical_content': result['identical_content'],
                'average_similarity': result['average_similarity'],
                'recommendation': result['recommendation'],
                'files': ' | '.join(result['files'])
            }
            writer.writerow(row)
    
    # 6. JSON-Export
    print(f"💾 Exportiere JSON-Report: {JSON_FILE}")
    with open(JSON_FILE, 'w', encoding='utf-8') as jsonfile:
        json.dump({
            "analysis_date": "2025-10-08",
            "total_duplicates": len(results),
            "statistics": {
                "identical": identical_count,
                "merge_recommended": merge_count,
                "review_required": review_count,
                "keep_separate": len(results) - identical_count - merge_count - review_count
            },
            "duplicates": results
        }, jsonfile, indent=2, ensure_ascii=False)
    
    print("\n✅ Analyse abgeschlossen!")
    print("=" * 80)
    
    return results


if __name__ == "__main__":
    try:
        results = analyze_duplicates()
        
        # Exit Code basierend auf Ergebnissen
        critical_duplicates = sum(1 for r in results if r["identical_content"])
        if critical_duplicates > 0:
            print(f"\n⚠️  WARNUNG: {critical_duplicates} identische Duplikate gefunden!")
            # exit(1)  # Auskommentiert für CI/CD Integration
    except Exception as e:
        print(f"\n❌ FEHLER: {e}")
        import traceback
        traceback.print_exc()
        exit(1)
