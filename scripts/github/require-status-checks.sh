#!/usr/bin/env bash
set -euo pipefail

# Configure required status checks for a protected branch via GitHub REST API.
# Usage:
#   GITHUB_TOKEN=... OWNER=... REPO=... BRANCH=... \
#   ./scripts/github/require-status-checks.sh

GITHUB_API=${GITHUB_API:-https://api.github.com}
OWNER=${OWNER:-}
REPO=${REPO:-}
BRANCH=${BRANCH:-main}
TOKEN=${GITHUB_TOKEN:-${GH_TOKEN:-}}

if [ -z "${OWNER}" ] || [ -z "${REPO}" ] || [ -z "${TOKEN}" ]; then
  echo "ERROR: OWNER, REPO und GITHUB_TOKEN müssen gesetzt sein" >&2
  exit 1
fi

# Required status contexts (adjust as needed)
read -r -d '' CONTEXTS_JSON <<'JSON' || true
{
  "required_status_checks": {
    "strict": true,
    "contexts": [
      "Phase 0 Verification",
      "verify-phase-0",
      "Generate SBOMs",
      "sbom",
      "Docs Lint & ADR Index",
      "docs",
      "API OpenAPI Export",
      "export-openapi"
    ]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": null,
  "restrictions": null
}
JSON

echo "Configuring required status checks on ${OWNER}/${REPO}@${BRANCH}..."
curl -sS -X PUT \
  -H "Authorization: Bearer ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  "${GITHUB_API}/repos/${OWNER}/${REPO}/branches/${BRANCH}/protection" \
  -d "${CONTEXTS_JSON}"

echo "\nDone."
