#!/usr/bin/env bash

C=`pwd`

echo using directory root for msys64 $C/msys64

export CFLAGS=-I$C/msys64/mingw64/x86_64-w64-mingw32/include
export LIBS=-L$C/msys64/mingw64/x86_64-w64-mingw32/lib
export PKG_CONFIG_PATH=$C/msys64/mingw64/lib/pkgconfig

./configure --prefix=$C/mingw64 --host=x86_64-w64-mingw32 \
            --disable-silent-rules --enable-jit=no \
            --enable-guile-debug --enable-mini-gmp --with-bdw-gc=bdw-gc \
            host_alias=x86_64-w64-mingw32 || exit 1
