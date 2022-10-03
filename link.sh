#!/bin/bash

mkdir -p $HOME/config/i3
mkdir -p $HOME/config/alacritty
mkdir -p $HOME/config/i3
mkdir -p $HOME/config/wallpaper

ln -sf $(pwd)/config/i3/config $HOME/.config/i3/config   
ln -sf $(pwd)/config/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml  
ln -sf $(pwd)/config/i3/i3blocks.conf $HOME/.config/i3/i3blocks.conf
ln -sf $(pwd)/config/helix/config.toml $HOME/.config/helix/config.toml 
ln -sf $(pwd)/config/helix/languages.toml $HOME/.config/helix/languages.toml

ln -sf $(pwd)/home_dotfiles/.vimrc $HOME/.vimrc
ln -sf $(pwd)/home_dotfiles/.gitconfig   $HOME/.gitconfig  
ln -sf $(pwd)/home_dotfiles/.gitglobalignore $HOME/.gitglobalignore  
ln -sf $(pwd)/home_dotfiles/.profile $HOME/.profile  
ln -sf $(pwd)/home_dotfiles/.Xresources $HOME/.Xresources  
ln -sf $(pwd)/home_dotfiles/.zshrc $HOME/.zshrc  

ln -sf $(pwd)/config/wallpaper/wallpaper.jpg $HOME/.config/wallpaper/wallpaper.jpg