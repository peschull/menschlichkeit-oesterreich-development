#!/usr/bin/env bash
# pr-logs-fetch.sh — Sammle GitHub Actions Logs für eine PR und erstelle Kurzberichte
#
# Usage:
#   scripts/pr-logs-fetch.sh <pr-number> [owner/repo]
#
# Outputs unter: logs/ci/pr-<number>/
#  - pr.json                PR-Metadaten
#  - summary.tsv            Liste relevanter Workflow-Runs (TSV)
#  - runs/<run-id>/...      Entpackte Step-Logs (aus ZIP)
#  - failed_report_keyworkflows.txt  Kurz-Zusammenfassung für Kern-Workflows

set -euo pipefail

if [[ ${1:-} == "" ]]; then
  echo "Usage: $0 <pr-number> [owner/repo]" >&2
  exit 2
fi

PR_NUMBER="$1"
REPO_SLUG="${2:-}"

# Repo ermitteln (Prio: CLI-Arg, Umgebung, git, gh)
if [[ -z "$REPO_SLUG" ]]; then
  if gh repo view --json nameWithOwner >/dev/null 2>&1; then
    REPO_SLUG=$(gh repo view --json nameWithOwner -q .nameWithOwner)
  else
    # Fallback auf festes Repo (projektspezifisch)
    REPO_SLUG="peschull/menschlichkeit-oesterreich-development"
  fi
fi

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
OUTDIR="$ROOT_DIR/logs/ci/pr-$PR_NUMBER"
mkdir -p "$OUTDIR/runs"

echo "Repo: $REPO_SLUG" >&2
echo "PR:   #$PR_NUMBER" >&2
echo "Out:  $OUTDIR" >&2

# 1) PR-Metadaten speichern
gh pr view "$PR_NUMBER" --repo "$REPO_SLUG" \
  --json number,title,headRepository,headRefName,headRefOid,baseRefName,author,mergeable,mergeStateStatus,url \
  | jq -r . > "$OUTDIR/pr.json"

HEAD_BRANCH=$(jq -r .headRefName "$OUTDIR/pr.json")
HEAD_SHA=$(jq -r .headRefOid "$OUTDIR/pr.json")
echo "Branch: $HEAD_BRANCH" >&2
echo "SHA:    $HEAD_SHA" >&2

# 2) Workflow-Runs (pull_request) listen und filtern
TMP_RUNS_JSON="$OUTDIR/runs.json"
gh api \
  -H "Accept: application/vnd.github+json" \
  repos/$REPO_SLUG/actions/runs \
  --paginate \
  -f event=pull_request -f per_page=100 \
  > "$TMP_RUNS_JSON"

jq -r \
  --arg b "$HEAD_BRANCH" \
  --arg s "$HEAD_SHA" \
  '.workflow_runs[] | select(.head_branch==$b or .head_sha==$s) | [.id,.name,.status,.conclusion,.html_url,.head_branch,.head_sha,.created_at,.updated_at] | @tsv' \
  "$TMP_RUNS_JSON" | sort -k8 > "$OUTDIR/summary.tsv" || true

echo "Runs in summary.tsv: $(wc -l < "$OUTDIR/summary.tsv" || echo 0)" >&2

# 3) Logs für fehlgeschlagene Runs laden und entpacken
while IFS=$'\t' read -r RUN_ID NAME STATUS CONCLUSION URL HEAD_B HEAD_S CREATED UPDATED; do
  [[ -z "${RUN_ID:-}" ]] && continue
  if [[ "$STATUS" == "completed" && "$CONCLUSION" != "success" ]]; then
    ZIP="$OUTDIR/runs/${RUN_ID}.zip"
    DIR="$OUTDIR/runs/${RUN_ID}"
    if [[ ! -f "$ZIP" ]]; then
      echo "Downloading logs for run $RUN_ID ($NAME)" >&2
      gh api -H "Accept: application/vnd.github+json" repos/$REPO_SLUG/actions/runs/$RUN_ID/logs > "$ZIP" || true
    fi
    if [[ -s "$ZIP" && ! -d "$DIR" ]]; then
      mkdir -p "$DIR"
      unzip -q "$ZIP" -d "$DIR" || true
    fi
  fi
done < "$OUTDIR/summary.tsv"

# 4) Kurzbericht Kern-Workflows
WF_LIST=("MCP Health" "Prompt CI" "Quality" "Trivy FS Scan" "CodeQL" "Codacy Analysis")
REPORT="$OUTDIR/failed_report_keyworkflows.txt"
: > "$REPORT"
for n in "${WF_LIST[@]}"; do
  LINE=$(awk -F"\t" -v n="$n" '$2==n && $3=="completed" && $4!="success"{print $0}' "$OUTDIR/summary.tsv" | sort -k8 | tail -n1 || true)
  if [[ -z "$LINE" ]]; then
    echo "## $n — no failed run found" >> "$REPORT"
    echo >> "$REPORT"
    continue
  fi
  ID=$(printf "%s" "$LINE" | cut -f1)
  URL=$(printf "%s" "$LINE" | cut -f5)
  echo "## ${n} — run ${ID}" >> "$REPORT"
  echo "URL: ${URL}" >> "$REPORT"
  echo "-- last 120 error lines --" >> "$REPORT"
  if [[ -d "$OUTDIR/runs/${ID}" ]]; then
    grep -inRE "(error|failed|timed out|fatal|Traceback)" "$OUTDIR/runs/${ID}" | tail -n 120 >> "$REPORT" || true
  else
    echo "(no extracted dir $OUTDIR/runs/${ID})" >> "$REPORT"
  fi
  echo >> "$REPORT"
done

echo "Created report: $REPORT" >&2
