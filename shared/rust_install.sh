#!/usr/bin/env bash


# Rust install or update if exists
rust_install() {
  echo -e "\n -- Installing rust (nightly) along with rustup\n"
  # check if rust is already installed
  if [[ ! rustup_loc="$(type -p "rustup")" ]] || [[ -z ${rustup_loc} ]]; then
    echo " ** rustup appears to be already installed, using that instead"
    rustup update
  else
    # uses nightly channel and `-y` skips prompts for a silent install.
    curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
  fi
  echo -e " -- Finished installing rust\n"
}