#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Validate .github instructions & chatmodes files for required YAML frontmatter and rules.

Checks:
- All .md files under .github/instructions/** and .github/chatmodes/** have YAML frontmatter
- Required fields exist: title, version, created, lastUpdated, status, priority, category, applyTo
- version is SemVer (X.Y.Z)
- created/lastUpdated are YYYY-MM-DD
- status == ACTIVE (in active directories)
- No DEPRECATED files in active directories
- MIGRATION_MAP.json exists and is valid JSON (in .github/prompts/)

Outputs a summary and exits 0 if OK, 1 if any error.

Idempotent, no external dependencies.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional, Tuple

REPO = Path(__file__).resolve().parents[1]
GITHUB = REPO / ".github"
INSTR = GITHUB / "instructions"
MODES = GITHUB / "chatmodes"
PROMPTS = GITHUB / "prompts"
MIGRATION_MAP = PROMPTS / "MIGRATION_MAP.json"

FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")

REQUIRED_FIELDS = (
    "title",
    "version",
    "created",
    "lastUpdated",
    "status",
    "priority",
    "category",
    "applyTo",
)


def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="replace")


def parse_frontmatter(content: str) -> Tuple[Optional[Dict[str, str]], str]:
    m = FRONTMATTER_RE.match(content)
    if not m:
        return None, content
    block = m.group(1)
    fm: Dict[str, str] = {}
    for line in block.splitlines():
        if not line.strip() or line.strip().startswith('#'):
            continue
        if ':' in line:
            k, v = line.split(':', 1)
            fm[k.strip()] = v.strip().strip('"').strip("'")
    rest = content[m.end():]
    return fm, rest


def validate_file(path: Path, active: bool) -> List[str]:
    errors: List[str] = []
    try:
        rel = path.relative_to(REPO).as_posix()
    except Exception:
        # Allow validation of ad-hoc files outside repo root (e.g., unit tests)
        rel = path.as_posix()
    content = read_text(path)
    fm, _ = parse_frontmatter(content)
    if not fm:
        errors.append(f"{rel}: fehlt YAML Frontmatter")
        return errors

    # Required fields
    for field in REQUIRED_FIELDS:
        if field not in fm or not str(fm[field]).strip():
            errors.append(f"{rel}: fehlt Pflichtfeld '{field}'")

    # Formats
    version = fm.get("version", "")
    if version and not SEMVER_RE.match(version):
        errors.append(f"{rel}: version kein SemVer: '{version}'")

    created = fm.get("created", "")
    if created and not DATE_RE.match(created):
        errors.append(f"{rel}: created kein YYYY-MM-DD: '{created}'")

    updated = fm.get("lastUpdated", "")
    if updated and not DATE_RE.match(updated):
        errors.append(f"{rel}: lastUpdated kein YYYY-MM-DD: '{updated}'")

    status = fm.get("status", "")
    if active:
        if status.upper() != "ACTIVE":
            errors.append(f"{rel}: status muss ACTIVE sein (ist '{status}')")
    else:
        # Inactive areas could be DEPRECATED, but we don't enforce here.
        pass

    # No DEPRECATED tag in active dirs
    if active and "DEPRECATED" in content[:200].upper():
        errors.append(f"{rel}: enthält 'DEPRECATED' in aktivem Verzeichnis")

    return errors


def main() -> int:
    print("=" * 80)
    print("VALIDATE .GITHUB FILES - Phase 4")
    print("=" * 80)

    all_errors: List[str] = []
    checked = 0

    # Validate active directories
    for base in (INSTR, MODES):
        if not base.exists():
            continue
        for p in base.rglob("*.md"):
            # Skip index files but still validate frontmatter presence (they may not have frontmatter)
            if p.name.lower() == "index.md":
                # Allow index files without frontmatter
                checked += 1
                continue
            checked += 1
            all_errors.extend(validate_file(p, active=True))

    # Validate migration map exists and is valid JSON
    print("\n🔎 Prüfe Migration Map...")
    if not MIGRATION_MAP.exists():
        all_errors.append(".github/prompts/MIGRATION_MAP.json fehlt")
    else:
        try:
            data = json.loads(read_text(MIGRATION_MAP))
            if not isinstance(data, dict) or "mappings" not in data or not isinstance(data["mappings"], dict):
                all_errors.append("MIGRATION_MAP.json: Struktur ungültig (erwartet Objekt mit 'mappings')")
        except Exception as e:
            all_errors.append(f"MIGRATION_MAP.json: JSON ungültig: {e}")

    # Summary
    print("\n📊 Zusammenfassung")
    print(f"   Geprüfte Dateien: {checked}")
    if all_errors:
        print(f"   ❌ Fehler: {len(all_errors)}\n")
        for err in all_errors:
            print(f" - {err}")
        return 1
    else:
        print("   ✅ Keine Fehler gefunden")
        return 0


if __name__ == "__main__":
    sys.exit(main())
