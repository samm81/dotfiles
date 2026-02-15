local function ShowFormatterOverview()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.bo[bufnr].filetype
  local formatting_method = vim.lsp.protocol.Methods and vim.lsp.protocol.Methods.textDocument_formatting
    or "textDocument/formatting"

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

  -- header
  table.insert(lines, "🌐 Formatter Overview")
  table.insert(lines, string.rep("─", width - 4))
  table.insert(lines, "")
  local fmt_clients = vim.lsp.get_clients({ bufnr = bufnr, method = formatting_method })

  local ok, none_ls = pcall(require, "null-ls")
  local ok_sources, none_ls_sources = pcall(require, "null-ls.sources")
  local available = {}
  if ok and ok_sources and none_ls.methods and none_ls.methods.FORMATTING then
    for _, src in ipairs(none_ls_sources.get_available(filetype, none_ls.methods.FORMATTING)) do
      table.insert(available, src.name)
    end
  end

  table.insert(lines, "🧩 Formatter Tool(s):")
  if #available > 0 then
    for _, name in ipairs(available) do
      table.insert(lines, "  • " .. name)
    end
  elseif #fmt_clients > 0 then
    for _, c in ipairs(fmt_clients) do
      table.insert(lines, "  • " .. c.name)
    end
  else
    table.insert(lines, "  (none)")
  end

  -- collect buffer-local + global save hooks
  local hooks = {}
  local seen = {}
  local function push_hook(ac)
    if not seen[ac.id] then
      table.insert(hooks, ac)
      seen[ac.id] = true
    end
  end

  for _, ac in ipairs(vim.api.nvim_get_autocmds({ event = "BufWritePre", buffer = bufnr })) do
    push_hook(ac)
  end
  for _, ac in ipairs(vim.api.nvim_get_autocmds({ event = "BufWritePre" })) do
    if ac.buffer == nil or ac.buffer == 0 then
      push_hook(ac)
    end
  end

  local has_format_on_save = false
  local extra_hooks = {}

  for _, ac in ipairs(hooks) do
    local group = ac.group_name or ""
    if group == "NoneLsFormatting" then
      has_format_on_save = true
    elseif not group:match("^nvim%.lsp") then
      table.insert(extra_hooks, ac)
    end
  end

  table.insert(lines, "")
  table.insert(lines, "💾 Format On Save:")
  table.insert(lines, has_format_on_save and "  • enabled (NoneLsFormatting)" or "  • not detected")

  table.insert(lines, "")
  table.insert(lines, "🧹 Extra Save Modifiers:")
  if #extra_hooks == 0 then
    table.insert(lines, "  (none)")
  else
    for _, ac in ipairs(extra_hooks) do
      local group = ac.group_name and #ac.group_name > 0 and ac.group_name or "(no group)"
      local desc = ac.desc and #ac.desc > 0 and ac.desc or ""
      local line = "  • " .. group
      if desc == "" then
        line = line .. " (custom BufWritePre hook)"
      else
        line = line .. " - " .. desc
      end
      table.insert(lines, line)
    end
  end

  -- write to floating window
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
end

return {
  ShowFormatterOverview = ShowFormatterOverview,
}
