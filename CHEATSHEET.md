# Vibe Cheat Sheet

One page with everything you reach for during a hackathon.

## Which skill, when

| Phase | Skill | What it is for |
|-------|-------|----------------|
| Sharpen the idea | business-panel | Business model, pitch, competition |
| Requirements | brainstorming | Hard gate questioning, decide what to build |
| Architecture | design | Structure and interfaces for larger ideas |
| Plan | writing-plans | A step by step plan |
| Build | implement | Turn a task into code |
| Test | test | End to end checks |
| Fix | systematic-debugging | When something breaks |
| Prove it works | verification-before-completion | Evidence before you say done |
| Ship | git | Commit and push |
| Get facts | research | Real sources instead of guesses |
| Isolate work | using-git-worktrees | A clean branch in its own folder |

Invoke a skill by naming it, for example "use brainstorming to gather requirements".

## Agent modes (Shift+Tab to cycle)

| Mode | Behavior |
|------|----------|
| plan | Read only, proposes steps, changes nothing. Start here. |
| default | Asks before each action. |
| accept-edits | Applies file edits automatically. |
| auto-approve | Runs everything. Use only when you trust the task. |

## Slash commands

| Command | Does |
|---------|------|
| /mcp | List your MCP servers and their tools |
| /reload | Reload skills after a change |
| /model | Switch the active model |
| /config | Open the config |
| /setup | Re run the onboarding wizard |

## MCP servers

Base, no extra account: context7 (live docs), playwright (real browser), fetch (one
URL), sequential-thinking (step by step reasoning).

Optional via setup.sh, own free account: github, firecrawl, tavily, sqlite, memory,
stripe.

## Secrets

Keys live in `~/.vibe/.env`, never in a repository. Run `./setup.sh` again to add a
server or key later.
