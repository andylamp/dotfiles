#!/usr/bin/env bash

## (My) Dotfiles for Ubuntu based distros

## Initialization

# my local home
myuser=$1
myhome=$2
# my email
myemail=$3
# my git username
mygituser=$4
# my ssh id pub/priv
myid=$5
myrsa=$6

## Register repos

return

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
