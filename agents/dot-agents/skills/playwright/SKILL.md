---
name: playwright
description: Use when the task requires automating a real browser from the terminal (navigation, form filling, snapshots, screenshots, data extraction, UI-flow debugging) via `playwright-cli` or the bundled wrapper script.
---

# Playwright CLI Skill

Drive a real browser from the terminal using `playwright-cli`. Prefer the bundled wrapper script so the CLI works even when it is not globally installed.

Treat this skill as CLI-first automation. Do not pivot to `@playwright/test` unless the user explicitly asks for test files.

When the task involves writing or modifying Playwright test files, hand off test assertions, fixtures, locators, and test configuration to `playwright-best-practices`. This skill owns interactive browser sessions and terminal automation.

## Skill path (set once)

```bash
export PWCLI="$HOME/.agents/skills/playwright/scripts/playwright_cli.sh"
export AGENTS_PLAYWRIGHT_STATE="${HOME}/.local/state/agents/playwright"
```

## Persistent profile for user logins

Use the Playwright CLI session/profile named `chad` by default for browser work unless the user explicitly asks for another profile. The wrapper script defaults to this session automatically:

```bash
export PLAYWRIGHT_CLI_SESSION=chad
export PLAYWRIGHT_CHAD_PROFILE="${PLAYWRIGHT_CHAD_PROFILE:-$AGENTS_PLAYWRIGHT_STATE/profiles/chad}"
```

For durable browser cookies and local storage, the wrapper script automatically adds `--persistent --profile "$PLAYWRIGHT_CHAD_PROFILE"` to `open` commands when no explicit profile is provided:

```bash
"$PWCLI" open https://example.com --headed
```

The global profile directory contains cookies and browser state. Keep it out of git and do not delete it unless the user explicitly requests a clean profile.

Before launching a browser, always check whether the `chad` session is already open:

```bash
"$PWCLI" list
```

If `chad` is already open, reuse that exact browser/session. Do not run `open` again. Use `snapshot`, `goto`, `tab-new`, `tab-select`, `reload`, and normal interactions inside the existing `chad` session. Only run `open` when `chad` is not already open, or when the user explicitly asks for a new browser launch.

When launching or interacting explicitly, pass the same session:

```bash
"$PWCLI" --session chad snapshot
```

For sites where the user logs in, also preserve authentication with storage state as a portable backup:

```bash
"$PWCLI" --session chad state-save "$AGENTS_PLAYWRIGHT_STATE/chad-auth.json"
chmod 600 "$AGENTS_PLAYWRIGHT_STATE/chad-auth.json"
```

Before reopening a login-dependent site, prefer the persistent profile. If the profile does not have the login but the state file exists, restore state:

```bash
test -f "$AGENTS_PLAYWRIGHT_STATE/chad-auth.json" && "$PWCLI" --session chad state-load "$AGENTS_PLAYWRIGHT_STATE/chad-auth.json"
```

Do not run `delete-data`, `cookie-clear`, `localstorage-clear`, `sessionstorage-clear`, `close-all`, or `kill-all` against the `chad` session unless the user explicitly requests it. Prefer `goto`, `tab-new`, `reload`, and `snapshot` inside the existing `chad` session over repeatedly running `open --headed`.

## Quick start

Use the wrapper script:

```bash
"$PWCLI" open https://playwright.dev --headed
"$PWCLI" snapshot
"$PWCLI" click e15
"$PWCLI" type "Playwright"
"$PWCLI" press Enter
"$PWCLI" screenshot
```

## Core workflow

1. Open the page.
2. Snapshot to get stable element refs.
3. Interact using refs from the latest snapshot.
4. Re-snapshot after navigation or significant DOM changes.
5. Capture artifacts (screenshot, pdf, traces) when useful.

Minimal loop:

```bash
"$PWCLI" open https://example.com
"$PWCLI" snapshot
"$PWCLI" click e3
"$PWCLI" snapshot
```

## When to snapshot again

Snapshot again after:

- navigation
- clicking elements that change the UI substantially
- opening/closing modals or menus
- tab switches

Refs can go stale. When a command fails due to a missing ref, snapshot again.

## Recommended patterns

### Form fill and submit

```bash
"$PWCLI" open https://example.com/form
"$PWCLI" snapshot
"$PWCLI" fill e1 "user@example.com"
"$PWCLI" fill e2 "password123"
"$PWCLI" click e3
"$PWCLI" snapshot
```

### Debug a UI flow with traces

```bash
"$PWCLI" open https://example.com --headed
"$PWCLI" tracing-start
# ...interactions...
"$PWCLI" tracing-stop
```

### Multi-tab work

```bash
"$PWCLI" tab-new https://example.com
"$PWCLI" tab-list
"$PWCLI" tab-select 0
"$PWCLI" snapshot
```

## Wrapper script

The wrapper script uses `npx --package @playwright/cli playwright-cli` so the CLI can run without a global install:

```bash
"$PWCLI" --help
```

Prefer the wrapper unless the repository already standardizes on a global install.

## Guardrails

- Always snapshot before referencing element ids like `e12`.
- Re-snapshot when refs seem stale.
- Prefer explicit commands over `eval` and `run-code` unless needed.
- When you do not have a fresh snapshot, use placeholder refs like `eX` and say why; do not bypass refs with `run-code`.
- Use `--headed` when a visual check will help.
- When capturing artifacts in this repo, use `output/playwright/` and avoid introducing new top-level artifact folders.
- Default to CLI commands and workflows, not Playwright test specs.
