" quick hints
" `:PlugUpgrade` - update `plug.vim`
" `:PlugUpdate` - update plugins
" `:TSUpdate` - update tree-sitter

" curl -fLO https://github.com/elixir-lsp/elixir-ls/releases/latest/download/elixir-ls.zip
" unzip elixir-ls.zip -d ~/src/elixir-ls
" chmod +x ~/src/elixir-ls/language_server.sh
" ln -s ~/src/elixir-ls/language_server.sh ~/bin/elixir-ls

" npm install -g vscode-langservers-extracted bash-language-server \
"   typescript typescript-language-server eslint prettier

" xbps-install shfmt


" show line numbers in gutter
set number
set relativenumber
if exists('$VIM_NUMBERWIDTH')
  let &numberwidth = $VIM_NUMBERWIDTH
endif


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

nnoremap <leader>ve :tabe $MYVIMRC<CR>
nnoremap <leader>vs :source $MYVIMRC<CR>

" copy to system clipboard
nnoremap <leader>c :w !wl-copy<CR>
vnoremap <leader>c :w !wl-copy<CR>

" re-read files when they change
set autoread

" unload a buffer when it is no longer in a window (abandoned)
set nohidden

autocmd BufEnter,BufNew *.bash set filetype=bash
autocmd BufEnter,BufNew *.tmate.conf set filetype=tmux
autocmd BufEnter,BufNew *.hbs set filetype=html
autocmd BufEnter,BufNew *.handlebars set filetype=html
autocmd BufEnter,BufNew *.envrc set filetype=bash
autocmd BufEnter,BufNew direnvrc set filetype=bash

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
  nnoremap <leader>nf <cmd>Neoformat<cr>
  let g:neoformat_try_node_exe=1
  let g:shfmt_opt="-ci"
  augroup fmt
    autocmd!
    autocmd BufWritePre * Neoformat
  augroup END
  let g:neoformat_javascript_prettier = {
          \ 'exe': 'prettier',
          \ 'args': ['--parser babel'],
          \ 'stdin': 1
          \ }
  let g:neoformat_enabled_javascript = ['prettier']
  let g:neoformat_heex_mix_format = {
          \ 'exe': 'mix',
          \ 'args': ['format', '--stdin-filename="%:t"', '-'],
          \ 'stdin': 1
          \ }
  let g:neoformat_enabled_heex = ['mix_format']
  "let g:neoformat_clojure_cljfmt = {
  "        \ 'exe': 'cljfmt',
  "        \ 'args': ['fix'],
  "        \ }
  "let g:neoformat_enabled_clojure = ['cljfmt']
  let g:neoformat_enabled_bash = ['shfmt']

  Plug 'tpope/vim-obsession'

  Plug 'embear/vim-localvimrc'

  Plug 'jparise/vim-graphql'

  " quickfix
  Plug 'yssl/QFEnter'
  let g:qfenter_keymap = {}
  let g:qfenter_keymap.open = ['<CR>']
  let g:qfenter_keymap.hopen = ['<C-s>']
  let g:qfenter_keymap.topen = ['<C-t>']
  let g:qfenter_keymap.vopen = ['<C-v>']

  "Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }

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

  " 2024-10-02
  Plug 'tpope/vim-surround'

  " 2025-06-23
  " dependencies
  Plug 'MunifTanjim/nui.nvim'
  " already `Plug`ed above
  " Plug 'nvim-lua/plenary.nvim'
  Plug 'jackMort/ChatGPT.nvim', { 'do': 'bash ./install.sh' }

  " 2025-06-23
  Plug 'milanglacier/minuet-ai.nvim'

call plug#end()

