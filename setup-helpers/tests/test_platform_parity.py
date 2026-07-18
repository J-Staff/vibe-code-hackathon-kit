import shutil
import subprocess

import pytest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SH = (ROOT / "setup.sh").read_text()
PS1 = (ROOT / "setup.ps1").read_text()

ALL_SERVERS = [
    "context7", "playwright", "fetch", "sequential-thinking",
    "github", "firecrawl", "tavily", "sqlite", "memory", "stripe",
]
PLACEHOLDERS = ["__FIRECRAWL_API_KEY__", "__TAVILY_API_KEY__"]


def test_both_installers_cover_every_server():
    for name in ALL_SERVERS:
        assert name in SH, f"setup.sh misses {name}"
        assert name in PS1, f"setup.ps1 misses {name}"


def test_both_installers_use_the_same_templates():
    for ph in PLACEHOLDERS:
        assert ph in SH, f"setup.sh misses {ph}"
        assert ph in PS1, f"setup.ps1 misses {ph}"


def test_both_installers_share_the_python_helper():
    assert "add_mcp_server.py" in SH
    assert "add_mcp_server.py" in PS1


@pytest.mark.skipif(shutil.which("pwsh") is None, reason="pwsh not installed")
def test_ps1_dry_run_executes():
    result = subprocess.run(
        ["pwsh", "-NoProfile", "-File", str(ROOT / "setup.ps1"), "-DryRun"],
        capture_output=True, text=True, timeout=120,
    )
    assert result.returncode == 0, result.stderr
    assert "Vibe step done" in result.stdout
