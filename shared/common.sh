#!/usr/bin/env bash

# source necessary files
# utility functions
source ${DOT_DIR}/shared/url_validator.sh
# git
source ${DOT_DIR}/shared/git_config.sh
# ssh config
source ${DOT_DIR}/shared/ssh_config.sh
# vim config
source ${DOT_DIR}/shared/vim_config.sh
# rust install
source ${DOT_DIR}/shared/rust_install.sh
# rvm install
source ${DOT_DIR}/shared/rvm_install.sh
# jetbrains install
source ${DOT_DIR}/shared/jetbrains_install.sh
# fetch my projects
source ${DOT_DIR}/shared/fetch_my_projects.sh

# beautiful and tidy way to expand tilde (~) by C. Duffy.
expand_path() {
  case $1 in
    ~[+-]*)
      local content content_q
      printf -v content_q '%q' "${1:2}"
      eval "content=${1:0:2}${content_q}"
      printf '%s\n' "$content"
      ;;
    ~*)
      local content content_q
      printf -v content_q '%q' "${1:1}"
      eval "content=~${content_q}"
      printf '%s\n' "$content"
      ;;
    *)
      printf '%s\n' "$1"
      ;;
  esac
}

find_linux_distro() {
  echo "Detected Linux-based OS, trying to find flavor"
  if [[ -f /etc/os-release ]]; then
      # freedesktop.org and systemd
      . /etc/os-release
      OS=${NAME}
      VER=${VERSION_ID}
  elif type lsb_release >/dev/null 2>&1; then
      # linuxbase.org
      OS=$(lsb_release -si)
      VER=$(lsb_release -sr)
  elif [[ -f /etc/lsb-release ]]; then
      # For some versions of Debian/Ubuntu without lsb_release command
      . /etc/lsb-release
      OS=${DISTRIB_ID}
      VER=${DISTRIB_RELEASE}
      echo "This"
  elif [[ -f /etc/debian_version ]]; then
      # Older Debian/Ubuntu/etc.
      OS=Debian
      VER=$(cat /etc/debian_version)
  elif [[ -f /etc/SuSe-release ]]; then
      # Older SuSE/etc.
      #...
      OS="Old SuSe derived distribution"
      VER="Unknown"
  elif [[ -f /etc/redhat-release ]]; then
      # Older Red Hat, CentOS, etc.
      #...
      OS="Old Red Hat Linux/Centos derived distribution"
      VER="Unknown"
  else
      # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
      OS=$(uname -s)
      VER=$(uname -r)
  fi
  echo " !! Found $OS, version: $VER"

  # launch the appropriate dotfile
  if [[ $OS -eq "Ubuntu" ]]; then
    echo " ** Configuring Ubuntu"
    source ${DOT_DIR}/ubuntu-distro/dot_script_ubuntu.sh
  elif [[ $OS -eq "Debian" ]]; then
    echo " ** Configuring Debian"
  else
    echo " ** No dotfile present for $OS"
  fi
}

# This file selects which one of the scripts we will use
detect_os() {
  echo "Trying to detect OS-type"
  if [[ "$OSTYPE" == "linux-gnu" ]]; then
    find_linux_distro
  elif [[ "$OSTYPE" == "dawrin" ]]; then
    echo "Detected MacOS"
  elif [[ "$OSTYPE" == "cygwin" ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
    echo "Detected win32/cygwin"
  elif [[ "$OSTYPE" == "msys" ]]; then
    echo "Detected win32/MinGW"
  elif [[ "$OSTYPE" == "win32" ]]; then
    # I'm not sure this can happen.
    echo "Detected win32"
  elif [[ "$OSTYPE" == "freebsd"* ]]; then
    echo "Detected FreeBSD"
  else
    echo "Unknown OS type"
  fi
}

check_params() {
  echo -e "\n ** Initialisation details **"
  echo -e " !! SSH Details:\n\tmy_id: ${myid}\n\tmy_rsa: ${myrsa}"
  echo -e " !! User details:\n\tuser: ${myhome}\n\thome: ${myhome}\n\temail: ${myemail}"
  echo -e " !! Git details:\n\tusername: ${mygituser}\n\temail: ${mygitemail}"
  echo -e " !! Kitty terminal parameters:\n\tConf file: ${my_kitty_conf}\n\tTheme: ${kitty_theme}"
  echo -e " !! Bash config:\n\t${kitty_theme}"

  # check for details
  read -p " !! Do the details shown above appear OK to you? [y/n]: " -n 1 -r; #echo ""
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    echo -e " -- Details seem to be OK, continuing\n"
  else
    echo -e " ** Details are not OK, aborting\n"
    exit 1
  fi
}