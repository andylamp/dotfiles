#!/usr/bin/env bash

vim_config() {
  cli_info "Configuring vim."
  # rudimentary sanity check
  if [[ -z ${MY_HOME} ]]; then
    cli_error "Error: expected non empty string -- skipping vim config."
    return 1
  fi
  if [[ -d ${MY_HOME}.vim_runtime ]]; then
    cli_warning "vim_runtime dir already exists, probably already configured."
  else
    cli_info "Installing awesome_vimrc to ${MY_HOME}."
    ## Configure vim
    git clone --depth=1 https://github.com/andylamp/vimrc.git ${MY_HOME}.vim_runtime
    sh ${MY_HOME}.vim_runtime/install_awesome_vimrc.sh
  fi
}