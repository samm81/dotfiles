return {
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local augroup = vim.api.nvim_create_augroup("NoneLsFormatting", {})

      return {
        sources = {
          null_ls.builtins.diagnostics.trail_space.with({
            disabled_filetypes = { "gitcommit" },
          }),
          null_ls.builtins.diagnostics.todo_comments,

          -- gitcommit
          null_ls.builtins.diagnostics.commitlint.with({
            command = { "commitlint", "--config", vim.fn.expand("~/.config/commitlint/commitlint.config.js") },
          }),

          -- js ecosystem
          formatting.prettier.with({ command = { "npx", "prettier" } }),

          -- lua
          formatting.stylua.with({ command = { "npx", "stylua" } }),

          -- shell
          formatting.shfmt.with({ extra_args = { "--indent", "2", "--case-indent" } }),

          -- python
          diagnostics.mypy,
          diagnostics.pydoclint,

          -- elixir
          formatting.mix.with({ extra_filetypes = { "heex", "eex" } }),
          diagnostics.credo.with({
            command = "credo",
            args = { "suggest", "--format", "json", "--read-from-stdin", "$FILENAME" },
          }),
        },
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      }
    end,
  },
}
