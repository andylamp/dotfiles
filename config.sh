#!/usr/bin/env bash

## Configuration for the script

# link for the non-public parts of the dotfiles
IMPORTANT_URL=""

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
#
# in case of non-minimal we will add fetch projects, pipenv, rust, rvm, and others...
CFG_MINIMAL=true

# enabled if we expect this to be run in a headless server
CFG_HEADLESS=true

# fetch important details
IMP_CONF=${DOT_DIR}/shared/important/imp_config.sh

# directory that contains non-public bits
IMP_DIR="${DOT_DIR}/shared/important"

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
