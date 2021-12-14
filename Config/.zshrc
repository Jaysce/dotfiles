# 8888888888P  .d8888b.  888    888 8888888b.   .d8888b.  
#       d88P  d88P  Y88b 888    888 888   Y88b d88P  Y88b 
#      d88P   Y88b.      888    888 888    888 888    888 
#     d88P     "Y888b.   8888888888 888   d88P 888        
#    d88P         "Y88b. 888    888 8888888P"  888        
#   d88P            "888 888    888 888 T88b   888    888 
#  d88P       Y88b  d88P 888    888 888  T88b  Y88b  d88P 
# d8888888888  "Y8888P"  888    888 888   T88b  "Y8888P"  

# fortune ~/dotfiles/quotes

# Path Exports
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # Use GNU utils instead of BSD
export PATH="/opt/homebrew/bin:$PATH" # Require for Apple Silicon
export PATH=/usr/local/anaconda3/bin/:$PATH # conda
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/"

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
alias cat='bat'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# ZSH Plugins & Customization
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

    autoload -Uz compinit
    compinit
  fi
eval "$(starship init zsh)"
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""' # Needed to fzf hidden files

# Conda
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
