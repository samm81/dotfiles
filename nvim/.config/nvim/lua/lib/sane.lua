local M = {}

function M.keymap(mode, lhs, rhs, opts)
  local options = vim.tbl_extend("force",
    { noremap = true, silent = true },
    opts or {}
  )
  vim.keymap.set(mode, lhs, rhs, options)
end

return M
