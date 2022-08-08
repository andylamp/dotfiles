#!/usr/bin/env bash

MY_ZSH_TAG_START="### MY ZSH CONF START ###"
ZSH_TAG_CONTENT="# include my personal touches\n\
if [[ -f ${HOME}/.my_zsh_conf  ]]; then\n
    . \"${HOME}/.my_zsh_conf\"\n\
fi\n"
ZSH_MY_TAG_END="### MY ZSH CONF END ###"
ZSH_TAG_HELPER="my_zsh_tag.sh"

# function for injecting my zsh config to the .zshrc
zsh_config() {
	# check if we have a zsh config file
	if [[ -z ${CFG_ZSH_CONF} ]] || [[ ! -f ${CFG_ZSH_CONF} ]]; then
		cli_error "Cannot proceed empty zsh config or not found... skipping."
		return 1
	fi

	cli_info "Configuring ZSH shell..."

	# check if my personalisation bits are there
	echo -en "${ZSH_TAG_CONTENT}" >./${ZSH_TAG_HELPER}
	if grep -xq "${MY_ZSH_TAG_START}" "${HOME}/.zshrc"; then
		cli_warning "My TAG has been detected in zshrc - not injecting but updating."
		# use sed and a helper tag buffer to do this
		sed -i "/${MY_ZSH_TAG_START}/,/${ZSH_MY_TAG_END}/{ /${MY_ZSH_TAG_START}/{p; r ./${ZSH_TAG_HELPER}
    }; /${ZSH_MY_TAG_END}/p; d }" "${HOME}/.zshrc"
		# now remove the tag helper
		rm ./${ZSH_TAG_HELPER}
	else
		# part for injecting the configuration source bits
		cli_info "My TAG has not been detected in zshrc - injecting."
		{
			echo "${MY_ZSH_TAG_START}"
			echo -e "${ZSH_TAG_CONTENT}"
			echo "${ZSH_MY_TAG_END}"
		} >>"${HOME}/.zshrc"
	fi

	# trying to copy my configuration
	if [[ -f ${CFG_ZSH_CONF} ]]; then
		cli_info "Copying configuration (only if newer)."
		rsync -u "${CFG_ZSH_CONF}" "${HOME}/.my_zsh_conf"
	else
		cli_error "zsh config not found, not copying."
	fi

	# final send-off
	cli_info "Finished configuring zsh shell."
}
