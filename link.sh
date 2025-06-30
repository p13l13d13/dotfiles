#!/bin/bash

mkdir -p $HOME/.config/alacritty
mkdir -p $HOME/.config/wallpaper
mkdir -p $HOME/.config/sway
mkdir -p $HOME/.config/ranger
mkdir -p $HOME/.config/hypr
mkdir -p $HOME/.config/quickshell

ln -sf $(pwd)/config/quickshell $HOME/.config/quickshell
ln -sf $(pwd)/config/hypr $HOME/.config/hypr
ln -sf $(pwd)/config/waybar $HOME/.config/waybar
ln -sf $(pwd)/config/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml  
ln -sf $(pwd)/config/helix/config.toml $HOME/.config/helix/config.toml 
ln -sf $(pwd)/config/helix/languages.toml $HOME/.config/helix/languages.toml

ln -sf $(pwd)/dotfiles/.gitconfig   $HOME/.gitconfig
ln -sf $(pwd)/dotfiles/.gitglobalignore $HOME/.gitglobalignore
ln -sf $(pwd)/dotfiles/.profile $HOME/.profile
ln -sf $(pwd)/dotfiles/.Xresources $HOME/.Xresources
ln -sf $(pwd)/dotfiles/.zshrc $HOME/.zshrc

ln -sf $(pwd)/config/wallpaper/wallpaper.jpg $HOME/.config/wallpaper/wallpaper.jpg
