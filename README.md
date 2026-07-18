# Vibe Code Hackathon Kit

Get a productive Vibe Code setup in minutes, then spend the hackathon
building instead of configuring. This kit ships a curated set of skills and MCP
servers, an interactive installer, and a hands on guide written for people who
are new to vibe coding.

## Quickstart

Pick your platform, run four lines, done.

**macOS / Linux**

```bash
git clone https://github.com/J-Staff/vibe-code-hackathon-kit
cd vibe-code-hackathon-kit
./setup.sh
vibe
```

**Windows (PowerShell)**

```powershell
git clone https://github.com/J-Staff/vibe-code-hackathon-kit
cd vibe-code-hackathon-kit
powershell -ExecutionPolicy Bypass -File .\setup.ps1
vibe
```

Both installers do the same thing. Prefer a Linux feel on Windows? WSL works
with the macOS/Linux path unchanged.

The only thing you must have is a free Mistral API key. Everything else is
optional and the installer walks you through it.

The installer also offers to install the skills and base MCP servers globally
into `~/.vibe`. Say yes (the default), and `vibe` is fully equipped in ANY
folder, including a brand new empty project. You are not tied to this repo.

## What you get

- A one command setup that installs Vibe, stores your key, and lets you pick optional tools
- Base MCP servers that work with no extra account
- 16 curated skills that turn a smaller model into a disciplined teammate
- A guide that explains not just how, but why, and where you need an account

Why this matters. Devstral, the model behind Vibe, is capable but smaller than
the largest frontier models. A smaller model improvises less, so it benefits
more from good tools (real documentation instead of guesses), skills (a proven
way of working), and planning before coding. This kit gives it exactly that.

## 1. Get started

**What Vibe Code is.** Vibe Code is Mistral's terminal coding agent, similar in
spirit to other CLI agents. You talk to it in your terminal, it reads and writes
files, runs commands, and uses tools. The package is called `mistral-vibe` and
the command you type is `vibe`.

**What you need.** A laptop with macOS, Linux, or Windows, a terminal, and git.
On Windows that means PowerShell (preinstalled) or Windows Terminal, plus
Node.js for some of the tool servers (the installer checks and tells you if it
is missing). That is all. You do NOT need VS Code or any IDE: Vibe runs
entirely in your terminal and edits the files for you. An editor is only useful if you want to
read the code yourself. If you prefer working inside an editor anyway, Mistral
ships native Vibe extensions for VS Code, JetBrains, and Zed. They share the
same configuration and sessions as the CLI, so everything in this kit works
there too.

**Install and key.** `setup.sh` installs Vibe for you. You need a Mistral API
key from https://console.mistral.ai. Create a free account, generate a key, and
paste it when the installer asks. Devstral 2 is free during the launch phase, so
you can start at no cost. If you have used Vibe on this machine before, it may
already keep your key in the system keychain. In that case just press Enter when
the installer asks, Vibe finds the key on its own.

**Running setup.sh again is safe.** Vibe gets upgraded, the kit's skills are
refreshed to their current versions, and existing MCP server entries and stored
keys are never overwritten.

**First run.** Run `vibe` inside this folder. The first time, Vibe asks you to
trust the folder so it can load the `.vibe/` config. Confirm it. Trust is a
safety feature. It means project config only loads where you allow it.

**The four agent modes.** Press Shift+Tab to cycle:

- `plan`: read only, the agent proposes steps and changes nothing. Start here.
- `default`: asks before each action.
- `accept-edits`: applies file edits automatically.
- `auto-approve`: runs everything without asking. Use only when you trust the task.

**Useful slash commands.** `/mcp` lists your tools, `/reload` reloads skills,
`/model` switches the model, `/config` opens the config.

## 2. MCP servers, the senses and hands of your agent

**What MCP is.** The Model Context Protocol lets the agent use external tools,
such as reading live documentation, driving a browser, or searching the web.
Without MCP the model only knows what it memorized during training. With MCP it
can check reality.

**Why it matters more here.** A smaller model is more likely to invent an API
that does not exist. An MCP server that fetches the real documentation removes
that whole class of mistakes. This is the single biggest quality lever in the kit.

**Base servers, already configured, no extra account:**

