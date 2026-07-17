import tomllib
from pathlib import Path

BLOCKS = Path(__file__).resolve().parents[1] / "mcp-blocks"


def test_github_block_is_secret_free_toml():
    text = (BLOCKS / "github.toml").read_text()
    data = tomllib.loads(text)
    s = data["mcp_servers"][0]
    assert s["name"] == "github"
    assert s["api_key_env"] == "GITHUB_PAT"
    assert "ghp_" not in text and "github_pat_" not in text


def test_stdio_templates_have_placeholder():
    fc = (BLOCKS / "firecrawl.toml.tmpl").read_text()
    assert "__FIRECRAWL_API_KEY__" in fc
    # once the placeholder is filled, it must parse as TOML
    parsed = tomllib.loads(fc.replace("__FIRECRAWL_API_KEY__", "fc-test"))
    assert parsed["mcp_servers"][0]["name"] == "firecrawl"


def test_new_static_blocks_are_valid_toml():
    for name in ["sqlite", "memory", "stripe"]:
        data = tomllib.loads((BLOCKS / f"{name}.toml").read_text())
        assert data["mcp_servers"][0]["name"] == name


def test_base_block_files_match_base_config():
    # setup.sh installs these blocks globally; they must never drift
    # from the committed .vibe/config.toml
    cfg = tomllib.loads((BLOCKS.parents[1] / ".vibe" / "config.toml").read_text())
    by_name = {s["name"]: s for s in cfg["mcp_servers"]}
    for name in ["context7", "playwright", "fetch", "sequential-thinking"]:
        block = tomllib.loads((BLOCKS / f"{name}.toml").read_text())["mcp_servers"][0]
        assert block == by_name[name], f"drift between block file and base config: {name}"


def test_stripe_block_is_secret_free():
    text = (BLOCKS / "stripe.toml").read_text()
    data = tomllib.loads(text)
    assert data["mcp_servers"][0]["api_key_env"] == "STRIPE_SECRET_KEY"
    assert "rk_" not in text and "sk_" not in text
