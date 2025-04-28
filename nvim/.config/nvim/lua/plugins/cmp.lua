return {
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      -- Completion sources
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      -- Snippet engine
      "L3MON4D3/LuaSnip",
    },
    -- Main nvim-cmp setup via opts (lazy.nvim will call setup(opts))
    opts = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      return {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        -- emulate `omnifunc` as much as possible
        mapping = cmp.mapping.preset.insert({
          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.config.disable,
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
        }, {
          { name = "buffer" },
        }),
      }
    end,
    config = function(_, opts)
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      local cmp = require("cmp")
      cmp.setup(opts)

      -- `/` uses buffer source
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      -- `:` uses path and cmdline sources
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },
}