" nvim-cmp with luasnip
" https://github.com/hrsh7th/nvim-cmp/blob/272cbdca3e327bf43e8df85c6f4f00921656c4e4/README.md#recommended-configuration
set completeopt=menu,menuone,noselect
lua <<EOF
  -- Setup nvim-cmp.
  local cmp = require('cmp')
  local luasnip = require('luasnip')

  cmp.setup({
    --experimental = {
    --  ghost_text = true,
    --},

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
      ['<C-n>'] = cmp.mapping.select_next_item(),
      ['<C-p>'] = cmp.mapping.select_prev_item(),
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),

      -- ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      -- ['<Tab>'] = cmp.mapping.confirm({ select = true }),

      -- `<CR>` `<Tab>` and `<S-Tab>`
      -- https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings
      ['<CR>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            if luasnip.expandable() then
                luasnip.expand()
            else
                cmp.confirm({ select = false })
            end
        else
            fallback()
        end
      end),

      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.confirm({ select = true })
        elseif luasnip.locally_jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { "i", "s" }),

      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
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
  vim.api.nvim_set_keymap('n', '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.api.nvim_set_keymap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.api.nvim_set_keymap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  vim.api.nvim_set_keymap('n', '[e', '<cmd>lua vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })<CR>', opts)
  vim.api.nvim_set_keymap('n', ']e', '<cmd>lua vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })<CR>', opts)
  vim.api.nvim_set_keymap('n', '<leader>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)

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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>K', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    --vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
  end
  -- nvim-cmp
  local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())

  -- Use a loop to conveniently call 'setup' on multiple servers and
  -- map buffer local keybindings when the language server attaches
  -- 'pylyzer'
  local servers = { 'eslint', 'graphql', 'ts_ls', 'pyright', 'purescriptls', 'gopls', 'ruff' }
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
  require('lspconfig').bashls.setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
    filetypes = { 'sh', 'bash', 'zsh' },
    -- nvim-cmp
    capabilities = capabilities,
  }
  require('lspconfig').elixirls.setup {
    cmd = { "/home/maynard/bin/elixir-ls" },
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    },
    --settings = {
    --  elixirLS = {
    --    dialyzerEnabled = true,
    --    fetchDeps = false,
    --    suggestSpecs = true,
    --    dialyzerFormat = "dialyxir",
    --  }
    --},
    -- nvim-cmp
    capabilities = capabilities,
  }
  --require('lspconfig').tailwindcss.setup {
  --  cmd = { "npx tailwindcss-language-server --stdio" },
  --  on_attach = on_attach,
  --  flags = {
  --    -- This will be the default in neovim 0.7+
  --    debounce_text_changes = 150,
  --  },
  --  -- nvim-cmp
  --  capabilities = capabilities,
  --}
  --require('lspconfig').pylsp.setup {
  --  on_attach = on_attach,
  --  flags = {
  --    -- This will be the default in neovim 0.7+
  --    debounce_text_changes = 150,
  --  },
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
nnoremap <leader>vse :tabe ~/.config/nvim/snippets/<CR>

" nvim-treesitter
lua << EOF
  require'nvim-treesitter.configs'.setup {
    ensure_installed = {
      "python", "json", "typescript", "jsdoc", "bash", "make", "css", "regex",
      "vim", "yaml", "nix", "tsx", "javascript", "elixir", "eex", "heex",
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

" telescope
lua << EOF
  require('telescope').setup{
    defaults = {
      -- Default configuration for telescope goes here:
      -- config_key = value,
      mappings = {
        i = {
          -- map actions.which_key to <C-h> (default: <C-/>)
          -- actions.which_key shows the mappings for your picker,
          -- e.g. git_{create, delete, ...}_branch for the git_branches picker
          -- ["<C-h>"] = "which_key"
        }
      },
      path_display = { "smart" },
    },
    pickers = {
      -- Default configuration for builtin pickers goes here:
      -- picker_name = {
      --   picker_config_key = value,
      --   ...
      -- }
      -- Now the picker_config_key will be applied every time you call this
      -- builtin picker
      live_grep = {
        glob_pattern = "!package-lock.json",
      }
    },
    extensions = {
      -- Your extension configuration goes here:
      -- extension_name = {
      --   extension_config_key = value,
      -- }
      -- please take a look at the readme of the extension you want to configure
    }
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
  vim.opt.listchars:append "tab:> "

  require("ibl").setup {
    indent = { char = "▏" }
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
imap <script><silent><nowait><expr> <leader>c codeium#Accept()
imap <leader>cn <Cmd>call codeium#CycleCompletions(1)<CR>
imap <leader>cp <Cmd>call codeium#CycleCompletions(-1)<CR>
imap <leader>cc <Cmd>call codeium#Clear()<CR>

" neoformat
function! NeoformatDbg()
  let g:neoformat_verbose = 1
  Neoformat
  let g:neoformat_verbose = 0
endfunction

command! NeoformatDbg call NeoformatDbg()

" chatgpt.nvim

lua << EOF
  local home = vim.fn.expand("$HOME")
  require("chatgpt").setup({
    -- api_host_cmd = "echo -n 'localhost:41410'",
    api_key_cmd = "cat " .. home .. "/.local/share/openai-api-key.txt",
    -- https://github.com/jackMort/ChatGPT.nvim/blob/5b6d296eefc75331e2ff9f0adcffbd7d27862dd6/README.md#example-configuration
    -- openai_params = {
    --   -- NOTE: model can be a function returning the model name
    --   -- this is useful if you want to change the model on the fly
    --   -- using commands
    --   -- Example:
    --   -- model = function()
    --   --     if some_condition() then
    --   --         return "gpt-4-1106-preview"
    --   --     else
    --   --         return "gpt-3.5-turbo"
    --   --     end
    --   -- end,
    model = "o4-mini-2025-04-16",
    --   frequency_penalty = 0,
    --   presence_penalty = 0,
    --   max_tokens = 4095,
    --   temperature = 0.2,
    --   top_p = 0.1,
    --   n = 1,
    -- }
  })
EOF

" minuet-ai
lua <<EOF
  require('minuet').setup({
    provider = 'openai',
    virtualtext = {
      auto_trigger_ft = {'*'},
      keymap = {
        -- accept whole completion
        accept = '<C-\\>',
        -- accept one line
        accept_line = '<A-a>',
        -- accept n lines (prompts for number)
        -- e.g. "A-z 2 CR" will accept 2 lines
        accept_n_lines = '<A-z>',
        -- Cycle to prev completion item, or manually invoke completion
        prev = '<A-[>',
        -- Cycle to next completion item, or manually invoke completion
        next = '<A-]>',
        dismiss = '<A-e>',
      },
    },
    --provider_options = {
    --  openai = {
    --    model = 'gpt-4.1-mini',
    --    system = "see [Prompt] section for the default value",
    --    few_shots = "see [Prompt] section for the default value",
    --    chat_input = "See [Prompt Section for default value]",
    --    stream = true,
    --    api_key = 'OPENAI_API_KEY',
    --    optional = {
    --      -- pass any additional parameters you want to send to OpenAI request,
    --      -- e.g.
    --      -- stop = { 'end' },
    --      -- max_tokens = 256,
    --      -- top_p = 0.9,
    --    },
    --  },
    --}
  })
EOF
