#!/usr/bin/env bash

echo Current dir:
pwd

C=`pwd`

export MSYSTEM=mingw64
export PATH=$C/msys64/mingw64/bin:$C/msys64/mingw64/lib:$C/msys64/usr/bin

pacman -v --noconfirm -S base-devel mingw-w64-x86_64-toolchain \
mingw-w64-x86_64-xpm-nox mingw-w64-x86_64-libtiff \
mingw-w64-x86_64-giflib mingw-w64-x86_64-libpng \
mingw-w64-x86_64-libjpeg-turbo mingw-w64-x86_64-librsvg \
mingw-w64-x86_64-libxml2 mingw-w64-x86_64-gnutls
