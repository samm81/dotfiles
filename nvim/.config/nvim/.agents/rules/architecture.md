# architecture

- `init.lua` is the entrypoint for options, keymaps, and filetypes.
- `lua/config/lazy.lua` bootstraps `lazy.nvim` and declares plugin specs.
- `lua/plugins/` contains modular plugin configuration, including `lsp.lua`, `none-ls.lua`, `cmp.lua`, `luasnip.lua`, and `treesitter.lua`.
- `lua/lib/` contains shared utilities, profiling helpers, and custom `none-ls` sources.
- `lua/helpers.lua` contains formatting helpers and `<leader>dt*` datetime helpers.
- `snippets/` contains SnipMate snippets.
