return {
  {
    "neovim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "neovim-treesitter/treesitter-parser-registry",
    },
    config = function()
      local treesitter = require("nvim-treesitter")
      local languages = {
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
      }

      treesitter.setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
      treesitter.install(languages)

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })

      vim.opt.foldmethod = "expr"
      vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.opt.foldlevel = 99
    end,
  },
}
