---
name: agents-md-refactor
description: Refactor AGENTS.md files to follow progressive disclosure principles. Use when AGENTS.md is too long or disorganized.
based-on: https://github.com/brianlovin/agent-config/blob/1a9819ebf3fee811150fc76cbe177ea4e5f747ff/skills/reclaude/SKILL.md
---

# agents-md-refactor

Refactor AGENTS.md files to follow progressive disclosure principles.

## Prompt

I want you to refactor my AGENTS.md file to follow progressive disclosure principles.

First, add the meta section. Add this to the top of the file:

```
## AGENTS.md

- This file and the `.agents/` directory should follow the progressive disclosure policy
- The top level AGENTS.md should ideally be < 50 lines, and never > 100
- The root AGENTS.md should contain only:
    - One-line project description
    - Package manager (if not npm)
    - Non-obvious commands only (skip `npm test`, `npm run build` if standard)
    - Links to `.agents/rules/` files with brief descriptions
    - Verification section (always required)
- Remaining instructions should go in `.agents/rules/` files by category (e.g., TypeScript conventions, testing patterns, API design, Git workflow).
- The following content should not go in AGENTS.md nor `.agents/` files:
    - **API documentation** — link to external docs instead
    - **Code examples** — agents can infer from reading source files
    - **Interface/type definitions** — these exist in the code
    - **Generic advice** — "write clean code", "follow best practices"
    - **Obvious instructions** — "use TypeScript for .ts files"
    - **Redundant info** — things already included in your operating instructions
    - **Too vague** — instructions that aren't actionable
```

Next, refactor the AGENTS.md file to conform to the above guidelines:

### 1. Check length

Report the current line count. Flag issues:
- **Ideal**: <50 lines
- **Acceptable**: 50-100 lines
- **Needs refactoring**: >100 lines (move content to `.agents/rules/` files)

### 2. Ensure verification section exists

Check for a `## Verification` section with commands agents can run after making changes. If missing:
- Look in package.json for test/lint/typecheck/build scripts
- Look for Makefile, justfile, or other task runners
- Add a `## Verification` section with discovered commands

This is critical - agents perform better when they can verify their work.

### 3. Find contradictions

Identify any instructions that conflict with each other. For each contradiction, ask me which version I want to keep.

### 4. Check for global skill extraction candidates

Look for content that could become a **reusable global skill** in `~/.agents/skills/`:
- Is about a tool/framework (not project-specific)
- Same instructions appear (or would apply) in 2+ projects
- Is substantial (>20 lines)

If found, suggest creating a global skill with name and description.

### 5. Identify essentials for root AGENTS.md

Extract only what belongs in the root AGENTS.md:
- One-line project description
- Package manager (if not npm)
- Non-obvious commands only (skip `npm test`, `npm run build` if standard)
- Links to `.agents/rules/` files with brief descriptions
- Verification section (always required)

### 6. Group remaining content

Organize remaining instructions into `.agents/rules/` files by category (e.g., TypeScript conventions, testing patterns, API design, Git workflow).

### 7. Flag for deletion

Identify content that should be removed entirely:
- **API documentation** — link to external docs instead
- **Code examples** — agents can infer from reading source files
- **Interface/type definitions** — these exist in the code
- **Generic advice** — "write clean code", "follow best practices"
- **Obvious instructions** — "use TypeScript for .ts files"
- **Redundant info** — things already included in your operating instructions
- **Too vague** — instructions that aren't actionable

## Target Template

```markdown
# Project Name

One-line description.

## AGENTS.md

- This file and the `.agents/` directory should follow the progressive disclosure policy
- The top level AGENTS.md should ideally be < 50 lines, and never > 100
- The root AGENTS.md should contain only:
    - One-line project description
    - Package manager (if not npm)
    - Non-obvious commands only (skip `npm test`, `npm run build` if standard)
    - Links to `.agents/rules/` files with brief descriptions
    - Verification section (always required)
- Remaining instructions should go in `.agents/rules/` files by category (e.g., TypeScript conventions, testing patterns, API design, Git workflow).
- The following content should not go in AGENTS.md nor `.agents/` files:
    - **API documentation** — link to external docs instead
    - **Code examples** — agents can infer from reading source files
    - **Interface/type definitions** — these exist in the code
    - **Generic advice** — "write clean code", "follow best practices"
    - **Obvious instructions** — "use TypeScript for .ts files"
    - **Redundant info** — things already included in your operating instructions
    - **Too vague** — instructions that aren't actionable

## Commands
- `command` - what it does (only non-obvious ones)

## Rules
- [Topic](/.agents/rules/topic.md) — brief description

## Verification
After making changes:
- `npm test` - Run tests
- `npm run lint` - Check linting
```

## What to Keep vs Remove

**Keep in AGENTS.md:**
- Commands agents can't guess from package.json / Makefile / etc
- Non-standard patterns specific to this project
- Project gotchas and footguns
- Links to detailed rules files

**Move to `.agents/rules/`:**
- Detailed conventions (>10 lines on a topic)
- Style guides
- Architecture decisions
- Workflow documentation

**Remove entirely:**
- Anything agents can infer from reading the codebase
- Standard practices for the language/framework
- Documentation that exists elsewhere (link instead)
