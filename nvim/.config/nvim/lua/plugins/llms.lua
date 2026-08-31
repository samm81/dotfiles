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
}
