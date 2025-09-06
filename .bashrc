# All the default Omarchy aliases and functions
# (don't mess with these directly, just overwrite them here!)
source ~/.local/share/omarchy/default/bash/rc

alias cat=bat
alias lg=lazygit
alias n=nvim
alias ffe="n \$(ff)"
alias ffv="bat \$(ff)"
alias ffd="cd \$(dirname \$(ff))"

export STARSHIP_CONFIG=~/.config/starship/starship.toml
