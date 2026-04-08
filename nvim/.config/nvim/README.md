# neovim config

this repo contains my neovim configuration.

`none-ls` is loaded only for supported filetypes, and its external formatters / diagnostics are gated by executable plus root or path checks so plain unsupported buffers do not pay for it.

## profiling

the repo includes a terminal-first profiling harness at `scripts/nvim-profile`.
it profiles whichever `nvim` environment is active in the current shell.
by default it runs a regular terminal-ui `nvim` startup path and reports `first screen update` timing. use `--headless` only when you specifically want lower-level internal timings.

examples:

```bash
scripts/nvim-profile startup
scripts/nvim-profile startup --headless
scripts/nvim-profile gitcommit --runs 20
scripts/nvim-profile diff --runs 20
scripts/nvim-profile all --runs 10 --warmup 2
scripts/nvim-profile all --runs 10 --warmup 2 --headless
```

by default, results are written under `${XDG_STATE_HOME:-$HOME/.local/state}/nvim/profile/<timestamp>`.
each scenario writes:

- `summary.json` with min / median / p95 / max timing stats
- `raw/result-*.json` with per-run timings and milestone data from inside neovim
- `logs/*.startuptime.log` with the native `nvim --startuptime` trace

the suite measures three scenarios:

- `startup`: plain `nvim` startup
- `gitcommit`: opening a generated `COMMIT_EDITMSG` inside a temporary git repo
- `diff`: opening two generated files with `nvim -d`

### snapshots

| date | mode | command | cpu | cores / threads | memory | os |
| --- | --- | --- | --- | --- | --- | --- |
| `2026-03-25` | `ui` | `scripts/nvim-profile all --runs 1 --warmup 0` | 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz | 4 / 8 | 15 GiB RAM | Linux 6.12.69_1 x86_64 |
| `2026-03-27` | `ui` | `scripts/nvim-profile all --runs 10 --warmup 2` | 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz | 4 / 8 | 15 GiB RAM | Linux 6.12.69_1 x86_64 |

| date | scenario | first screen update ms | startup complete ms | notes |
| --- | --- | ---: | ---: | --- |
| `2026-03-25` | `startup` | 47.325 | 47.325 | plain `nvim` startup |
| `2026-03-25` | `gitcommit` | 64.477 | 64.478 | generated `COMMIT_EDITMSG` in a temporary git repo |
| `2026-03-25` | `diff` | 62.662 | 62.663 | generated two-file `nvim -d` run |
| `2026-03-27` | `startup` | min 43.248 / med 46.364 / p95 52.636 | min 43.249 / med 46.365 / p95 52.637 | current user-facing baseline for plain `nvim` startup |
| `2026-03-27` | `gitcommit` | min 70.952 / med 76.442 / p95 105.323 | min 70.953 / med 76.443 / p95 105.324 | current user-facing baseline for generated `COMMIT_EDITMSG` in a temporary git repo |
| `2026-03-27` | `diff` | min 56.076 / med 57.915 / p95 60.509 | min 56.078 / med 57.916 / p95 60.510 | current user-facing baseline for generated two-file `nvim -d` run |

the 2026-03-25 rows are still just a single-sample ui reference point. the 2026-03-27 rows are the better comparison set for actual editor feel: terminal-ui mode, 10 measured runs, and 2 warmups. use this exact command when you want the current user-facing baseline:

```bash
scripts/nvim-profile all --runs 10 --warmup 2
```

the default benchmark includes terminal-ui startup cost and is meant to be closer to what you actually feel when opening `nvim`. use `--headless` only when you want lower-noise internal timing for debugging or regression isolation.

the suite is still best used for repeatable comparisons over time. if a run regresses, follow up manually inside `nvim`:

```bash
nvim
```

then inspect plugin timing with:

```vim
:Lazy profile
```

for a quick syntax/config check, use:

```bash
nvim --headless -c "quitall"
```
