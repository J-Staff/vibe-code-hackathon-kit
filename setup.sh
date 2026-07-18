#!/usr/bin/env bash
set -euo pipefail

# Vibe Code Hackathon Kit. Interactive setup.
# (Product: Vibe Code. Package: mistral-vibe. Command: vibe.)
# Installs Vibe, stores your Mistral key, and lets you pick optional MCP servers.
# Secrets are written only to ~/.vibe/, never into this repository.

VIBE_HOME="${VIBE_HOME:-$HOME/.vibe}"
ENV_FILE="$VIBE_HOME/.env"
USER_CONFIG="$VIBE_HOME/config.toml"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HELPER="$REPO_ROOT/setup-helpers/add_mcp_server.py"
BLOCKS="$REPO_ROOT/setup-helpers/mcp-blocks"
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --help) echo "Usage: ./setup.sh [--dry-run]"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

say()  { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
ok()   { printf '\033[1;32m[ok]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[!]\033[0m %s\n' "$1"; }

py() {  # portable python: macOS/Linux have python3, Git Bash on Windows often only python/py
  if command -v python3 >/dev/null 2>&1; then python3 "$@"
  elif command -v python >/dev/null 2>&1; then python "$@"
  elif command -v py >/dev/null 2>&1; then py -3 "$@"
  else uv run python "$@"; fi
}

save_secret() {  # $1 = key name, $2 = value
  [ -z "$2" ] && return 0
  if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] would save $1" >&2; return 0; fi
  mkdir -p "$VIBE_HOME"; touch "$ENV_FILE"; chmod 600 "$ENV_FILE"
  if grep -q "^$1=" "$ENV_FILE"; then ok "$1 already set"; return 0; fi
  printf '%s=%s\n' "$1" "$2" >> "$ENV_FILE"; ok "saved $1 to $ENV_FILE"
}

ask_secret() {  # $1 = prompt, $2 = key name -> echoes value on stdout
  local value=""
  if [ "$DRY_RUN" -eq 1 ]; then echo "DRYKEY"; return 0; fi
  printf '%s' "$1" >&2; read -rs value; echo >&2; echo "$value"
}

confirm() {  # $1 = question
  if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] would ask: $1" >&2; return 1; fi
  local a=""; printf '%s [y/N] ' "$1"; read -r a; [[ "$a" =~ ^[Yy]$ ]]
}

confirm_default_yes() {  # $1 = question, empty answer counts as yes
  if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] would ask: $1" >&2; return 1; fi
  local a=""; printf '%s [Y/n] ' "$1"; read -r a; [[ ! "$a" =~ ^[Nn]$ ]]
}

add_static_block() {  # $1 = name, $2 = block file
  if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] would add MCP: $1" >&2; return 0; fi
  py "$HELPER" "$USER_CONFIG" "$1" "$2"
}

add_stdio_block() {  # $1 = name, $2 = template, $3 = placeholder, $4 = value
  if [ "$DRY_RUN" -eq 1 ]; then echo "[dry-run] would add MCP: $1" >&2; return 0; fi
  local rendered
  rendered="$(mktemp)"
  VIBE_TMPL="$2" VIBE_PH="$3" VIBE_VAL="$4" VIBE_OUT="$rendered" py -c '
import os, pathlib
t = pathlib.Path(os.environ["VIBE_TMPL"]).read_text()
pathlib.Path(os.environ["VIBE_OUT"]).write_text(t.replace(os.environ["VIBE_PH"], os.environ["VIBE_VAL"]))
'
  py "$HELPER" "$USER_CONFIG" "$1" "$rendered"
  rm -f "$rendered"
}

# 1. uv
say "Checking for uv (Python tool manager)"
if ! command -v uv >/dev/null 2>&1; then
  if [ "$DRY_RUN" -eq 1 ]; then warn "[dry-run] would install uv"
  else curl -LsSf https://astral.sh/uv/install.sh | sh; export PATH="$HOME/.local/bin:$PATH"; fi
fi
ok "uv step done"

# 2. Vibe
say "Installing / updating Vibe Code (package: mistral-vibe)"
if [ "$DRY_RUN" -eq 1 ]; then warn "[dry-run] would install/upgrade mistral-vibe"
elif command -v vibe >/dev/null 2>&1; then uv tool upgrade mistral-vibe || true
else uv tool install mistral-vibe; fi
ok "Vibe step done"

