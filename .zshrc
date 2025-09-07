# Exports --------------------------------------------------------------------------------
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # Use GNU utils instead of BSD
export LANG=en_AU.UTF-8
export EDITOR=nvim
export TERM=xterm-256color
export BAT_THEME="base16"
export MANPAGER="nvim +Man!"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'

# Aliases --------------------------------------------------------------------------------
alias cat='bat'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias ffe="n \$(ff)"
alias ffv="bat \$(ff)"
alias ffc="ff | pbcopy"
alias ffd="cd \$(dirname \$(ff))"
alias ls='eza -lh --group-directories-first --icons=auto'
alias la='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ld='lazydocker'
alias lg='lazygit'
alias n='nvim'
alias cd="zd"
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}

# ZSH Options ----------------------------------------------------------------------------
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd
setopt CDABLE_VARS          # Change directory to a path stored in a variable
setopt EXTENDED_GLOB        # Use extended globbing syntax
setopt HIST_IGNORE_ALL_DUPS # Remove older duplicate entries from history
setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks from history items
setopt INC_APPEND_HISTORY   # Save history entries as soon as they are entered
setopt SHARE_HISTORY        # Share history between different instances
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shells

HISTFILE=$HOME/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
WORDCHARS=''

# ZSH Plugins ----------------------------------------------------------------------------
if type brew &>/dev/null; then
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
fi
autoload -Uz compinit
compinit

if type brew &>/dev/null; then
    BREW_PREFIX=$(brew --prefix)

    [[ -f $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
        source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    
    [[ -f $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
        source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

# Other Tools ----------------------------------------------------------------------------
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Work -----------------------------------------------------------------------------------
if [[ -f $HOME/.config/work-config/work-aliases.zsh ]]; then
    source $HOME/.config/work-config/work-aliases.zsh
fi
