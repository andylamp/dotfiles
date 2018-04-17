#!/usr/bin/env bash

vim_config() {
  # rudimentary sanity check
  if [[ $# -ne 1 ]] || [[ -z $1 ]]; then
    echo "Expected only one argument got none/more or empty string -- skipping vim config"
    return 1
  fi
  # got the path
  myhome=$1
  ## Configure vim
  git clone --depth=1 https://github.com/andylamp/vimrc.git $myhome/.vim_runtime
  sh $myhome/.vim_runtime/install_awesome_vimrc.sh
}