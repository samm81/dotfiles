local M = {}

local function enabled()
  return vim.env.NVIM_PROFILE_OUT ~= nil and vim.env.NVIM_PROFILE_OUT ~= ""
end

function M.enable()
  if not enabled() then
    return
  end

  local uv = vim.uv or vim.loop
  local started_at = uv.hrtime()
  local data = {
    scenario = vim.env.NVIM_PROFILE_SCENARIO or "unknown",
    run_id = vim.env.NVIM_PROFILE_RUN_ID or "",
    pid = vim.fn.getpid(),
    cwd = uv.cwd(),
    milestones = {},
    seen_buffers = {},
  }
  local seen_buffer_ids = {}

  local function now_ms()
    return math.floor(((uv.hrtime() - started_at) / 1e6) * 1000 + 0.5) / 1000
  end

  local function mark(name, value)
    if data.milestones[name] == nil then
      data.milestones[name] = value or now_ms()
    end
  end

  local function any_diff_window()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) and vim.wo[win].diff then
        return true
      end
    end
    return false
  end

  local function remember_buffer(bufnr)
    if not bufnr or seen_buffer_ids[bufnr] or not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    seen_buffer_ids[bufnr] = true
    table.insert(data.seen_buffers, {
      bufnr = bufnr,
      name = vim.api.nvim_buf_get_name(bufnr),
      filetype = vim.bo[bufnr].filetype,
      buftype = vim.bo[bufnr].buftype,
    })
  end

  local function bufwritepre_groups(bufnr)
    local groups = {}
    local seen = {}

    for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = "BufWritePre", buffer = bufnr })) do
      local group = autocmd.group_name
      if group and group ~= "" and not seen[group] then
        seen[group] = true
        table.insert(groups, group)
      end
    end

    table.sort(groups)
    return groups
  end

  mark("profile_enable", 0)

  vim.api.nvim_create_autocmd("UIEnter", {
    callback = function()
      mark("UIEnter")
    end,
  })

  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      mark("VimEnter")
      vim.schedule(function()
        mark("scheduled_after_VimEnter")
      end)
    end,
  })

  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(event)
      mark("BufEnter")
      remember_buffer(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("BufWinEnter", {
    callback = function(event)
      mark("BufWinEnter")
      remember_buffer(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("FileType", {
    callback = function(event)
      mark("FileType")
      data.detected_filetype = vim.bo[event.buf].filetype
      remember_buffer(event.buf)
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    pattern = "diff",
    callback = function()
      mark("OptionSet_diff")
    end,
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      mark("VeryLazy")
    end,
  })

  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(event)
      mark("LspAttach")
      if not data.first_lsp_client and event.data and event.data.client_id then
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        data.first_lsp_client = client and client.name or nil
      end
    end,
  })

  pcall(vim.api.nvim_create_autocmd, "DiffUpdated", {
    callback = function()
      mark("DiffUpdated")
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      mark("VimLeavePre")

      local current_buf = vim.api.nvim_get_current_buf()
      remember_buffer(current_buf)

      local lsp_clients = {}
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = current_buf })) do
        table.insert(lsp_clients, client.name)
      end
      table.sort(lsp_clients)

      local ok_lazy, lazy = pcall(require, "lazy")
      if ok_lazy and lazy.stats then
        data.lazy = lazy.stats()
      end

      data.final = {
        current_buf_name = vim.api.nvim_buf_get_name(current_buf),
        filetype = vim.bo[current_buf].filetype,
        any_diff_window = any_diff_window(),
        window_count = #vim.api.nvim_list_wins(),
        loaded_buffer_count = #vim.api.nvim_list_bufs(),
        lsp_clients = lsp_clients,
        bufwritepre_groups = bufwritepre_groups(current_buf),
      }

      local output_path = vim.env.NVIM_PROFILE_OUT
      vim.fn.mkdir(vim.fn.fnamemodify(output_path, ":h"), "p")
      vim.fn.writefile({ vim.json.encode(data) }, output_path)
    end,
  })
end

return M
