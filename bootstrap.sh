#!/bin/bash

## Boostrap.sh

## Common variables
# find current directory and put it in a global variable
DOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# now source everything else
source ${DOT_DIR}/shared/common.sh

# source config
source ${DOT_DIR}/config.sh

# user directory
myuser="$(whoami)"
myhome="$(expand_path "~/")"

detect_root() {
  if [[ $(id -u) -eq 0 ]]; then
    echo "\n Error: You cannot run this as root, exiting\n\n"; exit 1;
  else
    printf "\n ** Running as user $myuser\n\n"
  fi
}

# fetch my projects if needed
fetch_projects() {
  # check for details
  read -p " !! Do you want to fetch/update git projects as well? [y/n]: " -n 1 -r;
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    echo -e "\n -- OK, fetching\n"
    # fetch my projects
    fetch_my_projects
  else
    echo -e "\n -- OK, skipping fetching\n"
  fi
}

bootstrap() {
  printf "\nWelcome to dotfile script!\n\n"
  detect_root
  detect_os
  fetch_projects
}

# fire up the script
bootstrap