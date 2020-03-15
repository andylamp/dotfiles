#!/usr/bin/env bash

## (My) Dotfiles for Ubuntu based distros

## Initialization

cli_info "Executing Ubuntu distro dotfile."

# perform an update, upgrade, auto-remove before install
sudo apt update && sudo apt -y upgrade && sudo apt autoremove

# check if something went wrong
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero code encountered while updating - cannot continue."
  exit 1
fi

# add gpg since we are going to need it.
sudo apt install -y gnupg2

# check if something went wrong
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero code encountered while installing gnupg - cannot continue."
  exit 1
fi

# prepare config
prep_config

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

## Install (my) packages

# perform an update of the repositories
sudo apt update

# install (my) essential packages
sudo apt install -y \
  valgrind \
  graphviz \
  vim \
  curl \
  git \
  apt-transport-https \
  sublime-text \
  openjdk-11-jdk openjdk-11-doc \
  build-essential \
  python3 python3-dev \
  checkinstall \
  fonts-firacode \
  tmux \
  maven \
  kitty \
  openssl-server \
  glances \
  htop \
  python3-pip

# install optional packages
if [[ ${CFG_MINIMAL} = false ]]; then
  sudo apt install -y \
    lm-sensors \
    doxygen \
    qbittorrent \
    python-bottle
fi

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

if [[ ${CFG_MINIMAL} = false ]]; then
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

# sourcing profile to update the current window
cli_info "Sourcing updated ${MY_HOME}.profile"
source ${MY_HOME}.profile

# finally, auto-remove unused packages
sudo apt autoremove

cli_info "Execution of Ubuntu dotfile installation has been completed."