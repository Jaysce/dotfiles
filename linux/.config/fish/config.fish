# CachyOS Defaults -----------------------------------------------------------------------
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Disable CachyOS fastfetch greeting
function fish_greeting
end

# Exports --------------------------------------------------------------------------------
set -gx LANG en_AU.UTF-8
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx SUDO_EDITOR nvim
set -gx TERM xterm-256color
set -gx BAT_THEME base16
set -gx XDG_CONFIG_HOME "$HOME/.config"
set -gx TMUX_CONFIG_DIR "$XDG_CONFIG_HOME/tmux"
set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --exclude .git"
set -Ux ELECTRON_OZONE_PLATFORM_HINT auto # 1password key repeat bug

fish_add_path --global --move --prepend "$HOME/.local/bin"

# Aliases --------------------------------------------------------------------------------
alias cat bat
alias ff "fzf --preview 'bat --style=numbers --color=always {}'"
alias ffe "n (ff)"
alias ffv "bat (ff)"
alias lta "lt -a"
alias ld lazydocker
alias lg lazygit
alias n nvim
alias oc opencode
alias t tmx
alias wm workmux
alias gpo "git pull origin"

# Clipboard aliases
alias pbcopy wl-copy
alias pbpaste wl-paste
alias ffc "ff | wl-copy"

# Functions ------------------------------------------------------------------------------
function ffd --description "Open the selected fzf file's directory"
    set -l file (ff)
    test -n "$file"; and cd (dirname "$file")
end

# Smart cd: use zoxide if target isn't a direct path
# Usage: zd [directory]
# Example: zd ~/projects
#          zd myproject    # uses zoxide to fuzzy match
function zd --description "Smart cd: direct paths first, then zoxide"
    if test (count $argv) -eq 0
        builtin cd ~
        return
    else if test -d "$argv[1]"
        builtin cd "$argv[1]"
        return
    end

    z $argv
    and begin
        printf "\U000F17A9 "
        pwd
    end
    or echo "Error: Directory not found"
end

function cd --wraps=zd --description "Smart cd through zoxide"
    zd $argv
end

function is_integrated_terminal --description "Check if running in an IDE/editor integrated terminal"
    set -q VSCODE_INJECTION; or \
    set -q VSCODE_PID; or \
    test "$TERM_PROGRAM" = vscode; or \
    set -q INSIDE_EMACS; or \
    set -q ZED_TERM; or \
    set -q NVIM; or \
    set -q NVIM_LISTEN_ADDRESS
end

function auto_start_zellij --description "Auto-start Zellij"
    set -q SKIP_AUTO_TMUX; and return
    set -q SKIP_AUTO_ZELLIJ; and return
    is_integrated_terminal; and return
    set -q ZELLIJ; and return
    set -q TMUX; and return
    set -q SSH_CONNECTION; and return
    command -q zellij; or return

    zellij attach --create main
end

# Other Tools ----------------------------------------------------------------------------
if command -q zoxide
    zoxide init fish | source
end

if command -q workmux
    workmux completions fish | source
end

if status is-interactive
    auto_start_zellij
end
