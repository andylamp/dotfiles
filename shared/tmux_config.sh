#!/usr/bin/env bash

# configure my tmux config
tmux_config() {
	cli_info "Configuring tmux Terminal..."

	TMUX_CONF_DIR="${MY_HOME}.tmux"
	TMUX_CONF="${MY_HOME}.tmux.conf"

	# check if tmux is installed
	if [[ -z $(type -P "tmux") ]]; then
		cli_error "Error: tmux executable not found, maybe not installed?"
		return 1
	fi

	# check if tmux conf directories exist installed correctly
	if [[ ! -d "${TMUX_CONF_DIR}" ]]; then
		cli_warning "tmux configuration folder not found, creating..."
		# create kitty config directory for installation user
		mkdir -p "${TMUX_CONF_DIR}"
	else
		cli_info "tmux Terminal configuration found."
	fi

	# now download tpm
	if [[ ! -d "${TMUX_CONF_DIR}/tpm" ]]; then
		cli_info "Downloading tmux tpm to ${TMUX_CONF_DIR}."
		if ! git clone https://github.com/tmux-plugins/tpm "${TMUX_CONF_DIR}/tpm"; then
			cli_error "Failed to clone tmux tpm successfully - ensure you have git installed!"
			return 1
		fi
	else
		cli_warning "tpm directory already exists not downloading again."
	fi

	# copy my tmux conf
	if ! cp "${CFG_KITTY_CONF}" "${TMUX_CONF}"; then
		cli_error "Failed to copy tmux config at ${TMUX_CONF}"
		return 1
	fi

	# set permissions and ownership
	if ! chown -R "${MY_USER}" "${TMUX_CONF_DIR}"; then
		cli_error "Failed to set correct permissions to tmux directory at: ${TMUX_CONF_DIR}"
		return 1
	fi

	# set the conf file access parameters
	if ! chmod 664 "${TMUX_CONF}"; then
		cli_error "Failed to set correct permissions to tmux conf located at: ${TMUX_CONF}"
		return 1
	fi
}
