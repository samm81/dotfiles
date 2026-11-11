require("lib.profile").enable()

local sane = require("lib.sane")

--
-- editor options
--

local o = vim.opt
-- enable true-color and default background
o.termguicolors = true
o.background = "dark"
-- line numbers in gutter
o.number = true
o.relativenumber = true
if vim.env.VIM_NUMBERWIDTH then
  o.numberwidth = tonumber(vim.env.VIM_NUMBERWIDTH)
end

-- two space tabs
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true

-- always keep a couple of lines of context
o.scrolloff = 4
o.sidescrolloff = 4

o.splitbelow = true
o.splitright = true

o.showcmd = true

-- do not highlight search results
o.hlsearch = false

o.completeopt = { "menu", "menuone", "noselect" }

-- no scrubs
o.mouse = ""
local modes = { "n", "i", "v" }
for _, k in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set(modes, k, "<nop>", { silent = true })
end

-- autoread file from disk when changes
o.autoread = true

-- filesystem housekeeping: persistent undo & no swap/backup clutter
o.swapfile = false
o.backup = false
o.writebackup = false
o.undofile = true
vim.opt.undodir = vim.fn.stdpath("state") .. "/undo"

-- highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 })
  end,
})

vim.api.nvim_set_hl(0, "ClipboardCopyFlash", { bg = "#7A7442" })

local copy_flash_ns = vim.api.nvim_create_namespace("clipboard-copy-flash")
local function flash_line_range(line1, line2, hl_group, timeout)
  local bufnr = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count < 1 then
    return
  end

  line1 = math.max(1, math.min(line1, line_count))
  line2 = math.max(1, math.min(line2, line_count))
  if line1 > line2 then
    line1, line2 = line2, line1
  end

  vim.api.nvim_buf_clear_namespace(bufnr, copy_flash_ns, 0, -1)
  for lnum = line1 - 1, line2 - 1 do
    vim.api.nvim_buf_add_highlight(bufnr, copy_flash_ns, hl_group, lnum, 0, -1)
  end
  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, copy_flash_ns, 0, -1)
    end
  end, timeout or 150)
end

local function flash_visual_region(pos1, pos2, selection_type, hl_group, timeout)
  local bufnr = vim.api.nvim_get_current_buf()
  local region = vim.fn.getregionpos(pos1, pos2, {
    type = selection_type,
    eol = true,
  })

  vim.api.nvim_buf_clear_namespace(bufnr, copy_flash_ns, 0, -1)
  for _, segment in ipairs(region) do
    local start_pos, end_pos = segment[1], segment[2]
    local line = vim.api.nvim_buf_get_lines(bufnr, start_pos[2] - 1, start_pos[2], true)[1] or ""
    local start_col = math.max(0, start_pos[3] - 1)
    local end_col = math.max(start_col, end_pos[3] - 1)
    end_col = end_col + #vim.fn.matchstr(line:sub(end_col + 1), "^.")

    if end_col > start_col then
      vim.api.nvim_buf_add_highlight(bufnr, copy_flash_ns, hl_group, start_pos[2] - 1, start_col, end_col)
    end
  end

  vim.defer_fn(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_clear_namespace(bufnr, copy_flash_ns, 0, -1)
    end
  end, timeout or 150)
end

local function copy_text_to_clipboard(text)
  if vim.fn.executable("wl-copy") == 0 then
    vim.notify("wl-copy not found", vim.log.levels.ERROR)
    return false
  end

  vim.fn.system({ "wl-copy" }, text)
  if vim.v.shell_error ~= 0 then
    vim.notify("wl-copy failed", vim.log.levels.ERROR)
    return false
  end

  return true
end

local function copy_line_range_to_clipboard(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, true)
  if not copy_text_to_clipboard(table.concat(lines, "\n") .. "\n") then
    return
  end

  flash_line_range(line1, line2, "ClipboardCopyFlash", 150)
end

local function copy_visual_selection_to_clipboard()
  local selection_start = vim.fn.getpos("v")
  local selection_end = vim.fn.getpos(".")
  local selection_type = vim.fn.mode()
  local selection_lines = vim.fn.getregion(selection_start, selection_end, {
    type = selection_type,
  })
  local selection = table.concat(selection_lines, "\n")
  if selection_type == "V" then
    selection = selection .. "\n"
  end

  if not copy_text_to_clipboard(selection) then
    return
  end

  flash_visual_region(selection_start, selection_end, selection_type, "ClipboardCopyFlash", 150)
  vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "nx", false)
end

vim.api.nvim_create_user_command("CopyToClipboard", function(opts)
  copy_line_range_to_clipboard(opts.line1, opts.line2)
end, { desc = "copy lines to clipboard", range = true })

--
-- key bindings
--

-- sane.keymap("n", "<leader>ve", "<cmd>tabedit " .. vim.fn.stdpath("config") .. "/init.lua<CR>", { desc = "edit config" })
sane.keymap("n", "<leader>ve", function()
  require("telescope.builtin").find_files({ cwd = vim.fn.stdpath("config") })
end)

sane.keymap("n", "<leader>cc", "<cmd>%CopyToClipboard<CR>", { desc = "copy to system clipboard" })
sane.keymap("x", "<leader>cc", copy_visual_selection_to_clipboard, { desc = "copy to system clipboard" })
sane.keymap("n", "<leader>vo", function()
  require("lib.link_paste").paste("org")
end, { desc = "paste titled org link" })
sane.keymap("n", "<leader>vm", function()
  require("lib.link_paste").paste("markdown")
end, { desc = "paste titled markdown link" })

-- diagnostics
-- widely accepted, according to `gpt-4`
sane.keymap("n", "<leader>e", function()
  vim.notify("use <leader>de instead", vim.log.levels.INFO)
end)
sane.keymap("n", "<leader>de", vim.diagnostic.open_float)
sane.keymap("n", "[d", function()
  vim.diagnostic.jump({ count = -1 })
end)
sane.keymap("n", "]d", function()
  vim.diagnostic.jump({ count = 1 })
end)
sane.keymap("n", "[e", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR })
end)
sane.keymap("n", "]e", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR })
end)
-- sane.keymap("n", "<leader>qq", vim.diagnostic.setloclist, opts)

--
-- filetypes
--

vim.filetype.add({
  extension = {
    envrc = "bash",
    bash = "bash",
    zsh = "zsh",
    hbs = "html",
    handlebars = "html",
    config = "confini",
  },
  filename = { direnvrc = "bash" },
  pattern = { ["*.tmate.conf"] = "tmux", [".env.*"] = "bash" },
})

-- helpers

local helpers = require("helpers")

sane.keymap("n", "<leader>gf", function()
  helpers.FormatBufferWithoutSaving()
end, { desc = "format buffer without saving" })
sane.keymap("n", "<leader>dtt", function()
  helpers.InsertCurrentDatetimeAtLine()
end, { desc = "insert datetime below current line" })
sane.keymap("n", "<leader>dtG", function()
  helpers.InsertCurrentDatetimeAtTop()
end, { desc = "insert datetime at top of file" })
vim.api.nvim_create_user_command("Format", function()
  helpers.FormatBufferWithoutSaving()
end, { desc = "format current buffer without saving" })

-- now let `lazy.nvim` set up everything else
require("config.lazy")
