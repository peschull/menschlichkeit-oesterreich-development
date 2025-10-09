#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Normalize YAML frontmatter for .github instructions & chatmodes:
- Ensure YAML frontmatter block is at very top of file
- If a frontmatter-like block exists elsewhere (within the first ~2000 chars), move it to top
- If no frontmatter exists, synthesize one with sensible defaults
- Fill in missing required fields

Required fields: title, version, created, lastUpdated, status, priority, category, applyTo

Safe & idempotent. Only modifies files that need changes.
"""
from __future__ import annotations

import re
from datetime import date
from pathlib import Path
from typing import Dict, Optional, Tuple

REPO = Path(__file__).resolve().parents[1]
GITHUB = REPO / ".github"
INSTR = GITHUB / "instructions"
MODES = GITHUB / "chatmodes"

FRONTMATTER_TOP_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)
FRONTMATTER_ANY_RE = re.compile(r"---\n(.*?)\n---\n", re.DOTALL)
H1_RE = re.compile(r"^#\s+(.+)$", re.MULTILINE)
SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+$")
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")

REQUIRED_FIELDS = ("title","version","created","lastUpdated","status","priority","category","applyTo")

TODAY = date.today().isoformat()


def read(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="replace")

def write(p: Path, content: str) -> None:
    p.write_text(content, encoding="utf-8")


def parse_frontmatter_block(block: str) -> Dict[str, str]:
    meta: Dict[str, str] = {}
    for line in block.splitlines():
        if not line.strip() or line.strip().startswith('#'):
            continue
        if ':' in line:
            k, v = line.split(':', 1)
            meta[k.strip()] = v.strip().strip('"').strip("'")
    return meta


def dump_frontmatter(meta: Dict[str, str]) -> str:
    lines = ["---"]
    for key in ("title","version","created","lastUpdated","status","priority","category","applyTo"):
        lines.append(f"{key}: {meta.get(key,'')}")
    lines.append("---\n")
    return "\n".join(lines)


def extract_title(content: str, filename: str) -> str:
    m = H1_RE.search(content)
    if m:
        return m.group(1).strip()
    # derive from filename without extension
    base = Path(filename).stem
    return base.replace('_',' ').replace('-',' ').strip()


def default_category(path: Path) -> str:
    # Use folder name if already categorized
    parent = path.parent.name.lower()
    if path.as_posix().startswith(INSTR.as_posix()):
        allowed = {"core","compliance","deployment","quality","domain"}
        return parent if parent in allowed else "core"
    else:
        allowed = {"development","operations","compliance","content","general"}
        return parent if parent in allowed else "general"


def default_priority(filename: str, category: str) -> str:
    name = filename.lower()
    if any(k in name for k in ["security","sicherheits","dsgvo","compliance","privacy"]):
        return "critical"
    if any(k in name for k in ["review","deployment","deploy","statuten","verein","quality-gates"]):
        return "high"
    if any(k in name for k in ["marketing","feature","dokumentation","documentation"]):
        return "low"
    return "medium"


def default_apply_to(path: Path, is_instruction: bool) -> str:
    if is_instruction:
        if "plesk" in path.name.lower():
            return "deployment-scripts/**,scripts/**,**/deploy*.sh"
        if "civicrm" in path.name.lower():
            return "crm.menschlichkeit-oesterreich.at/**,automation/n8n/**,deployment-scripts/**,scripts/**"
        if "database" in path.name.lower():
            return "**/*.{sql,prisma,js,ts,py,php}"
        return "**"
    else:
        return "**/*"


def ensure_frontmatter(path: Path) -> Tuple[bool, str]:
    """Ensure frontmatter present and at top. Returns (changed, new_content)."""
    content = read(path)
    is_instruction = path.as_posix().startswith(INSTR.as_posix())

    top_m = FRONTMATTER_TOP_RE.match(content)
    if top_m:
        meta = parse_frontmatter_block(top_m.group(1))
        body = content[top_m.end():]
    else:
        # search anywhere in first 2000 chars
        head = content[:2000]
        any_m = FRONTMATTER_ANY_RE.search(head)
        if any_m:
            block = any_m.group(1)
            meta = parse_frontmatter_block(block)
            # remove that occurrence and move to top
            start = any_m.start()
            end = any_m.end()
            body = content[:start] + content[end:]
        else:
            meta = {}
            body = content

    # Fill defaults
    filename = path.name
    if not meta.get("title"):
        meta["title"] = extract_title(body, filename)
    if not meta.get("version") or not SEMVER_RE.match(meta.get("version","")):
        meta["version"] = "1.0.0"
    if not meta.get("created") or not DATE_RE.match(meta.get("created","")):
        meta["created"] = TODAY
    if not meta.get("lastUpdated") or not DATE_RE.match(meta.get("lastUpdated","")):
        meta["lastUpdated"] = TODAY
    # Active for these dirs
    meta["status"] = "ACTIVE"
    cat = meta.get("category") or default_category(path)
    meta["category"] = cat
    if not meta.get("priority"):
        meta["priority"] = default_priority(filename, cat)
    if not meta.get("applyTo"):
        meta["applyTo"] = default_apply_to(path, is_instruction)

    new_content = dump_frontmatter(meta) + body.lstrip('\n')
    changed = (new_content != content)
    if changed:
        write(path, new_content)
    return changed, new_content


def main() -> None:
    print("=" * 80)
    print("NORMALIZE FRONTMATTER - Phase 4 helper")
    print("=" * 80)

    changed = 0
    scanned = 0

    for base in (INSTR, MODES):
        if not base.exists():
            continue
        print(f"\n📁 Scanne: {base.relative_to(REPO)}")
        for p in sorted(base.rglob("*.md")):
            # Skip INDEX files
            if p.name.lower() == "index.md":
                continue
            scanned += 1
            c, _ = ensure_frontmatter(p)
            if c:
                changed += 1
                print(f"   ✏️  Normalisiert: {p.relative_to(REPO).as_posix()}")

    print("\n📊 Zusammenfassung")
    print(f"   Dateien gescannt: {scanned}")
    print(f"   Dateien geändert: {changed}")
    print("✅ Fertig")


if __name__ == "__main__":
    main()
