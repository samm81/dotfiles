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

local function copy_line_range_to_clipboard(line1, line2)
  if vim.fn.executable("wl-copy") == 0 then
    vim.notify("wl-copy not found", vim.log.levels.ERROR)
    return
  end

  vim.cmd(string.format("silent %d,%dw !wl-copy", line1, line2))
  flash_line_range(line1, line2, "ClipboardCopyFlash", 150)
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

sane.keymap("n", "<leader>cc", "<cmd>%CopyToClipboard<CR>", { desc = "copy to clipboard" })
sane.keymap("v", "<leader>cc", ":<C-u>'<,'>CopyToClipboard<CR>", { desc = "copy to clipboard" })

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

vim.keymap.set("n", "<leader>fo", function()
  helpers.ShowFormatterOverview()
end, { desc = "Show Formatter Overview" })
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
