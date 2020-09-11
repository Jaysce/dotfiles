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
Plug 'preservim/nerdtree'
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'jiangmiao/auto-pairs'
Plug 'wadackel/vim-dogrun'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'ap/vim-css-color'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

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
set clipboard+=unnamedplus
set termguicolors
set colorcolumn=80
highlight ColorColumn ctermbg=0 guibg=lightgrey
colorscheme aubergine
set background=dark
hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE
nnoremap <silent> <esc><esc> :noh<return>

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

nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

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

" Navigate code completion using Tab and Shift Tab
" and complete line using Enter
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <Return> pumvisible() ? "\<C-y>" : "\<Return>"

" Ctrl Space to refresh COC
inoremap <silent><expr> <c-space> coc#refresh()

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

"--- LightLine Settings --------------------------------------------------------

let g:lightline = {
  \ 'colorscheme': 'dogrun',
  \ 'active': {
  \     'left': [ ['mode', 'paste'],
  \               [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
  \ },
  \ 'component_function': {
  \     'gitbranch': 'FugitiveLine'
  \ },
  \ 'subseparator': { 'left': '\u2771', 'right': '\u2770' }
  \ }

function! FugitiveLine()
    let _ = fugitive#head()
    return strlen(_) ? ' '._ : ''
endfunction

"--- Goyo / LimeLight Settings -------------------------------------------------

nnoremap <silent> <leader>l :Goyo<CR>

" Use j and k to move between lines when in wrapped mode
nnoremap <expr> j v:count ? 'j' : 'gj'
nnoremap <expr> k v:count ? 'k' : 'gk'

" Enter / exit focused writing mode
autocmd! User GoyoEnter nested call <SID>EnterWritingMode()
autocmd! User GoyoLeave nested call <SID>ExitWritingMode()

function s:EnterWritingMode()
    Limelight
    setlocal wrap linebreak spell
endfunction

function s:ExitWritingMode()
    Limelight!
    setlocal nowrap
endfunction

let g:limelight_conceal_guifg = '#373C57'
