#!/bin/bash

ln -sf $(pwd)/config/i3/config $HOME/.config/i3/config   
ln -sf $(pwd)/config/alacritty/alacritty.yml $HOME/.config/alacritty/alacritty.yml  
ln -sf $(pwd)/config/nvim/init.vim $HOME/.config/nvim/nvim.init  
ln -sf $(pwd)/config/i3/i3blocks.conf $HOME/.config/i3/i3blocks.conf

ln -sf $(pwd)/dotfiles/.vimrc $HOME/.vimrc
ln -sf $(pwd)/dotfiles/.gitconfig   $HOME/.gitconfig  
ln -sf $(pwd)/dotfiles/.gitglobalignore $HOME/.gitglobalignore  
ln -sf $(pwd)/dotfiles/.profile $HOME/.profile  
ln -sf $(pwd)/dotfiles/.Xresources $HOME/.Xresources  
ln -sf $(pwd)/dotfiles/.zshrc $HOME/.zshrc  
