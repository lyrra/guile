#!/usr/bin/env bash

apt_packages_basic=(
  autopoint
  )

apt_packages_standard=(
  curl
  make
  gcc
  wget
  )

apt_packages_runtime=(
  libssl-dev
  )

sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  "${apt_packages_basic[@]}" \
  "${apt_packages_standard[@]}" \
  "${apt_packages_runtime[@]}"


