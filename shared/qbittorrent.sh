#!/usr/bin/env bash

function add_qbittorrent_nox_deb() {

	QBITTORRENT_PPA="ppa:qbittorrent-team/qbittorrent-stable"

	APT_SOURCE="/etc/apt/sources.list"
	APT_SOURCE_D="${APT_SOURCE}.d/"
	NOX_TARGET="/tmp/qbit-nox-temp.cfg"
	# the service location

	# add the repository
	if ! grep -Rq "qbittorrent-team/qbittorrent-stable" "${APT_SOURCE_D}"; then
		cli_warning "qbittorrent repo seems to be missing - adding."

		# check if we had an error
		if ! sudo add-apt-repository -y ${QBITTORRENT_PPA}; then
			cli_error "Could not add qbittorrent repository - cannot continue."
			return 1
		else
			cli_info "added qbitorrent repository successfully."
		fi
	else
		cli_info "qbitorrent repository seems to exist - not adding."
	fi

	# check if we install nox version as well
	if [[ ${CFG_QBITTORRENT_NOX_ONLY} = true ]]; then
		QBITTORRENT_PACKAGES="qbittorrent-nox"
	else
		QBITTORRENT_PACKAGES="qbittorrent"
	fi

	# try to install them
	if ! sudo apt-get -qq install -yy "${QBITTORRENT_PACKAGES}"; then
		cli_error "Error, non-zero code returned while installing qbitorrent - cannot continue."
		return 1
	fi

	if [[ ${CFG_QBITTORRENT_NOX_ONLY} = false ]]; then
		cli_info "qbittorrent installed successfully (nox was not selected)"
		return 0
	elif [[ ${CFG_QBITTORRENT_NOX_ONLY} = true && ${CFG_INSTALL_NOX_SYSTEMD} = false ]]; then
		cli_info "qbitorrent-nox was successfully installed but systemd service install is disabled - skipping..."
		return 0
	fi

	# now install the nox service
	cli_info "qbitorrent-nox systemd service install is enabled - trying to do so..."

	# add the systemd service
	if [[ -f ${CFG_QBITTORRENT_SYSTEMD_SERVICE} ]]; then
		cli_info "qbittorrent service seems to be present at ${CFG_QBITTORRENT_SYSTEMD_SERVICE} - skipping"
	fi

	if ! echo -e "
[Unit]
Description=qBittorrent Command Line Client
After=network.target

[Service]
# This has to be \"forking\" do not change this to \"simple\"
Type=forking
User=${CFG_QBITTORRENT_NOX_USER}
Group=${CFG_QBITTORRENT_NOX_USER}
UMask=007
ExecStart=/usr/bin/qbittorrent-nox -d --webui-port=${CFG_QBITTORRENT_NOX_PORT}
Restart=on-failure

[Install]
WantedBy=multi-user.target
" >${NOX_TARGET}; then
		cli_error "Could not create the temporary configuration file at: ${NOX_TARGET}"
		return 1
	fi

	if ! sudo mv "${NOX_TARGET}" "${CFG_QBITTORRENT_SYSTEMD_SERVICE}"; then
		cli_error "Error, failed to copy the systemd service config for qbittorrent-nox - cannot continue..."
		return 1
	else
		# remove the temporary file
		rm "${NOX_TARGET}"
	fi

	# try to add the user and group
	if ! grep -q "${CFG_QBITTORRENT_NOX_USER}" "/etc/passwd"; then
		cli_info "User seems to not exist - adding (system) user for qbittorrent-nox"
		# add the user for nox
		if ! sudo adduser --system --group "${CFG_QBITTORRENT_NOX_USER}"; then
			cli_error "Failed to add system user: ${CFG_QBITTORRENT_NOX_USER} for daemon - cannot continue..."
			return 1
		fi

		# add the current user to the group for convenience
		cli_info "adding ${MY_USER} to ${CFG_QBITTORRENT_NOX_USER} for convenience"
		if ! sudo adduser "${MY_USER}" "${CFG_QBITTORRENT_NOX_USER}"; then
			cli_error "Failed to add ${MY_USER} to ${CFG_QBITTORRENT_NOX_USER} group - things might not work as expected..."
			return 1
		fi
	else
		cli_warning "User ${CFG_QBITTORRENT_NOX_USER} seems to exist - skipping adding..."
	fi

	# finally, reload the configuration and try to start the service
	if ! sudo systemctl daemon-reload && sudo systemctl start qbittorrent-nox; then
		cli_error "There was an error starting the qbittorrent-nox service..."
		return 1
	else
		cli_info "qbittorrent-nox service has been installed - you can check its status by using: systemctl status qbittorrent-nox"
	fi

	cli_warning "Please restart your machine for qbittorrent-nox daemon changes to take effect!"
}
