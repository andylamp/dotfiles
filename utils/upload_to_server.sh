#!/usr/bin/env bash
# This script for uploading into a server the gpg packed private bits which can then be accessed
# by the dotscripts in other computers :).
#
# This has only been tested with bash - probably works with ksh as well.

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
  cli_error "Script requires three arguments - cannot continue."
  cli_error "Script usage:\n\t./upload_to_server.sh file.gpg url user"
  exit 1
else
  cli_info "Got arguments:\n\tFile to upload: ${1}\n\tURL: ${2}\n\tRemote username: ${3}"
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

# variables
FILE_TO_UPLOAD=${1}
REMOTE_URL=${2}
REMOTE_USER=${3}

# presets
REMOTE_DEST_DIR="/var/www/html"
REMOTE_SERVE_USER="www-data"
REMOTE_SERVE_GROUP="www-data"

cli_info "Trying to upload packed file to server..."

if [[ ! -f $1 ]]; then
  cli_error "Target File not found - cannot continue."
  exit 1
else
  cli_info "Target file found at ${1} - trying to upload."
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

cli_info "Adding stored ssh keys - you will be prompted to type the password for each."

# add the ssh keys, first use eval -- see: https://unix.stackexchange.com/questions/351725
eval $(ssh-agent -s)
# now add the available keys, you will be asked for your password.
ssh-add

# check if something went wrong
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero code encountered while adding the ssk keys - cannot continue."
else
  cli_info "ssh key(s) appear to be added correctly."
fi


# now try to upload the file to the url supplied - assumes that private keys are present!
cli_info "Uploading ${1} to ${2} using stored ssh keys"
scp ${FILE_TO_UPLOAD} ${REMOTE_USER}@${REMOTE_URL}:~

# check if everything went as planned.
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value return while copying file to remote - cannot continue."
  exit 1
fi

# do execute the commands to put it in the correct directory in the remove server
# in my case this would be an web server - so I'd make it owned by www-data
# normally under /var/www.
#
# this is a trick which expands the variables *before* they are passed to ssh so that they are
# available to the script verbatim to be executed in remote.
function ssh_move {
  REMOTE_FILE="$(printf '%q' "${FILE_TO_UPLOAD}")"
  REMOTE_PATH="$(printf '%q' "${REMOTE_DEST_DIR}/${REMOTE_USER}")"
  REMOTE_OWN="$(printf '%q' "${REMOTE_SERVE_USER}:${REMOTE_SERVE_GROUP}")"
  # "sudo mv ~/${REMOTE_FILE} ${REMOTE_PATH} && sudo chown -R ${REMOTE_OWN} ${REMOTE_PATH}"
  ssh -t ${REMOTE_USER}@${REMOTE_URL}\
  "sudo mv ~/\"${REMOTE_FILE}\" \"${REMOTE_PATH}\"; echo "Move OK" && sudo chown -R \"${REMOTE_OWN}\" \"${REMOTE_PATH}\"; echo "Permissions OK""
}

# call the function that is used to expand the variables
ssh_move

# check if everything went OK
if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero code returned while moving remote file to correct location."
else
  cli_info "It appears that file moved successfully at remote location."
fi

# notify the user that we're done.
cli_info "Finished uploading packed file to server..."