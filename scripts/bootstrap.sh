#!/bin/bash

# update and upgrade
sudo apt-get update -y
sudo apt-get upgrade -y

# essentials
sudo apt-get install -y curl wget git xclip vim bat unzip zip tmux zsh

# node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20

# sdk man
curl -s "https://get.sdkman.io" | bash

# build tools
sudo apt-get install -y gcc g++ make

# cleanup
sudo apt autoremove -y

# dotfiles
git clone https://github.com/Jaysce/dotfiles.git
mkdir -p ~/.config
ln -sv ~/dotfiles/Config/.gitconfig ~/.gitconfig
ln -sv ~/dotfiles/Config/tmux/.tmux.conf ~/.tmux.conf
ln -sv ~/dotfiles/Config/.zshrc ~/.zshrc
ln -sv ~/dotfiles/Config/starship.toml ~/.config