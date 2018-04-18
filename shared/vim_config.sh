#!/usr/bin/env bash

vim_config() {
  echo " -- Configuring vim"
  # rudimentary sanity check
  if [[ -z $myhome ]]; then
    echo " ** Error: expected non empty string -- skipping vim config"
    return 1
  fi
  if [[ -d $myhome.vim_runtime ]]; then
    echo " -- vim_runtime dir already exists, probably already configured"
  else
    echo " -- Installing awesome_vimrc to $myhome"
    ## Configure vim
    git clone --depth=1 https://github.com/andylamp/vimrc.git $myhome.vim_runtime
    sh $myhome.vim_runtime/install_awesome_vimrc.sh
  fi
}