#!/usr/bin/env bash

# setup rvm
rvm_install() {
  cli_info "Installing rvm along with stable ruby."

  # check if rvm is present.
  if [[ -d ${MY_HOME}.rvm ]]; then
    cli_info "rvm appears to be already installed, skipping."
    return 0
  fi

  # we need to install it
  gpg --keyserver hkp://pool.sks-keyservers.net \
      --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
                  7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  # get ruby now
  \curl -s -L https://get.rvm.io | bash -s stable --ruby > /dev/null 2>&1
  if [[ -d ${MY_HOME}.rvm ]]; then
    # source the rvm for the current window
    source ${MY_HOME}.rvm/scripts/rvm
    cli_info "rvm has been installed successfully - installed version: $(ruby -v)."
  else
    cli_error "Error: could not install rvm for some reason."
    return 1
  fi
}