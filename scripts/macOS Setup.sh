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
echo 'Xcode, Things3, Wipr, Unarchiver, Affinity, ColorSlurp, Twitter, GoodNotes, Messenger'

read response

sudo -v
cd ~

# Check if Homebrew is installed and install if not
if test ! $(which brew)
then
  echo "Installing Homebrew... "
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else
  echo "Homebrew is already installed"
  exit 1
fi

#--- Install / Update Apps via Homebrew ----------------------------------------

brew=(
  git
  ccls
  cmake
  cmatrix
  fortune
  gcc
  gh
  gotop
  gradle
  htop
  lazygit
  neofetch
  neovim
  node
  openjdk
  ranger
  starship
  tmux
  umlet
  yarn
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)

cask=(
  alacritty
  alfred
  appcleaner
  bartender
  daisydisk
  discord
  figma
  font-fira-code
  font-hack-nerd-font
  font-jetbrains-mono-nerd-font
  github
  google-chrome
  iina
  intellij-idea-ce
  mos
  notion
  rectangle
  sf-symbols
  sketch
  spotify
  visual-studio-code
)

# Update and upgrade existing homebrew recipes and formulae
brew update
brew upgrade

# Tap into required repositories
brew tap github/gh
brew tap homebrew/cask-fonts

# Begin installing formulae and casks
brew install ${brew[@]}
brew cask install ${cask[@]}

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
ln -sv ~/dotfiles/Config/.zshrc ~/.zshrc

# SymLink to .config
ln -sv ~/dotfiles/Config/nvim ~/.config
ln -sv ~/dotfiles/Config/starship.toml ~/.config

# Install Vim-Plug
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#--- System / App Preferences --------------------------------------------------

defaults write com.knollsoft.Rectangle gapSize -float 10

# Remove garbage
brew cleanup
brew cleanup -s

echo Done!
