#!/bin/bash

#                         ____   _____    _____      _               
#                        / __ \ / ____|  / ____|    | |              
#   _ __ ___   __ _  ___| |  | | (___   | (___   ___| |_ _   _ _ __  
#  | '_ ` _ \ / _` |/ __| |  | |\___ \   \___ \ / _ \ __| | | | '_ \ 
#  | | | | | | (_| | (__| |__| |____) |  ____) |  __/ |_| |_| | |_) |
#  |_| |_| |_|\__,_|\___|\____/|_____/  |_____/ \___|\__|\__,_| .__/ 
#                                                             | |    
#                                                             |_|    


# <--------------------------------- Housekeeping and Install Homebrew --------------------------------->

echo 'Are the Xcode command line tools installed?'
echo 'If not exit with ⌃C, and install Xcode along with other MAS apps or use:'
echo 'xcode-select -install'
echo ' '
echo 'MAS apps to install:'
echo 'Xcode, Things3, Bear, Wipr, Unarchiver, Affinity, ColorSlurp, Twitter'

read response

sudo -v # Give sudo access ahead of time
cd ~ # Move to home directory

# Check if Homebrew is installed and install if not
if test ! $(which brew)
then
  echo "Installing Homebrew... "
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Homebrew is already installed"
  exit 1
fi

# <--------------------------------- Install / Update Apps via Homebrew --------------------------------->

brew=(
  git
  neofetch
  vim
  nano
  starship
  htop
  node
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  gradle
  lazygit
)

cask=(
  alfred
  appcleaner
  bartender
  clion
  daisydisk
  discord
  font-fira-code
  font-hack-nerd-font
  github
  google-chrome
  iina
  intellij-idea-ce
  iterm2
  java
  microsoft-teams
  mos
  pycharm-ce
  rectangle
  sketch
  spotify
  tempo
  visual-studio-code
)

brew update # Update any existing homebrew recipes
brew upgrade # Upgrade any already installed formulae
brew tap homebrew/cask-fonts

brew install ${brew[@]} # Formulae app installer
brew cask install ${cask[@]} # Cask app installer

# Install Oh My ZSH
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Link dotfiles
cd ~
git clone https://github.com/Jaysce/dotfiles.git

ln -sv ~/dotfiles/.gitconfig ~/.gitconfig
ln -sv ~/dotfiles/.zshrc ~/.zshrc
ln -sv ~/dotfiles/.nanorc ~/.nanorc
ln -sv ~/dotfiles/.vimrc ~/.vimrc

# Install Vim-Plug

# <--------------------------------- System / App Preferences --------------------------------->

defaults write com.knollsoft.Rectangle gapSize -float 10

# Remove garbage
brew cleanup
brew cleanup -s

echo Done!