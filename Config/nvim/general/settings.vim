"--- Basic Settings ------------------------------------------------------------

let g:mapleader = "\<Space>"

syntax enable
set hidden
set nowrap
set encoding=utf-8
set pumheight=10
set fileencoding=utf-8
set ruler
set iskeyword+=-
set mouse=a
set t_Co=256
set conceallevel=0
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smarttab
set expandtab
set smartindent
set autoindent
set laststatus=0
set rnu nu
set cursorline
set background=dark
set cmdheight=1
set noshowmode
set nobackup
set nowritebackup
set updatetime=300
set timeoutlen=500
set formatoptions-=cro
set clipboard=unnamedplus
nnoremap <silent> <esc><esc> :noh<return>
"set autochdir " Your working directory will always be the same as your working directory

cmap w!! w !udo tee %

"--- Integrated Terminal Settings ----------------------------------------------

" Open new split panes to right and below
set splitright
set splitbelow

" Turn terminal to normal mode with escape
tnoremap <Esc> <C-\><C-n>

" Start terminal in insert mode
au BufEnter * if &buftype == 'terminal' | :startinsert | endif

" Open terminal on Ctrl + n
function! OpenTerminal()
  split term://zsh
  resize 10
endfunction
nnoremap <c-n> :call OpenTerminal()<CR>s

" Escape to exit fzf
if has("nvim")
  au TermOpen * tnoremap <Esc> <c-\><c-n>
  au FileType fzf tunmap <Esc>
endif
