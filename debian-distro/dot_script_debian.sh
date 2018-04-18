#!/usr/bin/env bash

## (My) Dotfiles for Debian based distros

## Initialization

echo -e "\n !! Executing Debian distro dotfile"
# rudimentary sanity check
check_params

## Register repos

# add sublime gpg key
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | \
sudo apt-key add -
# sublime repo
echo "deb https://download.sublimetext.com/ apt/dev/" | \
sudo tee /etc/apt/sources.list.d/sublime-text.list

# java package
echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
tee /etc/apt/sources.list.d/webupd8team-java.list
echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | \
tee -a /etc/apt/sources.list.d/webupd8team-java.list
# add the key
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886

# enable contrib and non-free repos (for fira-code)
sudo deb http://deb.debian.org/debian stretch main contrib non-free
sudo deb-src http://deb.debian.org/debian stretch main contrib non-free

# install java
echo oracle-java8-installer shared/accepted-oracle-licence-v1-1 boolean true | \
sudo /usr/bin/debconf-set-selections

# install set-default
sudo apt-get install oracle-java8-set-default