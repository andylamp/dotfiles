#!/usr/bin/env bash

# source necessary files
cli_info "Sourcing common files..."

# prepare configuration
PREP_CONF_SH="prep_config.sh"
source ${DOT_DIR}/shared/${PREP_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${PREP_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${PREP_CONF_SH} OK"
fi

# ufw rules
UFW_RULE_SH="add_ufw_rules.sh"
source ${DOT_DIR}/shared/${UFW_RULE_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${UFW_RULE_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${UFW_RULE_SH} OK"
fi

# url validators
URL_VAL_SH="url_validator.sh"
source ${DOT_DIR}/shared/${URL_VAL_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${URL_VAL_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${URL_VAL_SH} OK"
fi

# git
GIT_CONF_SH="git_config.sh"
source ${DOT_DIR}/shared/${GIT_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${GIT_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${GIT_CONF_SH} OK"
fi

# ssh config
SSH_CONF_SH="ssh_config.sh"
source ${DOT_DIR}/shared/${SSH_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${SSH_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${SSH_CONF_SH} OK"
fi

# vim config
VIM_CONF_SH="vim_config.sh"
source ${DOT_DIR}/shared/${VIM_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${VIM_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${VIM_CONF_SH} OK"
fi

# bash config
BASH_CONF_SH="bash_config.sh"
source ${DOT_DIR}/shared/${BASH_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${BASH_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${BASH_CONF_SH} OK"
fi

# kitty terminal config
KITTY_CONF_SH="kitty_config.sh"
source ${DOT_DIR}/shared/${KITTY_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${KITTY_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${KITTY_CONF_SH} OK"
fi

# rust install
RUST_INSTALL_SH="rust_install.sh"
source ${DOT_DIR}/shared/${RUST_INSTALL_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${RUST_INSTALL_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${RUST_INSTALL_SH} OK"
fi

# rvm install
RVM_INSTALL_SH="rvm_install.sh"
source ${DOT_DIR}/shared/${RVM_INSTALL_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${RVM_INSTALL_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${RVM_INSTALL_SH} OK"
fi

# pipenv3 config
PIPENV3_CONF_SH="pipenv3_config.sh"
source ${DOT_DIR}/shared/${PIPENV3_CONF_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${PIPENV3_CONF_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${PIPENV3_CONF_SH} OK"
fi

# fetch my projects
FETCH_PROJ_SH="fetch_my_projects.sh"
source ${DOT_DIR}/shared/${FETCH_PROJ_SH}

if [[ ${?} -ne 0 ]]; then
  cli_error "Error, non-zero value encountered while parsing ${FETCH_PROJ_SH} - cannot continue."
  exit 1
else
  cli_info "\tParsed ${FETCH_PROJ_SH} OK"
fi

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
  cli_warning "Detected Linux-based OS, trying to find its flavor."
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
    # ${DOT_DIR}/ubuntu-distro/dot_script_ubuntu.sh
  elif [[ ${OS} -eq "Debian" ]]; then
    cli_info "Configuring Debian."
    # source ${DOT_DIR}/debian-distro/dot_script_debian.sh
    ${DOT_DIR}/debian-distro/dot_script_debian.sh
  else
    cli_info "No dotfile present for ${OS}."
  fi
}

# This function selects which one of the scripts we will use
detect_os() {
  cli_info "Trying to detect OS-type."
  if [[ "${OSTYPE}" == "linux-gnu" ]]; then
    # find what type of linux distribution we got.
    find_linux_distro
  elif [[ "${OSTYPE}" == "dawrin" ]]; then
    cli_info "Detected MacOS."
    # run the macos dotfiles.
    source ${DOT_DIR}/macos/dot_script_macos.sh
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
  cli_info "  SSH Details:\n\tmy_id: ${CFG_SSH_PUB}\n\tmy_rsa: ${CFG_SSH_PRI}"
  cli_info "  User details:\n\tuser: ${MY_HOME}\n\thome: ${MY_HOME}\n\temail: ${CFG_EMAIL}"
  cli_info "  Git details:\n\tusername: ${CFG_GIT_USER}\n\temail: ${CFG_GIT_EMAIL}"
  cli_info "  Kitty terminal parameters:\n\tConf file: ${CFG_KITTY_CONF}\n\tTheme: ${CFG_KITTY_THEME}"
  cli_info "  Bash config:\n\t${CFG_BASH_CONF}"

  # check for details
  cli_warning_read "Do the details shown above appear OK to you? [y/n]: "
  read -n 1 -r; echo ""
  # read -p $'\e[1;32mFoobar\e[0m: ' -n 1 -r;
  # check the reply...
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    cli_warning "Details seem to be OK, continuing..."
  else
    cli_error "Details are not OK, aborting..."
    exit 1
  fi
  exit 1
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

cli_info "Finished sourcing common files..."