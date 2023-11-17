" show line numbers in gutter
set number
set relativenumber

" default to two space tabs
set tabstop=2 shiftwidth=2 expandtab

" make sure there are always couple of lines/columns of context
set scrolloff=4 sidescrolloff=4

set splitbelow splitright

set showcmd

" don't highlight search results
set nohlsearch

" bash-like tab in minibuffer
set completeopt=longest,menu

" disable mouse interactions
set mouse=

nnoremap <Leader>ve :tabe $MYVIMRC<CR>
nnoremap <Leader>vs :source $MYVIMRC<CR>

" copy to system clipboard
nnoremap <Leader>c :w !wl-copy<CR>
vnoremap <Leader>c :w !wl-copy<CR>

" firenvim
if exists('g:started_by_firenvim')
  set laststatus=0
  let fc['.*'] = { 'takeover': 'never' }
  au BufEnter github.com_*.txt set filetype=markdown
end


" re-read files when they change
set autoread

" unload a buffer when it is no longer in a window (abandoned)
set nohidden

autocmd BufEnter,BufNew *.bash set filetype=bash
autocmd FileType text setlocal textwidth=80
autocmd FileType python command! Blktxt setlocal textwidth=88
autocmd FileType python Blktxt
autocmd FileType javascript command! Prettiertxt setlocal textwidth=88
autocmd FileType javascript Prettiertxt

" Install vim-plug if not found
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

call plug#begin()

  " Make sure you use single quotes

  " allows for `:help plug-options`
  Plug 'junegunn/vim-plug'

  Plug 'neovim/nvim-lspconfig'

  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  " find files using Telescope command-line sugar
  nnoremap <leader>ff <cmd>Telescope find_files<cr>
  nnoremap <leader>fg <cmd>Telescope live_grep<cr>
  nnoremap <leader>fb <cmd>Telescope buffers<cr>
  nnoremap <leader>fh <cmd>Telescope help_tags<cr>

  Plug 'sbdchd/neoformat'
  let g:neoformat_try_node_exe=1
	augroup fmt
		autocmd!
		autocmd BufWritePre * Neoformat
	augroup END

  Plug 'tpope/vim-obsession'

  Plug 'embear/vim-localvimrc'

  Plug 'jparise/vim-graphql'

  Plug 'yssl/QFEnter'
  let g:qfenter_keymap = {}
  let g:qfenter_keymap.open = ['<CR>']
  let g:qfenter_keymap.hopen = ['<C-s>']
  let g:qfenter_keymap.topen = ['<C-t>']
  let g:qfenter_keymap.vopen = ['<C-v>']

  Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

  Plug 'windwp/nvim-autopairs'

  Plug 'hrsh7th/cmp-nvim-lsp'
  Plug 'hrsh7th/cmp-buffer'
  Plug 'hrsh7th/cmp-path'
  Plug 'hrsh7th/cmp-cmdline'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'L3MON4D3/LuaSnip'
  Plug 'saadparwaiz1/cmp_luasnip'

  Plug 'rafamadriz/friendly-snippets'

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

  Plug 'windwp/nvim-ts-autotag'

  Plug 'purescript-contrib/purescript-vim'

  Plug 'ntpeters/vim-better-whitespace'

  Plug 'lukas-reineke/indent-blankline.nvim'

  Plug 'EdenEast/nightfox.nvim'

  Plug 'b0o/SchemaStore.nvim'

  " :Copilot setup
  Plug 'github/copilot.vim'
call plug#end()

" nvim-cmp with luasnip
" https://github.com/hrsh7th/nvim-cmp/blob/272cbdca3e327bf43e8df85c6f4f00921656c4e4/README.md#recommended-configuration
set completeopt=menu,menuone,noselect
lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require'cmp'

  cmp.setup({
    snippet = {
      -- REQUIRED - you must specify a snippet engine
      expand = function(args)
        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
        require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      end,
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      -- { name = 'vsnip' }, -- For vsnip users.
      { name = 'luasnip' }, -- For luasnip users.
      -- { name = 'ultisnips' }, -- For ultisnips users.
      -- { name = 'snippy' }, -- For snippy users.
    }, {
      { name = 'buffer' },
    })
  })

  -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })
EOF

