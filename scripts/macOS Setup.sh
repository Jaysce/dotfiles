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

echo 'Are the Xcode command line tools installed?'
echo 'If not exit with ⌃C, and install Xcode along with other MAS apps or use:'
echo 'xcode-select -install'
echo ' '
echo 'MAS apps to install:'
echo 'Xcode, Things3, AdGuard, Unarchiver, Affinity, ColorSlurp, GoodNotes,
Mimestream, CleanShot, Craft, Amphetamine, Twitter, Developer, Dev Cleaner'

read response

sudo -v
cd ~

# Check if Homebrew is installed and install if not
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
  fortune
  fzf
  gcc
  gh
  gotop
  gradle
  htop
  jq
  lazygit
  llvm
  lua
  luarocks
  neofetch
  neovim
  node
  openjdk
  ranger
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
  alacritty
  alfred
  appcleaner
  bartender
  brooklyn
  cleanshot
  daisydisk
  discord
  figma
  font-fira-code-nerd-font
  font-hack-nerd-font
  font-jetbrains-mono-nerd-font
  google-chrome
  iina
  intellij-idea-ce
  iterm2
  mos
  notion
  postman
  rectangle
  sf-symbols
  sketch
  spaceman
  spotify
  visual-studio-code
  zoom
)

# Update and upgrade existing homebrew recipes and formulae
brew update
brew upgrade

# Tap into required repositories
brew tap homebrew/cask-fonts

# Begin installing formulae and casks
brew install ${brew[@]}
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
ln -sv ~/dotfiles/Config/ranger ~/.config
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
