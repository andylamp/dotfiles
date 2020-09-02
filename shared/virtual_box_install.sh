#!/usr/bin/env bash

# use oracle repos
function virtual_box_install() {
  # add the repo
sudo add-apt-repository \
   "deb [arch=amd64] ${REPO_LINK}/${DIST_FLAVOR} \
   ${DIST_VERSION} \
   ${CHANNEL}"
}
