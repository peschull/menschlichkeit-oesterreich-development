#!/usr/bin/env python3
"""
Pin GitHub Actions in workflow files to full commit SHAs.

Why: Security best practice – avoid mutable refs like @v4 or @master.

How it works:
- Scans .github/workflows/**/*.yml for `uses: owner/repo@ref` lines
- Skips if already pinned to a 40-char SHA
- Resolves the ref to a commit SHA via GitHub API:
  GET https://api.github.com/repos/{owner}/{repo}/commits/{ref}
  (works for branches and tags)
- Rewrites to: uses: owner/repo@<sha>  # ref: <original-ref>

Requirements:
- Python 3.8+
- Optional: GITHUB_TOKEN env for higher rate limits (recommended)

Usage:
- Dry run (default):
    python3 scripts/pin_gh_actions.py
- Write changes:
    python3 scripts/pin_gh_actions.py --write
- Limit to a subpath:
    python3 scripts/pin_gh_actions.py --path .github/workflows
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path
from typing import Dict, List, Optional

try:
    # Python 3.11+: use stdlib, else fall back
    from urllib.request import Request, urlopen
    from urllib.error import HTTPError, URLError
except Exception:  # pragma: no cover - very unlikely in our env
    print("FATAL: urllib not available in runtime", file=sys.stderr)
    sys.exit(2)


USES_PATTERN = re.compile(
    r"^(?P<prefix>\s*-?\s*uses:\s*)(?P<repo>[\w.-]+\/[\w.-]+)@(?P<ref>[^\s#]+)(?P<suffix>.*)$"
)


def is_sha(ref: str) -> bool:
    return bool(re.fullmatch(r"[0-9a-fA-F]{40}", ref))


def gh_api(url: str, token: Optional[str]) -> Optional[Dict]:
    headers = {"User-Agent": "moe-pin-actions-script"}
    if token:
        headers["Authorization"] = f"Bearer {token}"
    req = Request(url, headers=headers)
    try:
        with urlopen(req, timeout=30) as resp:
            data = resp.read()
            return json.loads(data.decode("utf-8"))
    except HTTPError as e:
        print(f"WARN: HTTP {e.code} for {url}", file=sys.stderr)
        try:
            body = e.read().decode("utf-8")
            if body:
                print(f"Details: {body}", file=sys.stderr)
        except Exception:
            pass
        return None
    except URLError as e:
        print(f"WARN: URL error for {url} -> {e}", file=sys.stderr)
        return None
    except Exception as e:
        print(f"WARN: Unexpected error calling {url}: {e}", file=sys.stderr)
        return None


def resolve_commit_sha(owner_repo: str, ref: str, token: Optional[str]) -> Optional[str]:
    """Resolve a branch/tag/ref to a commit SHA via GitHub API.

    We intentionally use the commits API which dereferences tags/branches:
      GET /repos/{owner}/{repo}/commits/{ref}
    https://docs.github.com/en/rest/commits/commits#get-a-commit
    """
    url = f"https://api.github.com/repos/{owner_repo}/commits/{ref}"
    data = gh_api(url, token)
    if not data:
        return None
    sha = data.get("sha")
    if sha and is_sha(sha):
        return sha
    # Some responses may nest commit info differently, attempt a best-effort
    for key in ("commit", "object", "target"):
        node = data.get(key)
        if isinstance(node, dict):
            sha = node.get("sha")
            if sha and is_sha(sha):
                return sha
    return None


def process_file(path: Path, token: Optional[str], write: bool) -> Dict:
    original = path.read_text(encoding="utf-8")
    lines = original.splitlines()
    changes: List[Dict[str, str]] = []
    new_lines: List[str] = []

    for idx, line in enumerate(lines):
        m = USES_PATTERN.match(line)
        if not m:
            new_lines.append(line)
            continue

        owner_repo = m.group("repo")
        ref = m.group("ref")
        prefix = m.group("prefix")
        suffix = m.group("suffix")

        if is_sha(ref):
            # Already pinned
            new_lines.append(line)
            continue

        sha = resolve_commit_sha(owner_repo, ref, token)
        if not sha:
            # Couldn't resolve; keep as-is and record warning
            changes.append(
                {
                    "status": "failed",
                    "file": str(path),
                    "line": str(idx + 1),
                    "owner_repo": owner_repo,
                    "ref": ref,
                    "message": "Could not resolve ref to commit SHA",
                }
            )
            new_lines.append(line)
            continue

        # Build replacement with trailing comment (preserve existing suffix, then add ref comment if missing)
        comment = f" # ref: {ref}"
        if f"ref: {ref}" in suffix:
            comment = ""  # already present in comment
        replacement = f"{prefix}{owner_repo}@{sha}{suffix}{comment}"
        new_lines.append(replacement)
        changes.append(
            {
                "status": "pinned",
                "file": str(path),
                "line": str(idx + 1),
                "owner_repo": owner_repo,
                "from": ref,
                "to": sha,
            }
        )

    changed = original != "\n".join(new_lines)
    if write and changed:
        path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")

    return {
        "file": str(path),
        "changed": changed,
        "changes": changes,
    }


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(description="Pin GitHub Actions to commit SHAs")
    parser.add_argument("--path", default=".github/workflows", help="Folder to scan (default: .github/workflows)")
    parser.add_argument("--write", action="store_true", help="Write changes to files (default: dry-run)")
    parser.add_argument("--report", default="security/reports/pin-actions-report.json", help="Report output path (JSON)")
    args = parser.parse_args(argv)

    root = Path(args.path)
    if not root.exists():
        print(f"ERROR: Path not found: {root}", file=sys.stderr)
        return 2

    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN")
    if not token:
        print("INFO: No GITHUB_TOKEN provided – GitHub API rate limit may be very low.", file=sys.stderr)

    files = list(root.rglob("*.yml")) + list(root.rglob("*.yaml"))
    results: List[Dict] = []
    total_pinned = 0
    total_failed = 0

    for file_path in files:
        res = process_file(file_path, token, write=args.write)
        results.append(res)
        for c in res["changes"]:
            if c["status"] == "pinned":
                total_pinned += 1
            elif c["status"] == "failed":
                total_failed += 1

    # Write report
    report_path = Path(args.report)
    report_path.parent.mkdir(parents=True, exist_ok=True)
    report = {
        "path": str(root),
        "write": args.write,
        "total_files": len(files),
        "total_pinned": total_pinned,
        "total_failed": total_failed,
        "results": results,
    }
    report_path.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    # Summary to stdout
    mode = "WRITE" if args.write else "DRY-RUN"
    print(f"Pin Actions – {mode}: files={len(files)} pinned={total_pinned} failed={total_failed}")
    print(f"Report: {report_path}")

    return 0 if total_failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
