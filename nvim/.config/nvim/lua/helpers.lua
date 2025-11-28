local function ShowFormatterOverview()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype

  local buf = vim.api.nvim_create_buf(false, true)

  -- Floating window layout
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.5)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    style = "minimal",
    border = "rounded",
  })

  -- Close on "q"
  vim.keymap.set("n", "q", function()
    local win = vim.api.nvim_get_current_win()
    vim.api.nvim_win_close(win, true)
  end, { buffer = buf, nowait = true, silent = true })

  local lines = {}

  -- Header
  table.insert(lines, "🌐 Formatter Overview")
  table.insert(lines, string.rep("─", width - 4))

  ----------------------------------------------------------------
  -- 1. Active LSP Clients
  ----------------------------------------------------------------
  table.insert(lines, "")
  table.insert(lines, "🟦 Active LSP Clients:")
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #clients == 0 then
    table.insert(lines, "  (none)")
  else
    for _, c in ipairs(clients) do
      table.insert(lines, "  • " .. c.name)
    end
  end

  ----------------------------------------------------------------
  -- 2. LSP clients that support formatting
  ----------------------------------------------------------------
  table.insert(lines, "")
  table.insert(lines, "🔧 LSP Clients Providing Formatting:")
  local fmt_clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/formatting" })
  if #fmt_clients == 0 then
    table.insert(lines, "  (none)")
  else
    for _, c in ipairs(fmt_clients) do
      table.insert(lines, "  • " .. c.name)
    end
  end

  ----------------------------------------------------------------
  -- 3. none-ls formatters
  ----------------------------------------------------------------
  local ok, none_ls = pcall(require, "null-ls")
  table.insert(lines, "")
  table.insert(lines, "📦 none-ls sources (formatting):")

  local available = {}
  if ok and none_ls.get_sources then
    local method_key = "NULL_LS_FORMATTING"
    for _, src in ipairs(none_ls.get_sources()) do
      -- Check filetype match
      if src.filetypes and vim.tbl_contains(src.filetypes, filetype) then
        -- Handle method being string or table
        if src.method == method_key then
          table.insert(available, src.name)
        elseif type(src.method) == "table" then
          for _, m in ipairs(src.method) do
            if m == method_key then
              table.insert(available, src.name)
              break
            end
          end
        end
      end
    end
  end

  if #available == 0 then
    table.insert(lines, ok and "  (none)" or "  (none-ls not installed)")
  else
    for _, name in ipairs(available) do
      table.insert(lines, "  • " .. name)
    end
  end

  ----------------------------------------------------------------
  -- 4. Which formatter Neovim *will* use
  ----------------------------------------------------------------
  table.insert(lines, "")
  table.insert(lines, "🧩 Formatter Selection (Neovim):")
  local chosen = nil
  for _, c in ipairs(fmt_clients) do
    chosen = c.name
    break
  end
  if chosen then
    table.insert(lines, "  → Neovim will use: **" .. chosen .. "**")
  else
    table.insert(lines, "  (no formatter available)")
  end

  ----------------------------------------------------------------
  -- Write to floating window
  ----------------------------------------------------------------
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return {
  ShowFormatterOverview = ShowFormatterOverview,
}
