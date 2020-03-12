#!/usr/bin/env bash

vim_config() {
  cli_info "Configuring vim."
  # rudimentary sanity check
  if [[ -z ${myhome} ]]; then
    cli_error "Error: expected non empty string -- skipping vim config."
    return 1
  fi
  if [[ -d ${myhome}.vim_runtime ]]; then
    cli_warning "vim_runtime dir already exists, probably already configured."
  else
    cli_info "Installing awesome_vimrc to ${myhome}."
    ## Configure vim
    git clone --depth=1 https://github.com/andylamp/vimrc.git ${myhome}.vim_runtime
    sh ${myhome}.vim_runtime/install_awesome_vimrc.sh
  fi
}