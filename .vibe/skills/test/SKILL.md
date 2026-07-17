---
name: test
description: "Execute tests with coverage analysis and automated quality reporting. For e2e: launches parallel research agents, tests every user journey via Playwright or Charlotte MCP with database validation, inline bug fixing, and responsive testing."
category: utility
complexity: enhanced
mcp-servers: [playwright, charlotte]
personas: [qa-specialist]
---

# /sc:test - Testing and Quality Assurance

## Triggers
- Test execution requests for unit, integration, or e2e tests
- Coverage analysis and quality gate validation needs
- Continuous testing and watch mode scenarios
- Test failure analysis and debugging requirements
- Full application validation before code review or PR

## Usage
```
/sc:test [target] [--type unit|integration|e2e|all] [--coverage] [--watch] [--fix] [--report]
```

**Flags:**
- `--type unit|integration|e2e|all` — Filter which test types to run (default: all)
- `--coverage` — Generate detailed coverage reports
- `--watch` — Continuous watch mode for development
- `--fix` — Auto-fix simple failures inline
- `--report` — Export full markdown report after e2e run

---

## Unit & Integration Testing

### Behavioral Flow
1. **Discover**: Categorize available tests using runner patterns and conventions
2. **Configure**: Set up appropriate test environment and execution parameters
3. **Execute**: Run tests with monitoring and real-time progress tracking
4. **Analyze**: Generate coverage reports and failure diagnostics
5. **Report**: Provide actionable recommendations and quality metrics

**Key behaviors:**
- Auto-detect test framework and configuration (pytest, vitest, jest, etc.)
- Generate comprehensive coverage reports with metrics
- Provide intelligent test failure analysis
- Support continuous watch mode for development

### Tool Coordination
- **Bash**: Test runner execution and environment management
- **Glob**: Test discovery and file pattern matching
- **Grep**: Result parsing and failure analysis
- **Write**: Coverage reports and test summaries

### Examples

```
/sc:test
# Discovers and runs all tests with standard configuration

/sc:test src/components --type unit --coverage
# Unit tests for specific directory with detailed coverage metrics

/sc:test --watch --fix
# Continuous testing with automatic simple failure fixes
```

---

## E2E Browser Testing (`--type e2e`)

Full application validation via **Charlotte MCP** (preferred, token-efficient) or **Playwright MCP** (fallback). Runs a parallel research phase first, then exercises every user journey with database validation and inline bug fixing.

### Browser Tool Selection

Two browser MCP servers are available. Choose based on the task:

| Criteria | Charlotte (preferred) | Playwright (fallback) |
|---|---|---|
| **Token efficiency** | 2-10x less tokens per page | Full DOM every snapshot |
| **Page observation** | 3 detail levels (minimal/summary/full) | Full accessibility tree always |
| **Console logs** | On-demand (enable monitoring group) | Automatic with every snapshot |
| **Network requests** | On-demand (enable monitoring group) | Separate tool call |
| **Interaction** | click, type, select, drag, hover, key | click, type, fill_form, select, press_key |
| **Screenshots** | Built-in with storage & diff | Save to file |
| **Responsive testing** | Via session > viewport | Via browser_resize |
| **Audits** | Built-in (a11y, perf, SEO) via dev_mode | Not built-in |
| **Use when** | Standard E2E testing, token budget matters | Complex multi-step JS evaluation needed |

**Default: Use Charlotte.** Fall back to Playwright only if Charlotte is unavailable or a specific Playwright feature is needed (e.g., `browser_run_code` for complex JS).

### Pre-flight Check

Before starting, verify:

1. **Frontend accessible?** Check for `package.json` with dev/start script, frontend framework files (`pages/`, `app/`, `src/components/`, `index.html`). If no frontend detected, stop:
   > "No browser-accessible frontend found. E2E testing requires a UI. Use `--type unit` or `--type integration` for backend-only testing."

2. **App running?** Attempt to navigate to the expected dev URL. If it fails, start the dev server in background:
   ```bash
   npm run dev &   # or the project-specific start command
   ```
   Wait for server ready, then verify navigation succeeds and take initial screenshot.

3. **Charlotte tool groups?** Enable required groups before testing:
   ```
   charlotte_tools(action: "enable", group: "interaction")   # click, type, drag etc.
   charlotte_tools(action: "enable", group: "monitoring")    # console logs, network
   charlotte_tools(action: "enable", group: "session")       # viewport, tabs, cookies
   ```

---

### Phase 1: Parallel Research (3 Sub-Agents)

Launch **three sub-agents simultaneously** via the Agent tool. Wait for all three before proceeding.

