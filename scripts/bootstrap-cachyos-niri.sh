#!/usr/bin/env bash
set -Eeuo pipefail

# Needs gh auth setup

shell_packages=(
  quickshell
  jq
  btop
  stow
)

terminal_packages=(
  alacritty
)

font_packages=(
  ttf-firacode-nerd
)

session_packages=(
  niri
  ly
)

wallpaper_packages=(
  awww
  matugen
)

power_packages=(
  upower
)

brightness_packages=(
  brightnessctl
)

audio_packages=(
  pipewire
  wireplumber
)

network_packages=(
  networkmanager
)

bluetooth_packages=(
  bluez
  bluez-utils
  bluetui
)

packages=(
  "${session_packages[@]}"
  "${shell_packages[@]}"
  "${terminal_packages[@]}"
  "${font_packages[@]}"
  "${wallpaper_packages[@]}"
  "${power_packages[@]}"
  "${brightness_packages[@]}"
  "${audio_packages[@]}"
  "${network_packages[@]}"
  "${bluetooth_packages[@]}"
)

aur_packages=(
  wlctl-bin
)

shell_repo="${SHELL_REPO:-git@github.com:Jaysce/terra-shell.git}"
shell_dir="${SHELL_DIR:-$HOME/Developer/terra-shell}"
quickshell_config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell"
dotfiles_dir="${DOTFILES_DIR:-$HOME/dotfiles}"
wallpaper_dir="${WALLPAPER_DIR:-$dotfiles_dir/wallpaper}"
pictures_wallpaper_dir="$HOME/Pictures/Wallpaper"
state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/quickshell"
colors_file="$state_dir/material-colors.json"
current_wallpaper_file="$state_dir/wallpaper"

install_shell() {
  mkdir -p "$(dirname "$shell_dir")" "$(dirname "$quickshell_config_dir")"

  echo "Cloning Shell into $shell_dir..."
  git clone "$shell_repo" "$shell_dir"

  ln -s "$shell_dir" "$quickshell_config_dir"
  echo "Linked $quickshell_config_dir -> $shell_dir"
}

find_initial_wallpaper() {
  find "$wallpaper_dir" -type f \( \
    -iname '*.jpg' -o \
    -iname '*.jpeg' -o \
    -iname '*.png' -o \
    -iname '*.webp' -o \
    -iname '*.jxl' -o \
    -iname '*.avif' \
    \) | sort | head -n 1
}

configure_wallpaper() {
  mkdir -p "$state_dir" "$HOME/Pictures"

  if [[ ! -d $wallpaper_dir ]]; then
    return
  fi

  ln -s "$wallpaper_dir" "$pictures_wallpaper_dir"

  local initial_wallpaper
  initial_wallpaper="$(find_initial_wallpaper)"

  if [[ -z $initial_wallpaper ]]; then
    return
  fi

  echo "Generating initial Material colors from $initial_wallpaper..."
  matugen image "$initial_wallpaper" \
    -m dark \
    -t scheme-tonal-spot \
    --source-color-index 0 \
    --json hex \
    --dry-run >"$colors_file"
  printf '%s\n' "$initial_wallpaper" >"$current_wallpaper_file"
}

echo "Installing official packages..."
sudo pacman -Syu --needed "${packages[@]}"

echo "Installing AUR packages..."
paru -S --needed --noconfirm "${aur_packages[@]}"

echo "Enabling ly display manager on tty2..."
sudo systemctl enable ly@tty2.service
sudo systemctl disable getty@tty2.service

echo "Enabling NetworkManager and Bluetooth services..."
sudo systemctl enable --now NetworkManager.service bluetooth.service

if systemctl --user enable --now pipewire.service wireplumber.service >/dev/null 2>&1; then
  echo "Enabled PipeWire user services."
else
  echo "PipeWire user services were not enabled automatically; they should start from the user session."
fi

install_shell

configure_wallpaper
"$quickshell_config_dir/bin/terra-sync-niri-accent"

echo "Setting dark color scheme preference..."
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

cat <<'EOF'

Bootstrap complete.

Installed:
  - niri, ly
  - quickshell, jq, btop, stow
  - alacritty
  - ttf-firacode-nerd
  - awww, matugen
  - upower
  - brightnessctl
  - pipewire, wireplumber
  - networkmanager
  - wlctl-bin from AUR when paru/yay is available
  - bluez, bluez-utils, bluetui

Shell config:
  - Shell is cloned at ~/Developer/terra-shell.
  - ~/.config/quickshell is symlinked to that checkout.

Networking:
  - Wi-Fi and Ethernet are managed by NetworkManager.
  - Wi-Fi is controlled from the bar with wlctl.

Not installed yet, by design:
  - xdg-desktop-portal-gnome: add when we need Niri screencasting/screen sharing
  - polkit-gnome: add when we need graphical privilege prompts
  - wl-clipboard: add when the shell needs clipboard commands

CachyOS no-DE installs already pull in xdg-desktop-portal-gtk on the tested
default package selection, so it is not listed explicitly here.

Wallpaper/theming:
  - Apps and websites are set to prefer dark variants.
  - If ~/dotfiles/wallpaper exists, it is linked into ~/Pictures/Wallpaper.
  - If that directory contains an image, initial Material colors are generated
    from the first image.
  - Wallpaper switching and Material color generation are handled by the
    Quickshell control panel after login.

Next step:
  Reboot, then choose/start the Niri session from ly.
EOF
