# Neovim config

**a focused setup for fast editing, formatting, and everyday terminal work**

use it as a drop-in Neovim configuration from a stow-managed dotfiles repository.

## Install

clone the dotfiles repository and link the Neovim package with GNU Stow:

```bash
git clone https://github.com/samm81/dotfiles.git ~/.dotfiles && cd ~/.dotfiles && stow nvim
```

## Quickstart

open Neovim from any project:

```bash
nvim
```

`lazy.nvim` bootstraps the plugin set on first launch.

## Keyboard shortcuts

- **`<leader>ve`:** find and open a file from the Neovim configuration.
- **`<leader>cc`:** copy the whole buffer or exact visual selection to the system clipboard.
- **`<leader>gf` / `:Format`:** format the current buffer without saving.
- **`<leader>de`:** use `<leader>de` to open diagnostics.
- **`[d` and `]d`:** move through diagnostic locations.
- **`[e` and `]e`:** move through error diagnostics only.
- **`<leader>dtt` / `<leader>dtG`:** insert the current datetime below the cursor or at the top of the buffer.
- **LSP navigation:** use `grn` for rename, `gra` for code actions, `grr` for references, `gri` for implementations, `gO` for document symbols, `grd` for definitions, `grD` for declarations, and `grt` for type definitions.
- **LSP help:** use `<C-S>` for signature help.

## Formatting and language support

- **LSP:** configure `lua_ls`, `pyright`, `ruff`, `ts_ls`, `gopls`, `bashls`, `elixirls`, `jsonls`, `yamlls`, `graphql`, `tailwindcss`, and `emmet_language_server`.
- **formatting:** load `none-ls` only for supported filetypes and check executable and project-root conditions before running external tools.
- **edn:** use the `clojure` filetype and `zprint` when `zprint` is available on `PATH`.

## Startup profiling

measure terminal-ui startup:

```bash
~/.dotfiles/nvim/.config/nvim/scripts/nvim-profile startup --runs 10 --warmup 2
```

use `--headless` for lower-level timing. results go to `${XDG_STATE_HOME:-$HOME/.local/state}/nvim/profile/<timestamp>`.

## Requirements

- **Neovim:** 0.11 or newer.
- **GNU Stow:** link the configuration into `~/.config/nvim`.
- **external tools:** keep language servers and formatters on `PATH`; install `wl-copy` for clipboard support and `zprint` for `.edn` formatting.
