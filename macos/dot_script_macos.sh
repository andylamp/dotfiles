#!/usr/bin/env bash
# shellcheck disable=SC1090

# (My) Dotfiles for MacOS based distros

cli_info "Executing MacOS dotfile."

# install the xcode command line tools
xcode-select --install

# KSH_SHELL=0
# check if we are using ksh
if [[ -n ${KSH_VERSION} ]]; then
	cli_info "Detected ksh version: ${KSH_VERSION}"
	# KSH_SHELL=1
else
	cli_info "Detected non-ksh shell, assuming BASH"
fi

# source common scripts
source "${DOT_DIR}/shared/common.sh"

# source brew install
source "${DOT_DIR}/shared/homebrew_install.sh"

# install homebrew first.
if ! homebrew_install; then
	cli_error "Error, non-zero code encountered while installing homebrew - cannot continue."
fi

# now brew the required packages
brew install gnupg \
	glances \
	ruby \
	cocoapods \
	python3 \
	vim \
	curl \
	tmux \
	maven

# check if something went wrong...
# shellcheck disable=SC2181
if [[ ${?} -ne 0 ]]; then
	cli_error "Failed to brew required packages - cannot continue."
fi

# install sublime

# check if something went wrong...
if ! brew cask install sublime-text; then
	cli_error "Failed to brew sublime-text - cannot continue."
	exit 1
fi

# install fira-code

# check if something went wrong...
if ! brew tap homebrew/cask-fonts && brew cask install font-fira-code; then
	cli_error "Failed to brew fira-code - cannot continue."
	exit 1
fi

cli_info "Execution of MacOS dotfile installation has been completed."
