set encoding=utf-8

" vim-plug
" auto install
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" :PlugInstall to install new plugins
call plug#begin()

" allows for `:help plug-options`
Plug 'junegunn/vim-plug'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --no-update-rc > /dev/null' }
" Plug 'godlygeek/tabular'
Plug 'ntpeters/vim-better-whitespace'
Plug 'tpope/vim-obsession'
" Plug 'tpope/vim-surround'
Plug 'tpope/vim-sleuth'
Plug 'danro/rename.vim'

" any and all languages, *automagically*!
Plug 'sheerun/vim-polyglot'

if filereadable(expand("~/.vimrc_background"))
  Plug 'chriskempson/base16-vim'
endif

call plug#end()

" powerline
" TODO check if `python3` exists
"python3 from powerline.vim import setup as powerline_setup
"python3 powerline_setup()
"python3 del powerline_setup
" Always show statusline
set laststatus=2

" fzf
nnoremap <C-P> :FZF<CR>

syntax on

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
"nnoremap ; :

" don't put me at the bottom of the screen
set scrolloff=5
set sidescrolloff=5

" permanent undo
set undofile
set undodir=~/.vimundo

" default tabs to 4 spaces
set tabstop=4
set shiftwidth=4
set noexpandtab

" incremental search
set incsearch

" .jinja is jinja.html
autocmd BufNewFile,BufRead *.jinja set syntax=jinja.html
" .md is markdown
autocmd BufRead,BufNewFile *.md set filetype=markdown

autocmd FileType text setl textwidth=80

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif
