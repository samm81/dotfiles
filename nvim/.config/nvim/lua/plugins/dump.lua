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
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "help tags" },
    },
    opts = function()
      return {
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
          ["ui-select"] = require("telescope.themes").get_dropdown({
            winblend = 10,
            previewer = false,
            layout_config = {
              width = 0.45,
              height = 0.4,
            },
          }),
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      telescope.load_extension("ui-select")
    end,
  },

  --'windwp/nvim-ts-autotag',
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = { char = "│" },
    },
  },

  -- whitespace
  {
    "echasnovski/mini.trailspace",
    version = false,
    opts = {},
    init = function()
      -- trim all trailing whitespace on save
      local augroup = vim.api.nvim_create_augroup("MiniTrailspaceFormatting", {})
      vim.api.nvim_create_autocmd("BufWritePre", {
        group = augroup,
        desc = "trim trailing whitespace on save",
        callback = function()
          MiniTrailspace.trim()
        end,
      })
    end,
  },
}
