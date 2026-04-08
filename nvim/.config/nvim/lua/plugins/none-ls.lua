local none_ls_filetypes = {
  "astro",
  "bash",
  "clojure",
  "css",
  "eex",
  "elixir",
  "gitcommit",
  "graphql",
  "handlebars",
  "heex",
  "html",
  "htmlangular",
  "javascript",
  "javascriptreact",
  "json",
  "jsonc",
  "less",
  "lua",
  "markdown",
  "markdown.mdx",
  "python",
  "scss",
  "sh",
  "svelte",
  "typescript",
  "typescriptreact",
  "vue",
  "yaml",
  "zsh",
}

return {
  {
    "nvimtools/none-ls.nvim",
    ft = none_ls_filetypes,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = function()
      local shellcheck = require("lib.null_ls.shellcheck")
      local null_ls = require("null-ls")
      local none_ls_sources = require("null-ls.sources")
      local null_ls_utils = require("null-ls.utils")
      local formatting = null_ls.builtins.formatting
      local diagnostics = null_ls.builtins.diagnostics
      local augroup = vim.api.nvim_create_augroup("NoneLsFormatting", {})
      local git_root = null_ls_utils.root_pattern(".git")
      local mix_root = null_ls_utils.root_pattern("mix.exs")
      local prettier_root = null_ls_utils.cosmiconfig("prettier")
      local python_root = null_ls_utils.root_pattern("pyproject.toml", "mypy.ini", ".mypy.ini", "setup.cfg", "setup.py")
      local stylua_root = null_ls_utils.root_pattern("stylua.toml", ".stylua.toml")

      local function executable(cmd)
        return vim.fn.executable(cmd) == 1
      end

      local function get_bufname(params)
        return params and params.bufname or vim.api.nvim_buf_get_name(0)
      end

      local function has_root(resolver, params)
        local bufname = get_bufname(params)
        return bufname ~= "" and resolver(bufname) ~= nil
      end

      local function find_local_bin(bufname, bin_name)
        if bufname == "" then
          return nil
        end

        local search_root = git_root(bufname)
        local start_dir = vim.fn.fnamemodify(bufname, ":p:h")

        for dir in null_ls_utils.path.ancestors(start_dir) do
          local candidate = null_ls_utils.path.join(dir, "node_modules", ".bin", bin_name)
          if null_ls_utils.is_executable(candidate) then
            return candidate
          end
          if search_root and dir == search_root then
            break
          end
        end
      end

      local function resolve_prettier_command(params)
        local bufname = get_bufname(params)
        if bufname == "" or prettier_root(bufname) == nil then
          return nil
        end

        return find_local_bin(bufname, "prettier") or (executable("prettier") and "prettier" or nil)
      end

      local function add_source(sources, source)
        table.insert(sources, source)
      end

      local function source_runs_for_buffer(source, bufnr)
        local runtime_condition = source.generator and source.generator.opts and source.generator.opts.runtime_condition
        if not runtime_condition then
          return true
        end

        local params = {
          bufnr = bufnr,
          bufname = vim.api.nvim_buf_get_name(bufnr),
        }
        local ok, result = pcall(runtime_condition, params)
        return not not (not ok or result)
      end

      local sources = {
        diagnostics.trail_space.with({
          disabled_filetypes = { "gitcommit" },
        }),
        diagnostics.todo_comments,
      }

      if executable("commitlint") then
        add_source(
          sources,
          diagnostics.commitlint.with({
            extra_args = { "--config", vim.fn.expand("~/.config/commitlint/commitlint.config.js") },
          })
        )
      end

      add_source(
        sources,
        formatting.prettier.with({
          runtime_condition = function(params)
            return resolve_prettier_command(params) ~= nil
          end,
          cwd = function(params)
            local bufname = get_bufname(params)
            return bufname ~= "" and prettier_root(bufname) or nil
          end,
          dynamic_command = function(params, done)
            done(resolve_prettier_command(params))
          end,
        })
      )

      if executable("stylua") then
        add_source(
          sources,
          formatting.stylua.with({
            runtime_condition = function(params)
              return has_root(stylua_root, params)
            end,
          })
        )
      end

      if executable("zprint") then
        add_source(
          sources,
          formatting.zprint.with({
            runtime_condition = function(params)
              return get_bufname(params):lower():match("%.edn$") ~= nil
            end,
          })
        )
      end

      if executable("shfmt") then
        add_source(
          sources,
          formatting.shfmt.with({
            extra_filetypes = { "bash", "zsh" },
          })
        )
      end

      if executable("zsh") then
        add_source(sources, diagnostics.zsh)
      end

      if executable("shellcheck") then
        add_source(sources, shellcheck)
      end

      if executable("mypy") then
        add_source(
          sources,
          diagnostics.mypy.with({
            runtime_condition = function(params)
              return has_root(python_root, params)
            end,
          })
        )
      end

      if executable("pydoclint") then
        add_source(
          sources,
          diagnostics.pydoclint.with({
            runtime_condition = function(params)
              return has_root(python_root, params)
            end,
          })
        )
      end

      if executable("mix") then
        add_source(
          sources,
          formatting.mix.with({
            extra_filetypes = { "heex", "eex" },
            runtime_condition = function(params)
              return has_root(mix_root, params)
            end,
          })
        )
      end

      if executable("credo") then
        add_source(
          sources,
          diagnostics.credo.with({
            command = "credo",
            args = { "suggest", "--format", "json", "--read-from-stdin", "$FILENAME" },
            runtime_condition = function(params)
              return has_root(mix_root, params)
            end,
          })
        )
      end

      return {
        sources = sources,
        should_attach = function(bufnr)
          local filetype = vim.bo[bufnr].filetype

          for _, source in ipairs(none_ls_sources.get_available(filetype)) do
            if source_runs_for_buffer(source, bufnr) then
              return true
            end
          end

          return false
        end,
        on_attach = function(client, bufnr)
          if client.supports_method("textDocument/formatting") then
            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
            })
          end
        end,
      }
    end,
  },
}
