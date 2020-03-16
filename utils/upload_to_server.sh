#!/usr/bin/env bash
# This script for uploading into a server the gpg packed private bits which can then be accessed
# by the dotscripts in other computers :).

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

cli_info "Welcome to upload to server script."

# root check
if [[ $(id -u) -eq 0 ]]; then
  cli_error "Error: You cannot run this as root, exiting."; return 1;
else
  cli_info "Running as user $(whoami)."
fi

# check if the script has two arguments
if [[ ! ${#} -eq 2 ]]; then
  cli_warning "Script requires two arguments - cannot continue."
  return 1
fi

cli_info "Trying to upload packed file to server..."

if [[ ! -f $1 ]]; then
  cli_error "Target File not found - cannot continue."
  return 1
else
  cli_info "Target file found at ${1} - are you sure you want to upload this file?"
fi

# check if we have access to ssh and scp
if [[ ! -x "$(command -v scp)" ]]; then
    cli_error "scp needs to be installed and accessible - cannot continue."
    return 1
elif [[ ! -x "$(command -v ssh)" ]]; then
    cli_error "ssh needs to be installed and accessible - cannot continue."
    return 1
else
    cli_info "scp and ssh appear to be present."
fi

cli_info "Uploading ${1} to ${2} using stored ssh keys"
scp ${1} > $(whoami)@${2}:~

# check if everything went as planned.
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value return while copying file to remove - cannot continue."
  return 1
fi

# now try to uploaded to the url supplied - assumes that private keys are present!
cli_info "Finished uploading packed file to server..."