return {
  -- https://codecompanion.olimorris.dev/installation
  -- Tue 2026-05-19 07:39 CST
  {
    "olimorris/codecompanion.nvim",
    version = "^19.0.0",
    opts = {
      interactions = {
        cli = {
          agent = "codex",
          agents = {
            codex = {
              cmd = "codex",
              args = { "--yolo" },
              description = "codex",
              provider = "terminal",
            },
          },
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
  -- Mon Sep  1 11:20:12 AM CST 2025
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
