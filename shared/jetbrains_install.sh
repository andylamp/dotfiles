#!/usr/bin/env bash

JB_REL="https://www.jetbrains.com/updates/updates.xml"
JB_TAR="./jb.xml"

# fetch jetbrains
jetbrains_unix_install() {
  echo "Installing Jetbrains to a Unix-based OS"

}

jetbrains_macos_install() {
  echo "Installing Jetbrains to MacOS"
}

fetch_release_xml() {
  # fetch jetbrains xml
  echo "Fetching XML for Jetbrain releases from: $JB_REL into $JB_TAR"
  wget $JB_REL  -O $JB_TAR
  # check if we need to clean it up
  if [[ -f $JB_TAR ]]; then
    rm $JB_TAR
  fi
}