# Binary Tools Directory

This directory contains downloaded security scanning tools.

## Tools

### Trivy (Aqua Security)
- **Purpose:** Container & dependency vulnerability scanner
- **Size:** ~204 MB
- **Install:** `curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b ./bin`

### Gitleaks
- **Purpose:** Secret scanning in Git repositories
- **Size:** ~20 MB
- **Install:** `curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/scripts/install.sh | sh -s -- -d ./bin`

## Note

These binaries are **NOT tracked in Git** (too large for GitHub).
Download them locally using the install commands above.

## CI/CD

GitHub Actions workflows download these automatically during runtime.
