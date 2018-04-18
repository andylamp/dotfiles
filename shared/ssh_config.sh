#!/usr/bin/env bash

# configure the ssh
ssh_config() {
  echo " !! Configuring SSH"
  # my id pub/priv
  cmyssh="$myhome.ssh"
  # check if we have empty parameters
  if [[ -z $myid ]] || [[ -z $myrsa ]]; then
    echo " ** Error: One the the supplied links is empty, cannot continue"
    return 1
  fi
  # check if we have valid links
  if validate_url $myid && validate_url $myrsa; then
    #echo " ** Links supplied seem valid URLs"
    echo -e "\t -- Home directory to place .ssh: $myhome (final would be: $cmyssh)"
    echo -e "\t -- User is: $myuser"
  else
    echo -e " ** Error: one of the links given is not valid, cannot continue"
    return 1
  fi
  read -p "Do the details shown above appear OK to you? [y/n]: " -n 1 -r; echo ""
  ## Configure ssh?
  if [[ $REPLY =~ ^[yY]$ ]] || [[ -z $REPLY ]]; then
    echo " -- Creating .ssh folder (if needed)"
    # fetch my key
    mkdir -p "$myhome/.ssh"
    # fetch id pub
    echo " -- Fetching candidate id_pub"
    wget -q $myid -O "$myhome/.ssh/id_pub"
    # fetch id rsa
    echo " -- Fetching candidate id_rsa"
    wget -q $myrsa -O "$myhome/.ssh/id_rsa"
    # fix permissions
    echo " -- Configuring permissions (.ssh folder 700, key files id_* 600)"
    chown -R $myuser $myhome/.ssh
    # access permissions for specific files
    chmod -R 700 $cmyssh
    chmod 600 $cmyssh/id_*
    echo -e "\n !! Finished ssh configuration successfully"
  else
    echo "Not configuring"
  fi
}