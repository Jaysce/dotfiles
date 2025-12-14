#!/bin/bash

# sh <(curl -sSL https://raw.githubusercontent.com/Jaysce/dotfiles/master/scripts/wsl_bootstrap.sh)

sudo -v
cd ~

# --- Update and Upgrade ---

sudo apt update -y
sudo apt upgrade -y

# --- Essential Packages ---

sudo apt install -y \
  bat \
  build-essential \
  cmake \
  curl \
  fd-find \
  fzf \
  gcc \
  git \
  hexyl \
  httpie \
  jq \
  neovim \
  nodejs \
  npm \
  ripgrep \
  stow \
  tig \
  tmux \
  tree \
  unzip \
  wget \
  xclip \
  zip \
  zsh

# --- GitHub CLI ---

(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
  && sudo mkdir -p -m 755 /etc/apt/keyrings \
  && out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  && cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
  && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

# --- Lazygit ---

LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
rm lazygit.tar.gz lazygit

# --- Lazydocker ---

curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# --- Eza ---

sudo mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt update
sudo apt install -y eza

# --- Delta (git-delta) ---

DELTA_VERSION=$(curl -s "https://api.github.com/repos/dandavison/delta/releases/latest" | \grep -Po '"tag_name": *"\K[^"]*')
curl -Lo delta.deb "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb"
sudo dpkg -i delta.deb
rm delta.deb

# --- Zoxide ---

curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh

# --- Starship ---

curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- Zsh Plugins (standalone, no oh-my-zsh) ---

mkdir -p ~/.zsh
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ~/.zsh/zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-completions ~/.zsh/zsh-completions

# --- TPM (Tmux Plugin Manager) ---

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# --- Dotfiles ---

cd ~
git clone https://github.com/Jaysce/dotfiles.git
mkdir -p ~/.config/starship
cd dotfiles
stow .
cd ~

# --- Neovim Config ---

git clone https://github.com/Jaysce/nvim.git ~/.config/nvim

# --- Set Zsh as Default Shell ---

chsh -s $(which zsh)

# --- Cleanup ---

sudo apt autoremove -y

echo "Done! Restart your session."
