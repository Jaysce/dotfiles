call plug#begin("~/.nvim/plugged")

Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
" Plug 'jiangmiao/auto-pairs'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ryanoasis/vim-devicons'
Plug 'preservim/nerdcommenter'
Plug 'alvan/vim-closetag'
Plug 'rhysd/vim-clang-format'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
Plug 'tpope/vim-surround'
Plug 'sainnhe/gruvbox-material'
Plug 'ntk148v/vim-horizon'
Plug 'eddyekofo94/gruvbox-flat.nvim'
Plug 'folke/tokyonight.nvim', { 'branch': 'main' }

Plug 'windwp/nvim-autopairs'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'kyazdani42/nvim-web-devicons'
Plug 'hoob3rt/lualine.nvim'
Plug 'kdheepak/tabline.nvim'

call plug#end()
