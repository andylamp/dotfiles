#!/usr/bin/env bash

# Prepare the script configuration
prep_config() {

	# filename that wget will use to name the downloaded file.
	IMP_NAME="important.gpg"

	cli_info "Preparing configuration..."
	# check if the IMP_URL is set, if so try to download
	if [[ -n ${CFG_IMP_URL} ]]; then
		cli_info "Trying to fetch important bits from ${CFG_IMP_URL}..."
		# try to fetch the private bits
		RET_STATUS=$(wget -q "${CFG_IMP_URL}" -O "${CFG_IMP_DIR}/${IMP_NAME}")
		if [[ ${RET_STATUS} -ne 0 ]]; then
			cli_error "wget returned a non-zero code while fetching private file at URL ${CFG_IMP_URL} - cannot continue"
			exit 1
		else
			cli_info "wget fetched file successfully \n\tFrom: ${CFG_IMP_URL}\n\tSaved at: ${CFG_IMP_DIR}/${IMP_NAME}\n"
			# now extract it
			cli_warning "Trying to extract contents -- you will be prompted for your password now."
			# read the actual password from the user.
			echo "Password: "
			if ! read_password GPG_PASSWORD; then
				cli_error "There was an error while getting the password..."
				exit 1
			fi

			# check if something went wrong
			if ! gpg --pinentry-mode loopback --passphrase "${GPG_PASSWORD}" -d "${CFG_IMP_DIR}/${IMP_NAME}" | tar -xj -C "${CFG_IMP_DIR}"; then
				cli_error "Error, non-zero value encountered while decrypting private files (${?}) - cannot continue."
				exit 1
			fi
		fi
	else
		cli_warning "No URL is presently set - ensure required files are present in ${CFG_IMP_DIR}, otherwise script will fail."
	fi

	# check if we have an extra configuration file to use
	if [[ ! -f ${CFG_IMP_CONF} ]]; then
		cli_warning "No extra configuration detected, using defaults"
		# my email
		CFG_EMAIL="andreas.grammenos@gmail.com"

		# git user/email
		CFG_GIT_USER="andylamp"
		CFG_GIT_EMAIL="${CFG_EMAIL}"

		# kitty terminal configuration
		CFG_KITTY_THEME="Afterglow"
		CFG_KITTY_CONF="${DOT_DIR}/shared/my_kitty.conf"

		# my bash configuration location
		CFG_BASH_CONF="${CFG_IMP_DIR}/my_bash.sh"

		# ssh id pub/priv
		CFG_SSH_PUB="${CFG_IMP_DIR}/id_pub"
		CFG_SSH_PRI="${CFG_IMP_DIR}/id_rsa"
	else
		cli_warning "Detected extra configuration file, sourcing it."
		# source the file with the extra bits.

		# report if something went wrong.
		# shellcheck source=/dev/null
		if ! source "${CFG_IMP_CONF}"; then
			cli_error "Error, non-zero value encountered while sourcing private configuration - cannot continue."
			exit 1
		fi
	fi

	# check that we have valid parameters
	if [[ -z ${CFG_GIT_USER} ]] ||
		[[ -z ${CFG_GIT_EMAIL} ]] ||
		[[ -z ${CFG_KITTY_THEME} ]] ||
		[[ -z ${CFG_KITTY_CONF} ]] ||
		[[ -z ${CFG_BASH_CONF} ]] ||
		[[ -z ${CFG_SSH_PUB} ]] ||
		[[ -z ${CFG_SSH_PRI} ]]; then
		cli_error "Error, one of the required parameters is not set."
		exit 1
	fi
	cli_info "Finishing preparing configuration..."
}
