" 888     888 8888888 888b     d888 8888888b.   .d8888b.
" 888     888   888   8888b   d8888 888   Y88b d88P  Y88b
" 888     888   888   88888b.d88888 888    888 888    888
" Y88b   d88P   888   888Y88888P888 888   d88P 888
"  Y88b d88P    888   888 Y888P 888 8888888P"  888
"   Y88o88P     888   888  Y8P  888 888 T88b   888    888
"    Y888P      888   888   "   888 888  T88b  Y88b  d88P
"     Y8P     8888888 888       888 888   T88b  "Y8888P"


"--- Vim Plug ------------------------------------------------------------------

call plug#begin('~/.vim/plugged')

Plug 'morhetz/gruvbox'
Plug 'preservim/nerdtree'
Plug 'preservim/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'maxmellon/vim-jsx-pretty'

call plug#end()

"--- Basic Settings ------------------------------------------------------------

syntax enable
set noerrorbells
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set rnu nu
set nowrap
set smartcase
set incsearch
set noshowmode
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey
colorscheme gruvbox
set background=dark
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE

"--- NERDTree Settings ---------------------------------------------------------

let g:NERDTreeShowHidden = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
nnoremap <silent> <C-f> :NERDTreeToggle<CR>

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

"--- Window / Tab Management Settings ------------------------------------------

let mapleader = " "

" Move between split windows
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

" Move next / prev tab
nnoremap <leader>. gt<CR>
nnoremap <leader>, gT<CR>

" Go to tab by number
noremap <leader>1 1gt
noremap <leader>2 2gt
noremap <leader>3 3gt
noremap <leader>4 4gt
noremap <leader>5 5gt
noremap <leader>6 6gt
noremap <leader>7 7gt
noremap <leader>8 8gt
noremap <leader>9 9gt
noremap <leader>0 :tablast<cr>

"--- Fuzzy Finder Settings -----------------------------------------------------

nnoremap <C-p> :FZF<CR>
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-s': 'split',
  \ 'ctrl-v': 'vsplit'
  \}

"--- COC Settings --------------------------------------------------------------

let g:coc_global_extensions = ['coc-emmet', 'coc-css', 'coc-html', 'coc-json', 'coc-prettier', 'coc-tsserver']

" GoTo code navigation.
nmap <silent> <leader>gd <Plug>(coc-definition)
nmap <silent> <leader>gy <Plug>(coc-type-definition)
nmap <silent> <leader>gi <Plug>(coc-implementation)
nmap <silent> <leader>gr <Plug>(coc-references)
