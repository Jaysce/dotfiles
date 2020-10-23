" d8b          d8b 888                d8b               
" Y8P          Y8P 888                Y8P               
"                  888                                  
" 888 88888b.  888 888888    888  888 888 88888b.d88b.  
" 888 888 "88b 888 888       888  888 888 888 "888 "88b 
" 888 888  888 888 888       Y88  88P 888 888  888  888 
" 888 888  888 888 Y88b.  d8b Y8bd8P  888 888  888  888 
" 888 888  888 888  "Y888 Y8P  Y88P   888 888  888  888


" - Plugins --------------------------------------------------------------------
source $HOME/.config/nvim/vim-plug/plugins.vim

" - General Settings -----------------------------------------------------------
source $HOME/.config/nvim/general/settings.vim

" - Plugin Settings ------------------------------------------------------------
source $HOME/.config/nvim/plug-config/coc.vim
source $HOME/.config/nvim/plug-config/sneak.vim
source $HOME/.config/nvim/plug-config/signify.vim
source $HOME/.config/nvim/plug-config/closetag.vim

" - Key Bindings ---------------------------------------------------------------
source $HOME/.config/nvim/keys/mappings.vim

" - Themes ---------------------------------------------------------------------
source $HOME/.config/nvim/themes/tokyonight.vim
source $HOME/.config/nvim/themes/airline.vim

lua require'plug-colorizer'