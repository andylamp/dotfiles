#!/usr/bin/env bash

# setup rvm
rvm_install() {
  echo -e "\n -- Installing rvm along with stable ruby"

  if [[ -d ${myhome}.rvm ]]; then
    echo " -- rvm appears to be already installed, skipping"
    return 0
  fi
  # we need to install it
  gpg2 --keyserver hkp://pool.sks-keyservers.net \
        --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 \
                    7D2BAF1CF37B13E2069D6956105BD0E739499BDB
  # get ruby now
  \curl -s -L https://get.rvm.io | bash -s stable --ruby > /dev/null 2>&1
  if [[ -d ${myhome}.rvm ]]; then
    # source the rvm for the current window
    source ${myhome}.rvm/scripts/rvm
    echo " -- rvm installed successfully"
    echo "source ${myhome}.rvm/scripts/rvm" >> ${myhome}.bashrc
    ruby -v
  else
    echo " ** Error: could not install rvm for some reason"
  fi
}