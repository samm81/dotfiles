---
name: python
description: synthesized skill for the python workspace.
synthesized_from:
  - 0xbigboss/claude-code/python-best-practices
  - wshobson/agents/python-anti-patterns
  - wshobson/agents/python-configuration
  - wshobson/agents/python-design-patterns
  - wshobson/agents/python-error-handling
  - wshobson/agents/python-type-safety
---

use when reading or writing python files.

## core rules

- define data models and function signatures before implementation. annotate all public APIs, use typed collections, and prefer modern syntax like `T | None`.
- make invalid states hard to represent. use dataclasses, pydantic models, `TypedDict`, enums, `Literal`, `NewType`, type aliases, and `Protocol` where they clarify domain constraints.
- validate external input at system boundaries. convert raw strings and dicts into typed domain values early, and fail fast with specific, actionable errors.
- preserve error context. catch specific exceptions, re-raise with `from err`, and ensure each code path returns a value or raises.
- centralize configuration in one typed settings object loaded from environment at startup. provide local-safe defaults, require explicit secrets, and never hardcode config or scatter `os.getenv()` calls.
- keep modules and functions focused. separate transport or I/O concerns from business logic, and keep pure logic testable without databases, HTTP clients, or framework objects.
- prefer composition and dependency injection over inheritance. abstract only after a real repeated pattern exists.
- do not leak internal storage or transport types across boundaries. map ORM models and external payloads to explicit domain or response models.
- use context managers for files, sockets, and similar resources. prefer `pathlib`, explicit encodings, and async-native libraries in async code.
- avoid class-level mutable state, mutable default arguments, bare `except`, silent failures, and retry logic duplicated across multiple layers.
- for batch work, capture partial failures instead of aborting the whole operation on the first bad item.
- run strict type checking in the project’s chosen tool (`mypy`, `pyright`, or `ty`) and add tests for edge cases and failure paths, not only happy paths.

## review checklist

- no hardcoded secrets or environment-specific values
- no mixed I/O and business logic in the same unit
- no exposed ORM or framework internals in public responses
- no blocking calls inside async functions
- no untyped public functions or bare collections like `list`
- no swallowed exceptions or generic `Exception` where a specific type fits
- no over-abstraction when a simple explicit solution is clearer
