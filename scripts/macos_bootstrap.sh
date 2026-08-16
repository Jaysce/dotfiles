#!/bin/bash

#                         ____   _____    _____      _
#                        / __ \ / ____|  / ____|    | |
#   _ __ ___   __ _  ___| |  | | (___   | (___   ___| |_ _   _ _ __
#  | '_ ` _ \ / _` |/ __| |  | |\___ \   \___ \ / _ \ __| | | | '_ \
#  | | | | | | (_| | (__| |__| |____) |  ____) |  __/ |_| |_| | |_) |
#  |_| |_| |_|\__,_|\___|\____/|_____/  |_____/ \___|\__|\__,_| .__/
#                                                             | |
#                                                             |_|

# bash <(curl -sSL https://raw.githubusercontent.com/Jaysce/dotfiles/master/scripts/macos_bootstrap.sh)

load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  local brew_bin
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$brew_bin" ]]; then
      eval "$("$brew_bin" shellenv)"
      return 0
    fi
  done

  return 1
}

install_homebrew() {
  if load_homebrew; then
    return
  fi

  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if ! load_homebrew; then
    echo "❌ Homebrew installation completed, but brew was not found." >&2
    exit 1
  fi

  local brew_bin brew_shellenv
  brew_bin="$(command -v brew)"
  brew_shellenv="eval \"\$($brew_bin shellenv)\""
  touch "$HOME/.zprofile"
  if ! grep -Fqx "$brew_shellenv" "$HOME/.zprofile"; then
    printf '%s\n' "$brew_shellenv" >>"$HOME/.zprofile"
  fi
  eval "$("$brew_bin" shellenv)"
}

base_brew=(
  git
  gh
)

brew=(
  ack
  ast-grep
  bat
  bazelisk
  buf
  ccls
  cmake
  colima
  curl
  docker
  docker-compose
  docker-credential-helper
  doggo
  eza
  fd
  fzf
  gcc
  git-delta
  go-task
  grpcurl
  gum
  herdr
  httpie
  hexyl
  jq
  lazydocker
  lazygit
  mas
  mole
  neovim
  node
  oha
  ripgrep
  shellcheck
  starship
  stow
  sshs
  the_silver_searcher
  tig
  tmux
  tree
  wget
  zoxide
  zsh-autosuggestions
  zsh-completions
  zsh-history-substring-search
  zsh-syntax-highlighting
  zulu
)

base_cask=(
  1password
)

cask=(
  cleanshot
  codex
  discord
  font-fira-code-nerd-font
  font-jetbrains-mono-nerd-font
  ghostty
  iina
  intellij-idea
  jordanbaird-ice
  mimestream
  obsidian
  raycast
  rectangle
  spaceman
  spotify
)

mas=(
  497799835  # Xcode
  1487937127 # Craft
  904280696  # Things
)

# --- Base Bootstrap ---

run_base_setup() {
  sudo -v
  install_homebrew

  echo "☁️ Updating Homebrew..."
  brew update

  echo "📦 Installing bootstrap tools..."
  brew install "${base_brew[@]}"
  brew install --cask "${base_cask[@]}"

  echo "✅ Base setup is complete."
}

run_remaining_setup() {
  if ! load_homebrew; then
    echo "❌ Homebrew is not installed. Run the base setup first." >&2
    exit 1
  fi
  if ! command -v gh >/dev/null 2>&1; then
    echo "❌ GitHub CLI is not installed. Run the base setup first." >&2
    exit 1
  fi
  if ! gh auth status --hostname github.com >/dev/null 2>&1; then
    echo "❌ GitHub CLI is not authenticated. Complete the base setup instructions first." >&2
    exit 1
  fi
  if [[ "$(gh config get git_protocol --host github.com 2>/dev/null)" != "ssh" ]]; then
    echo "❌ GitHub CLI is not configured to use SSH." >&2
    echo "   Run: gh config set git_protocol ssh --host github.com" >&2
    exit 1
  fi

  echo "🔑 Verifying SSH access to private GitHub repositories..."
  if ! git ls-remote git@github.com:Jaysce/nvim.git HEAD >/dev/null; then
    echo "❌ GitHub could not authenticate your SSH key." >&2
    echo "   Check the 1Password SSH agent and GitHub key registration, then try again." >&2
    exit 1
  fi

  sudo -v

  # --- Remaining Packages ---

  echo "📦 Installing remaining packages..."
  brew tap anomalyco/tap
  brew install "${brew[@]}"
  mas install "${mas[@]}"
  sudo xcodebuild -license accept
  brew install --cask "${cask[@]}"

  # --- Dotfiles ---

  echo "☁️ Cloning dotfiles and symlinking..."
  cd "$HOME" || exit
  gh repo clone Jaysce/dotfiles
  mkdir -p ~/.config/starship
  cd dotfiles || exit
  stow common macos
  cd "$HOME" || exit

  # --- Neovim ---

  echo "☁️ Cloning nvim and symlinking..."
  gh repo clone Jaysce/nvim ~/.config/nvim

  # --- Agents ---

  echo "🤖 Cloning agents repo and installing agent configuration..."
  agents_dir="$HOME/agents"
  if [ -d "$agents_dir/.git" ]; then
    git -C "$agents_dir" pull --ff-only
  else
    gh repo clone Jaysce/agents "$agents_dir"
  fi
  "$agents_dir/scripts/install-agents.sh" all
  "$agents_dir/scripts/install-skills.sh" all --obsidian-only

  # --- System / App Preferences ---

  echo "⚙️ Setting System Preferences..."
  defaults write com.knollsoft.Rectangle gapSize -float 10
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0.6
  defaults write com.apple.Dock showhidden -bool TRUE
  killall Dock
  defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
  defaults write -g NSWindowShouldDragOnGesture -bool true

  # --- Cleanup ---

  brew cleanup
  brew cleanup -s

  echo "🎉 Done!"
}

echo "Choose a setup phase:"
echo "  1) Base setup (Homebrew, Git, GitHub CLI, and 1Password)"
echo "  2) Remaining setup (apps, dotfiles, Neovim, agents, and preferences)"
read -r -p "Enter 1 or 2: " setup_phase

case "$setup_phase" in
  1)
    run_base_setup
    ;;
  2)
    run_remaining_setup
    ;;
  *)
    echo "❌ Choose 1 (base) or 2 (remaining)." >&2
    exit 1
    ;;
esac
