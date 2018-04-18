#!/usr/bin/env bash

# setup rvm
rvm_install() {
  echo " -- Installing rvm along with stable ruby"
  gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
  \curl -s -L https://get.rvm.io | bash -s stable --ruby > /dev/null 2>&1
  if [[ -d $myhome.rvm ]]; then
    # source the rvm for the current window
    source $myhome.rvm/scripts/rvm
    echo " -- rvm installed successfully"
    echo "source $myhome.rvm/scripts/rvm" >> $myhome.bashrc
    ruby -v
  else
    echo " ** Error: could not install rvm for some reason"
  fi
}