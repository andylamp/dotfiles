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

PI_HOLE_BASE="/usr/pihole"
PI_HOLE_CONF=${PI_HOLE_BASE}/etc-pihole
PI_HOLE_DNSMASQ_CONF=${PI_HOLE_BASE}/etc-dnsmasq.d
PI_HOLE_RESOLV_CONF=${PI_HOLE_BASE}/etc-resolv.conf
PI_HOLE_LOG=${PI_HOLE_BASE}/pihole.log

# the dns ip array (doesn't have to be ordered!)
declare -a DNS_IP_ARRAY=(
  "127.0.0.1"
  "1.1.1.1"
)

PI_HOLE_DOCKER_PROJ_NAME="pihole-docker"
PI_HOLE_DOCKERFILE="./pihole.yaml"

PI_HOLE_TZ="Europe/Athens"
PI_HOLE_PW="astrongpassword"

# create the volumes based on the user
USER_UID=$(id -u)
USER_NAME=$(whoami)

#### Create the required folders, if not already there.

# create the folders while making the user owner the pihole directory
if ! ret_val=$(sudo mkdir -p {${PI_HOLE_CONF},${PI_HOLE_DNSMASQ_CONF}} && \
sudo chown -R "${USER_NAME}":"${USER_NAME}" ${PI_HOLE_BASE});
then
  cli_error "Could not create pi-hole directories and/or assign permissions - ret val: ${ret_val}."
  exit 1
else
  cli_info "Created required pi-hole directories and assigned permissions for user ${USER_NAME} (id: ${USER_UID})"
fi

##### Crete the pihole yaml file

# nifty little function to print the plug IP's in a tidy way
function print_dns_ip() {
  if [[ ${#} -eq 0 ]]; then
    echo -e "# IP of your DNS entries"
  else
    echo -e "The DNS IP's supplied are the following:"
  fi
  printf '      - %s\n' "${DNS_IP_ARRAY[@]}"
}

cli_info "Creating pi-hole services dockerfile..."

echo -e "
# Generated automatically from pi-hole script
version: \"3.7\"

# More info at https://github.com/pi-hole/docker-pi-hole/ and https://docs.pi-hole.net/
services:
  pihole:
    container_name: pi-hole
    image: pihole/pihole:latest
    ports:
      # dns ports
      - \"53:53/tcp\"
      - \"53:53/udp\"
      # ftl (dhcp) ports
      #- \"67:67/udp\"
      #- \"547:547/udp\"
      # ports for http interface
      - \"19080:80/tcp\"
      - \"19443:443/tcp\"
    environment:
      TZ: ${PI_HOLE_TZ}
      WEBPASSWORD: ${PI_HOLE_PW}
    # Volumes store your data between container upgrades
    volumes:
      - \"${PI_HOLE_CONF}:/etc/pihole\"
      - \"${PI_HOLE_DNSMASQ_CONF}:/etc/dnsmasq.d/\"
      - \"${PI_HOLE_RESOLV_CONF}:/etc/resolv.conf\"
      - \"${PI_HOLE_LOG}:/var/log/pihole.log\"
    dns:
    $(print_dns_ip)
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
" > ${PI_HOLE_DOCKERFILE}

cli_info "Created pi-hole services dockerfile successfully..."

##### Pull images

if ! docker-compose -f ${PI_HOLE_DOCKERFILE} pull; then
  cli_info "Pulled the required docker images successfully"
else
  cli_error "Failed to pull the required docker images - please ensure network connectivity"
  exit 1
fi

#### Create the services

# now execute the docker-compose using our newly created yaml
if ! docker-compose -p ${PI_HOLE_DOCKER_PROJ_NAME} -f ./${PI_HOLE_DOCKERFILE} up -d --force-recreate; then
  cli_error "Could not create pi-hole docker service, exiting."
  exit 1
else
  cli_info "Installed pi-hole docker service successfully."
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