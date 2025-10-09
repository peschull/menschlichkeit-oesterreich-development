# -*- coding: utf-8 -*-
"""
Unit tests for scripts/validate-github-files.py frontmatter parsing and basic validation helpers.

These tests are minimal and do not require repo file IO; they import functions directly and test with strings.
"""
from pathlib import Path
import sys
import types

import importlib.util

SCRIPT_PATH = Path(__file__).resolve().parents[3] / "scripts" / "validate-github-files.py"

spec = importlib.util.spec_from_file_location("validate_github_files", SCRIPT_PATH)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)  # type: ignore


def test_parse_frontmatter_ok():
    content = """---\nversion: 1.2.3\ncreated: 2025-10-08\nlastUpdated: 2025-10-08\nstatus: ACTIVE\npriority: high\ncategory: core\napplyTo: '**'\ntitle: Test\n---\nBody\n"""
    fm, rest = mod.parse_frontmatter(content)
    assert fm is not None
    assert fm["version"] == "1.2.3"
    assert fm["status"] == "ACTIVE"
    assert rest.strip() == "Body"


def test_parse_frontmatter_missing_block():
    content = "No frontmatter here\n"
    fm, rest = mod.parse_frontmatter(content)
    assert fm is None
    assert rest == content


def test_validate_file_detects_missing_fields(tmp_path):
    md = tmp_path / "file.md"
    md.write_text("""---\nversion: 0.1.0\ncreated: 2025-10-08\nlastUpdated: 2025-10-08\nstatus: ACTIVE\n# missing: title, priority, category, applyTo\n---\n""", encoding="utf-8")
    errors = mod.validate_file(md, active=True)
    # Expect at least 4 errors for missing fields
    assert any("fehlt Pflichtfeld 'title'" in e for e in errors)
    assert any("fehlt Pflichtfeld 'priority'" in e for e in errors)
    assert any("fehlt Pflichtfeld 'category'" in e for e in errors)
    assert any("fehlt Pflichtfeld 'applyTo'" in e for e in errors)
