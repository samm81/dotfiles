return {
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    opts = {
      default = {
        dir_path = ".",
        file_name = "%Y-%m-%d-%H-%M-%S",
        prompt_for_file_name = false,
      },
    },
    keys = {
      { "<leader>vv", "<cmd>PasteImage<cr>", desc = "paste image from system clipboard" },
    },
  },
}
