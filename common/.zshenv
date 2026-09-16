# Prefer the Nix-managed zsh when it exists.
if [[ -x "$HOME/.nix-profile/bin/zsh" ]]; then
    export SHELL="$HOME/.nix-profile/bin/zsh"
elif command -v zsh >/dev/null 2>&1; then
    export SHELL="$(command -v zsh)"
fi

# Add Rust/Cargo tools to PATH when Cargo's environment file exists.
if [[ -r "$HOME/.cargo/env" ]]; then
    . "$HOME/.cargo/env"
fi
