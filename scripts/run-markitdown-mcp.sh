#!/usr/bin/env bash
set -euo pipefail

# markitdown MCP wrapper
# - bevorzugt uvx (UV Python runner)
# - Fallback: lokale venv in .ai-sandbox/markitdown-venv und pip install
# - Self-Test: --self-test prüft nur Umgebung und beendet

MARKITDOWN_MCP_VERSION="${MARKITDOWN_MCP_VERSION:-0.0.1a4}"
SANDBOX_DIR="$(cd "$(dirname "$0")/.." && pwd)/.ai-sandbox"
VENV_DIR="$SANDBOX_DIR/markitdown-venv"

mkdir -p "$SANDBOX_DIR"

if [[ "${1:-}" == "--self-test" ]]; then
  echo "Self-Test: markitdown MCP wrapper"
  if command -v uvx >/dev/null 2>&1; then
    echo "uvx: OK"
  else
    echo "uvx: not found (will use python+venv fallback)"
  fi
  if command -v python3 >/dev/null 2>&1; then
    echo "python3: OK"
  else
    echo "python3: MISSING"; exit 1
  fi
  echo "Sandbox: $SANDBOX_DIR"
  exit 0
fi

if command -v uvx >/dev/null 2>&1; then
  exec uvx "markitdown-mcp==${MARKITDOWN_MCP_VERSION}"
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 nicht gefunden. Installiere Python 3, oder nutze uvx." >&2
  exit 1
fi

# Venv vorbereiten
if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
python -m pip install --upgrade pip >/dev/null 2>&1 || true
python -m pip install "markitdown-mcp==${MARKITDOWN_MCP_VERSION}"

exec markitdown-mcp
#!/usr/bin/env bash
# Wrapper to start the markitdown MCP server reliably across environments.
# Prefers `uvx` if available; otherwise uses python3 and installs the package in user site if missing.
set -euo pipefail

VER="0.0.1a4"

if [[ "${1:-}" == "--check" ]]; then
  if command -v uvx >/dev/null 2>&1; then
    exit 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 - <<'PY'
import importlib, sys
try:
    importlib.import_module('markitdown_mcp')
    sys.exit(0)
except Exception:
    sys.exit(1)
PY
    exit $?
  fi
  exit 1
fi

if command -v uvx >/dev/null 2>&1; then
  exec uvx "markitdown-mcp==${VER}"
fi

if command -v python3 >/dev/null 2>&1; then
  # Check if module available; if not, try to install locally
  if ! python3 - <<'PY'
import importlib, sys
try:
    import importlib.metadata as md  # noqa: F401
    importlib.import_module('markitdown_mcp')
    sys.exit(0)
except Exception:
    sys.exit(1)
PY
  then
    echo "[markitdown-mcp] Installing markitdown-mcp==${VER} to user site..." >&2
    python3 -m pip install --user "markitdown-mcp==${VER}" >/dev/null 2>&1 || true
  fi
  exec python3 -m markitdown_mcp
fi

echo "[markitdown-mcp] Neither 'uvx' nor 'python3' available to run markitdown-mcp." >&2
exit 127
