#!/usr/bin/env bash

vim_config() {
  ## Configure vim
  git clone --depth=1 https://github.com/andylamp/vimrc.git ~/.vim_runtime
  sh ~/.vim_runtime/install_awesome_vimrc.sh
}