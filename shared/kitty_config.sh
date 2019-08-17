#!/usr/bin/env bash

# configure kitty terminal
kitty_config() {
	echo -e "\n -- Configuring Kitty Terminal"

	kitty_conf_dir="${myhome}.config/kitty"

	# check if kitty was installed correctly
	if [[ ! -d ${kitty_conf_dir} ]]; then
		echo -e " ** Error: Kitty configuration folder not found, maybe not installed?"
		return 1
	else
		echo -e " ** Kitty Terminal appears to be installed correctly"
	fi

	# now download the terminal themes
	if [[ ! -d ${kitty_conf_dir}/kitty-themes ]]; then
	    echo -e " -- Downloading Kitty Themes to ${kitty_conf_dir}"
	    git clone --depth 1 https://github.com/dexpota/kitty-themes.git ${kitty_conf_dir}/kitty-themes
	else
	    echo -e " -- Themes already exist not downloading again"
	fi

	# try to find if the theme is available in our fetched list
	kitty_theme_checked=$(ls ${kitty_conf_dir}/kitty-themes/themes | grep -w ${kitty_theme}.conf)
	# now check if the exact filename has been located
	if [[ -z ${kitty_theme_checked} ]]; then
	    # it hasn't, skip it
	    echo -e " !! Theme not found -- skipping; please symlink your valid theme to 'theme.conf' in ${kitty_conf_dir}\n"
	elif [[ -f ${kitty_conf_dir}/theme.conf ]]; then
	    echo -e " !! Theme config file already exists -- skipping"
	else
	    # it has, symlink it!
 	    echo -e " -- Theme valid: Enabling ${kitty_theme} via symlink"
	    ln -s ${kitty_conf_dir}/kitty-themes/themes/${kitty_theme}.conf \
	        ${kitty_conf_dir}/theme.conf
	fi

	# now, check if kitty config file exists
	if [[ ! -f ${kitty_conf_dir}/kitty.conf ]]; then
		echo -e " ** Kitty folder exists but has no config - creating..."
		echo -en    "# my kitty config start\n\
                    \include ./my_kitty.conf\n\
                    # my kitty config end" > ${kitty_conf_dir}/kitty.conf
		echo -e " -- Copying personal kitty configuration"
	fi

	# set the permissions
    cp ${my_kitty_conf} ${kitty_conf_dir}/my_kitty.conf
    # set the permissions & ownership
    chown -R ${myuser} ${kitty_conf_dir}
    chmod 664 ${kitty_conf_dir}/kitty.conf ${kitty_conf_dir}/my_kitty.conf

}