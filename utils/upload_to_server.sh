#!/usr/bin/env bash
# This script for uploading into a server the gpg packed private bits which can then be accessed
# by the dotscripts in other computers :).

# pretty functions for log output
function cli_info { echo -e " -- \033[1;32m$1\033[0m" ; }
function cli_warning { echo -e " ** \033[1;33m$1\033[0m" ; }
function cli_error { echo -e " !! \033[1;31m$1\033[0m" ; }

cli_info "Uploading packed file to server..."

cli_info "Finished uploading packed file to server..."