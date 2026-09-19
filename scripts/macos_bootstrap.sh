#!/bin/bash

set -Eeuo pipefail

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

is_expected_github_remote() {
  local repository="$1"
  local remote="$2"

  case "$remote" in
    "git@github.com:${repository}" | "git@github.com:${repository}.git" | \
      "ssh://git@github.com/${repository}" | "ssh://git@github.com/${repository}.git" | \
      "https://github.com/${repository}" | "https://github.com/${repository}.git")
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

clone_or_pull() {
  local repository="$1"
  local destination="$2"

  if [[ -e "$destination" || -L "$destination" ]]; then
    if [[ ! -d "$destination/.git" ]]; then
      echo "❌ $destination already exists but is not a Git repository." >&2
      exit 1
    fi

    local origin
    origin="$(git -C "$destination" remote get-url origin)"
    if ! is_expected_github_remote "$repository" "$origin"; then
      echo "❌ $destination belongs to $origin, not GitHub repository $repository." >&2
      exit 1
    fi

    echo "🔄 Updating $repository..."
    git -C "$destination" pull --ff-only
    return
  fi

  echo "☁️ Cloning $repository..."
  mkdir -p "$(dirname "$destination")"
  gh repo clone "$repository" "$destination"
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
  chatgpt
  cleanshot
  claude
  claude-code
  codex
  discord
  font-fira-code-nerd-font
  font-jetbrains-mono-nerd-font
  ghostty
  iina
  intellij-idea
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
  brew install "${brew[@]}"
  mas install "${mas[@]}"

  xcode_developer_dir="/Applications/Xcode.app/Contents/Developer"
  if [[ ! -d "$xcode_developer_dir" ]]; then
    echo "❌ Xcode is not available at $xcode_developer_dir." >&2
    echo "   Wait for the App Store installation to finish, then rerun the remaining setup." >&2
    exit 1
  fi

  echo "🛠️ Configuring Xcode..."
  sudo xcode-select --switch "$xcode_developer_dir"
  sudo xcodebuild -runFirstLaunch

  brew install --cask "${cask[@]}"

  # --- Dotfiles ---

  echo "🔗 Symlinking dotfiles..."
  clone_or_pull Jaysce/dotfiles "$HOME/dotfiles"
  # Link individual files so apps keep runtime state outside the repository.
  stow --no-folding --dir="$HOME/dotfiles" --target="$HOME" common macos

  # --- Neovim ---

  clone_or_pull Jaysce/nvim "$HOME/.config/nvim"

  # --- Agents ---

  echo "🤖 Installing agent configuration..."
  agents_dir="$HOME/agents"
  clone_or_pull Jaysce/agents "$agents_dir"
  "$agents_dir/scripts/install.sh" all

  # --- System / App Preferences ---

  echo "⚙️ Setting System Preferences..."
  defaults write com.knollsoft.Rectangle gapSize -float 10
  defaults write com.apple.dock autohide-delay -float 0
  defaults write com.apple.dock autohide-time-modifier -float 0.6
  defaults write com.apple.Dock showhidden -bool TRUE
  killall Dock || true
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
