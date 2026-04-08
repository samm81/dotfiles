# AGENTS.md - Neovim Configuration

## Build/Lint/Format Commands

- Format Lua: `stylua .` (uses `.stylua.toml` config with 2-space indents, LuaJIT syntax)
- Check config: `nvim --headless -c "quitall"` (syntax check; run from the environment where this config is active)
- Profile config: `scripts/nvim-profile all --runs 3` (repeatable startup, `gitcommit`, and `diff` timing suite; defaults to terminal-ui startup timing, with `--headless` as an opt-in internal mode, and inherits the current shell environment)
- keep committed scripts on default XDG behavior; any repo-local XDG overrides should come from the caller environment, not from committed code.
- No traditional tests - this is a Neovim configuration
- when debugging reproduce in an interactive `nvim` session, not a single-buffer headless one-liner.
- if headless checks are used, treat them as secondary confirmation only; final behavior validation should come from the interactive multi-buffer flow above.

## Architecture

- **Entry**: `init.lua` - main config with editor options, keymaps, filetypes
- **Package Manager**: `lua/config/lazy.lua` - lazy.nvim plugin management
- **Library**: `lua/lib/sane.lua` - utility functions for sane keymap defaults
- **Profiling**: `lua/lib/profile.lua` - opt-in startup/file-open timing probe enabled by `scripts/nvim-profile`
- **Custom none-ls Sources**: `lua/lib/null_ls/` - local diagnostics/formatting adapters that fill gaps in upstream none-ls builtins
- **Scripts**: `scripts/nvim-profile` - terminal-first profiling runner for standard startup, `gitcommit`, and `diff`
- **Helpers**: `lua/helpers.lua` - formatter overview, format-without-save, and `datet`-backed datetime insertion helpers used by `<leader>dt*`
- **Plugins**: `lua/plugins/` - modular plugin configurations
  - `lsp.lua` - LSP servers (lua_ls, ts_ls, eslint, tailwindcss, emmet, etc.) with `gr*` keymaps and cmp capabilities
  - `none-ls.lua` - filetype-lazy `none-ls` config with imperatively filtered executable/root-gated sources and a buffer-local attach guard (including shell/zsh shfmt + shellcheck wiring and `.edn` formatting via `zprint` when it is on `PATH`) with auto-format on save
  - `cmp.lua` - completion with nvim-cmp + luasnip
  - `luasnip.lua` - snippet engine with custom snippets in `snippets/`
- **Snippets**: `snippets/` - SnipMate format snippets per filetype

## Code Style

- LuaJIT syntax and runtime
- Module pattern: `local M = {}; return M`
- LSP uses `gr*` prefix (grn=rename, gra=action, grr=references, etc.)
- `.edn` buffers use the `clojure` filetype; formatting is scoped to `.edn` paths via `zprint` in none-ls when `zprint` is available on `PATH`
- language server binaries are expected to already exist on `PATH`; this config should not auto-install them at runtime

## User's philosophy

- keep behavior close to built-in vim/neovim defaults; avoid unnecessary plugins or abstractions.
- keep keymaps intentional and mnemonic, with room for growth: prefer two-character `<leader>` namespaces.
- never override existing keybindings; always check conflicts before adding or changing a map.
- prefer non-disruptive migration: when renaming a mapping, use reminder mappings when useful.
- optimize for fast, in-buffer workflows (for example formatting without requiring save).
