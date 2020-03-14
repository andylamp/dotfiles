#!/usr/bin/env bash

# configure the ssh
ssh_config() {
  cli_info "Configuring SSH."
  # my id pub/priv
  MY_SSH_DIR="${MY_HOME}.ssh"
  # check if we have empty parameters
  if [[ -z ${CFG_SSH_PUB} ]] || [[ -z ${CFG_SSH_RSA} ]]; then
    cli_error "Error: One the the supplied files does not exit, cannot continue."
    return 1
  fi

  #echo " ** Links supplied seem valid URLs"
  cli_info "\t -- Home directory to place .ssh: ${MY_HOME} (final would be: ${MY_SSH_DIR})."
  cli_info "\t -- User is: ${MY_USER}."

  read -p $(cli_info "Do the details shown above appear OK to you? [y/n]: ") -n 1 -r; echo ""
  ## Configure ssh?
  if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
    echo " -- Creating .ssh folder (if needed)"
    mkdir -p "${MY_HOME}/.ssh"

    # copy id pub
    cli_info "Copying candidate id_pub"
    cp ${IMP_DIR}/id_pub ${MY_HOME}/.ssh/id_pub

    # copy id rsa
    cli_info "Copying candidate id_rsa"
    cp ${IMP_DIR}/id_rsa ${MY_HOME}/.ssh/id_rsa

    # keep alive
    if [[ ! -f "${MY_HOME}/.ssh/config" ]]; then
      cli_info "ssh config does not exist, pushing keep alive."
      echo -en "Host *\n\tServerAliveInterval 240" > "${MY_HOME}/.ssh/config"
    else
      cli_info "ssh config exists, skipping keep alive!"
    fi

    # fix permissions
    cli_info "Configuring permissions (.ssh folder 700, key files id_* 600)."
    chown -R ${MY_USER} ${MY_HOME}/.ssh
    # access permissions for specific files
    chmod -R 700 ${MY_SSH_DIR}
    chmod 600 ${MY_SSH_DIR}/id_*
    cli_info "Finished ssh configuration successfully."
  else
    cli_info "Details not OK - skipping configuring SSH."
  fi
}