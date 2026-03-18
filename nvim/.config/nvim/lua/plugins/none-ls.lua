return {
  {
    "nvimtools/none-ls.nvim",
    event = { "BufReadPre", "BufNewFile", "BufEnter" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local shellcheck = require("lib.null_ls.shellcheck")
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local augroup = vim.api.nvim_create_augroup("NoneLsFormatting", {})

      return {
        sources = {
          diagnostics.trail_space.with({
            disabled_filetypes = { "gitcommit" },
          }),
          diagnostics.todo_comments,

          -- gitcommit
          diagnostics.commitlint.with({
            command = "commitlint",
            args = { "--config", vim.fn.expand("~/.config/commitlint/commitlint.config.js") },
          }),

          -- js ecosystem
          formatting.prettier,

          -- lua
          formatting.stylua,

          -- shell
          formatting.shfmt.with({
            extra_args = { "--indent", "2", "--case-indent" },
            extra_filetypes = { "bash", "zsh" },
          }),
          diagnostics.zsh,
          shellcheck,

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
