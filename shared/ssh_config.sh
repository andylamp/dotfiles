#!/usr/bin/env bash

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
  cmyssh="$cmyhome/.ssh"
  # check if we have valid links
  if validate_url $cmyid && validate_url $cmyrsa; then
    #echo " ** Links supplied seem valid URLs"
    echo "Home directory to place .ssh: $cmyhome (final would be: $cmyssh)"
    echo "User is: $cmyuser"
  else
    echo "One of the links given is not valid, cannot continue"
    return 1
  fi
  read -p "Do the details shown above appear OK to you? [y/n]: " -n 1 -r; echo ""
  ## Configure ssh?
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    echo "Creting .ssh folder (if needed)"
    # fetch my key
    mkdir -p "$cmyhome/.ssh"
    # fetch id pub
    echo "Fetching candidate id_pub"
    wget -q $cmyid -O "$cmyhome/.ssh/id_pub"
    # fetch id rsa
    echo "Fetching candidate id_rsa"
    wget -q $cmyrsa -O "$cmyhome/.ssh/id_rsa"
    # fix permissions
    echo "Configuring permissions (.ssh folder 700, key files id_* 600)"
    chown -R $cmyuser $cmyhome/.ssh
    # access permissions for specific files
    chmod -R 700 $cmyssh
    chmod 600 $cmyssh/id_*
    echo -e "\nFinished ssh configuration successfully"
  else
    echo "Not configuring"
  fi
}