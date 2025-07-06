return {
  -- vim first
  "tpope/vim-obsession",
  "embear/vim-localvimrc",
  "tpope/vim-surround",

  -- neovim after
  {
    "EdenEast/nightfox.nvim",
    init = function()
      vim.cmd("colorscheme nightfox")
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "find files", noremap = true, silent = true } },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "live grep", noremap = true, silent = true } },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "buffers", noremap = true, silent = true } },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "help tags", noremap = true, silent = true } },
    },
    defaults = {
      mappings = {
        i = {
          -- map actions.which_key to <C-h> (default: <C-/>)
          -- actions.which_key shows the mappings for your picker,
          -- e.g. git_{create, delete, ...}_branch for the git_branches picker
          -- ["<C-h>"] = "which_key"
        },
      },
      path_display = { "smart" },
    },
    pickers = {
      -- Default configuration for builtin pickers goes here:
      -- picker_name = {
      --   picker_config_key = value,
      --   ...
      -- }
      -- Now the picker_config_key will be applied every time you call this
      -- builtin picker
      live_grep = {
        glob_pattern = "!package-lock.json",
      },
    },
    extensions = {
      -- Your extension configuration goes here:
      -- extension_name = {
      --   extension_config_key = value,
      -- }
      -- please take a look at the readme of the extension you want to configure
    },
  },

  -- 'nvimtools/none-ls.nvim'

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = {
          "python",
          "json",
          "typescript",
          "jsdoc",
          "bash",
          "make",
          "css",
          "regex",
          "vim",
          "yaml",
          "nix",
          "tsx",
          "javascript",
          "elixir",
          "eex",
          "heex",
          "dockerfile",
          "html",
          "graphql",
          "lua",
        },
        sync_install = false,
        highlight = {
          enable = true,
          -- setting this to true will run `:h syntax` and tree-sitter at the same time.
          -- set this to `true` if you depend on 'syntax' being enabled (like for indentation).
          -- using this option may slow down your editor, and you may see some duplicate highlights.
          -- instead of true it can also be a list of languages
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
      })
    end,
  },

  --'windwp/nvim-ts-autotag',
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      char = "│",
      show_trailing_blankline_indent = false,
    },
  },

  -- whitespace
  {
    "echasnovski/mini.trailspace",
    version = false,
    opts = {},
    init = function()
      -- Trim all trailing whitespace on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
          MiniTrailspace.trim()
        end,
      })
    end,
  },
}
