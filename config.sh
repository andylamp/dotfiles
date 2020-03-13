#!/usr/bin/env bash

## Configuration for the script

# link for the non-public parts of the dotfiles
IMPORTANT_URL=""

# my email
CFG_EMAIL="andreas.grammenos@gmail.com"

# git user/email
CFG_GIT_USER="andylamp"
CFG_GIT_EMAIL="${CFG_EMAIL}"

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
#
# in case of non-minimal we will add fetch projects, pipenv, rust, rvm, and others...
CFG_MINIMAL=true

# enabled if we expect this to be run in a headless server
CFG_HEADLESS=true

# kitty terminal configuration
CFG_KITTY_THEME="Afterglow"
CFG_KITTY_CONF="${DOT_DIR}/shared/my_kitty.conf"

# my bash configuration location
CFG_BASH_CONF="${DOT_DIR}/shared/important/my_bash.sh"

# my ssh pub and private key location
CFG_SSH_PUB="${DOT_DIR}/shared/important/id_pub"
CFG_SSH_RSA="${DOT_DIR}/shared/important/id_rsa"

# ssh id pub/priv
CFG_MY_SSH_PUB="${DOT_DIR}/shared/important/id_pub"
CFG_MY_SSH_PRI="${DOT_DIR}/shared/important/id_rsa"

