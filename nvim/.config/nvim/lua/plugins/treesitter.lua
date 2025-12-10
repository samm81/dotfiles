return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
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

      -- set up treesitter folding after treesitter is loaded
      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      -- by default, open 99 levels of folds
      vim.opt.foldlevel = 99
    end,
  },
}
