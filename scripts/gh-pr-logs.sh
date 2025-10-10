#!/usr/bin/env bash

# gh-pr-logs.sh — Sammle fehlgeschlagene Workflow-Run-Logs für einen PR
#
# Voraussetzungen:
# - GitHub CLI (gh) ist konfiguriert und authentifiziert
# - unzip ist installiert
#
# Nutzung:
#   bash scripts/gh-pr-logs.sh <PR_NUMMER> [OWNER/REPO]
#   PR_NUMMER: Pflicht (z. B. 62)
#   OWNER/REPO: Optional, Standard: peschull/menschlichkeit-oesterreich-development
#
# Ausgabe:
# - logs/ci/pr-<PR>/runs.json               → alle Runs (event=pull_request) für den PR-Head-Branch
# - logs/ci/pr-<PR>/failed.json             → Liste fehlgeschlagener Runs (id, name, conclusion, url)
# - logs/ci/pr-<PR>/runs/<RUN_ID>/logs.zip  → Original-Logs-ZIP je Run
# - logs/ci/pr-<PR>/runs/<RUN_ID>/unzipped/ → entpackte Logs
# - logs/ci/pr-<PR>/aggregate.txt           → komprimierte Fehlerzusammenfassung

set -euo pipefail

if ! command -v gh >/dev/null 2>&1; then
  echo "Fehler: GitHub CLI (gh) ist nicht installiert." >&2
  exit 2
fi
if ! command -v unzip >/dev/null 2>&1; then
  echo "Fehler: unzip ist nicht installiert." >&2
  exit 2
fi

PR_NUMBER=${1:-}
REPO=${2:-peschull/menschlichkeit-oesterreich-development}

if [[ -z "${PR_NUMBER}" ]]; then
  echo "Nutzung: $0 <PR_NUMMER> [OWNER/REPO]" >&2
  exit 2
fi

echo "Repository: ${REPO} · PR: #${PR_NUMBER}" >&2

WORKDIR="logs/ci/pr-${PR_NUMBER}"
mkdir -p "${WORKDIR}/runs"

echo "Hole PR Metadaten …" >&2
HEAD_BRANCH=$(gh pr view "${PR_NUMBER}" --repo "${REPO}" --json headRefName --jq .headRefName)
HEAD_SHA=$(gh pr view "${PR_NUMBER}" --repo "${REPO}" --json headRefOid --jq .headRefOid)
echo "Head-Branch=${HEAD_BRANCH}" >&2
echo "Head-SHA=${HEAD_SHA}" >&2

RUNS_FILE="${WORKDIR}/runs.json"
echo "Liste Workflow-Runs (event=pull_request, branch=${HEAD_BRANCH}) …" >&2
gh api \
  "/repos/${REPO}/actions/runs" \
  -f event=pull_request \
  -f branch="${HEAD_BRANCH}" \
  -f per_page=100 > "${RUNS_FILE}"

FAILED_FILE="${WORKDIR}/failed.json"
python3 - "$HEAD_SHA" "$RUNS_FILE" "$FAILED_FILE" <<'PY'
import json,sys

head_sha=sys.argv[1]
runs_path=sys.argv[2]
failed_path=sys.argv[3]

with open(runs_path,"r") as f:
    data=json.load(f)

failed=[]
for wr in data.get("workflow_runs",[]):
    if wr.get("head_sha")!=head_sha:
        continue
    conc=wr.get("conclusion")
    # Im Status null (noch laufend) ignorieren; als fehlgeschlagen zählen alles außer success/skipped
    if conc and conc not in ("success","skipped"):
        failed.append({
            "id": wr.get("id"),
            "name": wr.get("name"),
            "status": wr.get("status"),
            "conclusion": conc,
            "event": wr.get("event"),
            "html_url": wr.get("html_url"),
            "run_attempt": wr.get("run_attempt"),
        })

with open(failed_path,"w") as f:
    json.dump(failed,f,indent=2)

print(json.dumps({"count":len(failed),"failed":failed},indent=2))
PY

echo "Lade Logs für fehlgeschlagene Runs …" >&2

download_logs() {
  local run_id="$1"
  local run_dir="${WORKDIR}/runs/${run_id}"
  mkdir -p "${run_dir}/unzipped"
  local zip_file="${run_dir}/logs.zip"
  # GitHub API liefert ein ZIP mit Logs aller Jobs
  gh api \
    -H "Accept: application/vnd.github+json" \
    "/repos/${REPO}/actions/runs/${run_id}/logs" > "${zip_file}"
  unzip -o -q "${zip_file}" -d "${run_dir}/unzipped" || true
}

# IDs einsammeln
RUN_IDS=$(python3 - "$FAILED_FILE" <<'PY'
import json,sys
with open(sys.argv[1],"r") as f:
    data=json.load(f)
ids=[str(x.get("id")) for x in data]
print(" ".join(ids))
PY
)

if [[ -z "${RUN_IDS}" ]]; then
  echo "Keine fehlgeschlagenen Runs gefunden (oder alle noch laufend)." >&2
else
  for rid in ${RUN_IDS}; do
    echo "→ Lade Run ${rid}" >&2
    download_logs "${rid}"
  done
fi

# Einfache Fehlerzusammenfassung
AGG_FILE="${WORKDIR}/aggregate.txt"
echo "Erzeuge Fehlerzusammenfassung → ${AGG_FILE}" >&2
{
  echo "Repository: ${REPO}"
  echo "PR: #${PR_NUMBER}"
  echo "Head-Branch: ${HEAD_BRANCH}"
  echo "Head-SHA: ${HEAD_SHA}"
  echo
  echo "Fehlgeschlagene Runs:"
  cat "${FAILED_FILE}" || true
  echo
  echo "— Wichtige Fehlermeldungen (kompakt) —"
  # Sammle typische Fehlerzeilen aus den entpackten Logs
  if [[ -n "${RUN_IDS}" ]]; then
    grep -RInE "(Error:|Failed:|Traceback|Exception|not ok|npm ERR!|✖|⨯)" "${WORKDIR}/runs" \
      | sed -E 's/^.+\/runs\///' \
      | head -n 500 || true
  fi
} > "${AGG_FILE}"

echo "Fertig. Siehe: ${AGG_FILE}" >&2
