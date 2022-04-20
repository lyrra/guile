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

echo "______________ running guild ____________________"
cd libguile || exit 1
echo "______________ cat guild ____________________"
cat ../meta/guild
echo "_________________________________________________"
export GUILE_AUTO_COMPILE=0
# gdb -batch -ex "run" -ex "bt" 
GUILE_AUTO_COMPILE=0 ../meta/build-env guild snarf-check-and-output-texi
echo "______________ DONE running guild ____________________"

command -v gdb
echo "______________ LS DOT ____________________"
ls -ltr 
echo "______________ LS / ____________________"
ls -ltr /
echo "________________________________________"
#cat libguile/vm-operations.h
#echo "______________libguile/modules.h__________________________"
#cat libguile/modules.h
#echo "______________libguile/cpp-E.h____________________________"
#cat libguile/cpp-E.c
#echo "__________________________________________________________"
