"let Vundle install some plugins
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
"Plugin 'Lokaltog/vim-powerline'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

call vundle#end()

"much of the stuff was stolen from github.com/evilsocket/dotfiles
filetype plugin indent on
syntax on
colorscheme mustang

set number
set numberwidth=1

"searching
set incsearch
set hlsearch
set showmatch
set ignorecase smartcase

set hidden
set history=10000
"set cryptmethod=blowfish2

"tab
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set smarttab
set autoindent

set laststatus=2
set switchbuf=useopen
set backspace=indent,eol,start
set nocompatible
set fileformats=unix,mac,dos

set foldmethod=syntax
set foldlevel=5

set tags=tags;

"enable mouse capabilities
set mouse=a

"256 color terminal
set t_Co=256
set t_ut= "clear BCE so bg gets redrawn

"Clear highlighting on escape in normal mode
nnoremap <esc> :noh<return><esc>
nnoremap <esc>^[ <esc>^[

"http://vim.wikia.com/wiki/VimTip102
"set omnifunc=syntaxcomplete#Complete
inoremap <tab> <c-r>=Smart_TabComplete()<CR>
function! Smart_TabComplete()
  let line = getline('.')                         " current line

  let substr = strpart(line, -1, col('.'))        " from the start of the current
                                                  " line to one character on
                                                  " the cursor
  let substr = matchstr(substr, "[^ \t]*$")       " word till cursor
  if (strlen(substr)==0)                          " nothing to match on empty string
    return "\<tab>"
  endif
  let has_period = match(substr, '\.') != -1      " position of period, if any
  let has_slash = match(substr, '\/') != -1       " position of slash, if any
  if (!has_period && !has_slash)
    return "\<C-X>\<C-P>"                         " existing text matching
  elseif ( has_slash )
    return "\<C-X>\<C-F>"                         " file matching
  else
    return "\<C-X>\<C-O>"                         " plugin matching
  endif
endfunction

"recognize golang filetype
au BufNewFile,BufRead *.go set filetype=go

"mapping
"Ctrl+H opens hex edit mode
nnoremap <c-h> :%!xxd<cr>
map <C-n> :tabnew<cr>
map <C-w> :tabclose<cr>
nmap <C-D> :!/bin/bash<CR>

"check perl syntax
nmap <C-p> :call Check_perl_syntax()<CR>
function! Check_perl_syntax()
    let l:f = @%
    if (&filetype == "perl")
        execute ':!perl -t -c ' . l:f
    endif
endfunction

"if powerline installed, then show fancy symbols
if exists('g:Powerline_symbols')
    let g:Powerline_symbols = 'fancy'
endif


if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" unicode symbols
let g:airline_left_sep = '»'
let g:airline_left_sep = '▶'
let g:airline_right_sep = '«'
let g:airline_right_sep = '◀'
let g:airline_symbols.crypt = '🔒'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.maxlinenr = '☰'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.branch = '⎇'
let g:airline_symbols.paste = 'ρ'
let g:airline_symbols.paste = 'Þ'
let g:airline_symbols.paste = '∥'
let g:airline_symbols.spell = 'Ꞩ'
let g:airline_symbols.notexists = '∄'
let g:airline_symbols.whitespace = 'Ξ'
