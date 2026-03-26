# zsh

## startup layout

- `.zshrc.d/` holds the interactive zsh snippets that get sourced by `shellrc/.zshrc`
- `.config/zsh/autocompletions.d/` holds completion registry entries for `zrefresh-completions`
- `.config/zsh/profiling/pre-autocompletion-cache/` holds the legacy inline-completion snippets used only for benchmarking
- `.local/bin/zrefresh-completions` refreshes cached completion files into the xdg `site-functions` dir
- `.local/bin/zsh-profile-startup` benchmarks the old inline-completion path against the cached-completion path

## profiling

for a quick startup benchmark from an interactive shell:

```zsh
zsh_profile_startup --runs 7
```

for a table plus the slowest sourced files:

```zsh
zsh_profile_startup --runs 7 --detail --markdown
```

the benchmark runs `zsh -dfi`, sources the repo's `shellrc.d/.rc.d/*.sh` and `zsh/.zshrc.d/*.zsh` files directly, and keeps `HOME` intact so oh-my-zsh and the installed tools behave like real startup. it uses temp `ZDOTDIR` and temp xdg dirs so it does not reuse or rewrite the normal zsh cache during the run. the `post-autocompletion-cache` variant prewarms the xdg completion cache with `zrefresh-completions`; the `pre-autocompletion-cache` variant sources the preserved legacy inline-completion snippets under `.config/zsh/profiling/pre-autocompletion-cache/`.

## measured results

measured on 2026-03-26 on this machine with `gh`, `uv`, `codex`, `pipx`, and `atuin` installed and `bw` absent:

| variant | median total (ms) | min (ms) | max (ms) |
| --- | ---: | ---: | ---: |
| pre-autocompletion-cache | 320.551 | 313.548 | 468.252 |
| post-autocompletion-cache | 101.250 | 94.520 | 270.755 |

that puts the median startup reduction at `219.301 ms`, or about `68.4%`.

the biggest change is exactly where expected: the old inline completion generators for `gh`, `codex`, `uv`, `pipx`, and `atuin` disappear from the startup hot path. in the cached path, the completion-specific cost drops to the `00-autocompletions-path.zsh`/`98-autocompletions-check.zsh` snippets plus normal `atuin init zsh`, and the due-check remains cheap in the steady state.
