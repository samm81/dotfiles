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
"Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': 'yes \| ./install --no-update-rc > /dev/null' }
"Plug 'godlygeek/tabular'
"Plug 'ntpeters/vim-better-whitespace'
" :StringWhitespace to clean extra whitepsace
"Plug 'tpope/vim-obsession'
"Plug 'tpope/vim-surround'
"Plug 'tpope/vim-sleuth'
"Plug 'danro/rename.vim'

" any and all languages, *automagically*!
"Plug 'sheerun/vim-polyglot'
Plug 'MaxMEllon/vim-jsx-pretty'

"Plug 'nvie/vim-flake8', { 'for': 'python' }
"Plug 'vim-scripts/HTML-AutoCloseTag'

"Plug 'tmux-plugins/vim-tmux-focus-events'
"Plug 'tpope/vim-endwise'

"if filereadable(expand("~/.vimrc_background"))
"  Plug 'chriskempson/base16-vim'
"endif

"Plug 'dense-analysis/ale'

" smooth scrolling
"Plug 'psliwka/vim-smoothie'

call plug#end()

"nnoremap <Leader>ve :tabe $MYVIMRC<CR>
"nnoremap <Leader>vs :source $MYVIMRC<CR>
"nnoremap <Leader>ze :tabe $ZSHRC<CR>
"
"" for vim-polyglot
"set nocompatible
"
"" whitespace config
"let g:better_whitespace_filetypes_blacklist = ['diff', 'gitcommit', 'help']
"let g:strip_whitelines_at_eof=1
"let g:show_spaces_that_precede_tabs=1
"
"" Always show statusline
"set laststatus=2
"
"set wildmenu
"
"" fzf
"nnoremap <C-P> :FZF<CR>
"
"syntax on
"
"" numberline on the side
"set number relativenumber
"
"" better splitting
"set splitbelow splitright
"
"" show commands as they're being typed
"set showcmd
"
"" trying to save with W and quit with Q makes me feel dumb
":command! WQ wq
":command! Wq wq
":command! W w
":command! Q q
"
"" don't put me at the bottom of the screen
"set scrolloff=5 sidescrolloff=5
"
"" permanent undo
"set undofile undodir=~/.vimundo
"
"" incremental search
"set incsearch
"
"autocmd FileType text setl textwidth=80
"
"if filereadable(expand("~/.vimrc_background"))
"  let base16colorspace=256
"  source ~/.vimrc_background
"endif
"
"" flake8
"" autorun
""autocmd BufWritePost *.py call flake8#Flake8()
"" manually run
"nnoremap <Leader>8 :call flake8#Flake8()<CR>
"
"" copy to system clipboard
"nnoremap <Leader>c :w ! xclip -sel c<CR>
"vnoremap <Leader>c :w ! xclip -sel c<CR>
"
"" don't let n00bs use arrow keys or scroll
"" TODO: now I can't use arrow keys in `:`
"noremap  <Up>    <nop>
"noremap! <Up>    <nop>
"noremap  <Down>  <nop>
"noremap! <Down>  <nop>
"noremap  <Left>  <nop>
"noremap! <Left>  <nop>
"noremap  <Right> <nop>
"noremap! <Right> <nop>
"map <ScrollWheelUp> <nop>
"map <S-ScrollWheelUp> <nop>
"map <ScrollWheelDown> <nop>
"map <S-ScrollWheelDown> <nop>
"
"" autoreload changed buffers
"set autoread
"autocmd FocusGained,BufEnter * :checktime
"
"" https://github.com/roryokane/dotvim/blob/e72074788cd2d246603ca42be280915ded916096/vimrc#L578-L584
"" Disable regexes in search by default. When editing a search pattern,
"" change V to v to enable standard (mostly not-Vim-flavored) regexes.
"" see :help \V
"nnoremap / /\V
"xnoremap / /\V
"nnoremap ? ?\V
"xnoremap ? ?\V
"
"" ignore Chinese characters in spellcheck
"set spelllang=en,cjk
"
"" ale
"let g:ale_fixers = {'*': ['remove_trailing_lines', 'trim_whitespace']}
"let g:ale_fix_on_save = 1
"let g:ale_linters = {}
""let g:ale_lint_on_text_changed = 'never'
""let g:ale_lint_on_insert_leave = 0
"
""let g:ale_set_quickfix = 1
""let g:ale_open_list = 0
"
"let g:ale_sign_error = '✘'
"let g:ale_sign_warning = '⚠'
""highlight ALEErrorSign ctermbg=NONE ctermfg=red
""highlight ALEWarningSign ctermbg=NONE ctermfg=yellow
"
""set completeopt=menu,menuone,preview,noselect,noinsert
""let g:ale_completion_enabled = 1
""let g:ale_set_balloons = 1
"let g:ale_set_highlights = 0
"
""noremap  <Leader>ae :ALEGoToDefinition<CR>
""noremap  <Leader>ad :ALEDetail<CR>
""nnoremap <leader>af :ALEFix<cr>
""noremap  <Leader>ar :ALEFindReferences<CR>
"
"" move between linting errors
""nnoremap ]r :ALENextWrap<CR>
""nnoremap [r :ALEPreviousWrap<CR>
"
"" ale and elixir-ls
"let g:ale_linters.elixir = ['elixir-ls']
"let g:ale_fixers.elixir = ['mix_format']
"let g:ale_elixir_elixir_ls_release = $HOME . '/src/elixir-ls/release'
"let g:ale_elixir_elixir_ls_config = {
"\ 'elixirLS': {
"\   'dialyzerEnabled': v:false
"\ }
"\}
"
"" tabular
"if exists(":Tabularize")
"    nmap <Leader>t= :Tabularize /=<CR>
"    vmap <Leader>t= :Tabularize /=<CR>
"    nmap <Leader>t: :Tabularize /:\zs<CR>
"    vmap <Leader>t: :Tabularize /:\zs<CR>
"    nmap <Leader>tt :Tabularize/<Bar><CR>
"    vmap <Leader>tt :Tabularize/<Bar><CR>
"endif
"
"function! Blog_image()
"  let filename = expand('%:t:r')
"  let imagehtml = [
"    \'<div class="post-image">',
"    \'  <img src="/assets/' . filename . '/">',
"    \'  <p class="post-image-caption"></p>',
"    \'</div>',
"    \'',
"  \]
"  call append(line('.'), imagehtml)
"  normal jj$F/
"endfunction
"function! Blog_double_image()
"  let filename = expand('%:t:r')
"  let imagehtml = [
"    \'<div class="post-image post-image--split">',
"    \'  <div class="split-image-group split-image-group--left">',
"    \'   <img src="/assets/' . filename . '/">',
"    \'   <p class="post-image-caption"></p>',
"    \'  </div>',
"    \'  <div class="split-image-group split-image-group--right">',
"    \'   <img src="/assets/' . filename . '/">',
"    \'   <p class="post-image-caption"></p>',
"    \'  </div>',
"    \'</div>',
"    \'',
"  \]
"  call append(line('.'), imagehtml)
"  normal 3j$F/
"endfunction
"function! Blog_video()
"  let filename = expand('%:t:r')
"  let imagehtml = [
"    \'<div class="post-image">',
"    \'  <video controls loop>',
"    \'    <source src="/assets/' . filename . '/" type="video/mp4">',
"    \'  </video>',
"    \'  <p class="post-image-caption"></p>',
"    \'</div>',
"    \'',
"  \]
"  call append(line('.'), imagehtml)
"  normal 3j2f"h
"endfunction
"nnoremap <Leader>bi :call Blog_image()<CR>
"nnoremap <Leader>bd :call Blog_double_image()<CR>
"nnoremap <Leader>bv :call Blog_video()<CR>
"
"augroup syntax_elixir
"    autocmd!
"    autocmd Syntax elixir syntax match coverallsEndWarn /\#.*coveralls-ignore-end.*/
"    autocmd Syntax elixir highlight link coverallsEndWarn ErrorMsg
"    autocmd Syntax elixir syntax match changsetWarn /Changset/
"    autocmd Syntax elixir highlight link changsetWarn ErrorMsg
"    autocmd Syntax elixir syntax match MyAppWarn /MyApp/
"    autocmd Syntax elixir highlight link MyAppWarn ErrorMsg
"    autocmd Syntax elixir syntax match my_appWarn /my_app/
"    autocmd Syntax elixir highlight link my_appWarn ErrorMsg
"augroup end
"
"" for elixir
"function! NextDoc()
"    normal /@doc
"endfunction
"" precondition: placed on @doc
"function! CleanElixirAutoDocsSingleLine()
"    normal f"lDJxA"jV/"""d
"endfunction
"" precondition: placed on @doc
"" cleans up auto generated docs into three lines (for `get_*!`)
"function! CleanElixirAutoDocsGet()
"    normal 4jV/"""kd
"endfunction
"" precondition: placed on @doc of `list_*`
"function! CleanElixirAutoDocs()
"    call CleanElixirAutoDocsSingleLine()
"    call NextDoc()
"    call CleanElixirAutoDocsGet()
"    call NextDoc()
"    call CleanElixirAutoDocsSingleLine()
"    call NextDoc()
"    call CleanElixirAutoDocsSingleLine()
"    call NextDoc()
"    call CleanElixirAutoDocsSingleLine()
"    call NextDoc()
"    call CleanElixirAutoDocsSingleLine()
"endfunction
"
"function! SpecElixirList()
"    normal j0ww"fywj0f(l"tywkO@spec "fpA:: ["tpA.t()]
"endfunction
"function! SpecElixirGet()
"    normal /defw"fyf)/get!f(w"tywO@spec "fpF(lcwpos_integer()A :: "tpA.t()
"endfunction
"function! SpecElixirCreate()
"    normal /defw"fyf)j0ww"tywkO@spec "fphci(map()A :: {:ok, "tpA.t()} | {:error, Ecto.Changeset.t()}
"endfunction
"function! SpecElixirUpdate()
"    normal jw"fyf)f%l"tywO@spec "fphdi(h"tpa.t(), map()A :: {:ok, "tpA.t()} | {:error, Ecto.Changeset.t()}
"endfunction
"function! SpecElixirDelete()
"    normal jw"fyf)f%w"tywO@spec "fphdi(h"tpa.t()A :: {:ok, "tpA.t()} | {:error, Ecto.Changeset.t()}
"endfunction
"function! SpecElixirChange()
"    normal jw"fyf)f%w"tywO@spec "fphdi(h"tpa.t(), map()A :: Ecto.Changeset.t()
"endfunction
"
"function! SpecElixirAutoGen()
"    call SpecElixirList()
"    call NextDoc()
"    call SpecElixirGet()
"    call NextDoc()
"    call SpecElixirCreate()
"    call NextDoc()
"    call SpecElixirUpdate()
"    call NextDoc()
"    call SpecElixirDelete()
"    call NextDoc()
"    call SpecElixirChange()
"endfunction
"
"function! CleanElixirAutoGen()
"    normal md
"    call CleanElixirAutoDocs()
"    normal 'd
"    call SpecElixirAutoGen()
"endfunction
"nnoremap <Leader>ec :call CleanElixirAutoGen()<CR>
