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
map <C-p> :call Check_perl_syntax()<CR>
function! Check_perl_syntax()
    let l:f = @%
    if (&filetype == "perl")
        execute ':!perl -t -c ' . l:f
    endif
endfunction

