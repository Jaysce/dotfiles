call plug#begin('~/.nvim/autoload/plugged')

Plug 'sheerun/vim-polyglot'                         " Better syntax support
Plug 'jiangmiao/auto-pairs'                         " Auto close brackets
Plug 'joshdick/onedark.vim'                         " Atom Dark theme
Plug 'wadackel/vim-dogrun'                          " Dark purple theme
Plug 'ghifarit53/tokyonight-vim'                    " Dark sythmwave theme
Plug 'sainnhe/gruvbox-material'                     " Gruuuuvbox
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
Plug 'liuchengxu/vim-which-key'                     " Keybinding popup
Plug 'voldikss/vim-floaterm'                        " Floating terminal
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()
