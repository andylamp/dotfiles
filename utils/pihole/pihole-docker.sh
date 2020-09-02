#!/bin/bash

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_info_read { echo -e -n " -- \e[1;32m$1\e[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_warning_read { echo -e -n " ** \e[1;33m$1\e[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

# check if we have access to docker-compose, jq, and curl
if [[ ! -x "$(command -v docker-compose)" ]]; then
  cli_error "docker-compose needs to be installed and accessible - cannot continue."
  exit 1
elif [[ ! -x "$(command -v curl)" ]]; then
  cli_error "curl needs to be installed and accessible - cannot continue."
  exit 1
else
  cli_info "curl and docker-compose appear to be present."
fi

# configure ufw for pihole flag - only configures it if true
UFW_CONF=true
# configure the local subnet
IP_BASE="10.10.1"
UFW_SUBNET="${IP_BASE}.0/24"
# the rule name
UFW_PIHOLE_RULENAME="pihole"

PIHOLE_BASE="/usr/pihole"
PIHOLE_CONF=${PIHOLE_BASE}/etc-pihole
PIHOLE_DNSMASQ_CONF=${PIHOLE_BASE}/etc-dnsmasq.d
PIHOLE_LOG=${PIHOLE_BASE}/pihole.log

PIHOLE_YAML="./pihole.yaml"

# create the volumes based on the user
USER_UID=$(id -u)
USER_NAME=$(whoami)

docker-compose -f ./pi-hole.yaml up -d --build --force-recreate
docker-compose -f ./pi-hole.yaml pull


# create the folders while making the user owner the pihole directory
if ! ret_val=$(sudo mkdir -p {${PIHOLE_CONF},${PIHOLE_DNSMASQ_CONF}} && \
sudo chown -R "${USER_NAME}":"${USER_NAME}" ${PIHOLE_BASE});
then
  cli_error "Could not create pi-hole directories and/or assign permissions - ret val: ${ret_val}."
  exit 1
else
  cli_info "Created required pi-hole directories and assigned permissions for user ${USER_NAME} (id: ${USER_UID})"
fi


##### Create and register ufw rule for pi-hole

setup_ufw() {
  # optionally, we can configure ufw to open grafana to our local network.
  if [[ ${UFW_CONF} = true ]]; then
    cli_info "Configuring ufw firewall is enabled - proceeding"
    # output the rule in the ufw application folder - note if rule already exists, skips creation.
    if [[ -f /etc/ufw/applications.d/${UFW_GRAF_RULENAME} ]]; then
      cli_warning "ufw grafana rule file already exists - skipping."
    else
        if ! echo -e \
"[${UFW_PIHOLE_RULENAME}]
title=pihole
description=Pi Hole firewall rule
ports=53/tcp|53/udp|19080/tcp|19443/tcp
" | sudo tee -a /etc/ufw/applications.d/${UFW_PIHOLE_RULENAME} > /dev/null; then
        cli_error "Failed to output grafana ufw rule successfully - exiting."
        return 1
      else
        cli_info "ufw grafana rule file was created successfully!"
      fi
    fi

    # now configure the ufw rule
    if [[ "$(sudo ufw status)" == "Status: inactive" ]]; then
      cli_warning "ufw is inactive we are not adding the rule in it for now."
    elif ! sudo ufw status verbose | grep -q ${UFW_PIHOLE_RULENAME}; then
      cli_info "ufw rule seems to be missing - trying to add!"
      if ! sudo ufw allow from ${UFW_SUBNET} to any app ${UFW_PIHOLE_RULENAME}; then
        cli_error "Failed to configure ufw rule - exiting!"
        return 1
      else
        cli_info "ufw pi-hole rule was applied successfully!"
      fi
    else
      cli_warning "ufw pi-hole rule seems to be registered already - skipping!"
    fi
  fi
}