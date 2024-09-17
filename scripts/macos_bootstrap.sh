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

# --- Xcode CLT ---

echo "💻 Installing Xcode Command Line Tools..."
xcode-select --install


# --- Homebrew ---

if test ! $(which brew) 
then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$user/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

brew=(
  git
  ack
  bat
  ccls
  cmake
  curl
  fd
  fzf
  gcc
  gh
  git-delta
  jq
  lazygit
  llvm
  mas
  neovim
  node
  openjdk
  ripgrep
  starship
  the_silver_searcher
  tig
  tmux
  tree
  wget
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

cask=(
  1password
  arc
  cleanshot
  discord
  docker
  font-fira-code-nerd-font
  font-hack-nerd-font
  font-jetbrains-mono-nerd-font
  hidock
  iina
  iterm2
  intellij-idea
  mimestream
  postman
  raycast
  rectangle
  replacicon
  spaceman
  spotify
  visual-studio-code
)

mas=(
  497799835   # Xcode
  1287239339  # ColorSlurp
  1487937127  # Craft
  1388020431  # DevCleaner
  640199958   # Developer
  904280696   # Things
  1444636541  # Photomator
)

echo "☁️ Updating homebrew..."
brew update
brew tap homebrew/cask-fonts

echo "📦 Installing packages..."
brew install ${brew[@]}
mas install ${mas[@]}
brew install --cask ${cask[@]}


# --- Oh My ZSH ---

echo "😱 Installing Oh My ZSH..."
curl -L http://install.ohmyz.sh | sh

# --- TPM ---

echo "🛠️ Installing TPM..."
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# --- SymLink Dotfiles ---

echo "☁️ Cloning dotfiles and symlinking..."
cd ~
git clone https://github.com/Jaysce/dotfiles.git
mkdir -p ~/.config
ln -sv ~/dotfiles/Config/.gitconfig ~/.gitconfig
ln -sv ~/dotfiles/Config/tmux/.tmux.conf ~/.tmux.conf
ln -sv ~/dotfiles/Config/.zshrc ~/.zshrc
ln -sv ~/dotfiles/Config/starship.toml ~/.config


# --- System / App Preferences ---

echo "⚙️ Setting System Preferences..."
defaults write com.knollsoft.Rectangle gapSize -float 10
defaults write com.apple.Dock showhidden -bool TRUE; killall Dock
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false


# --- Cleanup ---

brew cleanup
brew cleanup -s

echo "🎉 Done!"
