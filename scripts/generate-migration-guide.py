#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate .github/prompts/MIGRATION.md from .github/prompts/MIGRATION_MAP.json

Outputs a readable table with legacy → target mapping, plus summary stats.
Safe to re-run; overwrites the MIGRATION.md file.
"""
from __future__ import annotations

import json
from datetime import datetime
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
MAP_PATH = REPO / ".github" / "prompts" / "MIGRATION_MAP.json"
OUT_PATH = REPO / ".github" / "prompts" / "MIGRATION.md"


def main() -> None:
    data = json.loads(MAP_PATH.read_text(encoding="utf-8"))
    mappings: dict[str, str] = data.get("mappings", {})

    items = sorted(mappings.items(), key=lambda kv: kv[0].lower())
    total = len(items)
    tbd = sum(1 for _src, dst in items if str(dst).upper().startswith("TBD"))
    migrated = total - tbd

    now = datetime.utcnow().strftime("%Y-%m-%d %H:%M UTC")

    lines = []
    lines.append("# Prompts Migration Guide\n")
    lines.append(f"Generated: {now}  ")
    lines.append("Status: DEPRECATED → Migration zu Chatmodes/Instructions\n")

    lines.append("## Zusammenfassung\n")
    lines.append(f"- Gesamt-Mappings: {total}")
    lines.append(f"- Migriert: {migrated}")
    lines.append(f"- Offen (TBD): {tbd}\n")

    lines.append("## Mapping-Tabelle\n")
    lines.append("| Legacy | Ziel | Status |")
    lines.append("|-------|------|--------|")
    for src, dst in items:
        status = "TBD" if str(dst).upper().startswith("TBD") else "✅"
        lines.append(f"| `{src}` | `{dst}` | {status} |")

    OUT_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"Wrote {OUT_PATH.relative_to(REPO)} (total: {total}, migrated: {migrated}, tbd: {tbd})")


if __name__ == "__main__":
    main()
