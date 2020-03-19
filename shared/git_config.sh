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
  cli_info "\t-- username: ${CFG_GIT_USER}"
  cli_info "\t-- email: ${CFG_GIT_EMAIL}"

  # sanity check
  cli_warning_read "Do the details shown above appear OK to you? [y/n]: "
  read -n 1 -r; echo ""

  # Configure git?
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    cli_info "OK, setting git user.name to: ${CFG_GIT_USER} and email: ${CFG_GIT_EMAIL}."
    git config --global user.name "${CFG_GIT_USER}"
    git config --global user.email "${CFG_GIT_EMAIL}"
  else
    cli_info "OK, not configuring git."
  fi

  # return code
  return 0
}