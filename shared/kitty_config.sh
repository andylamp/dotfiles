#!/usr/bin/env bash

# configure kitty terminal
kitty_config() {
	cli_info "Configuring Kitty Terminal..."

	KITTY_CONF_DIR="${MY_HOME}.config/kitty"

	# check if kitty is installed
	if [[ -z $(type -P "kitty") ]]; then
		cli_error "Error: Kitty executable not found, maybe not installed?"
		return 1
	fi

	# check if kitty was installed correctly
	if [[ ! -d "${KITTY_CONF_DIR}" ]]; then
		cli_warning "Kitty configuration folder not found, creating..."
		# create kitty config directory for installation user
		mkdir -p "${KITTY_CONF_DIR}"
	else
		cli_info "Kitty Terminal configuration found."
	fi

	# now download the terminal themes
	if [[ ! -d "${KITTY_CONF_DIR}/kitty-themes" ]]; then
		cli_info "Downloading Kitty Themes to ${KITTY_CONF_DIR}."
		git clone --depth 1 https://github.com/dexpota/kitty-themes.git "${KITTY_CONF_DIR}/kitty-themes"
	else
		cli_warning "Themes already exist not downloading again."
	fi

	# try to find if the theme is available in our fetched list
	# shellcheck disable=SC2010
	KITTY_THEME_CHECKED=$(ls "${KITTY_CONF_DIR}/kitty-themes/themes" | grep -w "${CFG_KITTY_THEME}.conf")
	# now check if the exact filename has been located
	if [[ -z ${KITTY_THEME_CHECKED} ]]; then
		# it hasn't, skip it
		cli_error "Error: Theme not found -- skipping; please symlink your valid theme to 'theme.conf' in ${KITTY_CONF_DIR}."
	elif [[ -f ${KITTY_CONF_DIR}/theme.conf ]]; then
		cli_info "Theme config file already exists -- skipping."
	else
		# it has, symlink it!
		cli_info "Theme valid: Enabling ${CFG_KITTY_THEME} via symlink"
		ln -s "${KITTY_CONF_DIR}/kitty-themes/themes/${CFG_KITTY_THEME}.conf" "${KITTY_CONF_DIR}/theme.conf"
	fi

	# now, check if kitty config file exists
	if [[ ! -f ${KITTY_CONF_DIR}/kitty.conf ]]; then
		cli_info "Kitty folder exists but has no config - creating..."
		echo -en "# my kitty config start\ninclude ./my_kitty.conf\n# my kitty config end\n" >"${KITTY_CONF_DIR}/kitty.conf"
		cli_info "Copying (my) personal kitty configuration."
	fi

	# set the permissions
	if ! cp "${CFG_KITTY_CONF}" "${KITTY_CONF_DIR}/my_kitty.conf"; then
		cli_error "Failed to copy kitty config to ${KITTY_CONF_DIR}"
		return 1
	fi

	# set the ownership
	if ! chown -R "${MY_USER}" "${KITTY_CONF_DIR}"; then
		cli_error "Failed to set ownership for the kitty config directory at: ${KITTY_CONF_DIR}"
		return 1
	fi

	# set permissions
	if ! chmod 664 "${KITTY_CONF_DIR}/kitty.conf" "${KITTY_CONF_DIR}/my_kitty.conf"; then
		cli_error "Failed to set correct permissions for kitty configs at directory: ${KITTY_CONF_DIR}"
		return 1
	fi
}
