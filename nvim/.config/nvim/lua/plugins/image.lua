return {
  {
    "3rd/image.nvim",
    build = false,
    opts = {
      backend = "sixel",

      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          floating_windows = false,
        },
      },

      max_width = 100,
      max_height = 30,
    },
  },
}
