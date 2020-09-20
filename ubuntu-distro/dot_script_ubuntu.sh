#!/usr/bin/env bash

# (My) Dotfiles for Ubuntu based distros

# Initialization

cli_info "Executing Ubuntu distro dotfile."

# perform an update, upgrade, auto-remove before install
if sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove; then
  cli_info "Update and upgraded system packages successfully"
else
  cli_error "Error, non-zero code encountered while updating - cannot continue."
  exit 1
fi

# add gpg since we are going to need it.


# check if something went wrong
if sudo apt install -y gnupg2; then
  cli_info "Installed gpg successfully"
else
  cli_error "Error, non-zero code encountered while installing gnupg - cannot continue."
  exit 1
fi

# prepare config
prep_config

# rudimentary sanity check
check_params

# Register repos

if ! wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | \
sudo apt-key add - && \
# add sublime repo
echo "deb https://download.sublimetext.com/ apt/dev/" | \
sudo tee /etc/apt/sources.list.d/sublime-text.list && \
# add universe for fira-code
sudo add-apt-repository universe; then
  cli_error "There while adding the custom repos - cannot continue"
  exit 1
fi

# Install (my) packages

# install (my) essential packages while checking if packages installed correctly.
if ! sudo apt update && sudo apt install -y\
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
  cpu-checker \
  fonts-firacode \
  tmux \
  maven \
  kitty \
  openssh-server \
  openssh-client \
  glances \
  htop \
  python3-pip \
  jq; then
  cli_error "Error, non-zero code encountered while installing essential packages - cannot continue."
fi

# install optional packages
if [[ ${CFG_MINIMAL} = false ]]; then

  # try to install packages.
  if ! sudo apt install -y\
    lm-sensors \
    sysstat \
    doxygen \
    python3-sphinx \
    qbittorrent \
    python3-bottle; then
    cli_error "Error, non-zero code encountered while installing extra packages - cannot continue."
  fi
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

if [[ ${CFG_DOCKER_INSTALL} = true ]]; then
  cli_info "Installing docker and docker-compose"
  # shellcheck source=/dev/null
  if ! source "${DOT_DIR}/ubuntu-distro/docker_ubuntu_install.sh"; then
    cli_error "There was an error sourcing ubuntu docker installation function - skipping"
  fi

  # run docker install
  docker_ubuntu_install
fi

# sourcing profile to update the current window
cli_info "Sourcing updated ${MY_HOME}.profile"

# shellcheck source=/dev/null
if ! source "${MY_HOME}.profile"; then
  cli_error "There was an issue while sourcing updated ~/.profile - things might not work as expected..."
fi

# finally, perform one last auto-remove of any leftover unused packages
sudo apt -y autoremove

cli_info "Execution of Ubuntu dotfile installation has been completed."