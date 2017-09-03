set encoding=utf-8

" vim-plug
" :PlugInstall to install new plugins
call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --no-update-rc > /dev/null' }
Plug 'altercation/vim-colors-solarized'
Plug 'leshill/vim-json'
" Plug 'godlygeek/tabular'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-obsession'
" Plug 'tpope/vim-surround'
Plug 'tpope/vim-sleuth'
Plug 'danro/rename.vim'

Plug 'othree/yajs.vim', { 'for': 'javascript' }
Plug 'cakebaker/scss-syntax.vim', { 'for': ['sass', 'scss'] }

Plug 'ElmCast/elm-vim', { 'for': 'elm' }
Plug 'elixir-lang/vim-elixir', { 'for': 'elixir' }

call plug#end()

" powerline
python3 from powerline.vim import setup as powerline_setup
python3 powerline_setup()
python3 del powerline_setup
" Always show statusline
set laststatus=2

" fzf
nnoremap <C-P> :FZF<CR>

" solarized
syntax on
set background=dark
colorscheme solarized

" .md is markdown
au BufRead,BufNewFile *.md set filetype=markdown

" numberline on the side
set number
set relativenumber

" better splitting
set splitbelow
set splitright

" show commands as they're being typed
set showcmd

" trying to save with W and quit with Q makes me feel dumb
:command WQ wq
:command Wq wq
:command W w
:command Q q

" easier than hitting shift
nnoremap ; :

" don't put me at the bottom of the screen
set scrolloff=5
set sidescrolloff=5

" permanent undo
set undofile
set undodir=~/.vimundo