" lsp-config
" https://github.com/neovim/nvim-lspconfig/blob/858fc0ec1ffa02fc03f0c62d646e8054007c49ad/README.md#suggested-configuration
lua << EOF
  -- uncomment, then :LspLog
  -- vim.lsp.set_log_level("debug")

	-- Mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	local opts = { noremap=true, silent=true }
	vim.api.nvim_set_keymap('n', '<Leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
	vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
	vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
	vim.api.nvim_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>', opts)
	vim.api.nvim_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>', opts)
	vim.api.nvim_set_keymap('n', '<Leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

	-- Use an on_attach function to only map the following keys
	-- after the language server attaches to the current buffer
	local on_attach = function(client, bufnr)
		-- Enable completion triggered by <c-x><c-o>
		vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

		-- Mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>K', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
		--vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
		--vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
		--vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
		vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
	end
  -- nvim-cmp
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

	-- Use a loop to conveniently call 'setup' on multiple servers and
	-- map buffer local keybindings when the language server attaches
	local servers = { 'bashls', 'eslint', 'graphql', 'tsserver', 'pylyzer', 'purescriptls', 'gopls' }
	for _, lsp in pairs(servers) do
		require('lspconfig')[lsp].setup {
			on_attach = on_attach,
			flags = {
				-- This will be the default in neovim 0.7+
				debounce_text_changes = 150,
			},
      -- nvim-cmp
			capabilities = capabilities,
		}
	end
  require('lspconfig').elixirls.setup {
    cmd = { "/home/maynard/src/elixir-ls/language_server.sh" },
    on_attach = on_attach,
		flags = {
			-- This will be the default in neovim 0.7+
			debounce_text_changes = 150,
		},
    -- nvim-cmp
    capabilities = capabilities,
  }
  --require('lspconfig').tailwindcss.setup {
  --  cmd = { "npx tailwindcss-language-server --stdio" },
  --  on_attach = on_attach,
	--	flags = {
	--		-- This will be the default in neovim 0.7+
	--		debounce_text_changes = 150,
	--	},
  --  -- nvim-cmp
  --  capabilities = capabilities,
  --}
  --require('lspconfig').pylsp.setup {
  --  on_attach = on_attach,
	--	flags = {
	--		-- This will be the default in neovim 0.7+
	--		debounce_text_changes = 150,
	--	},
  --  -- nvim-cmp
  --  capabilities = capabilities,
  --  settings = {
  --    pylsp = {
  --      plugins = {
  --        pycodestyle = { enabled = false },
  --        mccabe = { enabled = false },
  --        pyflakes = { enabled = false },
  --        flake8 = { enabled = true },
  --      },
  --      configurationSources = {"pyflakes"}
  --    }
  --  }
  --}
  -- https://github.com/b0o/SchemaStore.nvim/blob/a592fbe98959d13014b022ec1b1418498309019c/README.md
  require('lspconfig').jsonls.setup {
    settings = {
      json = {
        schemas = require('schemastore').json.schemas(),
        validate = { enable = true },
      },
    },
  }
  -- https://github.com/b0o/SchemaStore.nvim/blob/a592fbe98959d13014b022ec1b1418498309019c/README.md
  --require('lspconfig').yamlls.setup {
  --  settings = {
  --    yaml = {
  --      schemas = require('schemastore').yaml.schemas(),
  --    },
  --  },
  --}
EOF

" use lsp to lookup tags
" https://github.com/weilbith/nvim-lsp-smag/issues/6#issuecomment-984044646
set tagfunc=v:lua.vim.lsp.tagfunc

" https://github.com/L3MON4D3/LuaSnip/blob/ed45343072aefa0ae1147aaee41fe64ad4565038/README.md#add-snippets
lua require("luasnip.loaders.from_vscode").lazy_load()
lua require("luasnip.loaders.from_snipmate").lazy_load()
nnoremap <Leader>vse :tabe ~/.config/nvim/snippets/<CR>

" nvim-autopairs
lua << EOF
  require('nvim-autopairs').setup({
    fast_wrap = {
      map = '<M-w>',
    },
    -- don't add if already has a close pair on the same line
    enable_check_bracket_line = true,
  })
EOF

" nvim-treesitter
lua << EOF
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "python", "json", "typescript", "jsdoc", "bash", "make", "css", "regex",
      "vim", "yaml", "nix", "tsx", "javascript", "eex", "elixir", "heex",
      "dockerfile", "html", "graphql", "lua"
    },
    highlight = {
      enable = true,
      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true
    },
  }
EOF

" nvim-ts-autotag
lua require('nvim-ts-autotag').setup()

" indent-blankline.nvim
" https://github.com/lukas-reineke/indent-blankline.nvim#with-context-indent-highlighted-by-treesitter
lua <<EOF
  vim.opt.list = true
  -- vim.opt.listchars:append "space:⋅"
  vim.opt.listchars:append "eol:↴"

  require("indent_blankline").setup {
    space_char_blankline = " ",
    show_current_context = true,
    show_current_context_start = true,
  }
EOF

" theme
" :colorsheme [scheme] to change in current session
colorscheme nordfox

highlight ExtraWhitespace ctermbg='white'
let g:better_whitespace_enabled=1
let g:strip_whitespace_on_save=1
let g:strip_whitelines_at_eof=1
let g:show_spaces_that_precede_tabs=1
let g:strip_whitespace_confirm=0

lua <<EOF
  -- https://github.com/bash-lsp/bash-language-server/blob/82d6897972378bc1ade0a79c1a26435878137bbc/README.md
  vim.api.nvim_create_autocmd('FileType', {
    pattern = {'sh', 'bash'},
    callback = function()
      vim.lsp.start({
        name = 'bash-language-server',
        cmd = { 'bash-language-server', 'start' },
      })
    end,
  })
EOF

" codeium
let g:codeium_disable_bindings = 1
imap <script><silent><nowait><expr> <Leader>c codeium#Accept()
imap <Leader>cn <Cmd>call codeium#CycleCompletions(1)<CR>
imap <Leader>cp <Cmd>call codeium#CycleCompletions(-1)<CR>
imap <Leader>cc <Cmd>call codeium#Clear()<CR>

" copilot
imap <silent><script><expr> <C-\> copilot#Accept("")
let g:copilot_no_tab_map = v:true

" neoformat
function! NeoformatDbg()
  let g:neoformat_verbose = 1
  Neoformat
  let g:neoformat_verbose = 0
endfunction

command! NeoformatDbg call NeoformatDbg()
