#!/usr/bin/env bash

# configure git
git_config() {
  cli_info "Configuring git."

  # check if they are empty
  if [[ -z ${CFG_GIT_EMAIL} ]] || [[ -z ${CFG_GIT_USER} ]] ; then
    cli_error "Error: empty variables for git user/email -- skipping git config."
    return 1
  fi

  # check if the details are correct.
  cli_info "Git Details"
  cli_info "\tusername: ${CFG_GIT_USER}"
  cli_info "\temail: ${CFG_GIT_EMAIL}"
  cli_warning "GPG: ${CFG_GPG_SIG}"
  # check if we have GPG signature
  if [[ -n ${CFG_GPG_SIG} ]]; then
    cli_info "\tGPG Sig: ${CFG_GPG_SIG}"
  fi

  # sanity check
  cli_warning_read "Do the details shown above appear OK to you? [y/n]: "
  read -n 1 -r; echo ""

  # Configure git?
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    cli_info "OK, setting git user.name to: ${CFG_GIT_USER} and email: ${CFG_GIT_EMAIL}."
    git config --global user.name "${CFG_GIT_USER}"
    git config --global user.email "${CFG_GIT_EMAIL}"

    # check if we also configure the signature
    if [[ -n ${CFG_GPG_SIG} ]]; then
      cli_info "GPG signing key found, setting to ${CFG_GPG_SIG} (and to sign always with it)"
      git config --global user.signingkey "${CFG_GPG_SIG}"
      git config --global commit.gpgsign true
    fi
  else
    cli_info "OK, not configuring git."
  fi

  # return code
  return 0
}