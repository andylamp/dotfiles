#!/usr/bin/env bash


# Rust install or update if exists
rust_install() {
  # uses nightly channel and `-y` skips prompts for a silent install.
  curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain nightly -y
}