#!/usr/bin/env bash
# This script is for packing important files into a gpg protected archive, which will be used
# as input for the dotfiles script.

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

# get the dotfile directory path
SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# get the important directory path
IMP_DIR="${SCRIPT_DIR}/../shared/important/"
# outfile name
OUT_NAME="important"

cli_info "Starting to pack important files at ${IMP_DIR}..."

# check if we have access to GPG
if [[ ! -x "$(command -v gpg)" ]]; then
    cli_error "gpg needs to be installed and accessible - cannot continue."
    exit 1
elif [[ ! -x "$(command -v tar)" ]]; then
    cli_error "tar needs to be installed and accessible - cannot continue."
    exit 1
else
    cli_info "gpg and tar appear to be present."
fi

# now check if the critical bits exist
if [[ ! -f ${IMP_DIR}/my_bash.sh ]]; then
    cli_error "Error: could not find bash config."
    exit 1
elif [[ ! -f ${IMP_DIR}/id_rsa ]]; then
    cli_error "Error: could not find ssh private key."
    exit 1
elif [[ ! -f ${IMP_DIR}/id_pub ]]; then
    cli_error "Error: could not find ssh public key."
    exit 1
fi

if [[ ! -f ${IMP_DIR}/imp_config.sh ]]; then
    cli_warning "No optional configuration present - not packing it."
else
    cli_info "Optional configuration found - packing it."
fi

cli_info "Compressing and encrypting..."

# pack them up with a given password
tar --exclude='./README.md' --exclude='*.gpg' -cjv -C ${IMP_DIR} . | gpg -co ${OUT_NAME}.gpg

cli_info "Finished packing - output resides at ${SCRIPT_DIR}/${OUT_NAME}.gpg."