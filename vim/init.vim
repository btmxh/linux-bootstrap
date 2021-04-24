echom "Welcome to vim/neovim"
echom "You are now officially better than 99% of dumb javascript bloat spammers"

" Functions
" Go to line XX for main code

function DetectProjectType()
  if filereadable('./CMakeLists.txt') or filereadable('./Makefile')
    return 'C' " also C++
  elseif filereadable('./build.gradle') or filereadable('./build.xml') or filereadable('./build.gradle.kts')
    return 'Java' " also kotlin
  elseif filereadable('./Cargo.toml')
    return 'Rust'
  endif

  if glob('./*.nimble')
    return 'Nim'
  endif
endfunction

function UseClangFormat()
  nunmap <leader>f
  nnoremap <leader>f :ClangFormat <CR>
endfunction

" Main code

call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" fzf file searching
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" git
Plug 'tpope/vim-fugitive'

" comments
Plug 'tpope/vim-commentary'

" brackets/parens/etc.
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-surround'

" C/C++ highlighting
Plug 'jackguo380/vim-lsp-cxx-highlight'

" C/C++ linting
Plug 'vim-syntastic/syntastic'

" neovim only plugins
if has('nvim')
  " Extension host (for vim-lsp-cxx-highlight and other utilities)
  Plug 'neoclide/coc.nvim'
endif

Plug 'rhysd/vim-clang-format'

call plug#end()

" Simple configs
set number
set relativenumber
set expandtab
set tabstop=2
set shiftwidth=2

" Keybinds
let mapleader=","

nnoremap <F2> :e $MYVIMRC <CR>
nnoremap <F3> :so $MYVIMRC <CR>

inoremap jk <ESC>

nnoremap <leader>c :echom "cosi" <CR>
" nnoremap <leader>f :CocCommand prettier.formatFile <CR>

nnoremap <leader>g :Files <CR>

" Plugin configs

" coc.nvim
set hidden " coc.nvim needs this
set updatetime=300

" tab key for autocomplete
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" ctrl+space suggest thingy
if has('nvim')
  inoremap <silent><expr> <C-space> coc#refresh()
else
  inoremap <silent><expr> <C-@> coc#refresh()
endif

" enter auto select first item if suggest window is open
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
nmap <silent> <leader>j <Plug>(coc-diagnostic-next)
nmap <silent> <leader>k <Plug>(coc-diagnostic-prev)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gt <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" K show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

nnoremap <leader>r <Plug>(coc-rename)

" xnoremap <C-f> <Plug>(coc-format-selected)
" nnoremap <C-f> <Plug>(coc-format-selected)

xnoremap <leader>f <Plug>(coc-format-selected)
nnoremap <leader>f <Plug>(coc-format-selected)

autocmd FileType c call UseClangFormat()
autocmd FileType cpp call UseClangFormat()

" syntastic
let g:syntastic_cpp_checkers = [ 'cpplint' ]
let g:syntastic_c_checkers = [ 'cpplint' ]
let g:syntastic_cpp_cpplint_exec = '~/.local/bin/cpplint'

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

