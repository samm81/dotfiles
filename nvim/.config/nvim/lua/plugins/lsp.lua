local sane = require("lib.sane")

-- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/lsp/init.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    dependencies = {
      "b0o/schemastore.nvim",
    },
    opts = function()
      ---@class PluginLspOpts
      local ret = {
        ---@type lspconfig.options
        servers = {
          eslint = {},
          graphql = {},
          ts_ls = {},
          pyright = {},
          purescriptls = {},
          gopls = {},
          ruff = {},
          bashls = {
            filetypes = { "sh", "bash", "zsh" },
          },
          elixirls = {
            cmd = { "/home/maynard/bin/elixir-ls" },
          },
          tailwindcss = {
            cmd = { "npx", "tailwindcss-language-server", "--stdio" },
            init_options = {
              userlanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
              },
            },
          },
          jsonls = {
            settings = {
              json = {
                schemas = require("schemastore").json.schemas(),
                validate = { enable = true },
              },
            },
          },
          yamlls = {
            settings = {
              yaml = {
                schemastore = {
                  -- you must disable built-in schemastore support if you want to use
                  -- this plugin and its advanced options like `ignore`.
                  enable = false,
                  -- avoid typeerror: cannot read properties of undefined (reading 'length')
                  url = "",
                },
                schemas = require("schemastore").yaml.schemas(),
              },
            },
          },
          html = {
            filetypes = { "html", "eelixir", "heex" },
          },
          lua_ls = {
            -- ---@type LazyKeysSpec[]
            -- keys = {},
            settings = {
              -- https://github.com/neovim/nvim-lspconfig/blob/8b0f47d851ee5343d38fe194a06ad16b9b9bd086/doc/configs.md#lua_ls
              Lua = {
                runtime = { version = "LuaJIT" },
                workspace = {
                  checkThirdParty = false,
                  library = { vim.env.VIMRUNTIME },
                },
              },
            },
          },
        },
        -- you can do any additional lsp server setup here
        -- return true if you don't want this server to be setup with lspconfig
        ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
        setup = {
          -- example to setup with typescript.nvim
          -- tsserver = function(_, opts)
          --   require("typescript").setup({ server = opts })
          --   return true
          -- end,
          -- Specify * to use this function as a fallback for any server
          -- ["*"] = function(server, opts) end,
        },
      }
      return ret
    end,
    ---@param opts PluginLspOpts
    config = function(_, opts)
      local servers = opts.servers
      local capabilities =
          vim.tbl_deep_extend("force", {}, vim.lsp.protocol.make_client_capabilities(), opts.capabilities or {})

      local on_attach = function(_, bufnr)
        local keymap = function(mode, lhs, rhs)
          sane.keymap(mode, lhs, rhs, { buffer = bufnr })
        end
        local keymap_remapped = function(mode, old, new)
          keymap(mode, old, function()
            vim.notify("use " .. new .. " instead", vim.log.levels.INFO)
          end)
        end

        -- lsp defaults
        -- `:help lsp-defaults`
        -- > - 'omnifunc' is set to |vim.lsp.omnifunc()|, use |i_CTRL-X_CTRL-O| to trigger completion.
        -- > - 'tagfunc' is set to |vim.lsp.tagfunc()|. This enables features like go-to-definition, |:tjump|, and keymaps like |CTRL-]|, |CTRL-W_]|, |CTRL-W_}| to utilize the language server.
        -- > - 'formatexpr' is set to |vim.lsp.formatexpr()|, so you can format lines via |gq| if the language server supports it.
        -- > - |K| is mapped to |vim.lsp.buf.hover()| unless |'keywordprg'| is customized or a custom keymap for `K` exists.

        -- starting in `nvim` 11:
        -- > These GLOBAL keymaps are created unconditionally when Nvim starts:
        -- > - "grn" is mapped in Normal mode to |vim.lsp.buf.rename()|
        -- > - "gra" is mapped in Normal and Visual mode to |vim.lsp.buf.code_action()|
        -- > - "grr" is mapped in Normal mode to |vim.lsp.buf.references()|
        -- > - "gri" is mapped in Normal mode to |vim.lsp.buf.implementation()|
        -- > - "gO" is mapped in Normal mode to |vim.lsp.buf.document_symbol()|
        -- > - CTRL-S is mapped in Insert mode to |vim.lsp.buf.signature_help()|

        keymap("n", "grn", vim.lsp.buf.rename)
        keymap({ "n", "v" }, "gra", vim.lsp.buf.code_action)
        keymap("n", "grr", vim.lsp.buf.references)
        keymap("n", "gri", vim.lsp.buf.implementation)
        keymap("n", "gO", vim.lsp.buf.document_symbol)
        keymap("n", "CTRL-S", vim.lsp.buf.signature_help)

        keymap_remapped("n", "<leader>rn", "grn")
        keymap_remapped({ "n", "v" }, "<leader>ca", "gra")
        keymap_remapped("n", "<leader>gr", "grr")
        keymap_remapped("n", "<leader>gi", "gri")

        -- some custom ones to match the new style

        keymap("n", "grd", vim.lsp.buf.definition)
        keymap("n", "grD", vim.lsp.buf.declaration)
        keymap("n", "grt", vim.lsp.buf.type_definition)

        keymap_remapped("n", "gd", "grd")
        keymap_remapped("n", "gD", "grD")
        keymap_remapped("n", "<leader>D", "grt")
      end

      vim.diagnostic.config({
        virtual_text = { source = true },
        float = { source = true },
      })

      local function setup(server)
        local server_opts = vim.tbl_deep_extend("force", {
          capabilities = vim.deepcopy(capabilities),
          on_attach = on_attach,
        }, servers[server] or {})
        if server_opts.enabled == false then
          return
        end

        -- optional `setup` function gets called first
        -- if it returns `true`, or if the fallback (`['*']`) returns `true`
        -- then return early and skip `.setup()`
        if opts.setup[server] then
          if opts.setup[server](server, server_opts) then
            return
          end
        elseif opts.setup["*"] then
          if opts.setup["*"](server, server_opts) then
            return
          end
        end

        require("lspconfig")[server].setup(server_opts)
      end

      for server, _server_opts in pairs(servers) do
        setup(server)
      end
    end,
  },
}
