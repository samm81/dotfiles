" apparently needed
set nocompatible
set encoding=utf-8

" vim-plug
call plug#begin()

Plug 'junegunn/fzf', { 'dir': '~/src/fzf', 'do': 'yes \| ./install' }

call plug#end()

" .md is markdown
au BufRead,BufNewFile *.md set filetype=markdown

" tabs
set smartindent
set tabstop=4
set shiftwidth=4
set noexpandtab

" numberline on the side
set number
set relativenumber

" Use 256 colours (Use this setting only if your terminal supports 256 colours)
set t_Co=256

" colors!
syntax on

" better splitting
set splitbelow
set splitright

" undo
set undodir=~/.vim/undo
set undofile
set undolevels=1000
set undoreload=10000

" powerline
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
" Always show statusline
set laststatus=2

" show commands as they're being typed
set showcmd

" latex
command Latex execute "!latex % && open %:r.pdf"
nnoremap <F3> :Latex<CR>

" trying to save with W and quit with Q makes me feel dumb
:command WQ wq
:command Wq wq
:command W w
:command Q q

" easier than hitting shift
nnoremap ; :

" delete comment character when joining lines
if version >= 704
	set formatoptions+=j
endif

" when finding don't put me at the bottom of the screen
set scrolloff=5
set sidescrolloff=5
