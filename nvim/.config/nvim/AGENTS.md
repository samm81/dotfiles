# Neovim Configuration

Personal Neovim configuration built around `lazy.nvim`, fast in-buffer workflows, and behavior that stays close to built-in Neovim defaults.

## Commands

- `stylua .` - format Lua with the repo's `.stylua.toml`
- `scripts/nvim-profile all --runs 3` - benchmark startup plus `gitcommit` and `diff` flows
- `nvim --headless -c "quitall"` - quick syntax smoke check only; not final validation

## Architecture

- `init.lua` - entrypoint for options, keymaps, and filetypes
- `lua/config/lazy.lua` - plugin bootstrap and specs
- `lua/plugins/` - modular plugin config, including `lsp.lua`, `none-ls.lua`, `cmp.lua`, `luasnip.lua`, and `treesitter.lua`
- `lua/lib/` - shared utilities, profiling helpers, and custom `none-ls` sources
- `lua/helpers.lua` - formatting helpers and `<leader>dt*` datetime helpers
- `snippets/` - SnipMate snippets

## Rules

- keep behavior close to built-in vim/neovim defaults; avoid unnecessary plugins or abstractions
- never override existing keybindings; check for conflicts before adding or changing a map
- prefer two-character `<leader>` namespaces, and use reminder mappings when a rename should be non-disruptive
- keep LSP mappings on the `gr*` prefix when adding or adjusting them
- optimize for in-buffer workflows; formatting should not require save
- keep language server binaries on `PATH`; this config should not auto-install them at runtime
- `.edn` buffers use the `clojure` filetype and should format through `zprint` in `none-ls` when available
- keep committed scripts on default XDG behavior; any repo-local XDG overrides should come from the caller environment

## Verification

After making changes:

- reproduce the behavior in an interactive `nvim` session; treat this as the primary validation path
- use a relevant multi-buffer flow when debugging instead of a single-buffer headless one-liner
- `stylua .`
- `nvim --headless -c "quitall"` as a secondary smoke check only
- `scripts/nvim-profile all --runs 3` when changing startup-sensitive config

## Documentation

- keep `AGENTS.md` and `README.md` up to date when behavior or workflows change
