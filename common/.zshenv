if [[ -x "$HOME/.nix-profile/bin/zsh" ]]; then
    export SHELL="$HOME/.nix-profile/bin/zsh"
elif command -v zsh >/dev/null 2>&1; then
    export SHELL="$(command -v zsh)"
fi
