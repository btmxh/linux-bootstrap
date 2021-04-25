echom "Welcome to vim/neovim"
echom "You are now officially better than 99% of dumb javascript bloat spammers"

" Functions
" Go to line XX for main code

function DetectProjectType()
  if filereadable('./CMakeLists.txt') || filereadable('./Makefile')
    return 'C' " also C++
  elseif filereadable('./build.gradle') || filereadable('./build.xml') || filereadable('./build.gradle.kts')
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

function GetBuildFile()
  let buildfiles = ['CMakeLists.txt', 'Makefile', 'build.gradle', 'build.xml', 'build.gradle.kts', 'Cargo.toml']

  for buildfile in buildfiles
    if(filereadable(buildfile))
      return buildfile
    endif
  endfor

  " TODO: add nim support
  return ""
endfunction

function OpenBuildFile()
  let buildfile = GetBuildFile()
  if len(buildfile) > 0
    exec 'e' buildfile
  endif
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

" C/C++/Java code formating
Plug 'rhysd/vim-clang-format'

" onedark style
Plug 'joshdick/onedark.vim'

" airline
Plug 'vim-airline/vim-airline'

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

nnoremap <leader>g :GFiles <CR>

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

xmap <leader>r <Plug>(coc-format-selected)
nmap <leader>r <Plug>(coc-format-selected)

nmap <leader>f <Plug>(coc-format)

" vim-clang-format
autocmd FileType java call UseClangFormat()
autocmd FileType c call UseClangFormat()
autocmd FileType cpp call UseClangFormat()

" syntastic
let g:syntastic_cpp_checkers = [ 'cpplint' ]
let g:syntastic_c_checkers = [ 'cpplint' ]
let g:syntastic_cpp_cpplint_exec = '~/.local/bin/cpplint'

let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" theme
colorscheme onedark

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
    "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
endif

let g:airline_theme='onedark'

hi VertSplit guifg=#606060

let g:fzf_colors = { 'border': ['fg', 'VertSplit'] }

" cmake keybinds
nnoremap <F4> :call OpenBuildFile()<CR>
nnoremap <F5> :CMakeGenerate<CR>
nnoremap <F6> :CMakeBuild<CR>

