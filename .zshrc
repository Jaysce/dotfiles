# Exports --------------------------------------------------------------------------------
export LANG=en_AU.UTF-8
export EDITOR=nvim
export TERM=xterm-256color
export BAT_THEME="base16"
export MANPAGER="nvim +Man!"
export STARSHIP_CONFIG=~/.config/starship/starship.toml
export XDG_CONFIG_HOME="$HOME/.config"

# OS Detection
if [[ "$OSTYPE" == "darwin"* ]]; then
    IS_MACOS=true
else
    IS_MACOS=false
fi

# macOS-specific exports
if $IS_MACOS; then
    export PATH="/usr/local/opt/llvm/bin:$PATH"
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
fi

# Handle bat/batcat and fd/fdfind differences
if command -v batcat &>/dev/null; then
    alias bat='batcat'
fi
if command -v fdfind &>/dev/null; then
    alias fd='fdfind'
    export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
else
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi

# Aliases --------------------------------------------------------------------------------
alias cat='bat'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias ffe="n \$(ff)"
alias ffv="bat \$(ff)"
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

# Clipboard alias (pbcopy/xclip)
if $IS_MACOS; then
    alias ffc="ff | pbcopy"
else
    alias pbcopy='xclip -selection clipboard'
    alias pbpaste='xclip -selection clipboard -o'
    alias ffc="ff | xclip -selection clipboard"
fi

alias ffd="cd \$(dirname \$(ff))"

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
if $IS_MACOS && type brew &>/dev/null; then
    # macOS with Homebrew
    FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
    FPATH=$(brew --prefix)/share/zsh/site-functions:$FPATH
    autoload -Uz compinit
    compinit

    BREW_PREFIX=$(brew --prefix)
    [[ -f $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
        source $BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
        source $BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    [[ -f $BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && \
        source $BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh
else
    # Linux (WSL/Ubuntu) with plugins in ~/.zsh
    FPATH=$HOME/.zsh/zsh-completions/src:$FPATH
    autoload -Uz compinit
    compinit

    [[ -f $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && \
        source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
    [[ -f $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] && \
        source $HOME/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
    [[ -f $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh ]] && \
        source $HOME/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ''

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Other Tools ----------------------------------------------------------------------------
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$BUN_INSTALL/_bun" ]] && source "$BUN_INSTALL/_bun"

# Work -----------------------------------------------------------------------------------
if [[ -f $HOME/.config/work-config/work-aliases.zsh ]]; then
    source $HOME/.config/work-config/work-aliases.zsh
fi
