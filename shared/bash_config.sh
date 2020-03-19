#!/usr/bin/env bash

MY_TAG_START="### MY BASH CONF START ###"
TAG_CONTENT="# include my personal touches\n\
if [[ -f ${HOME}/.my_shell_conf  ]]; then\n
    . "${HOME}/.my_shell_conf"\n\
fi\n"
MY_TAG_END="### MY BASH CONF END ###"
TAG_HELPER="my_bash_tag.sh"

# function for injecting my bash config to the profile
bash_config() {
  # check if we have a bash config file
  if [[ -z ${CFG_BASH_CONF} ]] || [[ ! -f ${CFG_BASH_CONF} ]]; then
    cli_error "Cannot proceed empty bash config or not found... skipping."
    return 1
  fi

  cli_info "Configuring Bash shell..."

  # check if my personalisation bits are there
  echo -en ${TAG_CONTENT}  > ./${TAG_HELPER}
  if grep -xq "${MY_TAG_START}" ${HOME}/.profile; then
    cli_warning "My TAG has been detected in profile - not injecting but updating."
    # use sed and a helper tag buffer to do this
    sed -i "/${MY_TAG_START}/,/${MY_TAG_END}/{ /${MY_TAG_START}/{p; r ./${TAG_HELPER}
    }; /${MY_TAG_END}/p; d }" ${HOME}/.profile
    # now remove the tag helper
    rm ./${TAG_HELPER}
  else
    # part for injecting the configuration source bits
    cli_info "My TAG has not been detected in profile - injecting."
    echo ${MY_TAG_START} >> ${HOME}/.profile
    echo -e "${TAG_CONTENT}" >> ${HOME}/.profile
    echo ${MY_TAG_END} >> ${HOME}/.profile
  fi

  # trying to copy my configuration
  if [[ -f ${CFG_BASH_CONF} ]]; then
    cli_info "Copying configuration (only if newer)."
    rsync -u ${CFG_BASH_CONF} ${HOME}/.my_shell_conf
  else
    cli_error "Bash config not found, not copying."
  fi

  # final send-off
  cli_info "Finished configuring Bash shell."
}