**Sub-Agent 1 — Application Structure & User Journeys**
> Research this codebase thoroughly. Return:
> 1. How to start the application (exact commands, URL, port)
> 2. Authentication/login — how to create a test account or log in (from .env.example, seed data, or sign-up flow)
> 3. Every user-facing route/page with URL paths
> 4. Every user journey — complete flows (e.g., "sign up → create profile → view public page") with specific steps, interactions (clicks, form fills, navigation), and expected outcomes
> 5. Key UI components requiring testing — forms, modals, dropdowns, toggles, pickers
> Be exhaustive. Testing only covers what is identified here.

**Sub-Agent 2 — Database Schema & Data Flows**
> Research this codebase's database layer. Read `.env.example` (NOT `.env`). Return:
> 1. Database type and connection (Postgres, MySQL, SQLite, etc.) and the env var name for the connection string
> 2. Full schema — every table, columns, types, relationships
> 3. Data flows per user action — what records are created/updated/deleted and in which tables
> 4. Validation queries — exact queries to verify records after each action

**Sub-Agent 3 — Bug Hunting**
> Analyze this codebase for bugs and quality issues:
> 1. Logic errors — incorrect conditionals, off-by-one, missing null checks, race conditions
> 2. UI/UX issues — missing error handling in forms, no loading states, broken responsive layouts, accessibility problems
> 3. Data integrity risks — missing validation, orphaned records, incorrect cascade behavior
> 4. Security concerns — SQL injection, XSS, missing auth checks, exposed secrets
> Return a prioritized list with file paths and line numbers.

---

### Phase 2: Task List Creation

From Sub-Agent 1's journeys + Sub-Agent 3's findings, create a TodoWrite task per user journey. Each task includes:
- Steps to execute
- Expected outcomes
- Database records to verify
- Related bug findings from Sub-Agent 3

Add a final task: **"Responsive testing across viewports"**.

---

### Phase 3: User Journey Testing

For each task, mark it `in_progress` and execute:

#### 3a. Browser Testing via Charlotte MCP (preferred)

Charlotte uses an on-demand approach — enable tool groups as needed, observe at minimal detail, then drill down. This saves 2-10x tokens vs Playwright.

**Charlotte MCP tools by group:**

```
# Navigation (always active)
charlotte_navigate          # Open URL (detail: minimal|summary|full)
charlotte_back              # Browser back
charlotte_forward           # Browser forward
charlotte_reload            # Reload page

# Observation (always active)
charlotte_observe           # Get page state (3 detail levels)
charlotte_find              # Search elements by type, text, CSS selector
charlotte_screenshot        # Take screenshot (stored with ID)
charlotte_diff              # Compare two page states (before/after)

# Interaction (enable first: charlotte_tools > interaction)
charlotte_click             # Click element by ID
charlotte_type              # Type text into element
charlotte_select            # Dropdown selection
charlotte_toggle            # Checkbox/toggle
charlotte_submit            # Submit form
charlotte_scroll            # Scroll page
charlotte_hover             # Hover element
charlotte_drag              # Drag & Drop
charlotte_key               # Keyboard press
charlotte_wait_for          # Wait for condition

# Monitoring (enable first: charlotte_tools > monitoring)
charlotte_console           # Get console logs (errors, warnings, info)
charlotte_requests          # Inspect network requests

# Session (enable first: charlotte_tools > session)
charlotte_viewport          # Change viewport size (responsive testing)
charlotte_tabs              # List open tabs
charlotte_tab_open          # Open new tab
charlotte_tab_switch        # Switch between tabs

# Dev Mode (enable first: charlotte_tools > dev_mode)
charlotte_dev_audit         # Run accessibility, performance, SEO audit
charlotte_dev_inject        # Inject CSS/JS into page

# Evaluate (enable first: charlotte_tools > evaluate)
charlotte_evaluate          # Execute JavaScript in page context
```

**Charlotte workflow per interaction step:**
1. `charlotte_observe(detail: "minimal")` → get page landmarks and element counts
2. `charlotte_find(type: "button", text: "Submit")` → get specific element IDs
3. Perform the interaction (click, type, select…)
4. `charlotte_wait_for` → wait for page to settle
5. `charlotte_screenshot` → captured and stored with ID
6. `charlotte_diff` → compare page state before/after interaction
7. Check `charlotte_console` periodically for JS errors and warnings

**Token efficiency tips:**
- Start with `detail: "minimal"` — only request `summary` or `full` when needed
- Use `charlotte_find` to target specific elements instead of observing the full page
- Use `charlotte_diff` to see what changed rather than re-observing the entire page
- Enable monitoring group only when debugging console/network issues

#### 3a-alt. Playwright MCP (fallback)

Use Playwright when Charlotte is unavailable or when you need `browser_run_code` for complex JS execution:

