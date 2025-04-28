local sane = require("lib.sane")

return {
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    config = function()
      local luasnip = require("luasnip")
      luasnip.config.set_config({
        history = true,
        updateevents = "TextChanged,TextChangedI",
      })

      local snippets_load = function()
        -- Load snippets in SnipMate format from ~/.config/nvim/snippets
        require("luasnip.loaders.from_snipmate").lazy_load({
          paths = { vim.fn.stdpath("config") .. "/snippets" },
        })
        -- Also load VSCode-style snippets if present
        require("luasnip.loaders.from_vscode").lazy_load()
      end

      -- Key mappings for snippet expansion and navigation
      sane.keymap({ "i", "s" }, "<Tab>", function()
        luasnip.expand_or_jump()
      end, { desc = "expand or jump in snippet" })
      sane.keymap({ "i", "s" }, "<S-Tab>", function()
        luasnip.jump(-1)
      end, { desc = "jump backward in snippet" })

      -- edit & reload snippet definitions

      sane.keymap("n", "<leader>vsr", function()
        snippets_load()
        print("Snippets reloaded")
      end, { desc = "Reload snippets" })

      snippets_load()
    end,
  },
}
