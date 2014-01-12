" Search basics

" Center the next/previous search result
" confusing in some situations, disabled for now
" nmap n nzz
" nmap N Nzz

" Automatically add \v when searching so that regexp acts more like in perl
" Warning: this will require to escape '<' and '>' charachters when
" looking for git conflicts; in this case it's just easier to press backspace
" twice before typing <<<< or >>>>
" nnoremap / /\v
" vnoremap / /\v

" Search for word under cursor without jumpin to next occurrence
" http://stackoverflow.com/questions/4256697/vim-search-and-highlight-but-do-not-jump
map <Leader>h *``

" Ignore case
set ignorecase
" ...unless one upper case letter is present in the word
set smartcase

" replace all the occurences by default
set gdefault

" start searching without pressing enter
set incsearch

" highlight results
set hlsearch

" highlight matching parentheses...
set showmatch
" ...but stay out of the way (do not jump around)
set matchtime=0

" clear search results pressing space
" nnoremap <space> :nohlsearch<CR>
" NOTE: disabled because already present in vim-sensible:
" Use <C-L> to clear the highlighting of :set hlsearch.
" (taken from https://github.com/tpope/vim-sensible)
" if maparg('<C-L>', 'n') ==# ''
"   nnoremap <silent> <C-L> :nohlsearch<CR><C-L>
" endif

" ignore some directories
set wildignore+=*/tmp/*,*.pyc