```
mcp__playwright__browser_navigate        # Navigate to URL
mcp__playwright__browser_snapshot        # Get accessibility snapshot with element refs
mcp__playwright__browser_click           # Click element by ref
mcp__playwright__browser_type           # Type into focused element
mcp__playwright__browser_fill_form      # Fill multiple form fields
mcp__playwright__browser_select_option  # Select dropdown option
mcp__playwright__browser_press_key      # Press keyboard key (Enter, Tab, Escape…)
mcp__playwright__browser_take_screenshot # Save screenshot
mcp__playwright__browser_wait_for       # Wait for element or network idle
mcp__playwright__browser_console_messages # Check JS console output
mcp__playwright__browser_evaluate       # Execute JS in page context
mcp__playwright__browser_resize         # Set viewport dimensions
mcp__playwright__browser_navigate_back  # Browser back
mcp__playwright__browser_close          # End browser session
```

**Playwright workflow per interaction step:**
1. `browser_snapshot` → get current element refs
2. Perform the interaction (click, fill, select…)
3. `browser_wait_for` → wait for page to settle
4. `browser_take_screenshot` → save to `e2e-screenshots/<journey>/<step>.png`
5. **Analyze the screenshot** via Read tool — check visual correctness, UX issues, broken layouts, error states
6. Periodically check `browser_console_messages` for JS errors

> **Note:** Element refs from `browser_snapshot` become invalid after navigation or DOM changes. Always re-snapshot after page navigation, form submissions, or dynamic content updates.

Go through **every interaction, every form field, every button**. Full coverage is the goal.

#### 3b. Database Validation

After any interaction that should modify data:
- Query the database using the env var and schema from Sub-Agent 2
  - **Postgres:** `psql "$DATABASE_URL" -c "SELECT ... FROM ... WHERE ..."`
  - **SQLite:** `sqlite3 db.sqlite "SELECT ..."`
  - **Other:** Write a minimal ad-hoc script, run it, delete it
- Verify: records created/updated/deleted as expected, values match UI input, no orphaned or duplicate records

#### 3c. Inline Bug Fixing

When an issue is found (UI bug, DB mismatch, JS error):
1. **Document it** — expected vs actual, screenshot path, relevant query result
2. **Fix the code directly** (if `--fix` flag is set or issue is clear)
3. **Re-run the failing step** to confirm the fix
4. **Take a new screenshot** showing the resolved state

#### 3d. Responsive Testing

Revisit all major pages at three viewports:
- **Mobile:** `charlotte_viewport` or `browser_resize` → 375 × 812
- **Tablet:** `charlotte_viewport` or `browser_resize` → 768 × 1024
- **Desktop:** `charlotte_viewport` or `browser_resize` → 1440 × 900

Screenshot each major page. Check for: layout overflow, broken alignment, touch target sizes, hidden content.

If using Charlotte, run `charlotte_dev_audit` (enable dev_mode group first) on each major page for accessibility, performance, and SEO scoring.

After each journey, mark its task `completed`.

---

### Phase 4: Cleanup

1. Stop the dev server background process (if started by this command)
2. Close browser session (`charlotte_navigate` leaves browser open for inspection; use `mcp__playwright__browser_close` if Playwright was used)

---

### Phase 5: Report

**Always output a text summary:**

```
## E2E Testing Complete

**Journeys Tested:** [count]
**Screenshots Captured:** [count]
**Issues Found:** [count] ([count] fixed, [count] remaining)

### Issues Fixed During Testing
- [Description] — [file:line]

### Remaining Issues
- [Description] — [severity: high/medium/low] — [file:line]

### Bug Hunt Findings (from code analysis)
- [Description] — [severity] — [file:line]

### Screenshots
All saved to: e2e-screenshots/
```

**If `--report` flag was passed**, also write `e2e-test-report.md` with:
- Full summary + stats
- Per-journey breakdown: steps, screenshots, DB checks, issues found
- All issues with fix status and file references
- Bug hunt findings from Sub-Agent 3
- Recommendations for unresolved issues

---

## MCP Integration

- **Charlotte MCP** (preferred): Token-efficient browser automation with on-demand tool groups, page diffing, and built-in audits
- **Playwright MCP** (fallback): Full browser automation when Charlotte is unavailable or complex JS execution is needed
- **Best-of-Both strategy**: Use Charlotte for navigation, observation, screenshots, and audits. Switch to Playwright for `browser_run_code` (complex JS) or `browser_fill_form` (multi-field forms)
- **QA Specialist Persona**: Activated for test analysis and quality assessment

## Boundaries

**Will:**
- Execute existing test suites using the project's configured test runner
- Generate coverage reports and quality metrics
- Provide intelligent test failure analysis with actionable recommendations
- For e2e: conduct parallel codebase research, database validation, inline bug fixing, and responsive testing

**Will Not:**
- Generate test cases or modify test framework configuration
- Execute tests requiring external services without proper setup
- Make destructive changes to test files without explicit permission
- Read `.env` files directly (only `.env.example` for schema/connection research)