#!/usr/bin/env bash

# add ufw firewall rules, if present.
add_ufw_rules() {
  RULE_DIR=${DOT_DIR}/shared/ufw-rules
  UFW_APP_DIR="/etc/ufw/applications.d/"
  # check if ufw application directory exists in /etc/
  if [[ -d ${UFW_APP_DIR} ]]; then
    cli_info "ufw dotfile rule directory found at ${UFW_APP_DIR}"
  else
    cli_error "ufw app rule directory could not be found - cannot continue with rule copy."
    return 1
  fi
  # check if the rule directory exists.
  if [[ -d ${RULE_DIR} ]]; then
    cli_info "ufw rule directory found at ${RULE_DIR} - enumerating..."
    # loop through the items in the ufw rules directory
    for r in $(ls ${RULE_DIR})
    do
      # copy each ufw rule to the application.d directory
      cli_info "Copying ufw rule: ${r} - will ask if you want to override"
      if [[ ! -f ${RULE_DIR}/${r} ]]; then

        if ! sudo cp "${RULE_DIR}/${r}" ${UFW_APP_DIR}; then
          cli_warning "There was an error copying ufw rule: ${r} - skipping."
        fi
      else
        cli_warning_read "Rule ${r} already exists, do you want to override it?"
        read -n 1 -r; echo ""
          if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
            cli_warning "\tOK, overriding ${r}..."

            if ! sudo cp "${RULE_DIR}/${r}" ${UFW_APP_DIR}; then
              cli_warning "There was an error copying ufw rule: ${r} - skipping."
            fi
          else
            cli_warning "\tOK, skipping ${r}..."
          fi
      fi
    done
  else
    cli_error "ufw dotfile rule directory seems to be missing (looked at: ${RULE_DIR}) - skipping..."
    return 1
  fi
}