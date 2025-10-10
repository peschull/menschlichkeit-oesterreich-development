import asyncio
import json
import os
import subprocess
from datetime import datetime, timezone
from typing import Any, Dict

from fastapi import APIRouter, HTTPException

router = APIRouter(prefix="/mcp", tags=["mcp"])


def _workspace_root() -> str:
    here = os.path.dirname(os.path.abspath(__file__))
    # app/routes -> app -> api root
    return os.path.abspath(os.path.join(here, "..", "..", ".."))


def _health_script_path() -> str:
    return os.path.join(_workspace_root(), "scripts", "mcp-health-check.sh")


async def _run_health_check(
    *, mode: str = "quick", timeout_s: int = 10
) -> Dict[str, Any]:
    script = _health_script_path()
    if not os.path.isfile(script):
        raise HTTPException(status_code=500, detail="health script not found")

    # Use subprocess in a thread to avoid blocking the event loop
    def _call() -> subprocess.CompletedProcess[bytes]:
        return subprocess.run(
            ["bash", script, f"--mode={mode}", "--format=json"],
            cwd=_workspace_root(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
            timeout=timeout_s,
        )

    try:
        proc = await asyncio.to_thread(_call)
    except subprocess.TimeoutExpired as exc:
        raise HTTPException(status_code=504, detail="health check timeout") from exc

    stdout = proc.stdout.decode("utf-8", errors="replace").strip()
    # Extract JSON from possible extra output defensively
    start = stdout.find("{")
    end = stdout.rfind("}")
    json_str = (
        stdout[start : end + 1] if start != -1 and end != -1 and end >= start else "{}"
    )
    try:
        data = json.loads(json_str)
    except json.JSONDecodeError as exc:
        raise HTTPException(status_code=502, detail="invalid health json") from exc

    if not isinstance(data, dict) or "status" not in data:
        raise HTTPException(status_code=502, detail="unexpected health payload")

    # Attach metadata
    data["ts"] = datetime.now(timezone.utc).isoformat()
    data["exitCode"] = proc.returncode
    return data  # type: ignore[return-value]


@router.get("/status")
async def mcp_status() -> Dict[str, Any]:
    """Return MCP health summary from the workspace health script.

    Response example:
    {"status":"ok|warn|error","summary":{"oks":7,"warns":0,"errs":0},"ts":"...","exitCode":0}
    """
    return await _run_health_check(mode="quick", timeout_s=12)
