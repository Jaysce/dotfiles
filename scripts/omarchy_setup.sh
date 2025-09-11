#!/bin/bash

# Fail fast, treat unset vars as errors, and safer pipelines
set -euo pipefail
IFS=$'\n\t'

# Setup ------------------------------------------------------------------

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

have_cmd() { command -v "$1" >/dev/null 2>&1; }

# Print helpers
section() { printf "\n%s%s%s\n\n" "$BLUE" "$1" "$NC"; }
info() { printf "%s%s%s\n" "$CYAN" "$1" "$NC"; }
warn() { printf "%sWarning:%s %s\n" "$YELLOW" "$NC" "$1"; }
ok() { printf "%s✓ %s%s\n" "$GREEN" "$1" "$NC"; }
error() { printf "%sError:%s %s\n" "$RED" "$NC" "$1"; }
bullet() { printf "%s• %s%s\n" "$CYAN" "$1" "$NC"; }

# Sudo warm-up and keepalive (optional; safe no-op if sudo absent)
if have_cmd sudo; then
  sudo -v || true
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

# Dotfiles ---------------------------------------------------------------
printf "\n%sCloning dotfiles...%s\n\n" "$BLUE" "$NC"

# Remove existing dotfiles safely if they exist
rm -f "$HOME/.bashrc"
rm -f "$HOME/.gitconfig"
rm -f "$HOME/.config/alacritty/alacritty.toml"
rm -f "$HOME/.config/lazygit/config.yml"
rm -f "$HOME/.config/hypr/autostart.conf"
rm -f "$HOME/.config/hypr/bindings.conf"
rm -f "$HOME/.config/hypr/input.conf"
rm -f "$HOME/.config/hypr/hyprsunset.conf"
rm -f "$HOME/.config/hypr/monitors.conf"
rm -f "$HOME/.config/omarchy/branding/about.txt"
rm -f "$HOME/.config/omarchy/branding/screensaver.txt"
rm -rf "$HOME/.config/waybar"

# Ensure needed directories exist
mkdir -p "$HOME/.config/alacritty" "$HOME/.config/hypr" "$HOME/.config/omarchy/branding"

if [ -d "$HOME/dotfiles" ]; then
  cd "$HOME/dotfiles"
  if have_cmd stow; then
    stow . || printf "%sWarning:%s stow failed; verify GNU stow is installed and dotfiles layout is correct.\n" "$YELLOW" "$NC"
  else
    printf "%sWarning:%s 'stow' not found. Skipping symlink step.\n" "$YELLOW" "$NC"
  fi
else
  printf "%sWarning:%s ~/dotfiles not found. Skipping stow.\n" "$YELLOW" "$NC"
fi

# Neovim -----------------------------------------------------------------
printf "\n%sCloning nvim...%s\n\n" "$BLUE" "$NC"

rm -rf "$HOME/.config/nvim"
if have_cmd gh; then
  if gh repo clone Jaysce/nvim "$HOME/.config/nvim"; then
    # Ensure plugins directory exists (should be present, but create to be safe)
    mkdir -p "$HOME/.config/nvim/lua/plugins"
    cd "$HOME/.config/nvim/lua/plugins"
    rm -f theme.lua
    if [ -e "$HOME/.config/omarchy/current/theme/neovim.lua" ]; then
      ln -s ../../../omarchy/current/theme/neovim.lua theme.lua
    else
      printf "%sWarning:%s omarchy Neovim theme not found; skipping theme symlink.\n" "$YELLOW" "$NC"
    fi
  else
    printf "%sError:%s failed to clone nvim with gh.\n" "$RED" "$NC"
  fi
else
  printf "%sWarning:%s GitHub CLI (gh) not found; skipping nvim clone.\n" "$YELLOW" "$NC"
fi

# Remove Bloat -----------------------------------------------------------
printf "\n%sRemoving packages...%s\n\n" "$BLUE" "$NC"

packages=(
  "obsidian"
  "signal-desktop"
  "typora"
)

failed_packages=()

for pkg in "${packages[@]}"; do
  printf "%sRemoving %s...%s\n" "$YELLOW" "$pkg" "$NC"
  if pacman -Qi "$pkg" >/dev/null 2>&1; then
    if sudo pacman -Rns --noconfirm "$pkg"; then
      printf "%s✓ Successfully removed %s%s\n" "$GREEN" "$pkg" "$NC"
    else
      failed_packages+=("$pkg")
    fi
  else
    printf "%s• %s is not installed; skipping.%s\n" "$CYAN" "$pkg" "$NC"
  fi
  printf "\n"
