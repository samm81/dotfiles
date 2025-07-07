return {
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local none_ls = require("null-ls")
      local formatting = none_ls.builtins.formatting
      local diagnostics = none_ls.builtins.diagnostics
      local augroup = vim.api.nvim_create_augroup("NoneLsFormatting", {})

      return {
        sources = {
          formatting.prettier.with({ command = { "npx", "prettier" } }),

          -- python
          formatting.black,
          formatting.isort,

          formatting.stylua.with({ command = { "npx", "stylua" } }),

          formatting.shfmt.with({ extra_args = { "--indent", "2", "--case-indent" } }),

          -- elixir
          formatting.mix.with({ extra_filetypes = { "heex", "eex" } }),
          diagnostics.credo.with({
            command = "credo",
            args = { "suggest", "--format", "json", "--read-from-stdin", "$FILENAME" },
            extra_filetypes = { "heex", "eex" },
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
