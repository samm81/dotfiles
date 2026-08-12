---
name: 12-factor
description: 12-Factor App patterns for deployable applications. Use when configuring environment variables, connecting to backing services, structuring application startup/shutdown, or handling graceful shutdown and process signals. Applies to any deployed application (services, APIs, frontends, workers). Server-specific factors (port binding, concurrency, disposability) apply only to backend services.
based-on: https://github.com/citypaul/.dotfiles/blob/87827c4b85fb310f377499e4bd2582bea52db34a/claude/.claude/skills/twelve-factor/SKILL.md
---

# 12-Factor App Patterns

Core factors (config, dependencies, backing services, logs) apply to any deployed application — services, frontends, workers, and CLI tools. Server-specific factors (port binding, concurrency, disposability) apply only to backend services that run as long-lived processes.

Based on [12factor.net](https://12factor.net). All 12 factors are covered below as language-agnostic rules, anti-patterns, and implementation implications.

---

## When to Apply

- **Greenfield projects**: All 12-factor rules are mandatory. Structure the application to follow every applicable factor from the start.
- **Brownfield projects**: Aim to follow as many factors as possible. Adopt incrementally in this priority order:
  1. **Config** (Factor III) — add env var validation without restructuring
  2. **Logs** (Factor XI) — switch to structured stdout logging
  3. **Disposability** (Factor IX) — add graceful shutdown handlers
  4. **Backing services** (Factor IV) — abstract connections behind config URLs
  5. **Stateless processes** (Factor VI) — migrate in-memory state to backing services

## Codebase (Factor I)

One codebase tracked in revision control, many deploys. Each deployable service has its own codebase. Shared code between services is extracted into libraries managed through the platform's dependency system, not copy-pasted.

In a monorepo, each service should have its own entry point, its own deploy pipeline, and its own set of backing service connections. A single repo is fine as long as each service deploys independently.

## Config (Factor III)

Store all configuration in environment variables. Never hardcode URLs, credentials, or per-environment values.

**Rules:**
- Validate config at startup with a schema — fail fast (exit non-zero, clear error) if config is invalid
- Read environment variables at the application boundary, then pass validated config explicitly to the code that needs it
- Provide `.env.example` as documentation (never commit `.env` with real values)

### Config Anti-Patterns

```text
DB_HOST = "prod-db.internal.example.com"

if environment == "production":
  connect_to("prod-db")
else:
  connect_to("localhost")

load_config_file("config." + environment + ".json")
```

**Why these are wrong:** Config that varies by deploy belongs in env vars, not code. Environment-name branching creates combinatorial explosion and breaks dev/prod parity.

## Dependencies (Factor II)

Explicitly declare all dependencies. Never rely on implicit system-wide packages.

**Rules:**
- Every dependency declared in the platform's dependency manifest
- Lockfile committed when the ecosystem supports one
- Dependencies are isolated — the app does not leak from or depend on globally installed packages
- No shell calls to assumed system tools without declaring and validating the requirement
- If a system tool is required, document it explicitly and check for it at startup

## Backing Services (Factor IV)

Treat every backing service (database, cache, queue, email, storage) as an attached resource identified by a URL in config.

**The code makes no distinction between local and third-party services.** Swapping a local PostgreSQL for a managed cloud database requires only a config change, never a code change. Connection setup should be centralized behind constructors, factories, or dependency injection that accepts validated config.

For projects using hexagonal architecture, backing services map naturally to ports (interfaces) and adapters (implementations). Follow the repository's architecture guidance when it exists.

## Stateless Processes (Factor VI)

Execute the app as stateless, share-nothing processes. Any data that must persist lives in a backing service.

### Stateless Anti-Patterns

```text
sessions = in_memory_map()

on_upload(request):
  write_file("/tmp/uploads/" + request.file_name, request.file_data)

request_count = 0
on_request():
  request_count = request_count + 1

every_minute(send_report)
```

**Why these are wrong:** In-memory state is lost on restart and invisible to other process instances. Local filesystem state cannot be shared across processes. In-process schedulers run in only one instance. Use backing services (Redis, S3, database) and external schedulers instead.

Immutable data patterns can support statelessness. Follow the repository's functional-programming guidance when it exists.

## Concurrency (Factor VIII)

Scale out via the process model. Design the app so work can be divided across process types.

**Rules:**
- Separate entry points for each process type (web, worker, scheduler)
- HTTP handlers dispatch background work to a queue, never process it inline
- Each process type scales independently
- Use a `Procfile` or equivalent to define process types

```
web: start-web-process
worker: start-worker-process
```

## Disposability (Factor IX)

Maximize robustness with fast startup and graceful shutdown.

**Rules:**
- Handle SIGTERM and SIGINT for graceful shutdown
- Set a drain timeout — force exit if shutdown hangs
- Stop accepting new work, then drain in-flight requests or jobs before exiting
- Close database pools, Redis connections, queue consumers
- Exit with non-zero code on shutdown failure
- Keep startup fast — defer heavy initialization to first request if needed
- Design background jobs to be reentrant/idempotent so interrupted work can be safely retried
- Provide `/health` and `/ready` endpoints for orchestrator probes

## Logs (Factor XI)

Treat logs as event streams. Write structured output to stdout. Never route or store logs from within the app.

For internet-facing servers, RFC 6302 (BCP 162) specifies minimum logging requirements: source and destination addresses and ports, timestamps (preferably UTC), and transport protocol. These should be captured at the server/framework level in addition to application-level structured logging.

### Semantic Requirements

Regardless of which logging library or implementation a project uses, all loggers must satisfy these properties:

- **Structured output** — logs are machine-parseable (JSON preferred), not free-form strings
- **stdout/stderr only** — the app never writes to log files, never configures file transports
- **Standard levels** — at minimum: `debug`, `info`, `warn`, `error` — configurable via environment
- **Contextual data** — logs accept structured metadata (key-value pairs), not just message strings
- **Timestamp included** — every log entry includes an ISO 8601 timestamp
- **Request correlation** — include a `requestId` or trace ID to correlate logs across a single request

Projects may use any logging library or telemetry framework as long as these semantics are met. If an existing logger is missing levels or structured data support, adapt it to meet these requirements.

### Logging Anti-Patterns

```text
append_to_file("/var/log/app.log", message)

logger.add_file_transport("error.log")

print("User " + user_id + " logged in")
```

**Why these are wrong:** File transports mean the app is routing its own logs. Unstructured string interpolation produces logs that cannot be parsed or queried. The execution environment (container orchestrator, PaaS) captures stdout and routes it to the appropriate destination.

## Build, Release, Run (Factor V)

Strictly separate build and run stages. Config is injected at release/run time, never baked into the build.

**Code-level implications:**
- No environment-specific build outputs — the same build artifact deploys to every environment
- Config comes from env vars at runtime, not from compile-time substitution
- Releases are immutable — code changes require a new build, not runtime patching

## Port Binding (Factor VII)

The app is self-contained and exports its service by binding to a port.

```text
server.listen(config.port)
logger.info("server_started", { "port": config.port })
```

Do not rely on runtime injection of a web server (e.g., a separate Apache/Nginx process serving your app). The app includes its own HTTP server library as a dependency.

## Dev/Prod Parity (Factor X)

Keep development and production as similar as possible. Use the same type of backing services in all environments.

**Rules:**
- If production uses PostgreSQL, develop against PostgreSQL (not SQLite)
- If production uses Redis, develop against Redis (not in-memory maps)
- Use containers (Docker Compose) to run backing services locally
- Config schema validation (Factor III) catches mismatches at startup

## Admin Processes (Factor XII)

Run admin tasks (migrations, data fixes, console sessions) as one-off processes using the same codebase and config.

Admin scripts live in the repo alongside application code. They are not separate tools or ad-hoc shell commands. Admin processes run in an identical environment to the app — same release, same config, same dependencies.

## Testing 12-Factor Patterns

12-factor patterns are testable through behavior-driven tests:

- **Config**: test that config loading fails on missing required vars and returns correct defaults
- **Disposability**: test that shutdown closes all connections (inject test doubles for db/cache)
- **Backing services**: test that services work with any backing service URL (inject via config)
- **Statelessness**: test that request handlers do not depend on prior request state

Explicit config injection makes all of these patterns naturally testable without mocking global environment state. Follow the repository's testing guidance when it exists.

## Checklist

- [ ] One codebase per deployable service; shared code extracted as libraries
- [ ] Same build artifact deploys to every environment (no env-specific builds)
- [ ] All config comes from environment variables, validated at startup with a schema
- [ ] Startup fails fast with a clear error message if config is invalid
- [ ] `.env.example` documents required variables (no real credentials)
- [ ] All dependencies explicitly declared in manifest with lockfile committed
- [ ] Backing services connected via config URLs, swappable without code changes
- [ ] No in-memory session state, no local filesystem state between requests
- [ ] Separate entry points for web and worker process types
- [ ] SIGTERM/SIGINT handlers with drain timeout for graceful shutdown
- [ ] Database pools and connections closed on shutdown
- [ ] `/health` and `/ready` endpoints for orchestrator probes
- [ ] Logs written as structured JSON to stdout, no file transports
- [ ] Logs include request correlation IDs
- [ ] App binds to a port from config, includes its own HTTP server
- [ ] Same backing service types used in development and production
- [ ] Admin scripts live in the repo and use the same config/dependencies
