#!/usr/bin/env bash

echo setup mingw64 environment

C=`pwd`
#export MSYSTEM=mingw64
#export PATH=$C/msys64/mingw64/bin:$C/msys64/mingw64/lib:$C/msys64/usr/bin

export CFLAGS=-I$C/msys64/mingw64/x86_64-w64-mingw32/include
export LIBS=-L$C/msys64/mingw64/x86_64-w64-mingw32/lib
export PKG_CONFIG_PATH=$C/msys64/mingw64/lib/pkgconfig

echo Building

make

echo "______________libguile/vm-operations.h____________________"
cat libguile/vm-operations.h
echo "______________libguile/modules.h__________________________"
cat libguile/modules.h
echo "__________________________________________________________"
