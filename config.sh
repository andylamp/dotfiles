#!/usr/bin/env bash

# This is the basic script configuration - a bit explanation is needed and TBD.

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
#
# in case of non-minimal we will add fetch projects, pipenv, rust, rvm, and others...
CFG_MINIMAL=true

# enabled if we expect this to be run in a headless server
CFG_HEADLESS=true

# link for the non-public parts of the dotfiles - can only be empty if
# you already have the files.
CFG_IMP_URL=""

# directory that contains non-public bits
CFG_IMP_DIR="${DOT_DIR}/shared/important"

# the extra config bits to be parsed - can be empty.
# IMP_CONF=""
CFG_IMP_CONF="${IMP_DIR}/imp_config.sh"

