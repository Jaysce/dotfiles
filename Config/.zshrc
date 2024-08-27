#            _              
#           | |             
#    _______| |__  _ __ ___ 
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__ 
# (_)___|___/_| |_|_|  \___|

# Work
if [[ -f $HOME/.config/work-config/work-aliases.zsh ]]; then
    source $HOME/.config/work-config/work-aliases.zsh
fi


# Aliases
alias lg='lazygit'

# Path Exports
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # Use GNU utils instead of BSD
export PATH="/opt/homebrew/bin:$PATH" # Require for Apple Silicon
export PATH=/usr/local/anaconda3/bin/:$PATH # conda
# export JAVA_HOME="/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/"

# oh-my-zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_AU.UTF-8
export EDITOR=nvim
export TERM=xterm-256color
export BAT_THEME="base16"

# Aliases
alias r='ranger'
alias lg='lazygit'
alias ccs='spctl -a -t exec -vv'
alias cat='bat'
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias f='nvim $(fzf)'

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
