#!/bin/bash

## Boostrap.sh

## Common variables
# find current directory and put it in a global variable
DOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# now source everything else
source $DOT_DIR/shared/common.sh

# source config
source $DOT_DIR/config.sh

# user directory
myuser="$(whoami)"
myhome="$(expand_path "~/")"

bootstrap() {
  printf "\nWelcome to dotfile script!\n\n"
  detect_os
}

# fire up the script
bootstrap