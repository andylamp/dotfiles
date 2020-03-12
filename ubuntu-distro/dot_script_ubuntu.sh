#!/usr/bin/env bash

## (My) Dotfiles for Ubuntu based distros

## Initialization

cli_info "Executing Ubuntu distro dotfile."

# rudimentary sanity check
check_params

## Register repos

# add sublime gpg key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | \
sudo apt-key add -
# sublime repo
echo "deb https://download.sublimetext.com/ apt/dev/" | \
sudo tee /etc/apt/sources.list.d/sublime-text.list
# add universe for fira-code
sudo add-apt-repository universe

## Install basic/essential packages

# perform an update before install
sudo apt-get update

# install the packages
sudo apt-get --assume-yes install \
  valgrind \
  graphviz \
  vim \
  doxygen \
  curl \
  git \
  apt-transport-https \
  sublime-text \
  openjdk-11-jdk openjdk-11-doc \
  build-essential \
  python3 python3-dev \
  checkinstall \
  fonts-firacode \
  gnupg2 \
  tmux \
  maven \
  kitty \
  openssl-server \
  lm-sensors \
  glances \
  python-bottle \
  htop \
  python3-pip

# Configure git
git_config

# Configure vim
vim_config

# Configure bash shell
bash_config

# Configure ssh
ssh_config

# kitty terminal config
kitty_config

if [[ ${MINIMAL} = false ]]; then
    cli_info "Minimal flag is false - installing rust, rvm, and pipenv."
    # Configure rust
    rust_install

    # pipenv3 config
    pipenv3_config

    # rvm and ruby install
    rvm_install
else
    cli_info "Minimal flag is true - skipping rust, rvm, and pipenv installation."
fi

cli_info "Execution of Ubuntu dotfile installation has been completed."

# finally, auto-remove unused packages
sudo apt autoremove
