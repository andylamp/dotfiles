#!/usr/bin/env bash

add_ufw_rules() {
    for r in $(ls ${DOT_DIR}/shared)
    do
        cli_msg "Adding ufw rule: ${r}"
    done
}