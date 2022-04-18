#!/usr/bin/env bash

export MSYSTEM=mingw64
export PATH=/mingw64/bin:/mingw64/lib:/usr/local/bin:/usr/bin:/bin

pacman -v --noconfirm -S base-devel mingw-w64-x86_64-toolchain \
mingw-w64-x86_64-xpm-nox mingw-w64-x86_64-libtiff \
mingw-w64-x86_64-giflib mingw-w64-x86_64-libpng \
mingw-w64-x86_64-libjpeg-turbo mingw-w64-x86_64-librsvg \
mingw-w64-x86_64-libxml2 mingw-w64-x86_64-gnutls
