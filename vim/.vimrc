set encoding=utf-8

" vim-plug
" :PlugInstall to install new plugins
call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/src/fzf', 'do': 'yes \| ./install' }
Plug 'altercation/vim-colors-solarized'
Plug 'leshill/vim-json'
Plug 'lambdatoast/elm.vim'
Plug 'godlygeek/tabular'
Plug 'tpope/vim-surround'

call plug#end()

" powerline
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
" Always show statusline
set laststatus=2

" fzf
nnoremap <C-P> :FZF<CR>

" solarized
syntax on
set background=dark
colorscheme solarized

" tabs
set tabstop=4
set softtabstop=0
set shiftwidth=4
set noexpandtab
set smartindent

" .md is markdown
au BufRead,BufNewFile *.md set filetype=markdown

" numberline on the side
set number
set relativenumber

" better splitting
set splitbelow
set splitright

" undo
set undodir=~/.vim/undo
set undofile
set undolevels=1000
set undoreload=10000

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
