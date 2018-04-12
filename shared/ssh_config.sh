#!/usr/bin/env bash

source ./url_validator.sh

# configure the ssh
ssh_config() {
  if [ $# -ne 2 ]; then
    echo "ssh_config expected 2 parameters, $# were given"
    return 1
  fi
  # my id pub/priv
  cmyid="$1"
  cmyrsa="$2"
  # get my local home
  cmyuser="$(whoami)"
  cmyhome="/home/$cmyuser"
  # check if we have valid links
  if validate_url $cmyid && validate_url $cmyrsa; then
    #echo " ** Links supplied seem valid URLs"
    echo "Home directory to place .ssh: $cmyhome"
    echo "User is: $cmyuser"
  else
    echo "One of the links given is not valid, cannot continue"
    return 1
  fi
  read -p "Do the details shown above appear OK to you? [y/n]: " -n 1 -r; echo ""
  ## Configure ssh?
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    return
    # fetch my key
    mkdir -p "$cmyhome/.ssh"
    # fetch id pub
    wget $cmyid -O "$cmyhome/.ssh/id_pub"
    # fetch id rsa
    wget $cmyrsa -O "$cmyhome/.ssh/id_rsa"
    # fix permissions
    chown -R $cmyuser "$cmyhome/.ssh"
  else
    echo "Not configuring"
  fi
}

#ssh_config $1 $2
