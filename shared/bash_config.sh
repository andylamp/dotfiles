#!/usr/bin/env bash

MY_TAG_START="### MY BASH CONF START ###"
TAG_CONTENT="# include my personal touches\n\
if [[ -f ${HOME}/.my_shell_conf  ]]; then\n
    . "$HOME/.my_shell_conf"\n\
fi\n"
MY_TAG_END="### MY BASH CONF END ###"
TAG_HELPER="my_bash_tag.sh"

# function for injecting my bash config to the profile
bash_config() {
    # check if we have a bash config file
    #if [[ -z ${my_bash_conf} ]] || [[ ! -f ${my_bash_conf} ]]; then
    #    echo -e " !! Cannot proceed empty bash config or not found... skipping\n"
    #fi
    echo -e " !! Configuring Bash shell"

    # check if my personalisation bits are there
    echo -en ${TAG_CONTENT} > ./${TAG_HELPER}
    if grep -xq "${MY_TAG_START}" ${HOME}/.profile; then #${HOME}/.profile
        echo -e " ** My TAG has been detected in profile - not injecting but updating\n"
        # use sed and a helper tag buffer to do this
        sed -i "/${MY_TAG_START}/,/${MY_TAG_END}/{ /${MY_TAG_START}/{p; r ./${TAG_HELPER}
        }; /${MY_TAG_END}/p; d }" ${HOME}/.profile
        # now remove the tag helper
        rm ./${TAG_HELPER}
    else
        # part for injecting the configuration source bits
        echo -e " ** My TAG has not been detected in profile - injecting\n"
        echo ${MY_TAG_START} >> ${HOME}/.profile
        echo -e "${TAG_CONTENT}" >> ${HOME}/.profile
        echo ${MY_TAG_END} >> ${HOME}/.profile
    fi

    # trying to copy my configuration
    if [[ -f ${my_bash_conf} ]]; then
        echo -e " -- Copying configuration (only if newer)\n"
        rsync -u ${my_bash_conf} ${HOME}/.my_shell_conf
    else
        echo -e " !! Bash config not found, not copying\n"
    fi
    # final send-off
    echo -e " -- Finished configuring Bash shell\n"
}