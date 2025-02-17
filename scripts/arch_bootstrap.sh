#!/bin/bash

# Ensure we are in the home directory
cd ~

# Use local time for RTC
timedatectl set-local-rtc 1 --adjust-system-clock

# Update package manager
sudo pacman -Syu

# Install yay
sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

# Install packages
packages=(
    bat
    bluez
    bluez-utils
    curl
    github-cli
    git-delta
    neovim
    starship
    stow
    tmux
    wget
    xclip
    zsh
    hyprland
    dolphin
    wofi
    alacritty
)

for package in "${packages[@]}"; do
    if ! pacman -Qi $package &> /dev/null; then
        yay -S --noconfirm $package
    else
        echo "$package is already installed"
    fi
done

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
if [ -f ~/.zshrc ]; then
    rm ~/.zshrc
fi
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Dotfiles
mkdir -p ~/.config/starship
mkdir -p ~/.ssh
git clone https://github.com/Jaysce/dotfiles.git
cd dotfiles
stow .
cd ~

# Install fonts
sudo yay -S $(yay -Ssq noto-fonts)
yay -S --noconfirm ttf-firacode-nerd
yay -S --noconfirm ttf-jetbrains-mono-nerd

# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Enable bluetooh
systemctl enable bluetooth.service
systemctl start bluetooth.service

chsh -s $(which zsh)
