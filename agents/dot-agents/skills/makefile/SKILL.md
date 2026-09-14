---
name: makefile
description: Create, modify, review, debug, or improve GNU Makefiles used as project build, development, CI, release, Docker, or deployment interfaces. Use when a user asks to write or refactor a Makefile, add targets, model build dependencies, improve incremental builds, add self-documenting help, harden recipes, or assess Makefile quality. This skill is intentionally opinionated toward GNU Make + Bash and the required strict header described below.
metadata:
  sources:
    - https://tech.davis-hansson.com/p/make/
    - https://skills.sh/itechmeat/llm-code/makefile
    - https://github.com/akin-ozer/cc-devops-skills/blob/main/devops-skills-plugin/skills/makefile-generator/SKILL.md
---

# Makefile

Treat a Makefile as a dependency graph and a stable project command interface, not merely a collection of shell aliases.

Prefer boring, explicit, incremental build logic. Let Make decide **what is stale**; let recipes describe **how to produce it**.

## Required GNU Make + Bash baseline

For newly created Makefiles, and when substantially refactoring an existing Makefile, use this header unless there is a strong project-specific reason not to:

```make
# https://tech.davis-hansson.com/p/make/
SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

# ANSI color codes
GREEN=$(shell tput -Txterm setaf 2)
YELLOW=$(shell tput -Txterm setaf 3)
RED=$(shell tput -Txterm setaf 1)
BLUE=$(shell tput -Txterm setaf 6)
RESET=$(shell tput -Txterm sgr0)

# !! `Makefile` must use tabs !!
```

This skill deliberately chooses GNU Make + Bash rather than pretending to be POSIX-portable. The header gives recipes consistent Bash semantics, makes shell failures propagate, deletes failed file targets, warns about undefined Make variables, and disables surprising built-in rules.

If the existing repository intentionally supports non-GNU Make, non-Bash systems, Windows-native Make variants, or another build dialect, preserve that contract rather than forcing this header. Explain the compatibility reason when departing from the baseline.

Do not add `.SUFFIXES:` merely by habit: `--no-builtin-rules` already disables built-in implicit rules. Add it only when it serves a concrete purpose.

## Default goal and self-documentation

New Makefiles MUST make help the default:

```make
.DEFAULT_GOAL := help
```

Public action targets SHOULD carry `##` documentation on the target line. Build `help` from those comments so the Makefile documents its real interface rather than maintaining a separate list.

Prefer a help rule that supports common target characters such as `/`, `.`, digits, `_`, and `-`:

```make
.PHONY: help
help: ## Show available targets
	@printf '%s\n' 'Targets:'
	@grep -E '^[a-zA-Z0-9_./-]+:.*?## .+$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  %-24s %s\n", $$1, $$2}'
```

Keep help concise. Document the targets users should invoke, not every implementation target.

## Inspect before editing

When modifying an existing repository, first inspect the relevant project files before designing targets:

- the current `Makefile` and included `.mk` files;
- README or contributor instructions that define canonical commands;
- language/package manifests and lockfiles;
- Docker/Compose files when container targets are involved;
- CI configuration when `make check`, `make test`, or release targets should match CI;
- scripts already used for builds, migrations, packaging, or deployment.

Preserve established project semantics unless the user is explicitly asking to redesign them.

## Model state with prerequisites

The core Make rule is:

```make
target: prerequisites
	recipe
```

Use prerequisites to encode causal relationships rather than manually sequencing commands inside a recipe.

Prefer:

```make
release: test package
```

only when `test` and `package` are independent prerequisites of `release`.

If packaging requires the build, encode that dependency:

```make
release: package
package: build
```

Do not use a prerequisite list to imply left-to-right execution. GNU Make may run independent prerequisites concurrently under `make -j`.

## Separate public actions from build state

Use `.PHONY` for actions that do not represent files:

```make
.PHONY: build test lint clean deploy
```

