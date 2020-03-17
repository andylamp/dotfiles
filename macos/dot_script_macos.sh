#!/usr/bin/env bash

## (My) Dotfiles for MacOS based distros

# install the xcode command line tools
xcode-select --install

KSH_SHELL=0
# check if we are using ksh
if [[ ! -z ${KSH_VERSION} ]]; then
  cli_info "Detected ksh version: ${KSH_VERSION}"
  KSH_SHELL=1
else
  cli_info "Detected non-ksh shell, assuming BASH"
fi

# source common scripts
source ${DOT_DIR}/shared/common.sh