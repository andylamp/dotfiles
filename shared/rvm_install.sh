#!/usr/bin/env bash

# setup rvm
rvm_install() {
  \curl -s -L https://get.rvm.io | bash -s stable --ruby > /dev/null 2>&1
}