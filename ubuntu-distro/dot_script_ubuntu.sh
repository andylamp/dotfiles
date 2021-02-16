#!/usr/bin/env bash

# (My) Dotfiles for Ubuntu based distros

# Initialization

cli_info "Executing Ubuntu distro dotfile."

# perform an update, upgrade, auto-remove before install
if sudo apt update && sudo apt -y upgrade && sudo apt -y autoremove; then
	cli_info "Update and upgraded system packages successfully"
else
	cli_error "Error, non-zero code encountered while updating - cannot continue."
	exit 1
fi

# add gpg since we are going to need it.

# check if something went wrong
if sudo apt install -yy gnupg2; then
	cli_info "Installed gpg successfully"
else
	cli_error "Error, non-zero code encountered while installing gnupg - cannot continue."
	exit 1
fi

# ensure that apt can work with https sources
if sudo apt install -yy apt-transport-https; then
	cli_info "Installed apt transport https successfully"
else
	cli_error "Error, non-zero code encountered while installing apt transport https - cannot continue."
	exit 1
fi

# prepare config
prep_config

# rudimentary sanity check
check_params

# Register repos

# register sublime
function add_sublime_repo() {
	if ! wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -; then
		cli_error "Error importing the gpg key for sublime - cannot continue..."
		return 1
	fi

	if ! echo "deb https://download.sublimetext.com/ apt/dev/" | sudo tee /etc/apt/sources.list.d/sublime-text.list; then
		cli_error "Error adding the sublime text apt repository to lists - cannot continue..."
	fi
}

if ! add_sublime_repo; then
	exit 1
fi

# add universe for fira-code
if ! sudo add-apt-repository universe; then
	cli_error "There while adding the universe repository - cannot continue"
	exit 1
fi

# Install (my) packages, but first try to refresh deb repository
if ! sudo apt update; then
	cli_error "Error, non-zero code encountered while updating apt local repository - cannot continue."
	exit 1
fi

# helper function for installing packages
function pkg_install() {
	if ! sudo apt install -yy "${1}"; then
		cli_error "Error, non-zero code encountered while installing package: ${package} - cannot continue."
		return 1
	fi
}

# (my) essential package list
BASE_PACKAGE_LIST=(
	"valgrind"
	"graphviz"
	"vim"
	"curl"
	"git"
	"sublime-text"
	"openjdk-11-jdk"
	"openjdk-11-doc"
	"build-essential"
	"python3"
	"python3-dev"
	"checkinstall"
	"cpu-checker"
	"fonts-firacode"
	"tmux"
	"maven"
	"kitty"
	"openssh-server"
	"openssh-client"
	"glances"
	"htop"
	"python3-pip"
	"nvme-cli"
	"smartmontools"
	"jq"
)

# my extended package list
EXT_PACKAGE_LIST=(
	"lm-sensors"
	"sysstat"
	"doxygen"
	"python3-sphinx"
	"python3-bottle"
)

# install (my) essential packages while checking if packages installed correctly.

cli_info "Installing my essential package list!"
for package in "${BASE_PACKAGE_LIST[@]}"; do
	if ! pkg_install "${package}"; then
		cli_error "Error, non-zero code encountered while installing essential packages - cannot continue."
		exit 1
	fi
done

# install optional packages
if [[ ${CFG_MINIMAL} = false ]]; then
	cli_info "Installing extended package list!"
	for package in "${EXT_PACKAGE_LIST[@]}"; do
		pkg_install "${package}"
	done
fi

# copy ufw rules
copy_ufw_rules

# Configure git
git_config

# Configure vim
vim_config

# Configure bash shell
bash_config

# Configure ssh
ssh_config

# kitty terminal config
kitty_config

# Configure qbittorrent
add_qbittorrent_nox

if [[ ${CFG_MINIMAL} = false ]]; then
	cli_info "Minimal flag is false - installing rust, rvm, and pipenv."
	# Configure rust
	rust_install

	# pipenv3 config
	pipenv3_config

	# rvm and ruby install
	rvm_install
else
	cli_info "Minimal flag is true - skipping rust, rvm, and pipenv installation."
fi

if [[ ${CFG_DOCKER_INSTALL} = true ]]; then
	cli_info "Installing docker and docker-compose"
	# shellcheck source=/dev/null
	if ! source "${DOT_DIR}/ubuntu-distro/docker_ubuntu_install.sh"; then
		cli_error "There was an error sourcing ubuntu docker installation function - skipping"
	fi

	# run docker install
	docker_ubuntu_install
fi

# sourcing profile to update the current window
cli_info "Sourcing updated ${MY_HOME}.profile"

# shellcheck source=/dev/null
if ! source "${MY_HOME}.profile"; then
	cli_error "There was an issue while sourcing updated ~/.profile - things might not work as expected..."
fi

# finally, perform one last auto-remove of any leftover unused packages
sudo apt -y autoremove

cli_info "Execution of Ubuntu dotfile installation has been completed."
