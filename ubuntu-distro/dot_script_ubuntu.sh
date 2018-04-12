#!/usr/bin/env bash

## (My) Dotfiles for Ubuntu based distros

## Initialization

# my id pub/priv
myid=""
myrsa=""
# git username
mygituser=""
# my email
myemail=""
# get my local home
myhome="$(pwd ~)"
myuser="$(whoami)"

## Register repos

# add sublime gpg key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | \
sudo apt-key add -
# sublime repo
echo "deb https://download.sublimetext.com/ apt/dev/" | \
sudo tee /etc/apt/sources.list.d/sublime-text.list
# java repo
sudo add-apt-repository ppa:webupd8team/java
# add universe for fira-code
sudo add-apt-repository universe

# source common scripts
source ../shared/common.sh

## Install basic/essential packages

# perform an update before install
sudo apt-get update
# install the packages
sudo apt-get --assume-yes install valgrind graphviz vim doxygen \
curl git apt-transport-https sublime-text oracle-java8-set-default \
build-essential python3 python3-dev checkinstall \
fonts-firacode

# Configure rust
rust_install

# Configure git
git_config $mygituser $myemail

# Configure vim
vim_config

# Configure ssh
ssh_config $myid $myrsa
