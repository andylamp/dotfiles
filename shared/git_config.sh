#!/usr/bin/env bash


git_config() {
  echo -e " !! Configuring git"
  # if [ ! $# -eq 2 ]; then
  #   echo " ** Error: missing arguments, expected two -- skipping git config"
  #   return 1
  # fi
  # # git username
  # mygitusername="$1"
  # # my email
  # myemail="$2"
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