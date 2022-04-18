#!/usr/bin/env bash

choco install -y git.install
choco install -y wget

wget https://github.com/msys2/msys2-installer/releases/download/nightly-x86_64/msys2-base-x86_64-latest.tar.xz || exit 1
tar xvf msys2-base-x86_64-latest.tar.xz || exit 1

# switch to msys2 shell
./msys64/msys2_shell.cmd

pacman -S base-devel mingw-w64-x86_64-toolchain \
mingw-w64-x86_64-xpm-nox mingw-w64-x86_64-libtiff \
mingw-w64-x86_64-giflib mingw-w64-x86_64-libpng \
mingw-w64-x86_64-libjpeg-turbo mingw-w64-x86_64-librsvg \
mingw-w64-x86_64-libxml2 mingw-w64-x86_64-gnutls
