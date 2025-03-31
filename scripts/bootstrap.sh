#!/bin/bash

# sh <(curl -sSL https://raw.githubusercontent.com/Jaysce/dotfiles/master/scripts/bootstrap.sh)

cd

# update and upgrade
sudo apt update -y
sudo apt upgrade -y

# essentials
sudo apt install -y curl wget git xclip neovim bat unzip zip tmux zsh gh stow jq httpie

# cleanup
sudo apt autoremove -y

cd

# prompt / omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sS https://starship.rs/install.sh | sh
rm .zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# dotfiles
git clone https://github.com/Jaysce/dotfiles.git
mkdir -p ~/.config/alacritty
mkdir -p ~/.config/hypr
mkdir -p ~/.config/starship
mkdir -p ~/.config/wofi
cd dotfiles
stow .
cd

chsh -s $(which zsh)

echo "Done! Restart your session."
