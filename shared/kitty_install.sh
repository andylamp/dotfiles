#!/usr/bin/env bash

# configure kitty terminal
kitty_install() {
	echo -e " -- Installing Kitty Terminal"

	# recent ubuntu distros will have that
	sudo apt-get --assume-yes install kitty

	kitty_conf_dir="${myhome}/.config/kitty"

	# check if kitty was installed correctly
	if [[ ! -d ${kitty_conf_dir} ]]; then
		echo -e " ** Error: Kitty configuration folder not found, maybe not installed?"
		return 1
	else
		echo -e " ** Kitty Terminal appears to be installed correctly"
	fi

	# now download the terminal themes
	echo -e " -- Downloading Kitty Themes to ${kitty_conf_dir}"
	git clone --depth 1 https://github.com/dexpota/kitty-themes.git ${kitty_conf_dir}/kitty-themes

	# enable the theme
	echo -e " -- Enabling ${kitty_theme} via symlink"

	# now, check if kitty config file exists
	if [[ ! -f ${kitty_conf_dir}/kitty.conf ]]; then
		echo -e " ** Kitty folder exists but has no config - creating..."
		echo -en "# my kitty config\ninclude ./my_kitty.conf" > ${kitty_conf_dir}/kitty.conf
		echo -e " -- Copying personal kitty configuration"
		cp ${DOT_DIR}/shared/my_kitty.conf ${kitty_conf_dir}/my_kitty.conf
		# set the permissions & ownership
		chown -R ${myuser} ${kitty_conf_dir}
		chmod 664 ${kitty_conf_dir}/kitty.conf ${kitty_conf_dir}/my_kitty.conf
	fi

}