call plug#begin('~/.config/nvim/autoload/plugged')

Plug 'sheerun/vim-polyglot'                         " Better syntax support
Plug 'jiangmiao/auto-pairs'                         " Auto close brackets
Plug 'joshdick/onedark.vim'                         " Dark theme
Plug 'wadackel/vim-dogrun'                          " Dark purple theme
Plug 'neoclide/coc.nvim', {'branch': 'release'}     " Intellisense
Plug 'ryanoasis/vim-devicons'                       " Icons in NERDTree
Plug 'vim-airline/vim-airline'                      " Status line
Plug 'vim-airline/vim-airline-themes'               " Status line themes
Plug 'preservim/nerdcommenter'                      " Easy comments
Plug 'justinmk/vim-sneak'                           " Text jumping
Plug 'mhinz/vim-signify'                            " Git on number line
Plug 'tpope/vim-fugitive'                           " Git support
Plug 'tpope/vim-rhubarb'                            " Github
Plug 'junegunn/gv.vim'                              " Git commit browser
Plug 'alvan/vim-closetag'                           " Auto close

call plug#end()