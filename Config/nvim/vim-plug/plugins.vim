call plug#begin('~/.config/nvim/autoload/plugged')

" Better syntax support
Plug 'sheerun/vim-polyglot'
" Auto close brackets
Plug 'jiangmiao/auto-pairs'
" Themes
Plug 'joshdick/onedark.vim'
Plug 'wadackel/vim-dogrun'
" Intellisense
Plug 'neoclide/coc.nvim', {'branch': 'release'}
" Git changes in ruler
Plug 'airblade/vim-gitgutter'
" Icons in NERDTree
Plug 'ryanoasis/vim-devicons'
" Status line
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Easy comments
Plug 'preservim/nerdcommenter'
" Text jumping
Plug 'justinmk/vim-sneak'

call plug#end()
