#!/bin/bash

## Boostrap.sh

## Detect if the script is being sourced which is not supported
# version similar to SO user answer mklement0.
sourced=0
if [[ -n "${ZSH_EVAL_CONTEXT}" ]]; then
  case ${ZSH_EVAL_CONTEXT} in *:file) sourced=1;; esac
elif [[ -n "${KSH_VERSION}" ]]; then
  [[ "$(cd $(dirname -- $0) && pwd -P)/$(basename -- $0)" != "$(cd $(dirname -- ${.sh.file}) && pwd -P)/$(basename -- ${.sh.file})" ]] && sourced=1
elif [[ -n "${BASH_VERSION}" ]]; then
  (return 0 2>/dev/null) && sourced=1
else # All other shells: examine $0 for known shell binary filenames
  # Detects `sh` and `dash`; add additional shell filenames as needed.
  case ${0##*/} in sh|dash) sourced=1;; esac
fi

# exit as this is not supported.
if [[ ${sourced} = 1 ]]; then
    echo "Error: cannot run script as sourced - please run it normally."
    return 1
fi

## Common variables

# find current directory and put it in a global variable for our script to use
# DOT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# this is simple and works on most shells - but is not able to be sourced.
DOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

# now source everything else
source ${DOT_DIR}/shared/common.sh

# user directory
MY_USER="$(whoami)"
MY_HOME="$(expand_path "~/")"

# detect if we are running as root
detect_root() {
  if [[ $(id -u) -eq 0 ]]; then
    cli_error "Error: You cannot run this as root, exiting."; exit 1;
  else
    cli_info "Running as user ${MY_USER}."
  fi
}

# fetch my projects if needed
fetch_projects() {
  # check for details
  read -p $(cli_info "Do you want to fetch/update git projects as well? [y/n]: ") -n 1 -r;
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    cli_info "\tOK, fetching!"
    # fetch my projects
    fetch_my_projects
  else
    cli_info "\tOK, skipping fetching!"
  fi
}

bootstrap() {
  cli_info "Welcome to dotfile script!"
  detect_root
  detect_os
  fetch_projects
}

# fire up the script
bootstrap