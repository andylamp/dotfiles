#!/usr/bin/env bash

# stub to run fetch my projects.
fetch_my_projects() {
	cli_info "Fetching my (GitHub) projects."

	# check if we are in headless mode
	if [[ ${CFG_HEADLESS} = true ]]; then
		cli_info "Detected headless mode."
		FETCH_PATH=${MY_HOME}/repos/mfetch_upstreams
	else
		cli_info "Detected Desktop mode."
		FETCH_PATH=${MY_HOME}/Desktop/mfetch_upstreams
	fi

	# check if my script is already available, if so invoke it.
	if [[ ! -d ${FETCH_PATH} ]]; then
		cli_info "Fetch and Merge script not present, cloning..."
		git clone https://github.com/andylamp/mfetch_upstreams "${FETCH_PATH}"
	else
		cli_info "Fetch and Merge script seems present, executing..."
	fi

	# now trying to fetch and merge
	"${FETCH_PATH}"/fetch_and_merge
}
