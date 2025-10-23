#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Directories under ~/.config that should exist
config_dirs=(
  alacritty
  helix
  hypr
  quickshell
  rofi
  waybar
  wallpaper
)

for dir in "${config_dirs[@]}"; do
  mkdir -p "$HOME/.config/$dir"
  ln -sfn "$repo_dir/config/$dir/"* "$HOME/.config/$dir"
done

ln -sfn "$repo_dir/config/fish/config.fish" "$HOME/.config/fish"
ln -sfn -t "$HOME" "$repo_dir"/dotfiles/.[!.]* "$repo_dir"/dotfiles/..?*
cp ./config/wallpaper/wallpaper.jpg "$HOME/current.wall"
