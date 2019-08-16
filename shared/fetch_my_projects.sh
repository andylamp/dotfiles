#!/usr/bin/env bash

fetch_my_projects() {
  echo " -- Fetching my projects"
  if [[ ! -d ${myhome}/Desktop/mfetch_upstreams ]]; then
    echo " -- fetch upstreams not present, cloning"
    git clone https://github.com/andylamp/mfetch_upstreams ${myhome}/Desktop/mfetch_upstreams
  else
    echo " -- fetch upstream seems present, executing"
  fi
  # now trying to fetch and merge
  bash ${myhome}/Desktop/mfetch_upstreams/fetch_and_merge.sh
}