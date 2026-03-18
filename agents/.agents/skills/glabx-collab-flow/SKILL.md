---
name: glabx-collab-flow
description: Use the repository's glabx discussion workflow for MR review collaboration, including listing unresolved discussions, posting replies with required prefixing, and expected follow-through after review rounds.
---

# glabx Collaboration Flow

## Goal

Use `glabx` consistently to review merge request discussions, respond with the required reply format, and complete the expected commit/push follow-through.

## glabx Usage

`glabx` provides a GitLab discussion workflow aligned with `glab` command shape.

- List unresolved discussions for an MR ref (or current branch when MR ref is omitted):
  - `glabx mr discussions list [<id> | <branch>] [--pretty] [--show-resolvability]`
  - Current-branch example: `glabx mr discussions list --pretty`
- Reply to a discussion:
  - `glabx mr discussions reply [<id> | <branch>] <DISCUSSION_ID> <BODY>`
  - Current-branch example: `glabx mr discussions reply <DISCUSSION_ID> "reply text"`
- Reply command behavior:
  - Exits `0` and prints nothing on success.
  - Leaves stderr visible and exits non-zero on errors.

## Flow

1. when asked to "start", first check if an `mr` already exists, and if not, create one, using `glab`. then return control to the user, informing them you are waiting for their comments.
2. when the user tells you they've left new comments, or they're done, or any language like that, use `glabx` to fetch discussions.
3. for each discussion, either respond to the user, or make an appropriate change to the code, and respond with what you changed.
4. use your judgment about how to batch commits. you should be making commits, but sometimes it will make sense to group a couple of discussion fixes together into one commit, and sometimes it will make sense to make just one commit for the entire turn.
5. after posting replies, re-list discussions and verify exactly one new [agent-name] note per targeted discussion
6. after verifying new notes, double check that all changes have been committed, push changes back up, and return control to the user, giving a brief overview of what you've changed.
7. return to 2

### MR Creation Notes

- Some `glab` installs do not support `glab mr status`; prefer `glab mr list` checks.
- To check whether the current branch already has an open MR, use:
  - `glab mr list --source-branch <branch> --output json --per-page 20`
- Ensure the branch exists on origin before creating an MR:
  - `git push -u origin <branch>`
- Prefer non-interactive MR creation in agent environments:
  - `glab mr create --source-branch <branch> --target-branch <target> --title "<title>" --description "<body>"`
- Avoid relying on `glab mr create --fill` in headless/PTY-limited runs; it may fail with prompt/cancelreader errors.
- If creation partially failed and `glab` prints a recovery file path, retry with:
  - `glab mr create --recover`

### Reply Safety (Required)

When posting discussion replies, prevent shell-quoting issues and duplicate comments.

1. Build reply bodies without backticks/code fences unless absolutely necessary.
2. Pass body text as a raw argv value via `xargs -0`, not inline shell quotes.

Example: `printf '%s\0' "$BODY" | xargs -0 glabx mr discussions reply <MR_ID> <DISCUSSION_ID>`

3. If a reply command errors, do not immediately retry.
4. First run: `glabx mr discussions list <MR_ID> --pretty` and check whether your `[agent-name]` reply was already created.
5. Only retry if no reply exists.
6. Post at most one agent reply per discussion per round unless the user explicitly asks for follow-up.

I’d also add a short checklist item in the flow: “

## Collaboration Style

- Prefer a discursive approach before implementing large or non-obvious changes.
- Feel free to push back on weak assumptions, risky requests, or unclear scope.
- Offer alternatives and trade-offs first when there are multiple reasonable approaches.
- Proceed immediately with implementation only when the path is clear and low-risk.
- After making a change or fix, reply to the discussion with what you changed. Never mark discussions as resolved; the user will do so.
- When replying to discussions, always prepend your reply with `"[agent-name]"` where `agent-name` is your name. Example: `"[codex-5.3] ..."`
- When reviewer feedback and code reality diverge, push back in-thread with concrete example code
- For MR comment rounds, prioritize minimal diffs and avoid structural refactors unless required
- If you compromise (temporary workaround), call it out explicitly and mark follow-up action
