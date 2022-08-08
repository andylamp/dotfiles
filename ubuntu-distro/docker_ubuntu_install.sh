#!/usr/bin/env bash

# function that installs docker and docker compose in ubuntu distributions
docker_ubuntu_install() {
	cli_info "Installing Docker (ubuntu)"

	# check if we are root
	if [[ $(id -u) -eq 0 ]]; then
		cli_error "Error: You cannot run this as root, exiting\n\n"
		exit 1
	else
		cli_info "Running as user $(whoami)"
	fi

	# put ubuntu etc
	REPO_LINK="https://download.docker.com/linux"
	DIST_FLAVOR="ubuntu"
	DIST_VERSION="$(lsb_release -cs)"
	CHANNEL="stable"

	# check if we are going to install (or update) docker-compose
	INSTALL_COMPOSE=true
	# check if we are going to remove the old versions
	WITH_REMOVE=false

	# the docker-compose related stuff
	DOCK_COMP_OUT="/usr/local/bin/docker-compose"
	DOCK_COMP_REPO="https://github.com/docker/compose"
	DOCK_COMP_DOWN_LINK="${DOCK_COMP_REPO}/releases/download"

	# remove old versions, if installed
	if [[ ${WITH_REMOVE} == true ]]; then
		cli_warning "Removing previous versions before installing"
		if ! sudo apt-get remove -y docker docker-engine docker.io containerd runc; then
			cli_error "There was an error removing previous versions - cannot continue"
		fi
	else
		cli_info "Not removing old versions - upgrading only"
	fi

	# update the apt index
	if ! sudo apt-get -qq update &&
		# install the required packages
		sudo apt-get -qq install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common; then
		cli_error "Could not perform the required package removal and updates - cannot continue"
		exit 1
	fi

	# fetch and install the docker GPG key
	cli_info "Fetching the docker key"

	if curl -fsSL ${REPO_LINK}/${DIST_FLAVOR}/gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/docker.gpg; then
		cli_info "Fetched docker key and installed it successfully"
	else
		cli_error "Could not retrieve and install the docker apt-key - cannot continue"
		exit 1
	fi

	# add the official docker repo
	if ! sudo add-apt-repository \
		"deb [arch=amd64] ${REPO_LINK}/${DIST_FLAVOR} \
     ${DIST_VERSION} \
     ${CHANNEL}"; then
		cli_error "Could not add the docker repository - cannot continue"
		exit 1
	else
		cli_info "Successfully added docker repository"
	fi

	# now installing docker
	if ! sudo apt-get -qq update; then
		cli_error "Could not update repositories - cannot continue"
		exit 1
	fi

	if ! sudo apt-get -qq install -y docker-ce docker-ce-cli docker-ce-rootless-extras containerd.io; then
		cli_error "Could not install the required packages - cannot continue"
		exit 1
	else
		cli_info "Install docker components successfully"
	fi

	# check if we have to install docker-compose
	if [[ ${INSTALL_COMPOSE} == true ]]; then
		cli_info "Installing docker-compose as well!"

		# find the latest (released) docker compose version
		DOCK_COMPOSE_VER="$(git ls-remote ${DOCK_COMP_REPO} |
			grep refs/tags |
			grep -oE "[0-9]+\.[0-9][0-9]+\.[0-9]+$" |
			sort --version-sort |
			tail -n 1)"

		cli_info "Discovered docker-compose version: ${DOCK_COMPOSE_VER}"

		# now generate the link
		DOCK_COMPOSE_LINK="${DOCK_COMP_DOWN_LINK}/${DOCK_COMPOSE_VER}/docker-compose-$(uname -s)-$(uname -m)"

		# download it
		if sudo curl -s -L "${DOCK_COMPOSE_LINK}" -o "${DOCK_COMP_OUT}" && sudo chmod +x "${DOCK_COMP_OUT}"; then
			cli_info "Docker compose installed successfully"
		else
			cli_error "There was an error installing docker-compose, cannot continue"
			exit 1
		fi
	else
		cli_warning "Skipping installation of docker-compose"
	fi

	# add the user to the docker group
	if [[ "$(whoami)" != "root" ]]; then
		cli_info "Non root user found $(whoami), adding to docker group"

		# check if we need to add the docker group
		if grep -q docker /etc/group; then
			cli_warning "docker group already exists - not adding again."
		else
			cli_info "docker group does not exist - adding"
			if sudo groupadd docker; then
				cli_info "docker group added successfully"
			else
				cli_error "Could not add docker group - cannot continue"
				exit 1
			fi
		fi

		# add the user to group docker so we can use it without sudo
		if sudo usermod -aG docker "$(whoami)"; then
			cli_info "User permissions to access docker were edited successfully"
		else
			cli_error "There was an error while altering the user permissions for docker - cannot continue"
			exit 1
		fi

		cli_info "Do not forget to restart your login session for the permissions to take effect!"
	fi

	cli_info "Docker (ubuntu) installation finished!"
}
