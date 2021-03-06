#!/usr/bin/env bash

# validate a given string if it is a URL.
validate_url() {
	# rudimentary input check
	if [[ ${#} -ne 1 ]]; then
		cli_error "Error: validate_url expected 1 argument, ${#} were supplied"
		return 0
	fi

	# check for a valid url
	regex='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
	if [[ ${1} =~ ${regex} ]]; then
		#echo "The link: ${1}, seems valid"
		return 0
	else
		#echo "The link: ${1}, seems to be not valid"
		return 1
	fi
}
