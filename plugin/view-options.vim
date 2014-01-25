" ====================
" === View options ===
" ====================

set noerrorbells visualbell t_vb=    " Disable all bells
set encoding=utf-8                   " Encoding
set number                           " display line numbers
" nnoremap <C-n> :setlocal number!<CR> " Toggle line numbers
set scrolloff=3                      " number of lines visible when scrolling
set sidescroll=3
set sidescrolloff=3
set splitright                       " position of the new split panes
set splitbelow
set nowrap
set autoindent                       " remember indent after going to the next line
set showcmd                          " show command that is being entered in the lower right
set showmode                         " show current mode (e.g. input, visual)
set cursorline                       " highlight currently edited line
set ruler                            " show cursor position in lower right
set backspace=indent,eol,start       " Allow extended backspace behaviour
set virtualedit=block                " allow placing the cursor after the last char
set shortmess+=I                     " disable welcome screen

" http://whiletruecode.com/post/adding-a-vertical-ruler-to-vim
if exists('+colorcolumn')
  set colorcolumn=81,101              " display vertical rulers for line length
endif

" ===============================================
" === Change status line color in insert mode ===
" ===============================================

" <http://fahdshariff.blogspot.co.uk/2012/06/vim-change-statusline-colour-based-on.html>

set laststatus=2
" change highlighting based on mode
" autocmd InsertLeave * highlight StatusLine cterm=bold ctermfg=white ctermbg=brown
autocmd InsertLeave * highlight StatusLine cterm=bold ctermfg=white ctermbg=240
" autocmd InsertEnter * highlight StatusLine cterm=bold ctermfg=white ctermbg=darkblue
autocmd InsertEnter * highlight StatusLine cterm=bold ctermfg=235 ctermbg=2
