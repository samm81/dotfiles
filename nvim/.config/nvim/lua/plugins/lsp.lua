local sane = require("lib.sane")

local path_vim_meta = vim.env.VIMRUNTIME .. "/lua/vim/_meta"
local library_lua_ls = {
  path_vim_meta .. "/api.gen.lua",
  path_vim_meta .. "/builtin.lua",
  path_vim_meta .. "/builtin_types.lua",
  path_vim_meta .. "/options.gen.lua",
  path_vim_meta .. "/vimfn.gen.lua",
  path_vim_meta .. "/vvars.gen.lua",
}

local filetypes_tailwind = {
  "astro",
  "astro-markdown",
  "css",
  "eex",
  "eelixir",
  "ejs",
  "erb",
  "eruby",
  "handlebars",
  "hbs",
  "heex",
  "html",
  "html-eex",
  "htmlangular",
  "htmldjango",
  "javascript",
  "javascriptreact",
  "mdx",
  "postcss",
  "sass",
  "scss",
  "svelte",
  "templ",
  "typescript",
  "typescriptreact",
  "vue",
}

-- https://github.com/LazyVim/LazyVim/blob/ec5981dfb1222c3bf246d9bcaa713d5cfa486fbd/lua/lazyvim/plugins/lsp/init.lua
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "b0o/schemastore.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    opts = function()
      local ret = {
        servers = {
          eslint = {},
          emmet_language_server = {
            cmd = { "emmet-language-server", "--stdio" },
            filetypes = {
              "astro",
              "css",
              "eelixir",
              "eruby",
              "heex",
              "html",
              "htmlangular",
              "htmldjango",
              "javascriptreact",
              "less",
              "sass",
              "scss",
              "svelte",
              "typescriptreact",
              "vue",
            },
            init_options = {
              includeLanguages = {
                eelixir = "html",
                heex = "html",
              },
            },
          },
          graphql = {},
          ts_ls = {},
          pyright = {},
          purescriptls = {},
          gopls = {},
          ruff = {
            init_options = {
              settings = {
                configurationPreference = "filesystemFirst",
                -- E = pycodestyle
                -- F = pyflakes
                -- I = isort
                -- B = bugbear
                -- UP = pyupgrade
                -- N = naming
                -- SIM = simplify
                -- C4 = comprehensions
                -- PERF = performance
                -- PL = pylint
                -- RUF = ruff's own extra rules
                -- ERA = eradicate
                -- FAST = fastapi
                -- A = flake8-builtins
                lint = {
                  select = { "E", "F", "I", "B", "UP", "N", "SIM", "C4", "PERF", "PL", "RUF", "ERA", "FAST", "A" },
                },
              },
            },
            on_attach = function(client, bufnr)
              -- Create a local formatting function
              local function ruff_format()
                vim.lsp.buf.code_action({
                  context = { only = { "source.organizeImports.ruff" } },
                  apply = true,
                })
                vim.lsp.buf.format({ async = false })
              end

              -- Autoformat on save
              vim.api.nvim_create_autocmd("BufWritePre", {
                buffer = bufnr,
                callback = ruff_format,
              })
            end,
          },
          bashls = {
            filetypes = { "sh", "bash", "zsh" },
          },
          elixirls = {
            cmd = { "elixir-ls" },
            exit_timeout = 1000,
            filetypes = { "elixir", "eelixir", "heex", "surface" },
            workspace_required = true,
          },
          tailwindcss = {
            cmd = { "tailwindcss-language-server", "--stdio" },
            filetypes = filetypes_tailwind,
            init_options = {
              userlanguages = {
                elixir = "html-eex",
                eelixir = "html-eex",
                heex = "html-eex",
              },
            },
            workspace_required = true,
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
          lua_ls = {
            -- ---@type LazyKeysSpec[]
            -- keys = {},
            settings = {
              -- https://github.com/neovim/nvim-lspconfig/blob/8b0f47d851ee5343d38fe194a06ad16b9b9bd086/doc/configs.md#lua_ls
              Lua = {
                runtime = { version = "LuaJIT" },
                workspace = {
                  checkThirdParty = false,
                  -- Avoid indexing the entire Neovim runtime implementation.
                  library = library_lua_ls,
                },
              },
            },
          },
        },
      }
      return ret
    end,
    config = function(_, opts)
      local servers = opts.servers
      local cmp_nvim_lsp = require("cmp_nvim_lsp")
      local capabilities = vim.tbl_deep_extend(
        "force",
        {},
        vim.lsp.protocol.make_client_capabilities(),
        cmp_nvim_lsp.default_capabilities()
      )

      local on_attach = function(_, bufnr)
        local keymap = function(mode, lhs, rhs)
          sane.keymap(mode, lhs, rhs, { buffer = bufnr })
        end
        local keymap_remapped = function(mode, old, new)
          keymap(mode, old, function()
            vim.notify("use " .. new .. " instead", vim.log.levels.INFO)
          end)
        end

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

      for server, server_options in pairs(servers) do
        vim.lsp.config(
          server,
          vim.tbl_deep_extend("force", {
            capabilities = vim.deepcopy(capabilities),
            on_attach = on_attach,
          }, server_options)
        )
        vim.lsp.enable(server)
      end
    end,
  },

  {
    "j-hui/fidget.nvim",
    opts = {},
  },
}
