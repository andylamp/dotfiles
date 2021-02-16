#!/usr/bin/env bash
# shellcheck disable=SC2034

# This is the basic script configuration - a bit explanation is needed and TBD.

# if we want a minimal setup (git cred, ssh, aliases, terminal, etc)
#
# in case of non-minimal we will add fetch projects, pipenv, rust, rvm, and others...

CFG_MINIMAL=false

# enabled if we expect this to be run in a headless server (this does not do anything yet)
CFG_HEADLESS=true

# enabled if we want to install docker and docker-compose (only for ubuntu currently)
CFG_DOCKER_INSTALL=true

# link for the non-public parts of the dotfiles - can only be empty if
# you already have the files.
CFG_IMP_URL=""

# check if we allow sshd login
CFG_OPEN_SSHD=true

# check if we install nox for qbittorrent
CFG_QBITTORRENT_INSTALL=false
# check if we install the headless version only (nox)
CFG_QBITTORRENT_NOX_ONLY=true
# check if we have a systemd daemon enabled
CFG_QBITTORRENT_NOX_SYSTEMD=true
# the username of qbittorrent that the daemon should run
CFG_QBITTORRENT_NOX_USER=qbittorrent-nox
# the systemd nox service file
CFG_QBITTORRENT_SYSTEMD_SERVICE="/etc/systemd/system/qbittorrent-nox.service"
# the port to use for qbittorrent
CFG_QBITTORRENT_NOX_PORT=18080

# directory that contains non-public bits
CFG_IMP_DIR="${DOT_DIR}/shared/important"

# the extra config bits to be parsed - can be empty.
# IMP_CONF=""
CFG_IMP_CONF="${CFG_IMP_DIR}/imp_config.sh"
