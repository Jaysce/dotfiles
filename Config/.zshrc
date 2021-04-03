# 8888888888P  .d8888b.  888    888 8888888b.   .d8888b.  
#       d88P  d88P  Y88b 888    888 888   Y88b d88P  Y88b 
#      d88P   Y88b.      888    888 888    888 888    888 
#     d88P     "Y888b.   8888888888 888   d88P 888        
#    d88P         "Y88b. 888    888 8888888P"  888        
#   d88P            "888 888    888 888 T88b   888    888 
#  d88P       Y88b  d88P 888    888 888  T88b  Y88b  d88P 
# d8888888888  "Y8888P"  888    888 888   T88b  "Y8888P"  
                                                        
                                                        
fortune ~/dotfiles/quotes

# oh-my-zsh
export ZSH="/Users/sasindujayasinghe/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_AU.UTF-8
export EDITOR=nvim
export TERM=xterm-256color

# Aliases
alias r='ranger'
alias lg='lazygit'
alias ccs='spctl -a -t exec -vv'

# Plugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Other Customisation
eval "$(starship init zsh)"
export PATH=$HOME/.config/nvim/utils/bin:$PATH
