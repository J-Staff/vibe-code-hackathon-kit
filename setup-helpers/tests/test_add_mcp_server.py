import tomllib
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from add_mcp_server import add_server  # noqa: E402

GH = (
    '[[mcp_servers]]\nname = "github"\ntransport = "streamable-http"\n'
    'url = "https://api.githubcopilot.com/mcp/"\napi_key_env = "GITHUB_PAT"'
)


def test_adds_to_empty_file(tmp_path):
    cfg = tmp_path / "config.toml"
    assert add_server(cfg, "github", GH) is True
    data = tomllib.loads(cfg.read_text())
    assert data["mcp_servers"][0]["name"] == "github"


def test_is_idempotent(tmp_path):
    cfg = tmp_path / "config.toml"
    add_server(cfg, "github", GH)
    assert add_server(cfg, "github", GH) is False
    data = tomllib.loads(cfg.read_text())
    assert sum(s["name"] == "github" for s in data["mcp_servers"]) == 1


def test_preserves_existing_content(tmp_path):
    cfg = tmp_path / "config.toml"
    cfg.write_text(
        'active_model = "devstral-small"\n\n'
        '[[mcp_servers]]\nname = "context7"\ntransport = "stdio"\n'
        'command = "npx"\nargs = ["-y","@upstash/context7-mcp@latest"]\n'
    )
    fc = (
        '[[mcp_servers]]\nname = "firecrawl"\ntransport = "stdio"\n'
        'command = "npx"\nargs = ["-y","firecrawl-mcp"]\n'
        'env = { FIRECRAWL_API_KEY = "fc-x" }'
    )
    add_server(cfg, "firecrawl", fc)
    data = tomllib.loads(cfg.read_text())
    assert [s["name"] for s in data["mcp_servers"]] == ["context7", "firecrawl"]
    assert data["active_model"] == "devstral-small"