| Server | What it does |
|--------|--------------|
| context7 | Pulls current, real library documentation into the chat so the model stops guessing API calls |
| playwright | Drives a real browser for end to end tests, screenshots, and web interaction |
| fetch | Loads a single URL as clean markdown |
| sequential-thinking | Helps the model break a hard task into clear steps instead of guessing |

**Optional servers, offered by the installer, each needs a free account:**

| Server | What it does | Account |
|--------|--------------|---------|
| github | Issues, pull requests, repositories, code search | Token at github.com/settings/tokens |
| firecrawl | Crawls whole websites into clean markdown, good for research | Key at firecrawl.dev |
| tavily | AI optimized web search | Key at tavily.com |
| sqlite | A local SQLite database for app data | None, local file |
| memory | Cross session knowledge graph in a local file | None |
| stripe | Payments tools for SaaS and founder demos | Restricted key at dashboard.stripe.com |

When you enable an optional server, `setup.sh` writes it to your private
`~/.vibe/config.toml` and the key to `~/.vibe/.env`. Nothing personal ever lands
in this repository.

## 3. Skills and agents

**What a skill is.** A skill is a `SKILL.md` file with a short instruction set
that the agent loads when it fits the task. Skills are how you give a smaller
model a reliable way of working.

**The shipped skills, by phase:**

- Shape the idea: `business-panel`, `design`, `using-superpowers`
- Idea to plan: `brainstorming`, `writing-plans`, `executing-plans`
- Build: `test-driven-development`, `systematic-debugging`, `implement`, `test`
- Quality: `verification-before-completion`, `requesting-code-review`, `receiving-code-review`
- Clean work and facts: `using-git-worktrees`, `git`, `research`

**Custom agents.** An agent bundles a model, a tool set, and a behavior. Try the
example with `vibe --agent demo-reviewer`, which runs a read only reviewer.
Define your own in `.vibe/agents`.

**Project memory.** `AGENTS.md` holds project wide instructions, the equivalent
of a house style. The agent reads it automatically. Keep it short so it costs
little context.

## 4. Best practices for smaller models

- **Start in plan mode.** Let the agent show its steps before it touches files.
- **Prompt small and specific.** One clear task beats one big vague request.
- **Requirements before code.** Use `brainstorming` to pin down what you actually want.
- **Test driven.** Write the test first when you can, then the code.
- **Verify before done.** Run it. Use `verification-before-completion` so the agent does not declare a success it cannot prove.
- **Mind the context.** Long sessions drift. Start fresh for a new task.
- **Pick the model.** `devstral-small` is fast and cheap for most edits. Switch to the stronger model with `/model` for hard reasoning.
- **Secret hygiene.** Keys live in `~/.vibe/.env`, never in a repository. This kit's `.gitignore` enforces that.

## 5. From idea to prototype, a two day walkthrough

A path a non technical founder can follow:

1. **Morning, day one.** Open `vibe` in plan mode. Describe your idea. Let `brainstorming` interview you until the requirements are clear.
2. **Midday.** Ask for a plan with `writing-plans`. Read it. This is where you catch wrong directions cheaply.
3. **Afternoon.** Work through the plan with `executing-plans`. For each feature, write a test first, then the code.
4. **Day two.** Use `systematic-debugging` when something breaks, `research` when you need a real fact, and the browser through playwright to watch your app run.
5. **Before the demo.** Run `verification-before-completion` and a quick self review. Ship what actually works.

## Working as a team on one repo

The shared base config is committed and identical for everyone. Your personal
key based servers and your secrets live only in your `~/.vibe/`, which Vibe
merges with the repo config at startup. So a whole team can clone the same repo,
each with their own keys, without overwriting each other.

**Where do I start vibe?** Anywhere. The global install puts skills and base
servers into `~/.vibe`, so any folder works with no trust prompt. Inside this
repo (or any repo shipping a `.vibe/` directory), Vibe additionally asks you
once to trust the folder before loading the project config. That prompt is a
safety feature, not a bug: it means a cloned repo cannot silently run its own
tool configuration on your machine.

## License

This kit is MIT licensed (see `LICENSE`). It bundles skills from Superpowers and
the SuperClaude Framework, both MIT, with full attribution in
`THIRD_PARTY_LICENSES.md`.