# 2b. Node (several MCP servers run via npx)
say "Checking for Node (context7, playwright, sequential-thinking and memory run via npx)"
if command -v npx >/dev/null 2>&1; then
  ok "npx found"
else
  warn "Node/npx not found. Those MCP servers will not start without it."
  warn "Install Node LTS from https://nodejs.org (macOS: brew install node), then re-run ./setup.sh"
fi

# 3. Mistral API key
say "Mistral API key (free at https://console.mistral.ai)"
save_secret "MISTRAL_API_KEY" "$(ask_secret 'Paste MISTRAL_API_KEY (hidden): ' MISTRAL_API_KEY)"

# 4. global install: skills + base MCP servers work in EVERY folder
say "Global install (recommended)"
if confirm_default_yes "Install the kit's skills and base MCP servers into $VIBE_HOME, so vibe has them in every folder?"; then
  mkdir -p "$VIBE_HOME/skills"
  count=0
  replaced=0
  for d in "$REPO_ROOT/.vibe/skills"/*/; do
    name="$(basename "$d")"
    [ -d "$VIBE_HOME/skills/$name" ] && replaced=$((replaced + 1))
    rm -rf "${VIBE_HOME:?}/skills/$name"
    cp -R "$d" "$VIBE_HOME/skills/$name"
    count=$((count + 1))
  done
  ok "installed $count skills to $VIBE_HOME/skills"
  if [ "$replaced" -gt 0 ]; then
    warn "$replaced skills of the same name already existed and were replaced by the kit versions"
  fi
  for b in context7 playwright fetch sequential-thinking; do
    python3 "$HELPER" "$USER_CONFIG" "$b" "$BLOCKS/$b.toml"
  done
  ok "base MCP servers ensured in $USER_CONFIG"
else
  warn "Skipped. The kit then only works inside this folder (after the trust prompt)."
fi

# 5. optional MCP servers
say "Optional MCP servers (each needs its own free account)"
if confirm "Enable GitHub MCP (issues, PRs, code search)?"; then
  save_secret "GITHUB_PAT" "$(ask_secret 'GitHub PAT (https://github.com/settings/tokens): ' GITHUB_PAT)"
  add_static_block github "$BLOCKS/github.toml"
  ok "GitHub MCP enabled"
fi
if confirm "Enable Firecrawl MCP (crawl whole sites to markdown)?"; then
  fckey="$(ask_secret 'Firecrawl key (https://firecrawl.dev): ' FIRECRAWL_API_KEY)"
  if [ -n "$fckey" ]; then
    save_secret "FIRECRAWL_API_KEY" "$fckey"
    add_stdio_block firecrawl "$BLOCKS/firecrawl.toml.tmpl" "__FIRECRAWL_API_KEY__" "$fckey"
    ok "Firecrawl MCP enabled"
  else warn "no key entered, skipping Firecrawl"; fi
fi
if confirm "Enable Tavily MCP (AI web search)?"; then
  tvkey="$(ask_secret 'Tavily key (https://tavily.com): ' TAVILY_API_KEY)"
  if [ -n "$tvkey" ]; then
    save_secret "TAVILY_API_KEY" "$tvkey"
    add_stdio_block tavily "$BLOCKS/tavily.toml.tmpl" "__TAVILY_API_KEY__" "$tvkey"
    ok "Tavily MCP enabled"
  else warn "no key entered, skipping Tavily"; fi
fi
if confirm "Enable sqlite MCP (local database, no account)?"; then
  add_static_block sqlite "$BLOCKS/sqlite.toml"
  ok "sqlite MCP enabled"
fi
if confirm "Enable memory MCP (cross session memory, no account)?"; then
  add_static_block memory "$BLOCKS/memory.toml"
  ok "memory MCP enabled"
fi
if confirm "Enable Stripe MCP (payments)?"; then
  save_secret "STRIPE_SECRET_KEY" "$(ask_secret 'Stripe restricted key rk_... (https://dashboard.stripe.com/apikeys): ' STRIPE_SECRET_KEY)"
  add_static_block stripe "$BLOCKS/stripe.toml"
  ok "Stripe MCP enabled"
fi

# 6. next steps
say "Almost done"
warn "Inside THIS folder, vibe asks you to trust it once so the repo's .vibe/ config loads."
ok "Setup complete. Start 'vibe' in any project folder, then type /mcp to see your servers."
