#!/usr/bin/env bash

# install homebrew for macos
function homebrew_install {

  # check if brew already exists
  if [[ -x "$(command -v brew)" ]]; then
    cli_info "homebrew appears to be installed - updating and upgrading"
    brew update && brew upgrade
    if [[ ${?} -ne 0 ]]; then
      cli_error "brew update failed"
      exit 1
    else
      cli_info "brew has been updated and upgraded."
      exit 0
    fi
  fi

  # check which way to install using bash or ksh.
  if [[ ${KSH_SHELL} -eq 0 ]]; then
    cli_info "Installing homebrew (ksh version)"
    # check if we are using ksh
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  else
    cli_info "Installing homebrew (bash version)"
    # bash installation of homebrew
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi

  # check if anything went wrong during installation.
  if [[ ${?} -ne 0 ]]; then
    cli_error "homebrew installation failed - cannot continue."
    exit 1
  fi
}