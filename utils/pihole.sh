#!/usr/bin/env bash

# this very much a WIP.

# pretty functions for log output
function cli_info { echo -e "\033[1;32m -- $1\033[0m" ; }
function cli_info_read { echo -e -n "\e[1;32m -- $1\e[0m" ; }
function cli_warning { echo -e "\033[1;33m ** $1\033[0m" ; }
function cli_warning_read { echo -e -n "\e[1;33m ** $1\e[0m" ; }
function cli_error { echo -e "\033[1;31m !! $1\033[0m" ; }

# edit this with your password to use.
PIHOLE_WEBPASSWORD=""
# the timezone.
TIMEZONE="Europe/London"

cat "version: "3"
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "80:80/tcp"
      - "443:443/tcp"
    environment:
      TZ: '${TIMEZONE}'
      WEBPASSWORD: '${PIHOLE_WEBPASSWORD}'
    # Volumes store your data between container upgrades
    volumes:
       - './etc-pihole/:/etc/pihole/'
       - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
    dns:
      - 127.0.0.1
      - 1.1.1.1
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
    cap_add:
      - NET_ADMIN
    restart: unless-stopped" > pihole.yaml

# if using a recent ubuntu-based distribution, run these to remove dnsmasq
sudo systemctl disable systemd-resolved.service
sudo service systemd-resolved stop
sudo systemctl restart network-manager