#!/usr/bin/env bash

validate_url() {
  if [ $# -ne 1 ]; then
    echo "Expected 1 arguments, $# were supplied"
    return 0
  fi
  # check for a valid url
  regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  if [[ $1 =~ $regex ]]; then
      echo "The link: $1, seems valid"
      return 0
  else
      echo "The link: $1, seems to be not valid"
      return 1
  fi
}