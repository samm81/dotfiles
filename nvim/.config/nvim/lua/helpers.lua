local DATET_COMMAND = { "datet" }

local function current_datetime_text()
  if vim.fn.executable(DATET_COMMAND[1]) ~= 1 then
    vim.notify("`datet` is not available on PATH", vim.log.levels.WARN)
    return nil
  end

  local output = vim.fn.system(DATET_COMMAND)
  if vim.v.shell_error ~= 0 then
    vim.notify("`datet` failed: " .. vim.trim(output), vim.log.levels.ERROR)
    return nil
  end

  return vim.trim(output)
end

local function insert_line_and_focus(bufnr, row, text)
  vim.api.nvim_buf_set_lines(bufnr, row, row, false, { text })

  local win = vim.api.nvim_get_current_win()
  if vim.api.nvim_win_get_buf(win) == bufnr then
    vim.api.nvim_win_set_cursor(win, { row + 1, 0 })
  end
end

local function InsertCurrentDatetimeAtLine()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local text = current_datetime_text()

  if text then
    insert_line_and_focus(bufnr, row, text)
  end
end

local function InsertCurrentDatetimeAtTop()
  local bufnr = vim.api.nvim_get_current_buf()
  local text = current_datetime_text()

  if text then
    insert_line_and_focus(bufnr, 0, text)
  end
end

local function FormatBufferWithoutSaving()
  local bufnr = vim.api.nvim_get_current_buf()
  local formatting_method = vim.lsp.protocol.Methods.textDocument_formatting
  local ext_by_ft = {
    markdown = "md",
    text = "txt",
    javascriptreact = "jsx",
    typescriptreact = "tsx",
  }

  local function has_format_client()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, method = formatting_method })
    return #clients > 0
  end

  local function try_attach_none_ls()
    local ok, null_ls_client = pcall(require, "null-ls.client")
    if ok then
      pcall(null_ls_client.try_add, bufnr)
    end
  end

  local function format_when_ready(remaining_retries)
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end
    if has_format_client() then
      vim.lsp.buf.format({ bufnr = bufnr, async = true })
      return
    end
    try_attach_none_ls()
    if remaining_retries <= 0 then
      vim.notify("no formatter attached for current buffer", vim.log.levels.WARN)
      return
    end
    vim.defer_fn(function()
      format_when_ready(remaining_retries - 1)
    end, 120)
  end

  local function set_scratch_name_if_needed()
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name ~= "" then
      return
    end
    local ft = vim.bo[bufnr].filetype
    local ext = ext_by_ft[ft] or (ft ~= "" and ft) or "txt"
    local uv = vim.uv
    local cwd = uv.cwd() or vim.fn.getcwd()
    local scratch_name = string.format(".nvim-scratch-%d.%s", uv.hrtime(), ext)
    local scratch_path = cwd .. "/" .. scratch_name

    -- none-ls formatters like prettier need a filename to resolve parser/config.
    vim.api.nvim_buf_set_name(bufnr, scratch_path)
  end

  local function pick_filetype_if_needed(continue_cb)
    if vim.bo[bufnr].filetype ~= "" then
      continue_cb()
      return
    end

    local all_filetypes = vim.fn.getcompletion("", "filetype")
    local seen = { text = true, markdown = true }
    local ordered = {}
    for _, ft in ipairs(all_filetypes) do
      if ft ~= "" and not seen[ft] then
        seen[ft] = true
        table.insert(ordered, ft)
      end
    end
    table.sort(ordered)

    local choices = {
      { label = "txt", ft = "text" },
      { label = "markdown", ft = "markdown" },
    }
    for _, ft in ipairs(ordered) do
      table.insert(choices, { label = ft, ft = ft })
    end

    vim.ui.select(choices, {
      prompt = "choose filetype for scratch buffer",
      format_item = function(item)
        return item.label
      end,
    }, function(choice)
      vim.bo[bufnr].filetype = (choice and choice.ft) or "text"
      continue_cb()
    end)
  end

  pick_filetype_if_needed(function()
    set_scratch_name_if_needed()
    format_when_ready(8)
  end)
end

return {
  FormatBufferWithoutSaving = FormatBufferWithoutSaving,
  InsertCurrentDatetimeAtLine = InsertCurrentDatetimeAtLine,
  InsertCurrentDatetimeAtTop = InsertCurrentDatetimeAtTop,
}
