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
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>",  desc = "live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>",    desc = "buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>",  desc = "help tags" },
    },
    opts = {
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
      -- Trim all trailing whitespace on save
      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function()
          MiniTrailspace.trim()
        end,
      })
    end,
  },
}
