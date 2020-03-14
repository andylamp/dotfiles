#!/usr/bin/env bash

add_ufw_rules() {
    RULE_DIR=${DOT_DIR}/shared/ufw-rules
    if [[ -d ${RULE_DIR} ]]; then
      cli_info "ufw rule directory found - enumerating..."
      # loop through the items in the ufw rules directory
      for r in $(ls ${RULE_DIR})
      do
        # copy each ufw rule to the application.d directory
        cli_info "Copying ufw rule: ${r}"
      done
    else
      cli_error "ufw rule directory seems to be missing - skipping..."
    fi
}