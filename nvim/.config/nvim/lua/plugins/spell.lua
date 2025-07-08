local sane = require("lib.sane")

-- spell checking configuration
vim.opt.spelllang = "en_us"
vim.opt.spellsuggest = "best,9"
vim.opt.spell = true

-- configures spell options for different filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "lua",
    "python",
    "javascript",
    "typescript",
    "rust",
    "go",
    "elixir",
    "bash",
    "sh",
    "zsh",
    "vim",
    "yaml",
    "json",
  },
  callback = function()
    -- only check spelling in comments and strings for code files
    vim.opt_local.spelloptions = "camel"
  end,
})

-- spell checking keymaps
sane.keymap("n", "<leader>ss", function()
  vim.opt_local.spell = not vim.opt_local.spell:get()
  if vim.opt_local.spell:get() then
    vim.notify(
      [[Spell check enabled. Built-in shortcuts:
]s  - next misspelled word
[s  - prev misspelled word
z=  - show spelling suggestions
1z= - fix with first suggestion
zg  - add word to dictionary
zw  - mark word as wrong]],
      vim.log.levels.INFO,
      { title = "Spell Check" }
    )
  else
    vim.notify("Spell check disabled", vim.log.levels.INFO)
  end
end, { desc = "toggle spell check" })

return {}
