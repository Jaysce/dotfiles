#!/bin/bash

# sh <(curl -sSL https://raw.githubusercontent.com/Jaysce/dotfiles/master/scripts/pi.sh)

cd

# update and upgrade
sudo apt update -y
sudo apt upgrade -y

# tools
sudo apt install -y curl wget git xclip bat unzip zip tmux zsh gh

# git delta
wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_arm64.deb
dpkg -i git-delta_0.18.2_arm64.deb
rm git-delta_0.18.2_arm64.deb

# cleanup
sudo apt autoremove -y

# dotfiles
mkdir -p ~/.config
mkdir -p ~/.ssh
git clone https://github.com/Jaysce/dotfiles.git
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

echo "Done! Restart your session."
