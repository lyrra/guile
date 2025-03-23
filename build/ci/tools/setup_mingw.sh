#!/usr/bin/env bash

choco install -y git.install
choco install -y wget

wget https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.tar.xz || exit 1
tar xvf msys2-base-x86_64-latest.tar.xz || exit 1

pacman -S mingw-w64-x86_64-gcc-libs
