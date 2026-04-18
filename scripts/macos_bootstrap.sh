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
sudo -v
cd ~

# --- Homebrew ---

if test ! $(which brew); then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>/Users/$user/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew=(
  git
  ack
  bat
  bazelisk
  bun
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
  gh
  git-delta
  grpcurl
  httpie
  hexyl
  jq
  lazydocker
  lazygit
  llvm
  mas
  mole
  neovim
  node
  oha
  opencode
  ripgrep
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

cask=(
  1password
  cleanshot
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
  replacicon
  spaceman
  spotify
  visual-studio-code
  zed
)

mas=(
  497799835  # Xcode
  1487937127 # Craft
  904280696  # Things
)

echo "☁️ Updating homebrew..."
brew update
brew tap oven-sh/bun
brew tap anomalyco/tap

echo "📦 Installing packages..."
brew install ${brew[@]}
mas install ${mas[@]}
sudo xcodebuild -license accept
brew install --cask ${cask[@]}

# --- TPM ---

echo "🛠️ Installing TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# --- Dotfiles ---

echo "☁️ Cloning dotfiles and symlinking..."
cd ~
git clone https://github.com/Jaysce/dotfiles.git
mkdir -p ~/.config/starship
cd dotfiles
stow .
cd ~

# --- Neovim ---
echo "☁️ Cloning nvim and symlinking..."
git clone https://github.com/Jaysce/nvim.git ~/.config/nvim

# --- Agents ---

echo "🤖 Cloning agents repo and installing skills..."
if [ ! -d ~/agents/.git ]; then
  git clone https://github.com/Jaysce/agents.git ~/agents
fi
bunx skills add ~/agents -g -a codex -y
bun add -g defuddle

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
