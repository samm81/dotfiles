# neovim config

this repo contains my neovim configuration.

## profiling

the repo includes a terminal-first profiling harness at `scripts/nvim-profile`.
the script sets `XDG_CONFIG_HOME` to this repo's parent `.config` directory, so it profiles this config while still invoking plain `nvim`.
by default it runs a regular terminal-ui `nvim` startup path and reports `first screen update` timing. use `--headless` only when you specifically want lower-level internal timings.

examples:

```bash
scripts/nvim-profile startup
scripts/nvim-profile startup --headless
scripts/nvim-profile gitcommit --runs 20
scripts/nvim-profile diff --runs 20
scripts/nvim-profile all --runs 10 --warmup 2
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

### snapshot: 2026-03-25

| field | value |
| --- | --- |
| mode | `ui` (default) |
| command | `scripts/nvim-profile all --runs 1 --warmup 0` |
| cpu | 11th Gen Intel(R) Core(TM) i7-1165G7 @ 2.80GHz |
| cores / threads | 4 / 8 |
| memory | 15 GiB RAM |
| os | Linux 6.12.69_1 x86_64 |

| scenario | first screen update ms | startup complete ms | notes |
| --- | ---: | ---: | --- |
| `startup` | 47.325 | 47.325 | plain `nvim` startup |
| `gitcommit` | 64.477 | 64.478 | generated `COMMIT_EDITMSG` in a temporary git repo |
| `diff` | 62.662 | 62.663 | generated two-file `nvim -d` run |

this snapshot is a single-sample run on generated inputs. treat it as a dated reference point, not a stable statistical baseline.

the default benchmark includes terminal-ui startup cost and is meant to be closer to what you actually feel when opening `nvim`. if you want the older lower-noise internal timing, add `--headless`.

the suite is still best used for repeatable comparisons over time. if a run regresses, follow up manually inside `nvim`:

```bash
XDG_CONFIG_HOME="$(pwd)/.." nvim
```

then inspect plugin timing with:

```vim
:Lazy profile
```

for a quick syntax/config check, use:

```bash
XDG_CONFIG_HOME="$(pwd)/.." nvim --headless -c "quitall"
```
