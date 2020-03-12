#!/usr/bin/env bash

## Configuration for the script

# link with blobs
blob_link=""

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
#
# in case of non-minimal we will add ufw rules, fetch projects, pipenv, rust, rvm, and others...
MINIMAL=true
# email
myemail="andreas.grammenos@gmail.com"

# git username
mygituser="andylamp"
mygitemail="$myemail"

# kitty (case sensitive!)
kitty_theme="Afterglow"
my_kitty_conf="${DOT_DIR}/shared/my_kitty.conf"

# important files

# my bash configuration
my_bash_conf="${DOT_DIR}/shared/important/my_bash.sh"

# ssh id pub/priv
myid="${DOT_DIR}/shared/important/id_pub"
myrsa="${DOT_DIR}/shared/important/id_rsa"
