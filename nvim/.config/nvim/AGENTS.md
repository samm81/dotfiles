# AGENTS.md - Neovim Configuration

## Build/Lint/Format Commands

- Format Lua: `stylua .` (uses `.stylua.toml` config with 2-space indents, LuaJIT syntax)
- Check config: `nvim-vibe --headless -c "quitall"` (syntax check)
- No traditional tests - this is a Neovim configuration
- when debugging reproduce in an interactive `nvim-vibe` session, not a single-buffer headless one-liner.
- if headless checks are used, treat them as secondary confirmation only; final behavior validation should come from the interactive multi-buffer flow above.

hello

## Architecture

- **Entry**: `init.lua` - main config with editor options, keymaps, filetypes
- **Package Manager**: `lua/config/lazy.lua` - lazy.nvim plugin management
- **Library**: `lua/lib/sane.lua` - utility functions for sane keymap defaults
- **Plugins**: `lua/plugins/` - modular plugin configurations
  - `lsp.lua` - LSP servers (lua_ls, ts_ls, eslint, etc.) with `gr*` keymaps
  - `none-ls.lua` - formatters (prettier, stylua, black, mix) with auto-format on save
  - `cmp.lua` - completion with nvim-cmp + luasnip
  - `luasnip.lua` - snippet engine with custom snippets in `snippets/`
- **Snippets**: `snippets/` - SnipMate format snippets per filetype

## Code Style

- LuaJIT syntax and runtime
- Module pattern: `local M = {}; return M`
- LSP uses `gr*` prefix (grn=rename, gra=action, grr=references, etc.)

## User's preferences

The user prefers a minimal `vim` experience, changing the built in defaults and tools as little as possible (for example, preferring `netrw` over adding a file manager with a plugin, or using built in shortcuts rather than adding new ones, and never repurposing already existing shortcuts). The user's writing style is lowercase (except for "I" and "I'm"), so comments should begin with lowercase characters instead of uppercase ones.
for `<leader>` mappings, prefer two-character commands (for example `<leader>ff`, `<leader>fs`) to leave room for future specificity.
never override existing keybindings.
before adding or changing a keymap, check for conflicts and pick a non-conflicting mapping.
