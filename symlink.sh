#!/bin/bash

# list of dot files to be symlinked
dotfiles=".bashrc .gitconfig .vimrc"

for dotfile in $dotfiles; do if [ -f ~/dotfiles/$dotfile ]; then
  target_path=~/dotfiles/$dotfile
  if [ -f ~/$dotfile ]; then
    link_path="$(readlink ~/$dotfile)"
    if [ "$link_path" != "$target_path" ]; then
     echo "Warning: ~/$dotfile already exists as a symlink to $link_path"
    fi
  else
    ln -s $target_path ~/$dotfile
    echo "created symlink for $dotfile"
  fi
fi
done
