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
export PATH="/usr/local/opt/llvm/bin:$PATH"
export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/"
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
alias cat='bat'

# Plugins
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Other Customisation
export PATH=$HOME/.local/bin:$PATH # Needed for ptSh (Might remove later)
export PATH=/usr/local/anaconda3/bin/:$PATH # conda
source ptSh_set_aliases
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""' # Needed to fzf hidden files
eval "$(starship init zsh)"

# Path exports
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # Use GNU utils instead of BSD

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/usr/local/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/usr/local/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/usr/local/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/usr/local/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

