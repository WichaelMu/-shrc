set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'tpope/vim-fugitive'
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
" Plugin 'ascenator/L9', {'name': 'newL9'}

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

nmap <silent> <C-N> :cn<CR>zv
nmap <silent> <C-P> :cp<CR>zv

" Define a custom function to open a terminal on the right side
function! OpenTerminalRight()
  " Close all other windows except the current one
  only

  " Split the window vertically
  vsplit

  " Move to the right window
  wincmd l

  " Open terminal in the right window
  terminal

  wincmd j
  wincmd c

  " Adjust window sizes equally
  wincmd =
endfunction

" Define a custom command :T to call the function
command! T call OpenTerminalRight()
command! E Ex

command! -range=% C silent! execute 'normal! "+y'<CR>
xmap <silent> <Leader>c :C<CR>
nmap <silent> <Leader>c :'<,'>C<CR>

set number
set relativenumber
set nowrap
set ruler

call plug#begin('~/.vim/plugged')
Plug 'drewtempelmeyer/palenight.vim'
Plug 'OmniSharp/omnisharp-vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'dense-analysis/ale'
call plug#end()

" colorscheme palenight

set backspace=indent,eol,start

Plugin 'davidhalter/jedi-vim'

command! -nargs=1 G execute 'vimgrep /' . <q-args> . '/gj **/*' | copen | wincmd = | set nowrap

vmap <leader>c "+y

let g:clang_library_path='/usr/lib/llvm-17/lib/libclang-17.so.1'

if !exists(":DiffOrig")
    command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
          \ | wincmd p | diffthis
endif

command! D exec "vert new | setlocal buftype=nofile | read !git diff --word-diff=color --word-diff-regex=. " . shellescape(expand('%')) . " | colordiff" | exec "AnsiEsc"

command L set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¶,precedes:«,extends:» | set list

command -nargs=1 TT tabnew <q-args>
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <C-h> :tabprevious<CR>
nnoremap <C-l> :tabnext<CR>

" Auto stuffs
" Only lint while you type, not on every file write
let g:ale_lint_on_text_changed = 'normal'
let g:ale_lint_on_enter = 1

" Use whichever linters you enabled above
let g:ale_linters = {
\   'python': [ 'pyright' ],
\}

" let g:ale_warn_about_trailing_whitespace = 0
" let g:ale_warn_about_trailing_blank_lines = 0
"
" <leader>l toggle globally
nnoremap <leader>p :ALEToggle<CR>
" <leader>b toggle just this buffer
" nnoremap <leader>b :ALEToggleBuffer<CR>
" <leader>c run checks once even if disabled
" nnoremap <leader>c :ALELint<CR>
