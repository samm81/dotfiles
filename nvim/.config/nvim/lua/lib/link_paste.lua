local M = {}
local namespace = vim.api.nvim_create_namespace("link-paste")

function M.paste(format)
  local url = vim.trim(vim.fn.getreg("+"))
  local bufnr = vim.api.nvim_get_current_buf()
  if not vim.bo[bufnr].modifiable then
    vim.notify("buffer is not modifiable", vim.log.levels.WARN)
    return
  end

  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local line = vim.api.nvim_get_current_line()
  local start_col = col + #vim.fn.matchstr(line:sub(col + 1), "^.")
  local lines = vim.split(url, "\n", { plain = true })
  vim.api.nvim_buf_set_text(bufnr, row - 1, start_col, row - 1, start_col, lines)
  if not url:match("^https?://%S+$") then
    vim.notify("invalid URL; pasted clipboard text", vim.log.levels.WARN)
    return
  end
  local mark = vim.api.nvim_buf_set_extmark(bufnr, namespace, row - 1, start_col, {
    end_row = row - 1,
    end_col = start_col + #url,
    right_gravity = false,
    end_right_gravity = true,
  })

  local function finish(title)
    if not vim.api.nvim_buf_is_loaded(bufnr) then
      return
    end
    local pos = vim.api.nvim_buf_get_extmark_by_id(bufnr, namespace, mark, { details = true })
    if #pos == 0 then
      return
    end
    local details = pos[3]
    local current = vim.api.nvim_buf_get_text(bufnr, pos[1], pos[2], details.end_row, details.end_col, {})
    vim.api.nvim_buf_del_extmark(bufnr, namespace, mark)
    if not vim.bo[bufnr].modifiable or #current ~= 1 or current[1] ~= url then
      vim.notify("link paste canceled: pasted text changed", vim.log.levels.WARN)
      return
    end
    if not title then
      vim.notify("could not fetch link title; pasted clipboard text", vim.log.levels.WARN)
      return
    end
    local link
    if format == "org" then
      link = "[[" .. url:gsub("%[", "%%5B"):gsub("%]", "%%5D") .. "][" .. title:gsub("%]", "&#93;") .. "]]"
    else
      local text = title:gsub("\\", "\\\\"):gsub("%[", "\\["):gsub("%]", "\\]")
      local target = url:gsub("%(", "%%28"):gsub("%)", "%%29")
      link = "[" .. text .. "](" .. target .. ")"
    end
    vim.api.nvim_buf_set_text(bufnr, pos[1], pos[2], details.end_row, details.end_col, { link })
  end

  if vim.fn.executable("curl") == 0 or vim.fn.executable("python3") == 0 then
    finish(nil)
    return
  end
  local script = vim.fn.stdpath("config") .. "/scripts/link-title.py"
  vim.system({ "python3", script, url }, { text = true }, function(result)
    vim.schedule(function()
      finish(result.code == 0 and vim.trim(result.stdout) or nil)
    end)
  end)
end

return M
