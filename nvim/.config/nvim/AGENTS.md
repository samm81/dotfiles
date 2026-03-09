# AGENTS.md - Neovim Configuration

## Build/Lint/Format Commands

- Format Lua: `stylua .` (uses `.stylua.toml` config with 2-space indents, LuaJIT syntax)
- Check config: `nvim-vibe --headless -c "quitall"` (syntax check)
- No traditional tests - this is a Neovim configuration
- when debugging reproduce in an interactive `nvim-vibe` session, not a single-buffer headless one-liner.
- if headless checks are used, treat them as secondary confirmation only; final behavior validation should come from the interactive multi-buffer flow above.

## Architecture

- **Entry**: `init.lua` - main config with editor options, keymaps, filetypes
- **Package Manager**: `lua/config/lazy.lua` - lazy.nvim plugin management
- **Library**: `lua/lib/sane.lua` - utility functions for sane keymap defaults
- **Plugins**: `lua/plugins/` - modular plugin configurations
  - `lsp.lua` - LSP servers (lua_ls, ts_ls, eslint, tailwindcss, emmet, etc.) with `gr*` keymaps and cmp capabilities
  - `none-ls.lua` - formatters (prettier, stylua, black, mix) with auto-format on save
  - `cmp.lua` - completion with nvim-cmp + luasnip
  - `luasnip.lua` - snippet engine with custom snippets in `snippets/`
- **Snippets**: `snippets/` - SnipMate format snippets per filetype

## Code Style

- LuaJIT syntax and runtime
- Module pattern: `local M = {}; return M`
- LSP uses `gr*` prefix (grn=rename, gra=action, grr=references, etc.)
- language server binaries are expected to already exist on `PATH`; this config should not auto-install them at runtime

## User's philosophy

- keep behavior close to built-in vim/neovim defaults; avoid unnecessary plugins or abstractions.
- keep keymaps intentional and mnemonic, with room for growth: prefer two-character `<leader>` namespaces.
- never override existing keybindings; always check conflicts before adding or changing a map.
- prefer non-disruptive migration: when renaming a mapping, use reminder mappings when useful.
- optimize for fast, in-buffer workflows (for example formatting without requiring save).
