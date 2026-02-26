-- spell checking configuration
vim.opt.spelllang = "en_us"
vim.opt.spellsuggest = "best,9"
vim.opt.spellcapcheck = "" -- disable capitalization check at start of sentences
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

return {}
