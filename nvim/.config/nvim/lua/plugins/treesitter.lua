return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdateSync",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "bash",
          "css",
          "dockerfile",
          "diff",
          "eex",
          "elixir",
          "graphql",
          "heex",
          "html",
          "javascript",
          "jsdoc",
          "json",
          "jsonnet",
          "lua",
          "make",
          "markdown",
          "markdown_inline",
          "nix",
          "purescript",
          "python",
          "regex",
          "tsx",
          "typescript",
          "vim",
          "yaml",
        },
        sync_install = false,
        highlight = {
          enable = true,
        },
        indent = { enable = true },
      })

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldlevel = 99
    end,
  },
}
