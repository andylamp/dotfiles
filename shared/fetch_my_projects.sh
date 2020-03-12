#!/usr/bin/env bash

fetch_my_projects() {
  cli_info "Fetching my (GitHub) projects."
  if [[ ! -d ${myhome}/Desktop/mfetch_upstreams ]]; then
    cli_info "Fetch and Merge script not present, cloning..."
    git clone https://github.com/andylamp/mfetch_upstreams ${myhome}/Desktop/mfetch_upstreams
  else
    cli_info "Fetch and Merge script seems present, executing..."
  fi
  # now trying to fetch and merge
  bash ${myhome}/Desktop/mfetch_upstreams/fetch_and_merge.sh
}