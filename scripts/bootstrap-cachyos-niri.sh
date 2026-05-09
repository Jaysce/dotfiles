#!/usr/bin/env bash
set -Eeuo pipefail

# Needs gh auth setup

shell_packages=(
  quickshell
  jq
  btop
  stow
  fuzzel
)

cli_packages=(
  hexyl
  httpie
  oha
  tree
)

terminal_packages=(
  alacritty
  sshs
  starship
  tmux
  zoxide
)

editor_packages=(
  neovim
  opencode
  zed
)

dev_packages=(
  bun
  git-delta
  github-cli
  go-task
  jdk-openjdk
  lazygit
  nodejs
  npm
  shellcheck
  the_silver_searcher
  tig
)

app_packages=(
  discord
  mpv
  obsidian
  spotify-launcher
)

clipboard_packages=(
  wl-clipboard
)

screenshot_packages=(
  grim
  satty
  slurp
)

font_packages=(
  ttf-firacode-nerd
  ttf-jetbrains-mono-nerd
)

session_packages=(
  niri
  ly
  swayidle
)

portal_packages=(
  xdg-desktop-portal
  xdg-desktop-portal-gtk
  xdg-desktop-portal-gnome
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
  "${portal_packages[@]}"
  "${shell_packages[@]}"
  "${cli_packages[@]}"
  "${terminal_packages[@]}"
  "${editor_packages[@]}"
  "${dev_packages[@]}"
  "${app_packages[@]}"
  "${clipboard_packages[@]}"
  "${screenshot_packages[@]}"
  "${font_packages[@]}"
  "${wallpaper_packages[@]}"
  "${power_packages[@]}"
  "${brightness_packages[@]}"
  "${audio_packages[@]}"
  "${network_packages[@]}"
  "${bluetooth_packages[@]}"
)

aur_packages=(
  1password
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
stow_backup_dir="$HOME/.local/state/dotfiles/stow-backup-$(date +%Y%m%d-%H%M%S)"
stow_packages=(
  common
  linux
)

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

should_stow_path() {
  local path="$1"

  case "$path" in
  README* | LICENSE* | COPYING | .gitignore | .stow-local-ignore | .bashrc | other/* | scripts/*)
    return 1
    ;;
  esac

  return 0
}

backup_stow_conflicts() {
  local package
  local tracked_path
  local source_path
  local target_path
  local relative_path

  for package in "${stow_packages[@]}"; do
    git -C "$dotfiles_dir" ls-files -z -- "$package" | while IFS= read -r -d '' tracked_path; do
      relative_path="${tracked_path#"$package"/}"
      should_stow_path "$relative_path" || continue

      source_path="$dotfiles_dir/$tracked_path"
      target_path="$HOME/$relative_path"

      if [[ -e $target_path || -L $target_path ]]; then
        if [[ $(readlink -f "$target_path" 2>/dev/null || true) == "$source_path" ]]; then
          continue
        fi

        mkdir -p "$stow_backup_dir/$(dirname "$relative_path")"
        mv "$target_path" "$stow_backup_dir/$relative_path"
        echo "Backed up $target_path -> $stow_backup_dir/$relative_path"
      fi
    done
  done
}

stow_dotfiles() {
  echo "Stowing dotfiles..."
  backup_stow_conflicts
  stow --dir "$dotfiles_dir" --target "$HOME" --restow "${stow_packages[@]}"
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

stow_dotfiles
configure_wallpaper
"$quickshell_config_dir/bin/terra-sync-theme"

echo "Setting dark color scheme preference..."
gsettings set org.gnome.desktop.interface color-scheme prefer-dark
gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark

cat <<'EOF'

Bootstrap complete.

Next steps:
  - Reboot.
  - Choose/start the Niri session from ly.
  - Open menu with Alt+Space after login to configure Wi-Fi, Bluetooth,
    wallpaper, power actions, and other shell tools.
EOF
