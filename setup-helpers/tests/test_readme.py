from pathlib import Path

README = Path(__file__).resolve().parents[2] / "README.md"


def test_readme_covers_the_five_themes_and_has_no_em_dash():
    text = README.read_text()
    assert "—" not in text  # no em-dash
    for anchor in [
        "Get started",       # Theme 1
        "MCP",               # Theme 2
        "Skills",            # Theme 3
        "Best practices",    # Theme 4
        "idea to prototype",  # Theme 5 (founder walkthrough)
    ]:
        assert anchor.lower() in text.lower(), f"missing: {anchor}"


def test_readme_has_one_command_quickstart():
    assert "./setup.sh" in README.read_text()
