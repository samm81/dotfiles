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

-- treesitter-based folding
o.foldmethod = "expr"
o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
o.foldlevel = 99

--
-- key bindings
--

sane.keymap("n", "<leader>ve", "<cmd>tabedit " .. vim.fn.stdpath("config") .. "/init.lua<CR>", { desc = "edit config" })
sane.keymap({ "n", "v" }, "<leader>c", ":w !wl-copy<CR>", { desc = "copy to clipboard" })

-- diagnostics
-- widely accepted, according to `gpt-4`
sane.keymap("n", "<leader>e", vim.diagnostic.open_float)
sane.keymap("n", "[d", vim.diagnostic.goto_prev)
sane.keymap("n", "]d", vim.diagnostic.goto_next)
sane.keymap("n", "[e", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end)
sane.keymap("n", "]e", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end)
-- sane.keymap("n", "<leader>q", vim.diagnostic.setloclist, opts)

--
-- filetypes
--

vim.filetype.add({
  extension = {
    envrc = "bash",
    bash = "bash",
    hbs = "html",
    handlebars = "html",
  },
  filename = { direnvrc = "bash" },
  pattern = { ["*.tmate.conf"] = "tmux" },
})

-- now let `lazy.nvim` set up everything else
require("config.lazy")
