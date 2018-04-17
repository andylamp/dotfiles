#!/bin/bash

## Boostrap.sh

## Common variables
# find current directory and put it in a global variable
DOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# now source everything else
source $DOT_DIR/shared/common.sh

# ssh id pub/priv
myid=""
myrsa=""

# user directory
myuser="$(whoami)"
myhome="$(expand_path "~/")"

echo -e "\n ** Initialisation details **\n"
echo -e "\n !! SSH Details:\n\tmy_id: $myid\n\tmy_rsa: $myrsa"
echo -e "\n !! User details:\n\tuser: $myhome\n\thome: $myhome"

# check for details
read -p "Do the details shown above appear OK to you? [y/n]: " -n 1 -r; echo ""
if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
  echo -e "\nDetails seem to be OK -- continuing\n"
else
  echo -e "\nDetails are not OK -- finishing\n"
  return
fi

bootstrap() {
  printf "\nWelcome to dotfile script!\n\n"
  detect_os
}

# fire up the script
bootstrap






