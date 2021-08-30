"--- Basic Settings ------------------------------------------------------------

let g:mapleader = "\<Space>"

syntax enable
set nocompatible
set hidden
set nowrap
set encoding=utf-8
set fileencodings=utf-8
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
set laststatus=2
set nu rnu
set cursorline
set pumheight=10
set cmdheight=1
set noshowmode
set nobackup
set nowritebackup
set updatetime=300
set timeoutlen=500
set formatoptions-=cro
set clipboard=unnamedplus
set title
set scrolloff=10
set nosc noru nosm
set lazyredraw " Don't redraw while executing macros (good performance config)
set ignorecase " Ignore case when searching
" indents
filetype plugin indent on
set backspace=start,eol,indent
" Finding files - Search down into subfolders
set path+=**
set wildignore+=*/node_modules/*

" Turn off paste mode when leaving insert
autocmd InsertLeave * set nopaste

" Add asterisks in block comments
set formatoptions+=r

"--- Theme ---------------------------------------------------------------------

if exists("&termguicolors") && exists("&winblend")
  syntax enable
  set termguicolors
  set winblend=0
  set wildoptions=pum
  set pumblend=5
  set background=dark
  let g:gruvbox_material_background = 'hard'
  colorscheme gruvbox-material
endif

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
nnoremap <c-n> :call OpenTerminal()<CR>
