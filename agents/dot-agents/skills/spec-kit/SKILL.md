---
name: spec-kit
description: Lightweight feature-spec workflow for repo-local specs. Use when the user invokes `$spec-kit`, asks to continue a feature spec such as `$spec-kit 001-trial-booking`, wants Codex to determine the current step from a specs feature directory, or wants help creating, clarifying, planning, tasking, or verifying a feature through the spec, clarify, plan, tasks, and verification process.
---

# Spec Kit

Use this skill to run a lightweight, diy spec-kit process inside the current
repository. Treat it as a workflow helper, not as a persistent project rule
system.

## Invocation

Accept feature identifiers such as:

- `001-trial-booking`
- `trial-booking`
- `001`

Resolve them against `specs/`:

1. If an exact `specs/<input>/` directory exists, use it.
2. If the input is a number, match a directory with that numeric prefix.
3. If the input is a slug, match a directory ending in that slug.
4. If no match exists, create `specs/<next-number>-<slug>/` when the user gave a
   usable slug.
5. If multiple matches exist, ask a concise clarification question.

Before creating files, inspect existing repo docs that are directly relevant,
especially `docs/spec-kit.md` when present. Do not require agents to reference
that file during normal implementation; it is human memory, not a project rule.

## Feature Directory

Use this shape:

```text
specs/
  001-feature-name/
    spec.md
    plan.md
    tasks.md
    verification.md
```

Create only the files needed for the current step unless the user asks to
bootstrap the whole directory.

## Step Detection

Inspect the feature directory and determine the next step:

1. Missing `spec.md`: create or draft the spec.
2. `spec.md` has unresolved open questions that would change behavior: clarify.
3. Missing `plan.md`: write the implementation plan.
4. Missing `tasks.md`: write the task checklist.
5. Missing `verification.md`: write verification checks.
6. All files exist: summarize current state and recommend or perform the next
   incomplete task from `tasks.md`.

When a file exists, read it before deciding. If the current step is ambiguous,
prefer making the smallest useful improvement and note the assumption.

## Spec Step

`spec.md` answers what and why, not how.

Include:

- user-facing goal.
- affected user types.
- user stories or scenarios.
- acceptance criteria.
- product invariants that must not break.
- open questions.

Do not include schema designs, module names, implementation details, or code in
the spec.

## Clarify Step

Resolve questions before planning when the answer affects behavior.

Good clarification targets include:

- duplicate booking submissions.
- payment success with delayed webhook delivery.
- exact cutoff-boundary behavior.
- conflicts between provider state and local state.
- what each user can see or change.

If answers are discoverable from existing project docs, update the spec with the
answer and cite the local file path. If answers require product judgment, ask the
user concise questions before planning.

## Plan Step

`plan.md` maps behavior to implementation.

Include:

- Phoenix contexts and boundaries.
- data model changes and migrations.
- external integrations and idempotency strategy.
- authorization checks.
- failure states and retry behavior.
- UI or LiveView flow changes.
- documentation that must change.

For Elixir/Phoenix code, follow any applicable repository instructions and
mandatory Elixir/Phoenix skills before editing implementation files.

## Tasks Step

`tasks.md` is the working checklist.

Make tasks small, ordered, and verifiable. Group by behavior when useful:

- data model.
- context behavior.
- web flow.
- integration side effects.
- tests.
- docs.

Use markdown checkboxes. If implementation begins later, update checkboxes as
tasks are completed.

## Verification Step

`verification.md` lists development and completion checks.

Include:

- narrow tests to run during development.
- broader checks before calling the feature done.
- manual browser scenarios for user-facing flows.
- relevant edge cases from project verification rules.

For booking and billing work, explicitly consider:

- exactly 12 hours before lesson start.
- subscription renewal.
- expired unbooked credits.
- returned credits.
- daylight-saving transitions.
- Stripe webhook retries, duplicates, and out-of-order events.
- duplicate booking submissions.

## Response Style

When invoked, first state the resolved feature directory and detected step in
one sentence. Then perform the next step. Keep the final response short and list
the files changed or the clarification questions that block progress.