Do not mark real generated files phony. Doing so defeats Make's timestamp model and forces unnecessary rebuilds.

A useful pattern for expensive commands whose result is not naturally represented by one local file is a stamp/sentinel target:

```make
.PHONY: build
build: .make/build.done

.make/build.done: $(BUILD_INPUTS) | .make
	./scripts/build.sh
	test -x build/myapp
	touch $@

.make:
	mkdir -p $@
```

The public target is an action interface; the stamp is build state.

Verify the actual artifact **before** touching the stamp. A successful timestamp must mean the intended output really exists.

Keep cache ownership simple. Avoid multiple nested stamps that independently claim freshness for the same expensive operation unless their invalidation relationship is explicit and correct. If an outer layer decides a rebuild is required, do not let a stale inner stamp incorrectly suppress that rebuild.

## Use order-only prerequisites for required structure

If a directory or setup target must exist before a build but changes to it should not invalidate the output, use an order-only prerequisite:

```make
build/app: $(OBJECTS) | build
	$(CC) $(LDFLAGS) $^ -o $@

build:
	mkdir -p $@
```

The `|` expresses: **must exist first, but is not an input whose timestamp makes this target stale**.

Use this pattern for build directories, stamp directories, and similar structural prerequisites.

## Make invalidation complete

Incremental builds are correct only when the target lists every input whose change should invalidate it.

Include relevant source files, manifests, lockfiles, configuration, templates, build scripts, Dockerfiles, and other build inputs.

Be careful when deriving sources from version control. `git ls-files` excludes untracked files. If a newly created but untracked source file should affect local builds, include untracked non-ignored files or use another source-discovery strategy.

Do not make everything depend on everything merely to be safe. That preserves correctness by destroying incrementality. Model the narrowest correct dependency graph.

## Variables communicate ownership

Use `?=` for knobs callers may override:

```make
PREFIX ?= /usr/local
IMAGE ?= myapp
COLOR ?= 1
```

Use `:=` by default for project-owned computed values:

```make
PROJECT := myapp
BUILD_DIR := build
SOURCES := $(wildcard src/*.c)
```

Use recursive `=` only when late expansion is intentional.

Quote shell expansions when paths or user-controlled values may contain spaces or special characters. Distinguish Make variables `$(NAME)` from shell variables `$$NAME`.

## Keep recipes understandable

Because `.ONESHELL` is required, recipe lines for a target execute in one Bash process. This makes blocks such as `export`, `cd`, shell variables, and sourced environment files persist throughout the recipe.

Use that power deliberately. A short, cohesive shell block is fine. Move substantial algorithms, parsing, or reusable application logic into scripts rather than turning Make recipes into large programs.

Do not prefix every command with `@`. Command echoing is useful when CI or a developer needs to understand what failed. Silence commands primarily for intentional human-facing output such as `help` or concise status lines.

Do not suppress failures with `|| true` or a leading `-` unless failure is genuinely acceptable.

## Prefer conventional public targets

Use familiar names when they fit the project:

- `help` — discover the interface;
- `build` — produce the main artifact;
- `dev` or `run` — start local development/runtime;
- `test` — run tests;
- `lint` — run static analysis;
- `format` — modify source formatting;
- `check` — run non-destructive validation appropriate for CI;
- `clean` — remove generated artifacts;
- `install` — install artifacts when the project needs it;
- `deploy/<env>` or `release` — explicit consequential operations.

When a target name expresses hierarchy or a namespace, always prefer `/` over
`-` unless a concrete compatibility or tooling constraint requires the
hyphenated form. For example, use `upload/scanner` rather than
`upload-scanner`.

Do not add targets merely because they are conventional. The Makefile should expose the operations this repository actually needs.

Be careful with `check: format lint test`: if `format` modifies files, then `check` is not a non-destructive CI check. Prefer a formatting check mode when available.

## Treat the Makefile as a project API

Design public targets so developers, CI, and automation can invoke the same canonical operations:

