import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_demo_agent_is_valid_toml():
    data = tomllib.loads((ROOT / ".vibe/agents/demo-reviewer.toml").read_text())
    assert "system_prompt_id" in data or "active_model" in data


def test_agents_md_has_principle_and_no_em_dash():
    text = (ROOT / "AGENTS.md").read_text()
    assert "plan" in text.lower()
    assert "—" not in text  # em-dash banned
