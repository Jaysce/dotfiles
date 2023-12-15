#!/bin/bash

#                         ____   _____    _____      _               
#                        / __ \ / ____|  / ____|    | |              
#   _ __ ___   __ _  ___| |  | | (___   | (___   ___| |_ _   _ _ __  
#  | '_ ` _ \ / _` |/ __| |  | |\___ \   \___ \ / _ \ __| | | | '_ \ 
#  | | | | | | (_| | (__| |__| |____) |  ____) |  __/ |_| |_| | |_) |
#  |_| |_| |_|\__,_|\___|\____/|_____/  |_____/ \___|\__|\__,_| .__/ 
#                                                             | |    
#                                                             |_|    


#--- Homebrew ------------------------------------------------------------------

# Check if Xcode command line tools are installed
if [[ ! $(xcode-select --version) ]]
then
  echo "Xcode Command Line Tools are not installed"
  echo "Install using 'xcode-select --install' then re-run install script"
  exit 1
fi

echo "Press any key to start installation..."
read response

sudo -v
cd ~

# Check if Homebrew is already installed and install if not
if test ! $(which brew)
then
  echo "Installing Homebrew... "
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "Homebrew is already installed"
  exit 1
fi

#--- Install / Update Apps via Homebrew ----------------------------------------

brew=(
  git
  bat
  ccls
  cmake
  curl
  fd
  fzf
  gcc
  gh
  git-delta
  gotop
  htop
  jq
  lazygit
  llvm
  lua
  luarocks
  mas
  neofetch
  neovim
  node
  openjdk
  ripgrep
  starship
  tmux
  the_silver_searcher
  umlet
  wget
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

cask=(
  1password
  appcleaner
  arc
  brooklyn
  cleanshot
  discord
  figma
  font-fira-code-nerd-font
  font-hack-nerd-font
  font-jetbrains-mono-nerd-font
  iina
  iterm2
  mimestream
  pictogram
  raycast
  rectangle
  sf-symbols
  spaceman
  spotify
  visual-studio-code
)

mas=(
  497799835   # Xcode
  1440147259  # AdGuard for Safari
  937984704   # Amphetamine
  1287239339  # ColorSlurp
  1487937127  # Craft
  1388020431  # DevCleaner
  640199958   # Developer
  904280696   # Things
)

# Update and upgrade existing homebrew recipes and formulae
brew update
brew upgrade

# Tap into required repositories
brew tap homebrew/cask-fonts

# Begin installing formulae, MAS apps and casks
brew install ${brew[@]}
mas install ${mas[@]}
brew install --HEAD universal-ctags/universal-ctags/universal-ctags
brew install --cask ${cask[@]}

# Install Oh My ZSH
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

#--- Install Vim-Plug / SymLink Dotfiles ---------------------------------------

# Link dotfiles
cd ~
git clone https://github.com/Jaysce/dotfiles.git

# Make .config directory if it doesn't already exist
mkdir -p ~/.config

# SymLink to ~
ln -sv ~/dotfiles/Config/.alacritty.yml ~/.alacritty.yml
ln -sv ~/dotfiles/Config/.gitconfig ~/.gitconfig
ln -sv ~/dotfiles/Config/tmux/.tmux.conf ~/.tmux.conf
ln -sv ~/dotfiles/Config/.zshrc ~/.zshrc

# SymLink to .config
ln -sv ~/dotfiles/Config/nvim ~/.config
ln -sv ~/dotfiles/Config/skhd ~/.config
ln -sv ~/dotfiles/Config/spacebar ~/.config
ln -sv ~/dotfiles/Config/yabai ~/.config
ln -sv ~/dotfiles/Config/starship.toml ~/.config

#--- System / App Preferences --------------------------------------------------

defaults write com.knollsoft.Rectangle gapSize -float 10
defaults write com.apple.Dock showhidden -bool TRUE
defaults write com.apple.dock autohide-delay -float 0; killall Dock
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false

# Remove garbage
brew cleanup
brew cleanup -s

echo Done!
