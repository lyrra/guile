#!/usr/bin/env bash

git branch

echo setup mingw64 environment

C=`pwd`
#export MSYSTEM=mingw64
#export PATH=$C/msys64/mingw64/bin:$C/msys64/mingw64/lib:$C/msys64/usr/bin

export CFLAGS=-I$C/msys64/mingw64/x86_64-w64-mingw32/include
export LIBS=-L$C/msys64/mingw64/x86_64-w64-mingw32/lib
export PKG_CONFIG_PATH=$C/msys64/mingw64/lib/pkgconfig

ls -ltr
echo Running autogen.sh
sh autogen.sh || exit 1
ls -ltr
echo Running configure

./configure --prefix=$C/mingw64 --host=x86_64-w64-mingw32 \
            --disable-silent-rules --enable-jit=no \
            --enable-guile-debug --enable-mini-gmp --with-bdw-gc=bdw-gc \
            host_alias=x86_64-w64-mingw32 \
            --no-create --no-recursion || exit 1
make || exit 1
