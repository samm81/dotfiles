return {
  -- https://codecompanion.olimorris.dev/installation.html#installation-1
  -- Mon Sep  1 11:20:12 AM CST 2025
  {
    "olimorris/codecompanion.nvim",
    opts = {
      env = {
        url = "https://openrouter.ai/api",
        api_key = 'cmd:echo -n "$(cat /home/maynard/.config/api-keys/openrouter-api-key.txt)"',
        chat_url = "/v1/chat/completions",
      },
      strategies = {
        chat = {
          adapter = "openai",
          model = "gpt-5-codex",
        },
        inline = {
          adapter = "openai",
          model = "gpt-5-codex",
        },
        cmd = {
          adapter = "openai",
          model = "gpt-5-codex",
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
  -- for codecompanion
  -- https://codecompanion.olimorris.dev/installation.html#mini-diff
  {
    "echasnovski/mini.diff",
    config = function()
      local diff = require("mini.diff")
      diff.setup({
        -- Disabled by default
        source = diff.gen_source.none(),
      })
    end,
  },
}
