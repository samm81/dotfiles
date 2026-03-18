---
name: screenshot
description: Capture screenshots on a Wayland desktop with grimshot. Use when Codex needs to take, save, or copy a screenshot from the user's live session, especially for requests about the active window, full screen, a selected area, a chosen window, or the current output.
---

# Screenshot

Use `grimshot` for screenshot capture.

`grimshot` wraps the common Wayland screenshot tools and exposes the main choices directly:

- action: `copy`, `save`, or `savecopy`
- target: `active`, `screen`, `output`, `area`, `window`, or `anything`

## Quick Start

Pick the action first:

- use `copy` when the user wants the image in the clipboard only
- use `save` when another tool or later step needs a file path
- use `savecopy` when both are useful

Pick the target second:

- use `active` for the focused window
- use `screen` for all visible outputs
- use `output` for the current monitor
- use `area` for a drag selection
- use `window` for an interactively chosen window
- use `anything` when the user wants to choose between area, window, or output at capture time

## Common Commands

```bash
grimshot copy area
grimshot save active /tmp/active-window.png
grimshot savecopy output ~/Pictures/current-output.png
grimshot --wait 3 save area /tmp/menu-after-delay.png
grimshot --cursor save window /tmp/window-with-cursor.png
grimshot check
```

Use `grimshot save ... -` only when the output should be piped to another command.

## Working Pattern

1. Run `grimshot check` if the environment is unknown or a prior capture failed.
2. Choose `save` or `savecopy` when a later tool needs to inspect the image.
3. Save to an explicit `.png` path and create parent directories first if needed.
4. Add `--wait N` for transient UI like menus, hover cards, or tooltips.
5. Add `--cursor` only when the pointer position matters.

## Failure Cases

- If `grimshot check` fails, report that the Wayland screenshot stack is incomplete.
- If the session is not Wayland-based, do not keep retrying `grimshot`; explain that the tool is environment-specific.
- If interactive targets like `area`, `window`, or `anything` are not appropriate for the task, switch to a non-interactive target such as `active`, `output`, or `screen`.
