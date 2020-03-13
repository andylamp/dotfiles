#!/usr/bin/env bash

pipenv3_config() {
    cli_info "Installing pipenv for current user ($(whoami))"
    # install pip env for the local user
    pip3 install --user pipenv
    # get the location of the installation
    python_loc=$(python3 -m site --user-base)
}