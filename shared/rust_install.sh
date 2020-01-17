#!/usr/bin/env bash


# Rust install or update if exists
rust_install() {
  echo -e "\n -- Installing rust (nightly) along with rustup\n"
  # check if rust is already installed
  if [[ -x "$(command -v rustup)" ]]; then
    echo " ** rustup appears to be already installed, using that instead"
    rustup update
  else
    # uses nightly channel and `-y` skips prompts for a silent install.
    curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
    # now merge to the path
    # path_merge $HOME/.cargo/bin after

  fi
  echo -e " -- Finished installing rust\n"
}