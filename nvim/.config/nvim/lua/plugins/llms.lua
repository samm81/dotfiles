return {
  -- for chatting with @@openai models using `:ChatGpt*`
  {
    "jackMort/ChatGPT.nvim",
    opts = {
      -- api_host_cmd = "echo -n 'localhost:41410'",
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
        model = "gpt-4o-mini",
        -- frequency_penalty = 0,
        -- presence_penalty = 0,
        -- max_completion_tokens = 4095,
        -- temperature = 0.2,
        -- top_p = 0.1,
        -- n = 1,
      },
    },
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "folke/trouble.nvim", -- optional
      "nvim-telescope/telescope.nvim",
    },
    config = function(_, opts)
      require("chatgpt").setup(opts)
      require("chatgpt.config").options.openai_params.max_tokens = nil
      require("chatgpt.config").options.openai_params.temperature = nil
    end,
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

  -- @@cursor for nvim
  {
    "yetone/avante.nvim",
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = function()
      -- conditionally use the correct build system for the current OS
      if vim.fn.has("win32") == 1 then
        return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
      else
        return "make"
      end
    end,
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    --@module 'avante'
    --@type avante.Config
    opts = {
      ---- add any opts here
      ---- for example
      provider = "openai",
      providers = {
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o-mini",
          timeout = 30000, -- millis
          --extra_request_body = {
          --  temperature = 0.75,
          --  max_tokens = 20480,
          --},
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      --"echasnovski/mini.pick",         -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
      --"ibhagwan/fzf-lua",              -- for file_selector provider fzf
      --"stevearc/dressing.nvim",        -- for input provider dressing
      --"folke/snacks.nvim",             -- for input provider snacks
      --"nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
      --"zbirenbaum/copilot.lua",        -- for providers='copilot'
      --{
      --  -- support for image pasting
      --  "HakonHarnes/img-clip.nvim",
      --  event = "VeryLazy",
      --  opts = {
      --    -- recommended settings
      --    default = {
      --      embed_image_as_base64 = false,
      --      prompt_for_file_name = false,
      --      drag_and_drop = {
      --        insert_mode = true,
      --      },
      --      -- required for Windows users
      --      use_absolute_path = true,
      --    },
      --  },
      --},
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },

  -- for doing code completion with a generic model
  {
    "milanglacier/minuet-ai.nvim",
    enabled = false,
    opts = {
      provider = "openai",
      virtualtext = {
        auto_trigger_ft = { "*" },
        keymap = {
          -- accept whole completion
          accept = "<C-\\>",
          -- accept one line
          --accept_line = '<A-a>',
          -- accept n lines (prompts for number)
          -- e.g. "A-z 2 CR" will accept 2 lines
          --accept_n_lines = '<A-z>',
          -- Cycle to prev completion item, or manually invoke completion
          prev = "<A-[>",
          -- Cycle to next completion item, or manually invoke completion
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },
      --provider_options = {
      --  openai = {
      --    model = 'gpt-4.1-mini',
      --    system = "see [Prompt] section for the default value",
      --    few_shots = "see [Prompt] section for the default value",
      --    chat_input = "See [Prompt Section for default value]",
      --    stream = true,
      --    api_key = 'OPENAI_API_KEY',
      --    optional = {
      --      -- pass any additional parameters you want to send to OpenAI request,
      --      -- e.g.
      --      -- stop = { 'end' },
      --      -- max_tokens = 256,
      --      -- top_p = 0.9,
      --    },
      --  },
      --}
    },
  },
}