```text
make build
make test
make check
```

Avoid reproducing the same workflow separately in CI YAML, README commands, and agent instructions when they can all call Make instead.

Keep public targets stable when practical. Internal implementation targets may change without forcing users or CI to learn a new command surface.

## Design for parallel correctness

Assume users may run `make -j`.

If two prerequisites can safely run independently, let Make parallelize them. If one consumes another's output, encode the dependency edge. Use `.NOTPARALLEL` only for operations that truly cannot overlap and whose dependency cannot be expressed more precisely.

Deployment, mutable shared services, migrations, and registry operations deserve particular scrutiny.

## Containers and reproducibility

Containerizing a build improves environment consistency but does not automatically make it reproducible.

When relevant:

- prefer pinned toolchain/container versions;
- use immutable image digests when reproducibility matters;
- avoid repeatedly installing floating OS packages inside every build when a purpose-built builder image is practical;
- avoid `--network=host` unless the build genuinely needs host networking;
- prevent containers from leaving root-owned files in host-mounted worktrees;
- make clear which environment/config values are compile-time inputs versus runtime-only configuration.

If a runtime-only secret or environment file should not invalidate compilation, do not make the build stamp depend on it merely because deployment uses it.

## Guard destructive operations

Treat `clean`, `install`, deployment, publishing, and commands using `rm -rf`, `rsync --delete`, or remote destinations as safety-sensitive.

For destructive path operations:

- quote paths;
- use `--` where supported;
- reject empty, root, current-directory, or otherwise catastrophic destinations;
- canonicalize local paths when that materially improves safety;
- keep deployment config separate from directories that are mirrored with deletion when possible;
- provide a dry-run mode for destructive deployment when useful;
- never bake credentials or secrets into recipe command lines unnecessarily.

Do not add `sudo` to normal development targets as a convenience.

## Review and improvement priorities

When auditing an existing Makefile, prioritize findings in this order:

1. **Correctness:** Does the dependency graph produce the right artifacts? Can stale state suppress needed work?
2. **Safety:** Can cleanup or deployment destroy the wrong data? Are failures hidden?
3. **Incrementality:** Does Make rebuild only what is stale?
4. **Parallel correctness:** Does `make -j` expose missing dependency edges or shared-state races?
5. **Interface:** Are public targets conventional, stable, and documented?
6. **Maintainability:** Are recipes understandable and configuration semantics explicit?
7. **Performance:** Can expensive work be skipped or cached without compromising correctness?

Distinguish genuine bugs from portability or style tradeoffs. This skill intentionally favors GNU Make + Bash, so do not criticize those choices as defects unless the repository itself requires broader portability.

## Validate changes

After creating or changing a Makefile, validate what is practical for the repository.

At minimum:

```bash
make help
make -n <important-target>
```

Also consider:

- running non-destructive targets such as `make test`, `make lint`, or `make check`;
- running the target twice to confirm incremental behavior;
- touching or modifying one input and confirming the correct dependent work reruns;
- using `make -j` to expose dependency mistakes when targets are expected to be parallel-safe;
- confirming failed file-producing recipes do not leave valid-looking outputs;
- testing deployment checks with deliberately unsafe paths without performing a real deployment.

Do not execute consequential deploy, publish, install, or destructive cleanup actions merely to validate syntax unless the user explicitly asked for that execution.

## Completion standard

A good Makefile should make the following easy to answer:

- What can I do? → `make` / `make help`
- What inputs produce this output? → prerequisites
- Why is this rebuilding? → a changed prerequisite
- Why is this *not* rebuilding? → the target is genuinely current
- Can this run under `make -j`? → dependency edges describe ordering correctly
- What can users override? → `?=` configuration knobs
- Will failure be obvious? → strict Bash + Make failure behavior
- Can cleanup/deployment hurt the wrong path? → explicit guardrails

Prefer the smallest Makefile that answers those questions correctly.
