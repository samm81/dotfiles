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

" powerline
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
" Always show statusline
set laststatus=2

" fzf
set rtp+=~/src/fzf
nnoremap <C-P> :FZF<CR>

" trying to save with W and quit with Q makes me feel dumb
:command WQ wq
:command Wq wq
:command W w
:command Q q

" easier than hitting shift
nnoremap ; :