done

if [[ ${#failed_packages[@]} -gt 0 ]]; then
  printf "%s✗ Could not remove packages: %s%s\n" "$RED" "${failed_packages[*]}" "$NC"
fi

printf "\n%sRemoving web apps...%s\n\n" "$BLUE" "$NC"

webapps=(
  "HEY"
  "Basecamp"
  "WhatsApp"
  "Google Photos"
  "Google Contacts"
  "Google Messages"
  "ChatGPT"
  "GitHub"
  "X"
  "Figma"
  "Discord"
  "Zoom"
)

failed_webapps=()

if have_cmd omarchy-webapp-remove; then
  for webapp in "${webapps[@]}"; do
    printf "%sRemoving %s webapp...%s\n" "$YELLOW" "$webapp" "$NC"
    if omarchy-webapp-remove "$webapp" >/dev/null 2>&1; then
      printf "%s✓ Successfully removed %s webapp%s\n" "$GREEN" "$webapp" "$NC"
    else
      failed_webapps+=("$webapp")
    fi
    printf "\n"
  done
else
  printf "%sWarning:%s 'omarchy-webapp-remove' not found; skipping webapp removal.\n" "$YELLOW" "$NC"
fi

if [[ ${#failed_webapps[@]} -gt 0 ]]; then
  printf "%s✗ Could not remove webapps: %s%s\n" "$RED" "${failed_webapps[*]}" "$NC"
fi

# Install Packages -------------------------------------------------------
printf "\n%sInstalling packages...%s\n\n" "$BLUE" "$NC"

# Official repo packages (installed via pacman)
repo_packages=(
  "git-delta"
  "stow"
)

# AUR packages (installed via yay/paru)
aur_packages=(
  "sunsetr-bin"
)

# Detect AUR helper
aur_helper=""
if have_cmd yay; then
  aur_helper="yay"
elif have_cmd paru; then
  aur_helper="paru"
fi

# Install official packages
failed_repo_packages=()
for pkg in "${repo_packages[@]}"; do
  if pacman -Si "$pkg" >/dev/null 2>&1; then
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
      printf "%sInstalling %s (pacman)...%s\n" "$YELLOW" "$pkg" "$NC"
      if sudo pacman -S --noconfirm --needed "$pkg"; then
        :
      else
        failed_repo_packages+=("$pkg")
      fi
    else
      printf "%s• %s already installed.%s\n" "$CYAN" "$pkg" "$NC"
    fi
  else
    printf "%sWarning:%s %s not found in official repos; skipping.\n" "$YELLOW" "$NC" "$pkg"
  fi
done

if [[ ${#failed_repo_packages[@]} -gt 0 ]]; then
  printf "%s✗ Could not install repo packages: %s%s\n" "$RED" "${failed_repo_packages[*]}" "$NC"
fi

# Install AUR packages
failed_aur_packages=()
for pkg in "${aur_packages[@]}"; do
  if [ -n "$aur_helper" ]; then
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
      printf "%sInstalling %s (%s)...%s\n" "$YELLOW" "$pkg" "$aur_helper" "$NC"
      if $aur_helper -S --noconfirm --needed "$pkg"; then
        :
      else
        failed_aur_packages+=("$pkg")
      fi
    else
      printf "%s• %s already installed.%s\n" "$CYAN" "$pkg" "$NC"
    fi
  else
    printf "%sWarning:%s no AUR helper (yay/paru) found; cannot install %s.\n" "$YELLOW" "$NC" "$pkg"
  fi
done

if [[ ${#failed_aur_packages[@]} -gt 0 ]]; then
  printf "%s✗ Could not install AUR packages: %s%s\n" "$RED" "${failed_aur_packages[*]}" "$NC"
fi

# Run sunsetr geo only if command exists
if have_cmd sunsetr; then
  if [ -n "${DISPLAY:-}" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
    sunsetr --geo || printf "%sWarning:%s 'sunsetr --geo' failed.\n" "$YELLOW" "$NC"
  else
    printf "%sNote:%s No GUI session detected; skipping 'sunsetr --geo'.\n" "$CYAN" "$NC"
  fi
else
  printf "%sNote:%s sunsetr not installed; skipping 'sunsetr --geo'.\n" "$CYAN" "$NC"
fi
