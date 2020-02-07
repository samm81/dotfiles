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
Plug 'ntpeters/vim-better-whitespace'
" :StringWhitespace to clean extra whitepsace
Plug 'tpope/vim-obsession'
Plug 'tpope/vim-surround'
Plug 'danro/rename.vim'

" any and all languages, *automagically*!
Plug 'sheerun/vim-polyglot'
" ...except elixir it seems
Plug 'elixir-editors/vim-elixir', { 'for': 'elixir' }

Plug 'nvie/vim-flake8', { 'for': 'python' }
Plug 'vim-scripts/HTML-AutoCloseTag'
Plug 'NikolayFrantsev/jshint2.vim', { 'for': 'javascript.jsx' }
"Plug 'chrisbra/csv.vim'

Plug 'tmux-plugins/vim-tmux-focus-events'

if filereadable(expand("~/.vimrc_background"))
  Plug 'chriskempson/base16-vim'
endif

call plug#end()

nnoremap <Leader>ve :tabe $MYVIMRC<CR>
nnoremap <Leader>vs :source $MYVIMRC<CR>

" whitespace config
let g:better_whitespace_filetypes_blacklist = ['diff', 'gitcommit', 'help']
let g:strip_whitelines_at_eof=1
let g:show_spaces_that_precede_tabs=1
" there's some bug with vim-better-whitespace, shouldn't need to do this...
nnoremap <Leader>s :StripWhitespace<CR>
vnoremap <Leader>s :StripWhitespace<CR>

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
set number relativenumber

" better splitting
set splitbelow splitright

" show commands as they're being typed
set showcmd

" trying to save with W and quit with Q makes me feel dumb
:command! WQ wq
:command! Wq wq
:command! W w
:command! Q q

" easier than hitting shift
"nnoremap ; :

" don't put me at the bottom of the screen
set scrolloff=5 sidescrolloff=5

" permanent undo
set undofile undodir=~/.vimundo

" default tabs to 4 spaces
set tabstop=4 softtabstop=0 expandtab shiftwidth=4 smarttab

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

" flake8
" autorun
"autocmd BufWritePost *.py call flake8#Flake8()
" manually run
nnoremap <Leader>8 :call flake8#Flake8()<CR>

" jshint2
let jshint2_read = 1
let jshint2_save = 1

" don't let n00bs use arrow keys
noremap  <Up>    <nop>
noremap! <Up>    <nop>
noremap  <Down>  <nop>
noremap! <Down>  <nop>
noremap  <Left>  <nop>
noremap! <Left>  <nop>
noremap  <Right> <nop>
noremap! <Right> <nop>

" autoreload changed buffers
set autoread
autocmd FocusGained,BufEnter * :checktime
