#Requires -Version 5.1
# Vibe Code Hackathon Kit. Interactive setup for Windows (PowerShell).
# (Product: Vibe Code. Package: mistral-vibe. Command: vibe.)
# Same behavior as setup.sh: installs Vibe, stores your Mistral key, and lets
# you pick optional MCP servers. Secrets are written only to your user profile
# ($env:USERPROFILE\.vibe), never into this repository.
#
# Run with:  powershell -ExecutionPolicy Bypass -File .\setup.ps1
# Dry run:   powershell -ExecutionPolicy Bypass -File .\setup.ps1 -DryRun

param([switch]$DryRun)
$ErrorActionPreference = "Stop"

if ($env:VIBE_HOME) { $VibeHome = $env:VIBE_HOME }
elseif ($env:USERPROFILE) { $VibeHome = Join-Path $env:USERPROFILE ".vibe" }
else { $VibeHome = Join-Path $env:HOME ".vibe" }
$EnvFile    = Join-Path $VibeHome ".env"
$UserConfig = Join-Path $VibeHome "config.toml"
$RepoRoot   = Split-Path -Parent $MyInvocation.MyCommand.Path
$Helper     = Join-Path $RepoRoot "setup-helpers\add_mcp_server.py"
$Blocks     = Join-Path $RepoRoot "setup-helpers\mcp-blocks"

function Say([string]$m)  { Write-Host ""; Write-Host "==> $m" -ForegroundColor Blue }
function Ok([string]$m)   { Write-Host "[ok] $m" -ForegroundColor Green }
function Warn([string]$m) { Write-Host "[!] $m" -ForegroundColor Yellow }

function Confirm-No([string]$q) {
  # default is no, like [y/N]
  if ($DryRun) { Write-Host "[dry-run] would ask: $q"; return $false }
  $a = Read-Host "$q [y/N]"
  return ($a -match '^[Yy]$')
}

function Confirm-Yes([string]$q) {
  # default is yes, like [Y/n]
  if ($DryRun) { Write-Host "[dry-run] would ask: $q"; return $false }
  $a = Read-Host "$q [Y/n]"
  return (-not ($a -match '^[Nn]$'))
}

function Ask-Secret([string]$prompt) {
  if ($DryRun) { return "DRYKEY" }
  $sec = Read-Host -AsSecureString $prompt
  $b = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($sec)
  try { return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($b) }
  finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($b) }
}

function Save-Secret([string]$name, [string]$value) {
  if ([string]::IsNullOrEmpty($value)) { return }
  if ($DryRun) { Write-Host "[dry-run] would save $name"; return }
  New-Item -ItemType Directory -Force -Path $VibeHome | Out-Null
  if (-not (Test-Path $EnvFile)) { New-Item -ItemType File -Path $EnvFile | Out-Null }
  $existing = @(Get-Content $EnvFile -ErrorAction SilentlyContinue)
  foreach ($line in $existing) {
    if ($line -like "$name=*") { Ok "$name already set"; return }
  }
  Add-Content -Path $EnvFile -Value "$name=$value"
  Ok "saved $name to $EnvFile"
}

function Invoke-Py([string[]]$PyArgs) {
  # portable python: plain Windows installs expose python or the py launcher
  if (Get-Command python -ErrorAction SilentlyContinue) { & python @PyArgs }
  elseif (Get-Command py -ErrorAction SilentlyContinue) { & py -3 @PyArgs }
  else { & uv run python @PyArgs }
}

function Add-StaticBlock([string]$name, [string]$file) {
  if ($DryRun) { Write-Host "[dry-run] would add MCP: $name"; return }
  Invoke-Py @($Helper, $UserConfig, $name, $file)
}

function Add-TemplateBlock([string]$name, [string]$tmpl, [string]$placeholder, [string]$value) {
  if ($DryRun) { Write-Host "[dry-run] would add MCP: $name"; return }
  $rendered = New-TemporaryFile
  $text = Get-Content -Raw $tmpl
  Set-Content -Path $rendered.FullName -Value $text.Replace($placeholder, $value) -NoNewline
  Invoke-Py @($Helper, $UserConfig, $name, $rendered.FullName)
  Remove-Item $rendered.FullName -Force
}

# 1. uv
Say "Checking for uv (Python tool manager)"
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
  if ($DryRun) { Warn "[dry-run] would install uv" }
  else {
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = (Join-Path $env:USERPROFILE ".local\bin") + ";" + $env:Path
  }
}
Ok "uv step done"

# 2. Vibe
Say "Installing / updating Vibe Code (package: mistral-vibe)"
if ($DryRun) { Warn "[dry-run] would install/upgrade mistral-vibe" }
elseif (Get-Command vibe -ErrorAction SilentlyContinue) { uv tool upgrade mistral-vibe }
else { uv tool install mistral-vibe }
Ok "Vibe step done"

# 2b. Node (several MCP servers run via npx)
Say "Checking for Node (context7, playwright, sequential-thinking and memory run via npx)"
if (Get-Command npx -ErrorAction SilentlyContinue) { Ok "npx found" }
else {
  Warn "Node/npx not found. Those MCP servers will not start without it."
  Warn "Install Node LTS: winget install OpenJS.NodeJS.LTS (then open a NEW terminal and re-run setup.ps1)"
}

# 3. Mistral API key
Say "Mistral API key (free at https://console.mistral.ai)"
Save-Secret "MISTRAL_API_KEY" (Ask-Secret "Paste MISTRAL_API_KEY (hidden, Enter to skip)")

# 4. global install: skills + base MCP servers work in EVERY folder
Say "Global install (recommended)"
if (Confirm-Yes "Install the kit's skills and base MCP servers into $VibeHome, so vibe has them in every folder?") {
  $skillsDst = Join-Path $VibeHome "skills"
  New-Item -ItemType Directory -Force -Path $skillsDst | Out-Null
  $count = 0
  $replaced = 0
  Get-ChildItem -Directory (Join-Path $RepoRoot ".vibe\skills") | ForEach-Object {
    $dst = Join-Path $skillsDst $_.Name
    if (Test-Path $dst) { $replaced++; Remove-Item -Recurse -Force $dst }
    Copy-Item -Recurse $_.FullName $dst
    $count++
  }
  Ok "installed $count skills to $skillsDst"
  if ($replaced -gt 0) {
    Warn "$replaced skills of the same name already existed and were replaced by the kit versions"
  }
  foreach ($b in @("context7", "playwright", "fetch", "sequential-thinking")) {
    Add-StaticBlock $b (Join-Path $Blocks "$b.toml")
  }
  Ok "base MCP servers ensured in $UserConfig"
}
else {
  Warn "Skipped. The kit then only works inside this folder (after the trust prompt)."
}

# 5. optional MCP servers
Say "Optional MCP servers (each needs its own free account)"
if (Confirm-No "Enable GitHub MCP (issues, PRs, code search)?") {
  Save-Secret "GITHUB_PAT" (Ask-Secret "GitHub PAT (https://github.com/settings/tokens)")
  Add-StaticBlock "github" (Join-Path $Blocks "github.toml")
  Ok "GitHub MCP enabled"
}
if (Confirm-No "Enable Firecrawl MCP (crawl whole sites to markdown)?") {
  $fckey = Ask-Secret "Firecrawl key (https://firecrawl.dev)"
  if (-not [string]::IsNullOrEmpty($fckey)) {
    Save-Secret "FIRECRAWL_API_KEY" $fckey
    Add-TemplateBlock "firecrawl" (Join-Path $Blocks "firecrawl.toml.tmpl") "__FIRECRAWL_API_KEY__" $fckey
    Ok "Firecrawl MCP enabled"
  }
  else { Warn "no key entered, skipping Firecrawl" }
}
if (Confirm-No "Enable Tavily MCP (AI web search)?") {
  $tvkey = Ask-Secret "Tavily key (https://tavily.com)"
  if (-not [string]::IsNullOrEmpty($tvkey)) {
    Save-Secret "TAVILY_API_KEY" $tvkey
    Add-TemplateBlock "tavily" (Join-Path $Blocks "tavily.toml.tmpl") "__TAVILY_API_KEY__" $tvkey
    Ok "Tavily MCP enabled"
  }
  else { Warn "no key entered, skipping Tavily" }
}
if (Confirm-No "Enable sqlite MCP (local database, no account)?") {
  Add-StaticBlock "sqlite" (Join-Path $Blocks "sqlite.toml")
  Ok "sqlite MCP enabled"
}
if (Confirm-No "Enable memory MCP (cross session memory, no account)?") {
  Add-StaticBlock "memory" (Join-Path $Blocks "memory.toml")
  Ok "memory MCP enabled"
}
if (Confirm-No "Enable Stripe MCP (payments)?") {
  Save-Secret "STRIPE_SECRET_KEY" (Ask-Secret "Stripe restricted key rk_... (https://dashboard.stripe.com/apikeys)")
  Add-StaticBlock "stripe" (Join-Path $Blocks "stripe.toml")
  Ok "Stripe MCP enabled"
}

# 6. next steps
Say "Almost done"
Warn "Inside THIS folder, vibe asks you to trust it once so the repo's .vibe/ config loads."
Ok "Setup complete. Start 'vibe' in any project folder, then type /mcp to see your servers."
