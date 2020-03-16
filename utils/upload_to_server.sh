#!/usr/bin/env bash
# This script for uploading into a server the gpg packed private bits which can then be accessed
# by the dotscripts in other computers :).

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_info_read { echo -e -n " -- \e[1;32m$1\e[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_warning_read { echo -e -n " ** \e[1;33m$1\e[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

cli_info "Welcome to upload to server script."

# root check
if [[ $(id -u) -eq 0 ]]; then
  cli_error "Error: You cannot run this as root, exiting."; exit 1;
else
  cli_info "Running as user $(whoami)."
fi

# check if the script has two arguments
if [[ ! ${#} -eq 3 ]]; then
  cli_warning "Script requires three arguments - cannot continue."
  cli_info "Script usage:\n\t./pack file.gpg url user"
  exit 1
else
  cli_info "Got arguments:\n\tfile ${1}\n\tURL ${2}\n\tRemote username ${3}"
  # do a sanity check, before proceeding...
  cli_warning_read "Do the details shown above appear OK to you? [y/n]: "
  read -n 1 -r; echo ""
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    cli_warning "Details seem to be OK, continuing..."
  else
    cli_error "Details are not OK, aborting..."
    exit 1
  fi
fi

REMOTE_DEST_DIR="/var/www"
REMOTE_DEST_USER="${3}"

cli_info "Trying to upload packed file to server..."

if [[ ! -f $1 ]]; then
  cli_error "Target File not found - cannot continue."
  exit 1
else
  cli_info "Target file found at ${1} - are you sure you want to upload this file?"
fi

# check if we have access to ssh and scp
if [[ ! -x "$(command -v scp)" ]]; then
    cli_error "scp needs to be installed and accessible - cannot continue."
    exit 1
elif [[ ! -x "$(command -v ssh)" ]]; then
    cli_error "ssh needs to be installed and accessible - cannot continue."
    exit 1
else
    cli_info "scp and ssh appear to be present - we can proceed."
fi

# now try to upload the file to the url supplied - assumes that private keys are present!
cli_info "Uploading ${1} to ${2} using stored ssh keys"
scp ${1} > ${3}@${2}:~

# check if everything went as planned.
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value return while copying file to remote - cannot continue."
  exit 1
fi

# do execute the commands to put it in the correct directory in the remove server
# in my case this would be an web server - so I'd make it owned by www-data
# normally under /var/www.

# notify the user that we're done.
cli_info "Finished uploading packed file to server..."