#!/usr/bin/env bash

## Configuration for the script

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
#
# in case of non-minimal we will add fetch projects, pipenv, rust, rvm, and others...
CFG_MINIMAL=true

# enabled if we expect this to be run in a headless server
CFG_HEADLESS=true

# link for the non-public parts of the dotfiles
IMP_URL=""

# fetch important details
IMP_CONF=${DOT_DIR}/shared/important/imp_config.sh

# directory that contains non-public bits
IMP_DIR="${DOT_DIR}/shared/important"

# try to fetch the private bits
RET_STATUS=$(wget -q ${IMP_URL} -O ${IMP_DIR}/important.gpg)
if [[ ${RET_STATUS} -ne 0 ]]; then
    cli_error "wget returned a non-zero code while fetching private file at URL ${IMP_URL} - cannot continue"
    exit 1
else
    cli_info "wget fetched file successfully \n\tFrom: ${IMP_URL}\n\tSaved at: ${IMP_DIR}/important.gpg\n"
    # now extract it
    cli_warning "Trying to extract contents -- you will be prompted for your password by gpg."
fi

# check if we have an extra configuration file to use
if [[ ! -f ${IMP_CONF}  ]]; then
    cli_info "No extra configuration detected, using defaults"
    # my email
    CFG_EMAIL="andreas.grammenos@gmail.com"

    # git user/email
    CFG_GIT_USER="andylamp"
    CFG_GIT_EMAIL="${CFG_EMAIL}"

    # kitty terminal configuration
    CFG_KITTY_THEME="Afterglow"
    CFG_KITTY_CONF="${DOT_DIR}/shared/my_kitty.conf"

    # my bash configuration location
    CFG_BASH_CONF="${CFG_IMP_DIR}/my_bash.sh"

    # ssh id pub/priv
    CFG_SSH_PUB="${CFG_IMP_DIR}/id_pub"
    CFG_SSH_PRI="${CFG_IMP_DIR}/id_rsa"
else
    cli_info "Detected extra configuration file, sourcing it."
    # source the file with the extra bits.
    source ${IMP_CONF}
fi

# check that we have valid parameters
if [[ -z ${CFG_GIT_USER} ]] ||\
   [[ -z ${CFG_GIT_EMAIL} ]] ||\
   [[ -z ${CFG_KITTY_THEME} ]] ||\
   [[ -z ${CFG_KITTY_CONF} ]] ||\
   [[ -z ${CFG_BASH_CONF} ]] ||\
   [[ -z ${CFG_SSH_PUB} ]] ||\
   [[ -z ${CFG_SSH_PRI} ]]; then
    cli_error "Error, one of the required parameters is not set."
    exit 1
fi
