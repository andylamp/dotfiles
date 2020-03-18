#!/usr/bin/env bash
# This script is for packing important files into a gpg protected archive, which will be used
# as input for the dotfiles script.

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

cli_info "Pack script started."

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
    cli_error "Error: cannot run script as sourced - please run it normally."
    exit 1
fi

# get the dotfile directory path
# old version
#SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# newer, this is simple and works on most shells - but is not able to be sourced.
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
if [[ ${#} -eq 1 ]]; then
  cli_info "Parsed argument for output directory: ${1}"
  IMP_DIR="${1}"
else
  # get the important directory path
  IMP_DIR="${SCRIPT_DIR}/../shared/important/"
fi

# outfile name
OUT_NAME="important"

# check if the directory exists and is valid
if [[ ! -d ${IMP_DIR} ]]; then
  cli_error "Error, directory ${IMP_DIR} cannot be accessed or does not exist - cannot continue."
  exit 1
fi

cli_info "Starting to pack important files at ${IMP_DIR}."

# check if we have access to gpg and tar
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
tar --exclude='README.md' --exclude='*.gpg' -cjv -C ${IMP_DIR} . | gpg -co ${OUT_NAME}.gpg

if [[ ${?} -ne 0 ]]; then
    cli_error "Error: non-zero exit code while compressing and encrypting"
else
    cli_info "Finished packing - output resides at ${SCRIPT_DIR}/${OUT_NAME}.gpg."
fi

cli_info "Pack script finished."