#!/bin/bash

cd

# update and upgrade
sudo apt update -y
sudo apt upgrade -y

# essentials
sudo apt install -y curl wget git xclip vim bat unzip zip tmux zsh

# node
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
nvm install 20

# sdk man
curl -s "https://get.sdkman.io" | bash

# build tools
sudo apt install -y gcc g++ make

# cleanup
sudo apt autoremove -y

cd

# dotfiles
git clone https://github.com/Jaysce/dotfiles.git
mkdir -p ~/.config
ln -sv ~/dotfiles/Config/.gitconfig ~/.gitconfig
ln -sv ~/dotfiles/Config/tmux/.tmux.conf ~/.tmux.conf
ln -sv ~/dotfiles/Config/starship.toml ~/.config

# prompt / omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sS https://starship.rs/install.sh | sh
rm .zshrc
ln -sv ~/dotfiles/Config/.zshrc ~/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

chsh -s $(which zsh)
