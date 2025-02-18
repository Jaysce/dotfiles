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
    alacritty
    amd-ucode
    bat
    bluez
    bluez-utils
    curl
    github-cli
    git-delta
    firefox
    neovim
    starship
    stow
    tmux
    wget
    xclip
    zsh
    hyprland
    dolphin
    waybar
    wofi
    pamixer
    refind
    sbctl
    ly
    hyprpaper
    openssh
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
mkdir -p ~/.config/waybar
mkdir -p ~/.ssh
git clone https://github.com/Jaysce/dotfiles.git
cd dotfiles
stow .
cd ~

# Install fonts
sudo pacman -S $(pacman -Ssq noto-fonts)
yay -S --noconfirm ttf-firacode-nerd
yay -S --noconfirm ttf-jetbrains-mono-nerd

# Install TPM (Tmux Plugin Manager)
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Enable bluetooh
systemctl enable bluetooth.service
systemctl start bluetooth.service

# Install refind
refind-install
# sudo mount --mkdir /dev/<your_device> /mnt/boot
# cd /mnt/boot/EFI/refind
# sudo mkdir themes
# sudo git clone https://github.com/AdityaGarg8/rEFInd-minimal-modded.git ./themes
# sudo mv ./themes/rEFInd-minimal-modded ./themes/rEFInd-minimal
# sudo sh -c "echo \"include themes/rEFInd-minimal/theme.conf\" >> refind.conf"
# sudo sh -c "echo \"resolution max\" >> refind.conf"

## Setup secure boot ensure that secure boot is in setup mode by deleting all keys
# sudo sbctl create-keys
# sudo sbctl enroll-keys -m
## Sign the bootloader and kernel
# sudo sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
# sudo sbctl sign -s /boot/EFI/refind/refind_x64.efi
# sudo sbctl sign -s /boot/vmlinuz-linux
## Verify everything is signed
# sudo sbctl verify

# Enable login manager
sudo systemctl enable ly.service
sudo systemctl start ly.service

chsh -s $(which zsh)
