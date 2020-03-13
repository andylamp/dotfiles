#!/usr/bin/env bash

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

# source necessary files

# utility functions
source ${DOT_DIR}/shared/url_validator.sh
# git
source ${DOT_DIR}/shared/git_config.sh
# ssh config
source ${DOT_DIR}/shared/ssh_config.sh
# vim config
source ${DOT_DIR}/shared/vim_config.sh
# bash config
source ${DOT_DIR}/shared/bash_config.sh
# kitty terminal config
source ${DOT_DIR}/shared/kitty_config.sh
# rust install
source ${DOT_DIR}/shared/rust_install.sh
# rvm install
source ${DOT_DIR}/shared/rvm_install.sh
# pipenv3 config
source ${DOT_DIR}/shared/pipenv3_config.sh
# jetbrains install
source ${DOT_DIR}/shared/jetbrains_install.sh
# fetch my projects
source ${DOT_DIR}/shared/fetch_my_projects.sh

# beautiful and tidy way to expand tilde (~) by C. Duffy.
expand_path() {
  case $1 in
    ~[+-]*)
      local content content_q
      printf -v content_q '%q' "${1:2}"
      eval "content=${1:0:2}${content_q}"
      printf '%s\n' "$content"
      ;;
    ~*)
      local content content_q
      printf -v content_q '%q' "${1:1}"
      eval "content=~${content_q}"
      printf '%s\n' "$content"
      ;;
    *)
      printf '%s\n' "${1}"
      ;;
  esac
}

# find which linux distribution we have
find_linux_distro() {
  echo "Detected Linux-based OS, trying to find flavor"
  if [[ -f /etc/os-release ]]; then
      # freedesktop.org and systemd
      . /etc/os-release
      OS=${NAME}
      VER=${VERSION_ID}
  elif type lsb_release >/dev/null 2>&1; then
      # linuxbase.org
      OS=$(lsb_release -si)
      VER=$(lsb_release -sr)
  elif [[ -f /etc/lsb-release ]]; then
      # For some versions of Debian/Ubuntu without lsb_release command
      . /etc/lsb-release
      OS=${DISTRIB_ID}
      VER=${DISTRIB_RELEASE}
      cli_info "Detected Debian based without lsb_release."
  elif [[ -f /etc/debian_version ]]; then
      # Older Debian/Ubuntu/etc.
      OS=Debian
      VER=$(cat /etc/debian_version)
  elif [[ -f /etc/SuSe-release ]]; then
      # Older SuSE/etc.
      #...
      OS="Old SuSe derived distribution"
      VER="Unknown"
  elif [[ -f /etc/redhat-release ]]; then
      # Older Red Hat, CentOS, etc.
      #...
      OS="Old Red Hat Linux/Centos derived distribution"
      VER="Unknown"
  else
      # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
      OS=$(uname -s)
      VER=$(uname -r)
  fi
  cli_info "Found $OS, version: $VER."

  # launch the appropriate dotfile
  if [[ ${OS} -eq "Ubuntu" ]]; then
    cli_info "Configuring Ubuntu."
    source ${DOT_DIR}/ubuntu-distro/dot_script_ubuntu.sh
  elif [[ ${OS} -eq "Debian" ]]; then
    cli_info "Configuring Debian."
  else
    cli_info "No dotfile present for $OS."
  fi
}

# This function selects which one of the scripts we will use
detect_os() {
  cli_info "Trying to detect OS-type."
  if [[ "${OSTYPE}" == "linux-gnu" ]]; then
    find_linux_distro
  elif [[ "${OSTYPE}" == "dawrin" ]]; then
    cli_info "Detected MacOS."
  elif [[ "${OSTYPE}" == "cygwin" ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
    cli_info "Detected win32/cygwin."
  elif [[ "${OSTYPE}" == "msys" ]]; then
    cli_info "Detected win32/MinGW."
  elif [[ "${OSTYPE}" == "win32" ]]; then
    # I'm not sure this can happen.
    cli_info "Detected win32."
  elif [[ "${OSTYPE}" == "freebsd"* ]]; then
    cli_info "Detected FreeBSD."
  else
    cli_info "Unknown OS type."
  fi
}

# rudimentary sanity check before proceeding
check_params() {
  cli_info "Initialisation details:"
  cli_info "  SSH Details:\n\tmy_id: ${CFG_MY_SSH_PUB}\n\tmy_rsa: ${CFG_MY_SSH_PRI}"
  cli_info "  User details:\n\tuser: ${MY_HOME}\n\thome: ${MY_HOME}\n\temail: ${CFG_EMAIL}"
  cli_info "  Git details:\n\tusername: ${CFG_GIT_USER}\n\temail: ${CFG_GIT_EMAIL}"
  cli_info "  Kitty terminal parameters:\n\tConf file: ${CFG_KITTY_CONF}\n\tTheme: ${CFG_KITTY_THEME}"
  cli_info "  Bash config:\n\t${CFG_BASH_CONF}"

  # check for details
  read -p $(cli_info "Do the details shown above appear OK to you? [y/n]: ") -n 1 -r; #echo ""
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    cli_info "Details seem to be OK, continuing..."
  else
    cli_info "Details are not OK, aborting..."
    exit 1
  fi
}

# check if the path contains a variable
path_merge () {
  if ! echo "${PATH}" | /bin/grep -Eq "(^|:)$1($|:)"; then
    if [[ "${2}" = "after" ]]; then
      PATH="${PATH}:${1}"
    else
      PATH="${1}:${PATH}"
    fi
  fi
}