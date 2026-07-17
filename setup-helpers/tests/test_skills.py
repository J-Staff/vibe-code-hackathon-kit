from pathlib import Path

SKILLS = Path(__file__).resolve().parents[2] / ".vibe" / "skills"
EXPECTED = {
    "using-superpowers", "brainstorming", "writing-plans", "executing-plans",
    "test-driven-development", "systematic-debugging", "verification-before-completion",
    "requesting-code-review", "receiving-code-review", "using-git-worktrees",
    "implement", "test", "git", "research",
    "business-panel", "design",
}


def test_all_skills_present_with_frontmatter():
    for name in EXPECTED:
        md = SKILLS / name / "SKILL.md"
        assert md.exists(), f"missing {name}"
        head = md.read_text()[:400]
        assert head.startswith("---"), f"{name}: no frontmatter"
        assert "name:" in head and "description:" in head, f"{name}: incomplete frontmatter"
