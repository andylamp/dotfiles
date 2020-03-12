#!/usr/bin/env bash


git_config() {
  cli_info "Configuring git."
  # check if they are empty
  if [[ -z ${myemail} ]] || [[ -z ${mygituser} ]] ; then
    cli_error "Error: empty variables for git user/email -- skipping git config."
    return 1
  fi
  cli_info "Git Details"
  echo -e "\t-- username: ${mygituser}"
  echo -e "\t-- email: ${myemail}"
  read -p $(cli_info "Do the details shown above appear OK to you? [y/n]: ") -n 1 -r;
  ## Configure git?
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    cli_info "OK, setting git user.name to: ${mygituser} and email: ${myemail}"
    git config --global user.name "${mygituser}"
    git config --global user.email "${myemail}"
  else
    cli_info "OK, not configuring git."
  fi
  # return code
  return 0
}