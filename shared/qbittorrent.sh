#!/usr/bin/env bash

function add_qbittorrent_nox() {

	# the service location

	# add the repository
	if ! sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable; then
		cli_error "Could not add the qbittorrent repository - cannot continue"
		return 1
	fi

	# check if we install nox version as well
	if [[ "${CFG_INSTALL_NOX}" = true ]]; then
		QBITTORRENT_PACKAGES="qbittorrent-nox qbitorrent"
	else
		QBITTORRENT_PACKAGES="qbittorrent"
	fi

	# try to install them
	if ! sudo apt install -yy "${QBITTORRENT_PACKAGES}"; then
		cli_error "Error, non-zero code returned while installing qbitorrent - cannot continue."
		return 1
	fi

	if [[ "${CFG_INSTALL_NOX}" = false ]]; then
		cli_info "qbittorrent installed successfully (nox was not selected)"
		return 0
	elif [[ "${CFG_INSTALL_NOX}" = true && "${CFG_INSTALL_NOX_SYSTEMD}" = false ]]; then
		cli_info "qbitorrent and nox was successfully installed but systemd service install is disabled - skipping..."
		return 0
	fi

	# now install the nox service
	cli_info "qbitorrent-nox systemd service install is enabled - trying to do so..."

	# add the systemd service
	if [[ -f ${CFG_QBITTORRENT_SYSTEMD_SERVICE} ]]; then
		cli_info "qbittorrent service seems to be present - skipping"
	fi

	if echo - e "
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
" | sudo tee "${CFG_QBITTORRENT_SYSTEMD_SERVICE}"; then
		cli_error "Error, failed to output the systemd service for qbittorrent-nox - cannot continue..."
		return 1
	fi

	# add the service
	if ! sudo systemctl start qbittorrent-nox; then
		cli_error "There was an error starting the qbittorrent-nox service..."
		return 1
	else
		cli_info "qbittorrent-nox service has been installed - you can check its status by using: systemctl status qbittorrent-nox"
	fi

	cli_info "adding (system) user for qbittorrent-nox"
	# add the user for nox
	if ! sudo adduser --system --group "${CFG_QBITTORRENT_NOX_USER}"; then
		cli_error "Failed to add system user: ${CFG_QBITTORRENT_NOX_USER} for daemon - cannot continue..."
		return 1
	fi

	if ! sudo adduser "${MY_USER}" "${CFG_QBITTORRENT_NOX_USER}"; then
		cli_error "Failed to add ${MY_USER} to ${CFG_QBITTORRENT_NOX_USER} group - things might not work as expected..."
		return 1
	fi

	cli_warning "Please restart your machine for qbittorrent-nox daemon changes to take effect!"
}
