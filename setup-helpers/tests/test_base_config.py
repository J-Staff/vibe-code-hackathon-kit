import tomllib
import re
from pathlib import Path

CONFIG = Path(__file__).resolve().parents[2] / ".vibe" / "config.toml"


def test_base_config_parses_and_has_key_free_servers():
    data = tomllib.loads(CONFIG.read_text())
    names = [s["name"] for s in data["mcp_servers"]]
    assert names == ["context7", "playwright", "fetch", "sequential-thinking"]
    assert data["default_agent"] == "plan"


def test_base_config_contains_no_secrets():
    text = CONFIG.read_text()
    # no api keys, tokens or env blocks with secrets in the committed file
    assert not re.search(r"(api_key|token|secret|_KEY)\s*=\s*[\"']", text, re.I)
    assert "[mcp_servers.env]" not in text
