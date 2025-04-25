return {
  -- vim first
  'tpope/vim-obsession',
  'embear/vim-localvimrc',
  'tpope/vim-surround',

  -- neovim after
  {
    'EdenEast/nightfox.nvim',
      init = function ()
        vim.cmd('colorscheme nightfox')
      end,
  },

  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<CR>', { desc = 'find files', noremap = true, silent = true }},
      { '<leader>fg', '<cmd>Telescope live_grep<CR>', { desc = 'live grep', noremap = true, silent = true }},
      { '<leader>fb', '<cmd>Telescope buffers<CR>', { desc = 'buffers', noremap = true, silent = true }},
      { '<leader>fh', '<cmd>Telescope help_tags<CR>', { desc = 'help tags', noremap = true, silent = true }},
    },
    defaults = {
      mappings = {
        i = {
          -- map actions.which_key to <C-h> (default: <C-/>)
          -- actions.which_key shows the mappings for your picker,
          -- e.g. git_{create, delete, ...}_branch for the git_branches picker
          -- ["<C-h>"] = "which_key"
        }
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
      }
    },
    extensions = {
      -- Your extension configuration goes here:
      -- extension_name = {
      --   extension_config_key = value,
      -- }
      -- please take a look at the readme of the extension you want to configure
    }
  },

  -- 'nvimtools/none-ls.nvim'

  {
    'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function ()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
              "python", "json", "typescript", "jsdoc", "bash", "make", "css", "regex",
              "vim", "yaml", "nix", "tsx", "javascript", "elixir", "eex", "heex",
              "dockerfile", "html", "graphql", "lua"
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
  --'lukas-reineke/indent-blankline.nvim',

  -- whitespace
  { 'echasnovski/mini.trailspace',
      version = false,
      opts = {},
      init = function ()
        -- Trim all trailing whitespace on save
        vim.api.nvim_create_autocmd('BufWritePre', {
          callback = function()
            MiniTrailspace.trim()
          end,
        })
      end
  },

  {
    'jackMort/ChatGPT.nvim',
      opts = {
        -- api_host_cmd = "echo -n 'localhost:41410'",
        api_key_cmd = "cat " .. vim.fn.expand("$HOME") .. "/.local/share/openai-api-key.txt",
        -- https://github.com/jackMort/ChatGPT.nvim/blob/5b6d296eefc75331e2ff9f0adcffbd7d27862dd6/README.md#example-configuration
        openai_params = {
          -- NOTE: model can be a function returning the model name
          -- this is useful if you want to change the model on the fly
          -- using commands
          -- Example:
          -- model = function()
          --     if some_condition() then
          --         return "gpt-4-1106-preview"
          --     else
          --         return "gpt-3.5-turbo"
          --     end
          -- end,
          model = "o4-mini-2025-04-16",
          -- frequency_penalty = 0,
          -- presence_penalty = 0,
          -- max_tokens = 4095,
          -- temperature = 0.2,
          -- top_p = 0.1,
          -- n = 1,
        }
      },
      event = 'VeryLazy',
      dependencies = {
        'MunifTanjim/nui.nvim',
        'nvim-lua/plenary.nvim',
        'folke/trouble.nvim', -- optional
        'nvim-telescope/telescope.nvim'
      },
    keys = {
      --c = { "<cmd>ChatGPT<CR>", "ChatGPT" },
      --e = { "<cmd>ChatGPTEditWithInstruction<CR>", "Edit with instruction", mode = { "n", "v" } },
      --g = { "<cmd>ChatGPTRun grammar_correction<CR>", "Grammar Correction", mode = { "n", "v" } },
      --t = { "<cmd>ChatGPTRun translate<CR>", "Translate", mode = { "n", "v" } },
      --k = { "<cmd>ChatGPTRun keywords<CR>", "Keywords", mode = { "n", "v" } },
      --d = { "<cmd>ChatGPTRun docstring<CR>", "Docstring", mode = { "n", "v" } },
      --a = { "<cmd>ChatGPTRun add_tests<CR>", "Add Tests", mode = { "n", "v" } },
      --o = { "<cmd>ChatGPTRun optimize_code<CR>", "Optimize Code", mode = { "n", "v" } },
      --s = { "<cmd>ChatGPTRun summarize<CR>", "Summarize", mode = { "n", "v" } },
      --f = { "<cmd>ChatGPTRun fix_bugs<CR>", "Fix Bugs", mode = { "n", "v" } },
      --x = { "<cmd>ChatGPTRun explain_code<CR>", "Explain Code", mode = { "n", "v" } },
      --r = { "<cmd>ChatGPTRun roxygen_edit<CR>", "Roxygen Edit", mode = { "n", "v" } },
      --l = { "<cmd>ChatGPTRun code_readability_analysis<CR>", "Code Readability Analysis", mode = { "n", "v" } },
    },
  },

  --'milanglacier/minuet-ai.nvim',
}
