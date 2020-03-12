#!/usr/bin/env bash

## Configuration for the script

# link with blobs
blob_link=""

# ssh id pub/priv
myid="${DOT_DIR}/shared/id_pub"
myrsa="${DOT_DIR}/shared/id_rsa"

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
MINIMAL=true

# if non minimal we will add ufw rules, fetch projects, pipenv, rust, rvm, and others...

# email
myemail="andreas.grammenos@gmail.com"

# git username
mygituser="andylamp"
mygitemail="$myemail"

# kitty (case sensitive!)
kitty_theme="Afterglow"
my_kitty_conf="${DOT_DIR}/shared/my_kitty.conf"

# my bash configuration
my_bash_conf="${DOT_DIR}/shared/my_bash.sh"
