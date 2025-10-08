#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Reorganize .github instructions & chatmodes by frontmatter category.

- Scans .github/instructions/*.md and .github/chatmodes/*.md
- Parses YAML frontmatter (lightweight parser, no external deps)
- Creates subdirectories per category
- Moves files accordingly
- Updates Markdown links across repo for moved files
- Generates .github/MOVE_LOG.json and category INDEX.md files

Idempotent: safe to run multiple times.
"""
from __future__ import annotations

import json
import os
import re
import shutil
from pathlib import Path
from typing import Dict, Tuple, Optional, List

REPO_ROOT = Path(__file__).resolve().parents[1]
GITHUB_DIR = REPO_ROOT / ".github"
INSTR_DIR = GITHUB_DIR / "instructions"
MODES_DIR = GITHUB_DIR / "chatmodes"
MOVE_LOG = GITHUB_DIR / "MOVE_LOG.json"

CATEGORY_FOLDERS_INSTR = {"core", "compliance", "deployment", "quality", "domain"}
CATEGORY_FOLDERS_MODES = {"development", "operations", "compliance", "content", "general"}

MD_LINK_RE = re.compile(r"\[(?P<text>[^\]]+)\]\((?P<url>[^)]+)\)")
FRONTMATTER_RE = re.compile(r"^---\n(.*?)\n---\n", re.DOTALL)


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def write_text(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding="utf-8")


def parse_frontmatter(content: str) -> Tuple[Optional[Dict[str, str]], str]:
    """Return (frontmatter_dict, rest_content). If no frontmatter, returns (None, content)."""
    m = FRONTMATTER_RE.match(content)
    if not m:
        return None, content
    block = m.group(1)
    fm: Dict[str, str] = {}
    for line in block.splitlines():
        # naive key: value parser, ignore nested structures
        if not line.strip() or line.strip().startswith('#'):
            continue
        if ':' in line:
            k, v = line.split(':', 1)
            fm[k.strip()] = v.strip().strip('"').strip("'")
    rest = content[m.end():]
    return fm, rest


def detect_category(file_path: Path, fm: Optional[Dict[str, str]], is_instruction: bool) -> str:
    if fm and fm.get("category"):
        cat = fm["category"].strip().lower()
        # normalize
        cat = cat.replace(' ', '-').replace('_', '-')
    else:
        cat = "general" if not is_instruction else "core"

    allowed = CATEGORY_FOLDERS_INSTR if is_instruction else CATEGORY_FOLDERS_MODES
    if cat not in allowed:
        # fallback
        cat = "general" if not is_instruction else "core"
    return cat


def compute_new_path(file_path: Path, category: str, is_instruction: bool) -> Path:
    base_dir = INSTR_DIR if is_instruction else MODES_DIR
    return base_dir / category / file_path.name


def find_md_files_to_update() -> List[Path]:
    paths: List[Path] = []
    # Update links in all markdowns under repo
    for p in REPO_ROOT.rglob("*.md"):
        # Skip node_modules/vendor/large folders for safety
        if any(part in {"node_modules", "vendor", ".git", "playwright-results"} for part in p.parts):
            continue
        paths.append(p)
    return paths


def update_links_in_file(path: Path, mapping: Dict[str, str]) -> bool:
    """Update markdown links based on mapping of old_rel_path -> new_rel_path (posix).
    Returns True if file changed."""
    original = read_text(path)

    def repl(match: re.Match) -> str:
        text = match.group('text')
        url = match.group('url')
        # Only update relative in-repo paths
        if url.startswith('http://') or url.startswith('https://'):
            return match.group(0)
        norm_url = url
        # Normalize './' and resolve oddities (we keep relative form)
        norm_url = norm_url.lstrip('./')
        # Build repo-relative posix path of current link target
        # Since mapping keys are repo-relative, attempt to resolve relative to repo root
        # If link already starts with .github/, use as-is
        candidate = norm_url
        if candidate in mapping:
            return f"[{text}]({mapping[candidate]})"
        # Also try to prepend current file relative dir if link is like 'instructions/foo.md'
        # Already handled.
        return match.group(0)

    updated = MD_LINK_RE.sub(repl, original)
    if updated != original:
        write_text(path, updated)
        return True
    return False


def main() -> None:
    print("=" * 80)
    print("REORGANIZE .GITHUB FILES - Phase 3")
    print("=" * 80)

    moves: Dict[str, str] = {}

    # 1) Collect moves for instructions and chatmodes
    for base_dir, is_instruction in ((INSTR_DIR, True), (MODES_DIR, False)):
        if not base_dir.exists():
            continue
        print(f"\n📁 Scanne: {base_dir.relative_to(REPO_ROOT)}")
        for p in sorted(base_dir.glob("*.md")):
            rel = p.relative_to(REPO_ROOT).as_posix()
            content = read_text(p)
            fm, _ = parse_frontmatter(content)
            cat = detect_category(p, fm, is_instruction)
            target = compute_new_path(p, cat, is_instruction)
            target_rel = target.relative_to(REPO_ROOT).as_posix()

            # Skip if already in correct folder
            if p == target:
                print(f"   ⏭️  Bereits richtig: {rel}")
                continue
            if p.parent.name == cat:
                print(f"   ⏭️  Bereits kategorisiert: {rel}")
                continue

            target.parent.mkdir(parents=True, exist_ok=True)
            print(f"   🚚 Verschiebe: {rel} → {target_rel}")
            shutil.move(str(p), str(target))
            moves[rel] = target_rel

    # 2) Update links across markdown files using mapping
    print("\n🔗 Aktualisiere interne Links...")
    changed_files = 0
    md_files = find_md_files_to_update()
    for md in md_files:
        # Mapping keys should be relative paths from repo root; links we saw keep as relative
        if update_links_in_file(md, moves):
            changed_files += 1
            print(f"   ✏️  Links aktualisiert: {md.relative_to(REPO_ROOT).as_posix()}")

    # 3) Write MOVE_LOG
    print("\n💾 Exportiere Move Log: .github/MOVE_LOG.json")
    MOVE_LOG.parent.mkdir(parents=True, exist_ok=True)
    MOVE_LOG.write_text(json.dumps({
        "generated": __import__("datetime").datetime.utcnow().isoformat(),
        "moved_count": len(moves),
        "link_updates": changed_files,
        "moves": moves,
    }, indent=2, ensure_ascii=False), encoding="utf-8")

    # 4) Generate INDEX files per area
    def build_index(area_dir: Path, allowed: set, title: str) -> None:
        items: Dict[str, List[str]] = {k: [] for k in sorted(allowed)}
        for cat in allowed:
            cat_dir = area_dir / cat
            if not cat_dir.exists():
                continue
            for f in sorted(cat_dir.glob("*.md")):
                items[cat].append(f.name)
        lines = [f"# {title}", "", "Automatisch generiert. Bitte nicht manuell bearbeiten.", ""]
        for cat in sorted(allowed):
            lines.append(f"## {cat}")
            lines.append("")
            if items[cat]:
                for name in items[cat]:
                    rel = (area_dir / cat / name).relative_to(GITHUB_DIR).as_posix()
                    lines.append(f"- [{name}]({rel})")
            else:
                lines.append("- (leer)")
            lines.append("")
        idx_path = area_dir / "INDEX.md"
        write_text(idx_path, "\n".join(lines).rstrip() + "\n")
        print(f"   📚 INDEX erstellt: {idx_path.relative_to(REPO_ROOT).as_posix()}")

    print("\n📚 Erzeuge INDEX Dateien...")
    build_index(INSTR_DIR, CATEGORY_FOLDERS_INSTR, ".github/instructions – Index")
    build_index(MODES_DIR, CATEGORY_FOLDERS_MODES, ".github/chatmodes – Index")

    print("\n✅ Reorganisation abgeschlossen!")
    print(f"🧾 Verschobene Dateien: {len(moves)} | Link-Updates: {changed_files}")


if __name__ == "__main__":
    main()
