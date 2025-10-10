"""
Pytest configuration for test environment.

Ensures the API package directory is on sys.path so tests can import
`app.lib.pii_sanitizer` regardless of the current working directory.
"""

import sys
from pathlib import Path


def _ensure_api_on_sys_path() -> None:
    repo_root = Path(__file__).resolve().parent.parent
    api_dir = repo_root / "api.menschlichkeit-oesterreich.at"
    api_str = str(api_dir)
    if api_dir.exists() and api_str not in sys.path:
        sys.path.insert(0, api_str)


_ensure_api_on_sys_path()
