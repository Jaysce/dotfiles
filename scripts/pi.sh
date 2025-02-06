#!/bin/bash

# sh <(curl -sSL https://raw.githubusercontent.com/Jaysce/dotfiles/master/scripts/pi.sh)

cd

localectl set-locale en_AU.UTF-8

# update and upgrade
sudo apt update -y
sudo apt upgrade -y

# tools
sudo apt install -y curl wget git xclip bat unzip zip tmux zsh gh stow

# git delta
wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_arm64.deb
dpkg -i git-delta_0.18.2_arm64.deb
rm git-delta_0.18.2_arm64.deb

# cleanup
sudo apt autoremove -y

# prompt / omz
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
curl -sS https://starship.rs/install.sh | sh
rm .zshrc
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# dotfiles
mkdir -p ~/.config/starship
mkdir -p ~/.ssh
git clone https://github.com/Jaysce/dotfiles.git
cd dotfiles
stow .
cd ~

chsh -s $(which zsh)

echo "Done! Restart your session."
