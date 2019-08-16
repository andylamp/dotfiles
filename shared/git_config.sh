#!/usr/bin/env bash


git_config() {
  echo -e "\n !! Configuring git"
  # check if they are empty
  if [[ -z ${myemail} ]] || [[ -z ${mygituser} ]] ; then
    echo " ** Error: empty variables for git user/email -- skipping git config"
    return 1
  fi
  echo " !! Git Details"
  echo -e "\t-- username: ${mygituser}"
  echo -e "\t-- email: ${myemail}"
  read -p " !! Do the details shown above appear OK to you? [y/n]: " -n 1 -r; #echo ""
  ## Configure git?
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    echo -e "\n -- OK, setting git user.name to: ${mygituser} and email: ${myemail}"
    git config --global user.name "${mygituser}"
    git config --global user.email "${myemail}"
  else
    echo -e "\n ** OK, not configuring git"
  fi
  # return code
  return 0
}