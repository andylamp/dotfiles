#!/usr/bin/env bash

# add ufw firewall rules, if present.
copy_ufw_rules() {
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
		for r in "${RULE_DIR}"/*; do
			[[ -e "${r}" ]] || break # handle the case of empty directory
			# copy each ufw rule to the application.d directory
			RULE_NAME=$(basename "${r}")
			cli_info "Copying ufw rule: ${RULE_NAME} - will ask if you want to override"
			if [[ ! -f ${UFW_APP_DIR}/${RULE_NAME} ]]; then
				if ! sudo cp "${r}" ${UFW_APP_DIR}; then
					cli_warning "There was an error copying ufw rule: ${r} - skipping."
				fi
			else
				cli_warning_read "Rule ${RULE_NAME} already exists, do you want to override it?"
				read -n 1 -r
				echo ""
				if [[ ${REPLY} =~ ^[yY]$ ]] || [[ -z ${REPLY} ]]; then
					cli_warning "\tOK, overriding ${r}..."

					if ! sudo cp "${r}" ${UFW_APP_DIR}; then
						cli_warning "There was an error copying ufw rule: ${RULE_NAME} - skipping."
					fi
				else
					cli_warning "\tOK, skipping ${RULE_NAME} ufw rule..."
				fi
			fi
		done
	else
		cli_error "ufw dotfile rule directory seems to be missing (looked at: ${RULE_DIR}) - skipping..."
		return 1
	fi
}

# add the ufw rules
add_ufw_rule() {
	if [[ "${#}" -eq 1 ]]; then
		UFW_RULE_LOC="${1}"
		cli_info "Processing ufw rule ${1} allowing for all."
	elif [[ "${#}" -eq 2 ]]; then
		UFW_SUBNET="${2}"
		cli_info "Processing ufw rule ${1} allowing for subnet ${2}"
	else
		cli_error "Error invalid arguments provided\n\tUsage: \n\t add_ufw_rule full_path\n\t add_ufw_rule full_path ufw_subnet"
		return 1
	fi
	UFW_RULE_LOC="${1}"
	UFW_RULE_NAME=$(basename "${UFW_RULE_LOC}")
	cli_info "adding ufw file for ${UFW_RULE_NAME}}"

	# output the rule in the ufw application folder - note if rule already exists, skips creation.
	if [[ ! -f "${UFW_RULE_LOC}" ]]; then
		cli_warning "ufw rule does not exist - skipping."
		return 1
	else
		cli_info "adding ufw file: ${UFW_RULE_NAME}"
	fi

	# now configure the ufw rule
	if [[ "$(sudo ufw status)" == "Status: inactive" ]]; then
		cli_warning "ufw is inactive we are not adding the rule in it for now."
	elif ! sudo ufw status verbose | grep -q "${UFW_RULE_NAME}"; then
		cli_info "ufw rule seems to be missing - trying to add!"
		if [[ "${#}" -eq 1 ]]; then
			if ! sudo ufw allow "${UFW_RULE_NAME}"; then
				cli_error "Failed to configure ufw rule: ${UFW_RULE_NAME}, skipping"
				return 1
			fi
		else
			if ! sudo ufw allow from "${UFW_SUBNET}" to any app "${UFW_RULE_NAME}"; then
				cli_error "Failed to configure ufw rule: ${UFW_RULE_NAME} for subnet: ${UFW_SUBNET}, skipping"
			fi
		fi
		cli_info "ufw rule ${UFW_RULE_NAME} was applied successfully!"
	else
		cli_warning "ufw rule with name ${UFW_RULE_NAME} seems to be registered already - skipping!"
	fi
}
