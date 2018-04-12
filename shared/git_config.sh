#!/usr/bin/env bash


git_config() {
  if [ ! $# -eq 2 ]; then
    echo "Missing arguments, expected two -- skipping git config"
    return 1
  fi
  # git username
  mygituser="$1"
  # my email
  myemail="$2"
  # check if they are empty
  if [ -z $myemail ] || [ -z $mygituser ] ; then
    echo "Empty variables for git user/email -- skipping git config"
    return 1
  fi
  echo "Git Details"
  echo " -- username: $mygituser"
  echo " -- email: $myemail"
  read -p "Do the details shown above appear OK to you? [y/n]: " -n 1 -r; echo ""
  ## Configure git?
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    echo "OK, setting git user.name to: $mygituser and email: $myemail"
    git config --global user.name "$mygituser"
    git config --global user.email "$myemail"
  else
    echo "OK, not configuring git"
  fi
  # return code
  return 0
}

#git_config andylamp an@an.com