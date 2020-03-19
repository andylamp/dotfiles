#!/usr/bin/env bash

# configure vim.
vim_config() {
  cli_info "Configuring vim."

  # rudimentary sanity check
  if [[ -z ${MY_HOME} ]]; then
    cli_error "Error: expected non empty string -- skipping vim config."
    return 1
  fi
  # check if we need to clone for the first time or update.
  if [[ -d ${MY_HOME}.vim_runtime ]]; then
    cli_warning "vim_runtime dir already exists, probably already configured - trying to update it!"
    # updating from master
    git -C ${MY_HOME}.vim_runtime pull
  else
    cli_info "Installing awesome_vimrc to ${MY_HOME}."
    # clone the repository
    git clone --depth=1 https://github.com/andylamp/vimrc.git ${MY_HOME}.vim_runtime
  fi

  # (re)-install it.
  sh ${MY_HOME}.vim_runtime/install_awesome_vimrc.sh
}