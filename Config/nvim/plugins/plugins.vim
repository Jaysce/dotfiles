call plug#begin("~/.nvim/plugged")

Plug 'sheerun/vim-polyglot'
Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdcommenter'
Plug 'alvan/vim-closetag'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'rhysd/vim-clang-format'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()

" Theme
if (has("termguicolors"))
 set termguicolors
endif
set background=dark

packadd! dracula_pro
syntax enable
let g:dracula_colorterm = 0
colorscheme dracula_pro
